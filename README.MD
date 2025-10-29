# Diseño de aplicaciones básicas en la nube


## Desarrollo
Antes de nada se va a desarrollar una aplicación gráfica donde se creará,eliminará,buscará y actualizará 
los datos de un cubo.
Una vez explicado esto el diseño de esta aplicación se pensará para su desarrollo en la nube donde se hará una versión acoplada y otra desacoplada.
## Arquitectura Acoplada
Tras decir esto empezamos con la arquitectura acoplada  que es una clase de ordenamiento donde cada componente
individual tiene una alta dependencia directa entre sí.

Esta arquitectura no es muy recomendada por una serie de problemas:
1. Fallo en Cascada: si un componente falla los demás también fallarán
2. Escalibilidad Limitada: Porque implica escalar todo el sistema
3. Dificultad de Mantenimiento: Los cambios o actualizaciones en un componente puede requerir modificaciones o pruebas exahustivas en los 
                                componentes acoplados.

Después de explicar qué es y sus fallas vamos a explicar como se desarrolla.Primero creamos un archivo YAML usando CloudFormation como base
para definir las condiciones,descripciones,versión del formato,mapping,metadatos,saldias,parametros,recursos,reglas y transformaciones.
Empezamos definiendo  los recursos empezando con la ApiGateway que si no sabes es como un portero de discoteca donde controla quien entra y quien no a la fiesta(a la aplicación),además de gestionar la lógica de la API .Este tiene una serie de componentes que necesita que son los siguentes:
1. VPCLink
2. Recursos(Los tipos de url que van a la api y los identificadores de los metodos)
3. Metodos(GET,PUT,POST,DELETE)
4. Recurso para desplegar la aplicación (deployment),la puesta en escena(staging) 
   y la monetización/control de acceso de una API REST en Amazon API Gateway.

Una vez definida al portero definiremos el distribuidor de productos(Load Balancing)
donde controla el trafico a nivel inferior que el ApiGateway y equilibra el trafico.
Para esta practica se ha decidido desarrollar el tipo ALB(Application Load Balancer) 
puesto que es el mejor para aplicaciones web como nuestro caso.Este tiene como 
propiedades nombre,tipo,esquema y subredes al menos 2.Luego También necesita 
una serie de recursos TargetGroup y Listener.

Un listener es un proceso que espera conexiones de los clientes en un puerto y un protocolo específicos donde sus 
parametros son los siguientes DefaultActions el cual define qué hacer con el tráfico que NO coincide con ninguna regla específica del Listener dentro de el esta type que es forward que significa  que el tráfico se reenviará a un Target Group,luego tenemos TargetGroupArn que hacemos referencia al targetGroup creado,al igual que tiene LoadBalancerArn que hacer referencia al load balancer creado ,después especificamos el puerto 8080 por el cual el listener estará escuchando y el protocolo especifica el protocolo de capa de aplicación que el Listener aceptará.

Un targetGroup es el grupo de servidores finales (EC2, Fargate, IPs) a donde se envía el tráfico donde sus propiedades son el nombre por el que se identificara que es cubetargetgroup ,luego el puerto donde estará el grupo de servicios finales que es el 8080,después el protolo por el que se les escuchará.Además especificamos la VPC por la que estará ,el tipo de target que es ip ,por último tenemos HealthCheckProtocol que define el protocolo que el Load Balancer usará para verificar la salud de tus targets que en nuestro caso es HTTP y HealthCheckPath especifica la ruta URL que el Load Balancer consultará para verificar la salud del target la cual es /health.

Después empezamos a definir el grupo de servidores finales que es un ECS de tipo servicio donde especificamos el tipo que es con Type: AWS::ECS::Service y usamos DependsOn para especificar que depende de un Listener que hemos definido anteriormente para el load balancer.Tras decir esto empezamos con las propiedades donde usamos un cluster que definimos nostros  anteriormente  que se define por el tipo AWS::ECS::Cluster y su única propiedad es su nombre que es cubesCluster,luego viene el nombre del ECS que hemos puesto cubesService,después definimos una tarea de definición  que hemos hecho antes y la llamamos TaskDefinition donde especificamos que su tipo es  Type: AWS::ECS::TaskDefinition y tiene una gran serie de propiedades en primer lugar family que se basa en el nombre que definimos a este tipo de tareas,En segundo lugar tenemos NetworkMode que define la red que usará los contenedores en este caso usan awsvpc.En tercer lugar ponemos RequiresCompatibilities especifica el launch type que puede ejecutar esta task que en nuestro caso es un serveless (FARGATE).En cuarto lugar definimos el tamaño de Cpu que es 256 y el tamaño de memoría 512.En quinto lugar especificamos ExecutionRoleArn para definir el rol que ECS usa para llamar a AWS APIs en tu nombre;en sexto lugar,especificamos TaskRoleArn para definir el rol que tus contenedores usan para acceder a servicios AWS.En séptimo lugar definimos el contenedor con Container Definitions donde especificamos un nombre cubesContainer,la imagen  donde estará localizada con Image,el protocolo que acepta que es el TCP para que sea seguro con el parametro Protocol,luego definimos mapeo de puertos con PortMappings especificando que el ContainerPort es el puerto 8080.En octavo lugar definimos la configuración de los logs con LogConfiguration donde especificamos LogDriver que envía logs directamente a CloudWatch Logs,luego Options donde hay una serie de variables que diremos a continuación: awslogs-group: /ecs/cubes  que es grupo de logs en CloudWatch donde se almacenarán,awslogs-region: !Ref AWS::Region especificamos la región  donde se crearán los logs,
awslogs-stream-prefix: cubes donde se define un prefijo para identificar streams individuales por task y awslogs-create-group: "true" para que cree el grupo de logs si no existe.En noveno lugar tenemos Enviorment donde inyecta variables de entorno en tu contenedor como las siguientes :- Name: DB_TYPE especifica el nombre de la variable de tipo de BD y Value: !Ref DBType para ver que BD se usa,- Name: DB_HOST donde se especifica la dirección o endpoint de tu servidor de base de datos y Value: !Ref DBHost donde se almacena la referencia,- Name: DB_NAME especifica el nombre de la BD  y Value: !Ref DBName donde lo almacena,- Name: DB_USER  es el nombre de usuario para autenticarse en la base de datos y donde se referencia Value: !Ref DBUser y ,por último,- Name: DB_PASS que especifica  la contraseña asociada al usuario de la base de datos y el valor donde se refencia Value: !Ref DBPass.

Tras explicar esto seguimos con las propiedades del ECS con DesiredCount que es el número de copias de tu aplicación que quieres ejecutando que en nuestro caso es 1.La siguiente propiedad es LaunchType que especifica el tipo de plataforma en ejecución Fargate,luego comenzamos con otro parametro que es NetworkConfiguration que es la configuración de red y especificamos luego otro parametro dentro de el AWSVPCConfiguration donde añadimos tres parametros más que son los siguientes:AssignPublicIp: ENABLED donde decimos que puede asignar ips publicas,
Subnets: !Ref SubnetIds donde referenciamos a las subnets especificadas como el parametro previamente para que sea minimo dos y ,por último,SecurityGroups: - !Ref ECSSecurityGroup que referenciamos al anterior hecho que tiene las siguientes propiedades  GroupDescription: Security group for ECS tasks descripción del grupo de seguridad,la id de la VPC y el SecurityGroupIngress donde especificamos la ipProtocol donde escogimos tcp por seguridad,Desde el puerto 8080 hacia el puerto 8080 con las variables FromPort y ToPort y por ultimo significa (CidrIp)"Classless Inter-Domain Routing IP" y representa un rango de direcciones IP en formato CIDR que en nuestro caso hemos especificado todas con la dirección 0.0.0.0/0.

Por último en el ECS especificamos el load balancer  especificando el nombre del conetenedor con ContainerName donde pusimos cubesContainer,el puerto por el que escucha el contenedor con el parametro ContainerPort y especificamos el puerto 8080 y el TargetGroup definido antes y explicado antes con la variable TargetGroupArn
y la referencia  !Ref TargetGroup.



## Diagrama Arquitectura Acoplada


## Princing Acoplada

| Resources    |Una hora(60 min)|Un día (24 horas) |Mes de 30 días | Mes de 31 días |Mes de 28 días|Mes de 29 días|Año de 365 días|Año de 366 días|
|--------------|----------------|------------------|---------------|----------------|--------------|--------------|---------------|---------------|
| ELB          |0,255           |6,12              |183,6          |189,72          |171,36        |177,48        |2.233,8        |2.239,92       |
| Rest Api     |0.5993          |14.38             |431.50         |445.89          |402.73        |417.12        |5,249.75       |5,264.14       |
| ECS          |0.01            |0.30              |8.88           |9.18            |8.29          |8.59          |108.19         |108.49         |
| DynamoDB     |0.00            |0.0               |0.0            |0.0             |0.0           |0.0           |0.0            |0.0            |

## Arquitectura Desacoplada


## Diagrama Arquitectura Desacoplada


## Princing Desacoplada

| Resources    |Una hora(60 min)|Un día (24 horas) |Mes de 30 días | Mes de 31 días |Mes de 28 días|Mes de 29 días|Año de 365 días|Año de 366 días|
|--------------|----------------|------------------|---------------|----------------|--------------|--------------|---------------|---------------|
| Rest Api     |0.5993          |14.38             |431.50         |445.89          |402.73        |417.12        |5,249.75       |5,264.14       |
| DynamoDB     |0.00            |0.0               |0.0            |0.0             |0.0           |0.0           |0.0            |0.0            |
| lambdas      |0.00            |0.0               |0.0            |0.0             |0.0           |0.0           |0.0            |0.0            |
