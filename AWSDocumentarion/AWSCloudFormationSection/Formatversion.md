La sección AWSTemplateFormatVersion (opcional) identifica la versión del formato de plantilla a la que se ajusta la plantilla. La última versión del formato de plantilla es la 2010-09-09 y actualmente es el único valor válido.

La versión del formato de plantilla no es la misma que la versión de la API. La versión del formato de plantilla puede cambiar independientemente de las versiones de la API.

El valor de la declaración de la versión del formato de plantilla debe ser una cadena literal. No se puede usar un parámetro ni una función para especificar la versión del formato de plantilla. Si no se especifica un valor, CloudFormation asume la última versión del formato de plantilla. El siguiente fragmento es un ejemplo de una declaración válida de la versión del formato de plantilla:
```
AWSTemplateFormatVersion: 2010-09-09
```