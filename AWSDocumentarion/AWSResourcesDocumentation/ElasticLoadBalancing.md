
AccessLoggingPolicy: Información sobre dónde y cómo se almacenan los registros de acceso para el balanceador de carga.

AppCookieStickinessPolicy: Información sobre una política para la permanencia de sesiones controlada por aplicaciones.
  
AvailabilityZones: Zonas de disponibilidad de un balanceador de carga en una VPC predeterminada. Para un balanceador de carga en una VPC no predeterminada, especifique Subredes.

La actualización requiere reemplazo si no especificó previamente una Zona de disponibilidad o si está eliminando todas las Zonas de disponibilidad. De lo contrario, la actualización no requiere interrupción.

  
ConnectionDrainingPolicy: Si está habilitado, el balanceador de carga permite que las solicitudes existentes se completen antes de desviar el tráfico de una instancia anulada o con problemas de registro.

Para obtener más información, consulte "Configurar el drenaje de conexiones" en la Guía del usuario de balanceadores de carga clásicos.

   
ConnectionSettings: Si está habilitado, el balanceador de carga permite que las conexiones permanezcan inactivas (sin enviar datos a través de ellas) durante el tiempo especificado.

De forma predeterminada, Elastic Load Balancing mantiene un tiempo de espera de conexión inactiva de 60 segundos para las conexiones front-end y back-end del balanceador de carga. Para obtener más información, consulte "Configurar el tiempo de espera de conexión inactiva" en la Guía del usuario de balanceadores de carga clásicos.
  
CrossZone: Si está habilitado, el balanceador de carga enruta el tráfico de solicitudes de forma uniforme entre todas las instancias, independientemente de las zonas de disponibilidad.

Para obtener más información, consulte "Configurar el balanceo de carga entre zonas" en la Guía del usuario de balanceadores de carga clásicos.

HealthCheck: La configuración de la comprobación de estado que se utiliza al evaluar el estado de sus instancias EC2.

La actualización requiere reemplazo si no especificó previamente la configuración de la comprobación de estado o si la está eliminando. De lo contrario, la actualización no requiere interrupción.
  
Instances: Los ID de las instancias para el balanceador de carga.
   
LBCookieStickinessPolicy: Información sobre una política para la permanencia de sesiones en función de la duración.
  
Listeners: Los escuchas del balanceador de carga. Puede especificar un solo escucha por puerto como máximo.

Si actualiza las propiedades de un escucha, AWS CloudFormation lo elimina y crea uno nuevo con las propiedades especificadas. Mientras se crea el nuevo escucha, los clientes no pueden conectarse al balanceador de carga.
 
LoadBalancerName: El nombre del balanceador de carga. Este nombre debe ser único dentro del conjunto de balanceadores de carga de la región.

Si no especifica un nombre, AWS CloudFormation genera un ID físico único para el balanceador de carga. Para obtener más información, consulte Tipo de nombre. Si especifica un nombre, no podrá realizar actualizaciones que requieran la sustitución de este recurso, pero sí podrá realizar otras actualizaciones. Para sustituir el recurso, especifique un nuevo nombre.

Policies: Las políticas definidas para su balanceador de carga clásico. Especifique solo las políticas del servidor backend. 
    
Scheme: El tipo de balanceador de carga. Válido solo para balanceadores de carga en una VPC.

Si Scheme está conectado a internet, el balanceador de carga tiene un nombre DNS público que resuelve a una dirección IP pública.

Si Scheme es interno, el balanceador de carga tiene un nombre DNS público que resuelve a una dirección IP privada.

SecurityGroups:Los grupos de seguridad del balanceador de carga. Válido solo para balanceadores de carga en una VPC.
    
Subnets: Los ID de las subredes del balanceador de carga. Puede especificar como máximo una subred por zona de disponibilidad.

La actualización requiere reemplazo si no especificó una subred previamente o si elimina todas las subredes. De lo contrario, la actualización no requiere interrupción. Para actualizar a una subred diferente en la zona de disponibilidad actual, primero debe actualizar a una subred en una zona de disponibilidad diferente y luego a la nueva subred en la zona de disponibilidad original.
  
Tags: Las etiquetas asociadas con un balanceador de carga.
    
