Propiedades de EC2

AdditionalInfo: Esta propiedad está reservada para uso interno. Si la usa, la pila falla con este error: Conjunto de propiedades incorrecto: [Probando esta propiedad] (Servicio: AmazonEC2; Código de estado: 400; Código de error: InvalidParameterCombination; ID de solicitud: 0XXXXXX-49c7-4b40-8bcc-76885dcXXXXX).

Affinity:Indica si la instancia está asociada a un host dedicado. Si desea que la instancia se reinicie siempre en el mismo host en el que se inició, especifique el host. Si desea que la instancia se reinicie en cualquier host disponible, pero que intente iniciarse en el último host en el que se ejecutó (lo mejor posible), especifique el valor predeterminado.

AvailabilityZone:La zona de disponibilidad de la instancia.
Si no se especifica, se seleccionará automáticamente una zona de disponibilidad según los criterios de equilibrio de carga de la región.No es soportado por DescribeImageAttribute

BlockDeviceMappings:Las entradas de mapeo de dispositivos de bloque definen los dispositivos de bloque que se asociarán a la instancia durante el lanzamiento.
De forma predeterminada, se utilizan los dispositivos de bloque especificados en el mapeo de dispositivos de bloque para la AMI. Puede anular el mapeo de dispositivos de bloque de la AMI mediante el mapeo de dispositivos de bloque de la instancia. Para el volumen raíz, solo puede anular el tamaño, el tipo, la configuración de cifrado y la opción DeleteOnTermination.

Advertencia de esta propiedad
Una vez que la instancia se esté ejecutando, solo se puede modificar el parámetro DeleteOnTermination para los volúmenes conectados sin interrumpir la instancia. Modificar cualquier otro parámetro implica el reemplazo de la instancia.

CpuOptions:Las opciones de CPU para la instancia. Para obtener más información, consulte Optimizar las opciones de CPU en la Guía del usuario de Amazon Elastic Compute Cloud.

CreditSpecification:Opción de crédito para el uso de CPU de la instancia de rendimiento expandible. Los valores válidos son estándar e ilimitado. Para cambiar este atributo después del lanzamiento, utilice ModifyInstanceCreditSpecification. Para obtener más información, consulte "Instancias de rendimiento expandible" en la Guía del usuario de Amazon EC2.

Valor predeterminado: estándar (instancias T2) o ilimitado (instancias T3/T3a/T4g).

Para las instancias T3 con arrendamiento de host, solo se admite el valor estándar.

DisableApiTermination:Indica si la protección de terminación está habilitada para la instancia. El valor predeterminado es "false", lo que significa que puede terminar la instancia mediante la consola de Amazon EC2, las herramientas de línea de comandos o la API. Puede habilitar la protección de terminación al iniciar una instancia, mientras está en ejecución o mientras está detenida.

EbsOptimized:Indica si la instancia está optimizada para E/S de Amazon EBS. Esta optimización proporciona un rendimiento dedicado a Amazon EBS y una pila de configuración optimizada para un rendimiento óptimo de E/S de Amazon EBS. Esta optimización no está disponible para todos los tipos de instancia. Se aplican cargos por uso adicionales al usar una instancia optimizada para EBS.

ElasticGpuSpecifications: Una GPU elástica para asociar con la instancia.
Nota: Ya no existe desde el 8 de enero de 2024

ElasticInferenceAccelerators:Un acelerador de inferencia elástico para asociar con la instancia.
Nota: Amazon Elastic Inference is no longer available.

EnclaveOptions:Indica si la instancia está habilitada para AWS Nitro Enclaves.

HibernationOptions: Indica si una instancia está habilitada para la hibernación. Este parámetro solo es válido si la instancia cumple los requisitos de hibernación. Para obtener más información, consulte "Hibernar su instancia de Amazon EC2" en la Guía del usuario de Amazon EC2.No se puede habilitar la hibernación y los enclaves de AWS Nitro en la misma instancia.

HostId:Si especifica el host para la propiedad Afinidad, el ID de un host dedicado al que está asociada la instancia. Si no especifica un ID, Amazon EC2 lanza la instancia en cualquier host dedicado compatible disponible en su cuenta. Este tipo de lanzamiento se denomina lanzamiento no dirigido. Tenga en cuenta que, para los lanzamientos no dirigidos, debe tener un host dedicado compatible disponible para lanzar las instancias correctamente.

HostResourceGroupArn: El ARN del grupo de recursos del host donde se lanzarán las instancias. Si especifica un ARN del grupo de recursos del host, omita el parámetro Tenancy o configúrelo como host.

IamInstanceProfile: El nombre de un perfil de instancia de IAM. Para crear un nuevo perfil de instancia de IAM, utilice el recurso AWS::IAM::InstanceProfile.

ImageId: El ID de la AMI. Se requiere un ID de AMI para iniciar una instancia y debe especificarse aquí o en una plantilla de inicio.

InstanceInitiatedShutdownBehavior: Indica si una instancia se detiene o finaliza cuando se inicia el apagado desde la instancia (utilizando el comando del sistema operativo para el apagado del sistema).

InstanceType: El tipo de instancia. Para obtener más información, consulte "Tipos de instancia" en la Guía del usuario de Amazon EC2.Al cambiar el tipo de instancia respaldada por EBS, el reinicio o el reemplazo de la instancia dependen de la compatibilidad entre los tipos antiguos y nuevos. Una instancia con un volumen de almacén de instancias como volumen raíz siempre se reemplaza. Para obtener más información, consulte "Cambiar el tipo de instancia" en la Guía del usuario de Amazon EC2.

Ipv6AddressCount:El número de direcciones IPv6 que se asociarán a la interfaz de red principal. Amazon EC2 selecciona las direcciones IPv6 del rango de su subred. No puede especificar esta opción y la opción para asignar direcciones IPv6 específicas en la misma solicitud. Puede especificar esta opción si ha especificado un número mínimo de instancias para lanzar. 

Ipv6Addresses: Las direcciones IPv6 del rango de la subred que se asociarán con la interfaz de red principal. No se puede especificar esta opción y la opción para asignar varias direcciones IPv6 en la misma solicitud. No se puede especificar esta opción si se ha especificado un número mínimo de instancias para iniciar.
           
KernelId: El ID del kernel.
Nota:Recomendamos usar PV-GRUB en lugar de kernels y discos RAM. Para obtener más información, consulte PV-GRUB en la Guía del usuario de Amazon EC2.

KeyName: El nombre del par de claves. Para obtener más información, consulte Crear un par de claves para su instancia de EC2.
Nota:Si no especifica un par de claves, no podrá conectarse a la instancia a menos que elija una AMI configurada para permitir a los usuarios otra forma de iniciar sesión.


LaunchTemplate: La plantilla de lanzamiento. Cualquier parámetro adicional que especifique para la nueva instancia sobrescribirá los parámetros correspondientes incluidos en la plantilla de lanzamiento.

LicenseSpecifications: Las configuraciones de la licencia.
        
MetadataOptions: Las opciones de metadatos para la instancia.
[MetadataOptions](https://docs.aws.amazon.com/AWSCloudFormation/latest/TemplateReference/aws-properties-ec2-instance-metadataoptions.html)


Monitoring: Especifica si la monitorización detallada está habilitada para la instancia. Especifique "true" para habilitarla. De lo contrario, se habilita la monitorización básica. Para obtener más información sobre la monitorización detallada, consulte "Habilitar o desactivar la monitorización detallada para sus instancias" en la Guía del usuario de Amazon EC2.

NetworkInterfaces: Las interfaces de red para asociarse con la instancia.
Nota: Si usa esta propiedad para apuntar a una interfaz de red, debe finalizar la interfaz original antes de conectar una nueva para que la actualización de la instancia se realice correctamente.

PlacementGroupName: El nombre de un grupo de ubicación existente en el que desea iniciar la instancia (clúster | partición | distribución).

PrivateDnsNameOptions: Las opciones para el nombre de host de la instancia.

PrivateIpAddress: La dirección IPv4 principal. Debe especificar un valor del rango de direcciones IPv4 de la subred.

Solo se puede designar una dirección IP privada como principal. No puede especificar esta opción si ya especificó la opción para designar una dirección IP privada como principal en una especificación de interfaz de red. No puede especificar esta opción si está lanzando más de una instancia en la solicitud.

No puede especificar esta opción y la opción de interfaces de red en la misma solicitud.

Si actualiza una instancia que requiere reemplazo, debe asignar una nueva dirección IP privada. Durante un reemplazo, AWS CloudFormation crea una nueva instancia, pero no elimina la instancia anterior hasta que la pila se haya actualizado correctamente. Si la actualización de la pila falla, AWS CloudFormation utiliza la instancia anterior para revertirla a su estado operativo anterior. Las instancias anterior y nueva no pueden tener la misma dirección IP privada.

Obligatorio: No

Tipo: Cadena

La actualización requiere: Reemplazo


PropagateTagsToVolumeOnCreation: Indica si se deben asignar las etiquetas especificadas en la propiedad Tags a los volúmenes especificados en la propiedad BlockDeviceMappings.
Tenga en cuenta que esta función no asigna las etiquetas a los volúmenes creados por separado y luego conectados mediante AWS::EC2::VolumeAttachment.


RamdiskId: El ID del disco RAM que se seleccionará. Algunos kernels requieren controladores adicionales al iniciar. Consulte los requisitos del kernel para saber si necesita especificar un disco RAM. Para consultar los requisitos del kernel, vaya al Centro de recursos de AWS y busque el ID del kernel.
Nota: Recomendamos usar PV-GRUB en lugar de kernels y discos RAM. Para obtener más información, consulte PV-GRUB en la Guía del usuario de Amazon EC2.

SecurityGroupIds: Los ID de los grupos de seguridad. Puede especificar los ID de los grupos de seguridad existentes y las referencias a los recursos creados por la plantilla de pila.
Si especifica una interfaz de red, debe especificar todos los grupos de seguridad que formen parte de ella.

SecurityGroups: [VPC predeterminada] Los nombres de los grupos de seguridad. Para una VPC no predeterminada, debe usar los ID de los grupos de seguridad.
No puede especificar esta opción y la opción de interfaces de red en la misma solicitud. La lista puede contener tanto el nombre de los grupos de seguridad de Amazon EC2 existentes como referencias a los recursos AWS::EC2::SecurityGroup creados en la plantilla.
Predeterminado --> Amazon EC2 usa el grupo de seguridad predeterminado.

SourceDestCheck: Habilite o deshabilite las comprobaciones de origen/destino, que garantizan que la instancia sea el origen o el destino del tráfico que recibe. Si el valor es verdadero, las comprobaciones de origen/destino están habilitadas; de lo contrario, están deshabilitadas. El valor predeterminado es verdadero. Debe deshabilitar las comprobaciones de origen/destino si la instancia ejecuta servicios como traducción de direcciones de red, enrutamiento o firewalls.


SsmAssociations: El documento SSM y los valores de los parámetros de AWS Systems Manager que se asociarán con esta instancia. Para usar esta propiedad, debe especificar un rol de perfil de instancia de IAM para la instancia. Para obtener más información, consulte "Crear un perfil de instancia de IAM para Systems Manager" en la Guía del usuario de AWS Systems Manager.
Nota: Solo puedes asociar un documento a una instancia.

SubnetId: El ID de la subred donde se iniciará la instancia.
Si especifica una interfaz de red, debe especificar cualquier subred como parte de ella en lugar de usar este parámetro.

Tags: Las etiquetas que se agregarán a la instancia. Estas etiquetas no se aplican a los volúmenes EBS, como el volumen raíz, a menos que PropagateTagsToVolumeOnCreation sea verdadero.

Tenancy: La tenencia de la instancia. Una instancia con una tenencia dedicada se ejecuta en hardware de un solo inquilino.


UserData: Los parámetros o scripts que se almacenarán como datos de usuario. Cualquier script en los datos de usuario se ejecuta al iniciar la instancia. Los datos de usuario tienen un límite de 16 KB. Debe proporcionar texto codificado en base64. Para obtener más información, consulte Fn::Base64.
           
Volumes:Los volúmenes que se adjuntarán a la instancia.