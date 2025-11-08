import yaml
from diagrams import Diagram, Cluster
from diagrams.aws.compute import ECS, Fargate
from diagrams.aws.network import APIGateway, ALB, VPC, ELB
from diagrams.aws.database import RDS
# Usar componentes que definitivamente existen
from diagrams.aws.general import User
from diagrams.onprem.network import Internet
import os
import sys
import subprocess

# Contenido YAML por defecto con las claves que el script necesita detectar.
DEFAULT_CFN_CONTENT = """
Resources:
  RestApi:
    Type: AWS::ApiGateway::RestApi
  VPCLink:
    Type: AWS::ApiGateway::VpcLink
  ALB:
    Type: AWS::ElasticLoadBalancingV2::LoadBalancer
  TargetGroup:
    Type: AWS::ElasticLoadBalancingV2::TargetGroup
  ECSSecurityGroup:
    Type: AWS::EC2::SecurityGroup
  ECSCluster:
    Type: AWS::ECS::Cluster
  TaskDefinition:
    Type: AWS::ECS::TaskDefinition
  ECSService:
    Type: AWS::ECS::Service
  DBType:
    Type: AWS::RDS::DBInstance
Parameters:
  DBType:
    Default: Aurora
Metadata:
  Title: Arquitectura_Completa_CFN_Ejemplo
"""


def check_graphviz():
    """Verifica si el ejecutable 'dot' de Graphviz está en el PATH."""
    try:
        subprocess.run(['dot', '-V'], check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        return True
    except (subprocess.CalledProcessError, FileNotFoundError):
        return False

def get_resource_by_type(resources, resource_type):
    """Encuentra el primer recurso del tipo especificado"""
    for name, resource in resources.items():
        if resource.get('Type') == resource_type:
            return name, resource
    return None, None

def generate_cfn_diagram(template_file="template.yaml"):
    cfn_template = None
    
    # Intentar leer el archivo YAML de CloudFormationdot -V
    try:
        with open(template_file, 'r') as f:
            cfn_template = yaml.safe_load(f)
            if not cfn_template or not cfn_template.get('Resources'):
                 print(f"⚠️ Advertencia: El archivo '{template_file}' está vacío o incompleto.")
                 
    except FileNotFoundError:
        print(f"⚠️ Advertencia: No se encontró el archivo '{template_file}'.")
    except Exception as e:
        print(f"Error al leer el YAML: {e}")
    
    # Si no se pudo leer el archivo o estaba vacío/incompleto, usamos el contenido por defecto.
    if not cfn_template or not cfn_template.get('Resources'):
        cfn_template = yaml.safe_load(DEFAULT_CFN_CONTENT)
        print("    Usando contenido de CloudFormation por defecto para el diagrama.")
        
    # Extraer los recursos
    resources = cfn_template.get('Resources', {})

    # Definir el nombre del archivo de salida
    diagram_name = cfn_template.get('Metadata', {}).get('Title', 'AWS_Architecture').replace(' ', '_').replace('"', '')
    output_filename = diagram_name
    
    # Iniciar el Diagrama
    with Diagram(
        name=diagram_name, 
        filename=output_filename,
        show=False, 
        direction="LR",
        graph_attr={"splines": "ortho"}
    ):
        # Diccionario para almacenar las referencias a los objetos 'diagrams'
        nodes = {}

        # Definir el punto de entrada (generalmente un Usuario o Internet)
        # Usamos componentes que definitivamente existen
        Internet = User("Internet\n(Punto de Acceso)")

        # ----------------------------------------------------
        # Agrupar Recursos dentro de un Cluster VPC para claridad
        # ----------------------------------------------------
        with Cluster("VPC - Red Privada"):
            
            # --- API Gateway ---
            api_name, api_resource = get_resource_by_type(resources, "AWS::ApiGateway::RestApi")
            if api_name:
                nodes['RestApi'] = APIGateway(f"API Gateway\n({api_name})")
                Internet >> nodes['RestApi']

            # --- VPC Link --- (Usamos un nodo de red genérico)
            vpclink_name, vpclink_resource = get_resource_by_type(resources, "AWS::ApiGateway::VpcLink")
            if vpclink_name:
                # Usamos ELB como representación para VPC Link
                nodes['VPCLink'] = ELB(f"VPC Link\n({vpclink_name})") 
                if 'RestApi' in nodes:
                    nodes['RestApi'] >> nodes['VPCLink']
            
            # --- Load Balancer (ALB) ---
            alb_name, alb_resource = get_resource_by_type(resources, "AWS::ElasticLoadBalancingV2::LoadBalancer")
            if alb_name:
                nodes['ALB'] = ALB(f"Application Load Balancer\n({alb_name})")
                if 'VPCLink' in nodes:
                    nodes['VPCLink'] >> nodes['ALB']
                elif 'RestApi' in nodes:
                    # Si no hay VPC Link, conectar API Gateway directamente al ALB
                    nodes['RestApi'] >> nodes['ALB']

            # --- Target Group --- (Usamos ELB como representación)
            tg_name, tg_resource = get_resource_by_type(resources, "AWS::ElasticLoadBalancingV2::TargetGroup")
            if tg_name:
                nodes['TargetGroup'] = ELB(f"Target Group\n({tg_name})") 
                if 'ALB' in nodes:
                    nodes['ALB'] >> nodes['TargetGroup']

            # --- Security Groups --- (Usamos un nodo de computo como representación)
            sg_name, sg_resource = get_resource_by_type(resources, "AWS::EC2::SecurityGroup")
            if sg_name:
                # Usamos ECS como representación para Security Group
                nodes['ECSSecurityGroup'] = ECS(f"Security Group\n({sg_name})")

            # --- ECS Cluster y Service (Fargate) ---
            with Cluster("ECS Cluster (Fargate)"):
                # ECS Cluster
                cluster_name, cluster_resource = get_resource_by_type(resources, "AWS::ECS::Cluster")
                if cluster_name:
                    nodes['ECSCluster'] = ECS(f"Cluster\n({cluster_name})") 

                # Task Definition
                task_name, task_resource = get_resource_by_type(resources, "AWS::ECS::TaskDefinition")
                if task_name:
                    nodes['TaskDefinition'] = Fargate(f"Task Definition\n({task_name})")
                
                # ECS Service
                service_name, service_resource = get_resource_by_type(resources, "AWS::ECS::Service")
                if service_name:
                    nodes['ECSService'] = ECS(f"ECS Service\n({service_name})")
                    
                    # Conectar el Target Group al Service
                    if 'TargetGroup' in nodes:
                        nodes['TargetGroup'] >> nodes['ECSService']
                    
                    # El Service utiliza el SG
                    if 'ECSSecurityGroup' in nodes:
                        nodes['ECSService'] - nodes['ECSSecurityGroup'] 

            # --- Base de Datos ---
            rds_name, rds_resource = get_resource_by_type(resources, "AWS::RDS::DBInstance")
            if not rds_name:
                rds_name, rds_resource = get_resource_by_type(resources, "AWS::RDS::DBCluster")
            
            if rds_name:
                db_type = "RDS"
                if rds_resource:
                    db_engine = rds_resource.get('Properties', {}).get('Engine', 'Database')
                    db_type = db_engine if db_engine else "RDS"
                nodes['Database'] = RDS(f"Base de Datos\n({rds_name})\n{db_type}")
            else:
                # Si no hay BD específica, usar parámetro o valor por defecto
                db_type = cfn_template.get('Parameters', {}).get('DBType', {}).get('Default', 'Database')
                nodes['Database'] = RDS(f"Base de Datos\n({db_type})")

            # Conectar el Service (la App) a la BD
            if 'ECSService' in nodes and 'Database' in nodes:
                nodes['ECSService'] >> nodes['Database']
                
        print(f"\n✅ Diagrama '{output_filename}.png' generado exitosamente en el directorio actual.")
        
        # Mostrar recursos detectados
        print("\n🔍 Recursos detectados en el template:")
        for resource_type in [
            "AWS::ApiGateway::RestApi",
            "AWS::ApiGateway::VpcLink", 
            "AWS::ElasticLoadBalancingV2::LoadBalancer",
            "AWS::ElasticLoadBalancingV2::TargetGroup",
            "AWS::EC2::SecurityGroup",
            "AWS::ECS::Cluster",
            "AWS::ECS::TaskDefinition",
            "AWS::ECS::Service",
            "AWS::RDS::DBInstance",
            "AWS::RDS::DBCluster"
        ]:
            name, _ = get_resource_by_type(resources, resource_type)
            if name:
                print(f"   ✅ {resource_type}: {name}")
            else:
                print(f"   ❌ {resource_type}: No encontrado")


# Requisitos y Ejecución
if __name__ == "__main__":
    if not check_graphviz():
        print("🛑 ERROR: Graphviz no está instalado o no se encuentra en el PATH.")
        print("Graphviz es necesario para que 'diagrams' pueda dibujar el gráfico.")
        print("Por favor, instálalo e inténtalo de nuevo.")
        sys.exit(1)
        
    print("Graphviz encontrado. Procediendo a generar el diagrama...")
    generate_cfn_diagram()
    print("¡Proceso completado! Busca el archivo .png generado.")