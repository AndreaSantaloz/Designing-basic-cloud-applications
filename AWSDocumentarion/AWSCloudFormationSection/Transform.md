
La sección opcional "Transform" especifica una o más macros que CloudFormation utiliza para procesar la plantilla.

Las macros pueden realizar tareas sencillas, como buscar y reemplazar texto, o realizar transformaciones más exhaustivas en toda la plantilla. CloudFormation ejecuta las macros en el orden especificado. Al crear un conjunto de cambios, CloudFormation genera un conjunto de cambios que incluye el contenido de la plantilla procesada. A continuación, puede revisar los cambios y ejecutar el conjunto de cambios. Para obtener más información sobre el funcionamiento de las macros, consulte "Realizar procesamiento personalizado en plantillas de CloudFormation con macros de plantilla".

CloudFormation también admite transformaciones, que son macros alojadas por CloudFormation. CloudFormation trata estas transformaciones de la misma manera que cualquier macro que cree en cuanto a orden de ejecución y alcance. Para obtener más información, consulte la referencia de transformaciones.

Para declarar varias macros, utilice un formato de lista y especifique una o más macros.

Por ejemplo, en el ejemplo de plantilla a continuación, CloudFormation evalúa MyMacro y luego AWS::Serverless, los cuales pueden procesar el contenido de toda la plantilla debido a su inclusión en la sección Transformación.
```
# Start of processable content for MyMacro and AWS::Serverless
Transform:
  - MyMacro
  - 'AWS::Serverless'
Resources:
  WaitCondition:
    Type: AWS::CloudFormation::WaitCondition
  MyBucket:
    Type: AWS::S3::Bucket
    Properties: 
      BucketName: amzn-s3-demo-bucket
      Tags: [{"key":"value"}]
      CorsConfiguration: []
  MyEc2Instance:
    Type: AWS::EC2::Instance 
    Properties:
      ImageId: ami-1234567890abcdef0
# End of processable content for MyMacro and AWS::Serverless
```