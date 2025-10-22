AvailabilityZoneRebalancing: Indica si se debe utilizar el reequilibrio de zonas de disponibilidad para el servicio.

Para obtener más información, consulte "Equilibrio de un servicio de Amazon ECS en zonas de disponibilidad" en la Guía para desarrolladores de Amazon Elastic Container Service.

El comportamiento predeterminado de AvailabilityZoneRebalancing difiere entre las solicitudes de creación y actualización:

Para las solicitudes de creación de servicios, si no se especifica ningún valor para AvailabilityZoneRebalancing, Amazon ECS lo establece como HABILITADO de forma predeterminada.

Para las solicitudes de actualización de servicios, si no se especifica ningún valor para AvailabilityZoneRebalancing, Amazon ECS establece el valor de AvailabilityZoneRebalancing del servicio existente de forma predeterminada. Si el servicio nunca tuvo un valor de AvailabilityZoneRebalancing establecido, Amazon ECS lo considera DESHABILITADO.

CapacityProviderStrategy: La estrategia del proveedor de capacidad que se usará para el servicio.

Si se especifica una estrategia de proveedor de capacidad (capacityProviderStrategy), se debe omitir el parámetro launchType. Si no se especifica ninguna estrategia de proveedor de capacidad (capacityProviderStrategy) ni launchType, se utiliza la estrategia de proveedor de capacidad predeterminada (defaultCapacityProviderStrategy) del clúster.
Una estrategia de proveedor de capacidad puede contener un máximo de 20 proveedores de capacidad.
Nota:Para eliminar esta propiedad de su recurso de servicio, especifique una matriz CapacityProviderStrategyItem vacía.



Cluster: El nombre corto o completo del nombre de recurso de Amazon (ARN) del clúster donde se ejecuta el servicio. Si no se especifica un clúster, se asume el predeterminado.


DeploymentConfiguration: Parámetros de implementación opcionales que controlan cuántas tareas se ejecutan durante la implementación y el orden de detención e inicio de las tareas.

DeploymntController: El controlador de implementación que se utilizará para el servicio.

DesiredCount: El número de instancias de la definición de tarea especificada que se colocarán y mantendrán en ejecución en su servicio.

Para servicios nuevos, si no se especifica el número deseado, se utiliza el valor predeterminado 1. Al utilizar la estrategia de programación DAEMON, no se requiere el número deseado.

Para servicios existentes, si no se especifica el número deseado, se omite de la operación.

EnableECSManagedTags: 

Especifica si se activan las etiquetas administradas de Amazon ECS para las tareas del servicio. Para obtener más información, consulte "Etiquetado de recursos de Amazon ECS" en la Guía para desarrolladores de Amazon Elastic Container Service.

Al usar etiquetas administradas de Amazon ECS, debe configurar el parámetro de solicitud propagateTags.

EnableExecuteCommand: Determina si la función de ejecución de comandos está activada para el servicio. Si es "true", la función de ejecución de comandos está activada para todos los contenedores de las tareas que forman parte del servicio.


ForceNewDeployment: Determina si se debe forzar una nueva implementación del servicio. De forma predeterminada, las implementaciones no se fuerzan. Puede usar esta opción para iniciar una nueva implementación sin modificar la definición del servicio. Por ejemplo, puede actualizar las tareas de un servicio para usar una imagen de Docker más reciente con la misma combinación de imagen y etiqueta (my_image:latest) o para implementar las tareas de Fargate en una versión más reciente de la plataforma.

HealthCheckGracePeriodSeconds: El periodo de tiempo, en segundos, que el programador del servicio Amazon ECS ignora las comprobaciones de estado de Elastic Load Balancing, VPC Lattice y del contenedor que no funcionan correctamente tras el inicio de una tarea. Si no se especifica un valor para el periodo de gracia de la comprobación de estado, se utiliza el valor predeterminado 0. Si no se utiliza ninguna comprobación de estado, healthCheckGracePeriodSeconds no se utiliza.

Si el servicio tiene más tareas en ejecución de las deseadas, es posible que las tareas con problemas durante el periodo de gracia se detengan hasta alcanzar el número deseado

LaunchType: El tipo de lanzamiento en el que se ejecutará el servicio. Para obtener más información, consulte "Tipos de lanzamiento de Amazon ECS" en la Guía para desarrolladores de Amazon Elastic Container Service.
Nota: Si desea utilizar instancias administradas, debe utilizar el parámetro de solicitud capacityProviderStrategy

LoadBalancers: Una lista de objetos de balanceador de carga que se asociarán al servicio. Si especifica la propiedad Rol, también debe especificar los balanceadores de carga. Para obtener información sobre la cantidad de balanceadores de carga que puede especificar por servicio, consulte "Balanceo de carga de servicios" en la Guía para desarrolladores de Amazon Elastic Container Service.
Nota: Para eliminar esta propiedad de su recurso de servicio, especifique una matriz LoadBalancer vacía.

NetworkConfiguration: La configuración de red del servicio. Este parámetro es necesario para las definiciones de tareas que utilizan el modo de red awsvpc para recibir su propia interfaz de red elástica y no es compatible con otros modos de red. Para obtener más información, consulte Redes de tareas en la Guía para desarrolladores de Amazon Elastic Container Service.

PlacementConstraints: Una matriz de objetos de restricción de ubicación para las tareas de su servicio. Puede especificar un máximo de 10 restricciones por tarea. Este límite incluye las restricciones de la definición de la tarea y las especificadas en tiempo de ejecución.
Nota:Para eliminar esta propiedad de su recurso de servicio, especifique una matriz PlacementConstraint vacía.


PlacementStrategies: Los objetos de estrategia de colocación que se usarán en las tareas de su servicio. Puede especificar un máximo de 5 reglas de estrategia para cada servicio.
Nota:Para eliminar esta propiedad de su recurso de servicio, especifique una matriz PlacementStrategy vacía.

PlatformVersion: La versión de la plataforma en la que se ejecutan las tareas del servicio. La versión de la plataforma solo se especifica para las tareas que usan el tipo de lanzamiento Fargate. Si no se especifica, se utiliza la versión más reciente. Para obtener más información, consulte las versiones de la plataforma AWS Fargate en la Guía para desarrolladores de Amazon Elastic Container Service.

PropagateTags: Especifica si se propagan las etiquetas desde la definición de la tarea a la tarea. Si no se especifica ningún valor, las etiquetas no se propagan. Las etiquetas solo se pueden propagar a la tarea durante su creación. Para añadir etiquetas a una tarea después de su creación, utilice la acción de la API TagResource.

Debe establecer este valor en un valor distinto de NONE al utilizar Cost Explorer. Para obtener más información, consulte los informes de uso de Amazon ECS en la Guía para desarrolladores de Amazon Elastic Container Service.

El valor predeterminado es NONE.

Role: El nombre o el nombre de recurso de Amazon (ARN) completo del rol de IAM que permite a Amazon ECS realizar llamadas a su balanceador de carga en su nombre. Este parámetro solo se permite si utiliza un balanceador de carga con su servicio y la definición de tarea no utiliza el modo de red awsvpc. Si especifica el parámetro de rol, también debe especificar un objeto de balanceador de carga con el parámetro loadBalancers.
Importante
Nota importante: Si su cuenta ya ha creado el rol vinculado al servicio de Amazon ECS, este se usará para su servicio a menos que especifique un rol aquí. El rol vinculado al servicio es necesario si la definición de tarea utiliza el modo de red awsvpc o si el servicio está configurado para usar la detección de servicios, un controlador de implementación externo, varios grupos de destino o aceleradores de Elastic Inference; en ese caso, no especifique ningún rol aquí. Para obtener más información, consulte "Uso de roles vinculados al servicio para Amazon ECS" en la Guía para desarrolladores de Amazon Elastic Container Service.
Si el rol especificado tiene una ruta distinta a /, debe especificar el ARN completo del rol (recomendado) o añadir la ruta como prefijo al nombre del rol. Por ejemplo, si un rol llamado bar tiene la ruta /foo/, deberá especificar /foo/bar como nombre del rol. Para obtener más información, consulte Nombres descriptivos y rutas en la Guía del usuario de IAM.

SchedulingStrategy: La estrategia de programación que se utilizará para el servicio. Para obtener más información, consulte Servicios.

Hay dos estrategias de programación de servicios disponibles:

RÉPLICA: La estrategia de programación de réplicas asigna y mantiene la cantidad deseada de tareas en el clúster. De forma predeterminada, el programador de servicios distribuye las tareas entre las zonas de disponibilidad. Puede usar estrategias y restricciones de asignación de tareas para personalizar las decisiones de asignación de tareas. Esta estrategia de programación es necesaria si el servicio utiliza los tipos de controlador de implementación CODE_DEPLOY o EXTERNAL.

DAEMON: La estrategia de programación de daemon implementa exactamente una tarea en cada instancia de contenedor activa que cumpla con todas las restricciones de asignación de tareas que especifique en el clúster. El programador de servicios también evalúa las restricciones de asignación de tareas para las tareas en ejecución y detiene las tareas que no las cumplen. Al usar esta estrategia, no es necesario especificar una cantidad deseada de tareas, una estrategia de asignación de tareas ni usar políticas de escalado automático del servicio.
Nota importante: Las tareas que utilizan el tipo de lanzamiento Fargate o los tipos de controlador de implementación CODE_DEPLOY o EXTERNAL no admiten la estrategia de programación DAEMON.

ServiceConnectConfiguration: La configuración para que este servicio detecte y se conecte a servicios, y sea detectado por otros servicios dentro de un espacio de nombres y conectado desde ellos.

Las tareas que se ejecutan en un espacio de nombres pueden usar nombres cortos para conectarse a los servicios del espacio de nombres. Las tareas pueden conectarse a servicios en todos los clústeres del espacio de nombres. Las tareas se conectan a través de un contenedor proxy administrado que recopila registros y métricas para una mayor visibilidad. Solo las tareas creadas por los servicios de Amazon ECS son compatibles con Service Connect. Para obtener más información, consulte Service Connect en la Guía para desarrolladores de Amazon Elastic Container Service.

ServiceName: El nombre de su servicio. Se permiten hasta 255 letras (mayúsculas y minúsculas), números, guiones bajos y guiones. Los nombres de los servicios deben ser únicos dentro de un clúster, pero puede tener servicios con nombres similares en varios clústeres dentro de una región o en varias regiones.

Nota importante: 
La actualización de la pila falla si se modifica alguna propiedad que requiera reemplazo y el ServiceName está configurado. Esto se debe a que AWS CloudFormation crea primero el servicio de reemplazo, pero cada ServiceName debe ser único en el clúster.

ServiceRegistries: Detalles del registro de descubrimiento de servicios que se asociará con este servicio. Para más información, consulte Descubrimiento de servicios.

Nota:Cada servicio puede estar asociado a un registro de servicio. No se admiten varios registros de servicio para cada servicio.

Nota importante:Para eliminar esta propiedad de su recurso de servicio, especifique una matriz ServiceRegistry vacía.


Tags: Los metadatos que aplica al servicio para ayudarle a categorizarlo y organizarlo. Cada etiqueta consta de una clave y un valor opcional, ambos definidos por usted. Al eliminar un servicio, también se eliminan las etiquetas.

Las etiquetas se rigen por las siguientes restricciones básicas:

Número máximo de etiquetas por recurso: 50

Para cada recurso, cada clave de etiqueta debe ser única y cada clave de etiqueta solo puede tener un valor.

Longitud máxima de clave: 128 caracteres Unicode en UTF-8

Longitud máxima de valor: 256 caracteres Unicode en UTF-8

Si su esquema de etiquetado se utiliza en varios servicios y recursos, recuerde que otros servicios pueden tener restricciones sobre los caracteres permitidos. Generalmente, los caracteres permitidos son: letras, números y espacios representables en UTF-8, y los siguientes caracteres: + - = . _ : / @.

Las claves y los valores de las etiquetas distinguen entre mayúsculas y minúsculas.

No utilice aws:, AWS: ni ninguna combinación de mayúsculas o minúsculas, como prefijos, para claves o valores, ya que está reservado para AWS. No puede editar ni eliminar claves o valores de etiqueta con este prefijo. Las etiquetas con este prefijo no se contabilizan para el límite de etiquetas por recurso.

TaskDefinition: La familia y la revisión (familia:revisión) o el ARN completo de la definición de tarea que se ejecutará en el servicio. Si no se especifica una revisión, se utiliza la última revisión activa.

Se debe especificar una definición de tarea si el servicio utiliza los controladores de implementación ECS o CODE_DEPLOY.

Para obtener más información sobre los tipos de implementación, consulte Tipos de implementación de Amazon ECS.

VolumeConfigurations: La configuración de un volumen especificado en la definición de la tarea como un volumen configurado al iniciarse. Actualmente, el único tipo de volumen compatible es Amazon EBS.

Nota importante:Para eliminar esta propiedad de su recurso de servicio, especifique una matriz ServiceVolumeConfiguration vacía.

VpcLatticeConfigurations: La configuración de VPC Lattice para el servicio que se está creando.