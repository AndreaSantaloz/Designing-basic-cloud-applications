Type: AWS::ECR::Repository
Properties:
  EmptyOnDelete: Si es verdadero, al eliminar el repositorio se elimina forzosamente su contenido. Si es falso, el repositorio debe estar vacío antes de intentar eliminarlo.

  EncryptionConfiguration: La configuración de cifrado del repositorio. Esta determina cómo se cifra el contenido del repositorio en reposo.
    
  ImageScanningConfiguration: El parámetro imageScanningConfiguration se está descontinuando y ahora se especifica la configuración de escaneo de imágenes a nivel de registro. Para obtener más información, consulte PutRegistryScanningConfiguration.
  Nota: El parámetro imageScanningConfiguration se está descontinuando y ahora se especifica la configuración de escaneo de imágenes a nivel de registro. Para obtener más información, consulte PutRegistryScanningConfiguration.

  ImageTagMutability: La configuración de mutabilidad de etiquetas del repositorio. Si se omite este parámetro, se utilizará la configuración predeterminada MUTABLE, que permite sobrescribir las etiquetas de imagen. Si se especifica IMMUTABLE, todas las etiquetas de imagen del repositorio serán inmutables, lo que evitará que se sobrescriban.

  ImageTagMutabilityExclusionFilters: Una lista de filtros que especifican qué etiquetas de imagen están excluidas de la configuración de mutabilidad de etiquetas de imagen del repositorio.

  LifecyclePolicy: Crea o actualiza una política de ciclo de vida. Para obtener información sobre la sintaxis de la política de ciclo de vida, consulte Plantilla de política de ciclo de vida.

  RepositoryName: El nombre que se usará para el repositorio. El nombre del repositorio puede especificarse solo (como nginx-web-app) o puede anteponerse con un espacio de nombres para agruparlo en una categoría (como proyecto-a/nginx-web-app). Si no se especifica un nombre, AWS CloudFormation genera un ID físico único y lo utiliza para el nombre del repositorio. Para obtener más información, consulte Tipo de nombre.
  
  Nota:El nombre que se usará para el repositorio. El nombre del repositorio puede especificarse solo (como nginx-web-app) o puede anteponerse con un espacio de nombres para agruparlo en una categoría (como proyecto-a/nginx-web-app). Si no se especifica un nombre, AWS CloudFormation genera un ID físico único y lo utiliza para el nombre del repositorio. Para obtener más información, consulte Tipo de nombre.


  RepositoryPolicyText: El texto de la política del repositorio JSON que se aplicará al repositorio. Para obtener más información, consulte las políticas del repositorio de Amazon ECR en la Guía del usuario de Amazon Elastic Container Registry.

  Tags: Una matriz de pares clave-valor para aplicar a este recurso.