

# Amazon web Fargate
La tecnología AWS Fargate se puede utilizar en Amazon ECS para ejecutar contenedores
sin tener que administrar servidores ni clústeres de instancias de Amazon EC2. Con AWS Fargate ya no tendrá que aprovisionar, configurar ni escalar clústeres de máquinas virtuales para ejecutar los contenedores. De esta manera, se elimina la necesidad de elegir tipos de servidores, decidir cuándo escalar los clústeres u optimizar conjuntos de clústeres.

Al ejecutar las tareas y servicios con el tipo de lanzamiento de Fargate, la aplicación se empaqueta en contenedores, se especifican los requisitos de CPU y de memoria, se definen las políticas de IAM y de redes y se lanza la aplicación. Cada tarea de Fargate tiene su propio límite de aislamiento y no comparte el kernel subyacente, los recursos de CPU, los recursos de memoria ni la interfaz de red elástica con otra tarea. Usted configura las definiciones de tareas para Fargate estableciendo el parámetro de definición de tareas requiresCompatibilities en FARGATE. Para obtener más información, consulte Tipos de lanzamiento.

Fargate ofrece versiones de la plataforma para Amazon Linux 2 (versión de la plataforma 1.3.0), el sistema operativo Bottlerocket (versión de la plataforma 1.4.0) y las ediciones Full y Core de Microsoft Windows Server 2019. A menos que se especifique lo contrario, la información de esta página se aplica a todas las plataformas Fargate.

En este tema, se describen los diferentes componentes de las tareas y los servicios de Fargate, y se mencionan consideraciones especiales para el uso de Fargate con Amazon ECS.

## Definiciones de tareas
Las tareas que utilizan el tipo de lanzamiento Fargate no admiten todos los parámetros de definición de tareas de Amazon ECS que están disponibles. Algunos parámetros directamente no son compatibles, y otros se comportan de forma distinta para tareas de Fargate. Para obtener más información, consulte Memoria y CPU de tarea.

## Elastic Load Balancer (Equilibrio de carga)
El servicio Amazon ECS en AWS Fargate se puede configurar opcionalmente para que utilice Elastic Load Balancing a fin de distribuir el tráfico de manera uniforme entre las tareas del servicio.

Los servicios de Amazon ECS alojados en AWS Fargate admiten los tipos de equilibrador de carga Equilibrador de carga de aplicación, Equilibrador de carga de red y Equilibrador de carga de puerta de enlace. Los Application Load Balancers se utilizan para dirigir el tráfico HTTP/HTTPS (o de capa 7). Los Network Load Balancers se utilizan para dirigir el tráfico TCP o UDP (o de capa 4). Para obtener más información, consulte Uso del equilibrador de carga para distribuir el tráfico de servicio de Amazon ECS.

Al crear un grupo de destino para estos servicios, se debe elegir ip como tipo de destino, no instance. Esto se debe a que las tareas que utilizan el modo de red awsvpc están asociadas a una interfaz de red elástica, no a una instancia de Amazon EC2. Para obtener más información, consulte Uso del equilibrador de carga para distribuir el tráfico de servicio de Amazon ECS.

El uso de un equilibrador de carga de red para direccionar el tráfico UDP a las tareas de Amazon ECS en AWS Fargate solo es compatible cuando se utiliza la versión 1.4 o posterior de la plataforma.

## Metricas en Uso
Puede utilizar las métricas de uso de CloudWatch para proporcionar visibilidad sobre el uso de los recursos de su cuenta. Utilice estas métricas para visualizar el uso actual del servicio en paneles y gráficos de CloudWatch.

Las métricas de uso de AWS Fargate se corresponden con las cuotas de servicio de AWS. Puede configurar alarmas que le avisen cuando su uso se acerque a una Service Quota. Para obtener más información acerca de las Service Quotas de AWS Fargate, consulte Puntos de conexión y cuotas de Amazon ECS en la Referencia general de Amazon Web Services.

Para obtener más información sobre las métricas de uso de AWS Fargate, consulte Métricas de uso de AWS Fargate.

["necesario para la app"]("https://docs.aws.amazon.com/AmazonECS/latest/developerguide/getting-started-managed-instances.html")
## Necesario
1. Crear tareas
2. Crear clusters
3. API GATEWAY
    4.1 VPC
    4.2 Subents
    4.3 grupos de seguridad
4. Configure la configuración de instancias gestionadas:
    1. Para el rol de infraestructura, seleccione el rol de IAM que creó para la administración de  infraestructura de instancias gestionadas.
    2. Para el perfil de instancia, seleccione el ecsInstanceRoleTú has creado.
    3. Para atributos de instancia, seleccione Usar ECS Por defecto.


## Tareas
Una definición de tarea es un plan para su aplicación. Cada vez que inicie una tarea en Amazon ECS, especifique una definición de tarea. El servicio entonces sabe qué imagen de Docker usar para los contenedores, cuántos contenedores usar en la tarea y la asignación de recursos para cada contenedor. Siga estos pasos para crear una definición de tarea


