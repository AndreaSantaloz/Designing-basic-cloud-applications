
Tenemos los siguientes secciones del fichero
Primero empezamos con Resources
La sección Resources es obligatoria en el nivel superior de una plantilla de CloudFormation.
Declara los recursos de AWS que desea que  CloudFormation aprovisione y configure como parte 
de su pila.Así se vería en YAML
```
Resources:
  LogicalResourceName1:
    Type: AWS::ServiceName::ResourceType
    Properties:
      PropertyName1: PropertyValue1
      ...

  LogicalResourceName2:
    Type: AWS::ServiceName::ResourceType
    Properties:
      PropertyName1: PropertyValue1
      ...

```
## ID lógico (también llamado nombre lógico)

En una plantilla de CloudFormation, los recursos se identifican por sus nombres lógicos. Estos nombres deben ser alfanuméricos (A-Za-z0-9) y únicos dentro de la plantilla. Los nombres lógicos se utilizan para hacer referencia a recursos de otras secciones de la plantilla.

## Tipo de recurso

Cada recurso debe tener un atributo Type, que define el tipo de recurso de AWS. El atributo Type tiene el formato AWS::ServiceName::ResourceType. Por ejemplo, el atributo Type para un bucket de Amazon S3 es AWS::S3::Bucket.

Para obtener la lista completa de tipos de recursos compatibles, consulte la referencia de tipos de recursos y propiedades de AWS.

## Propiedades de recurso

Las propiedades de recurso son opciones adicionales que puede especificar para definir los detalles de configuración del tipo de recurso específico. Algunas propiedades son obligatorias, mientras que otras son opcionales. Algunas propiedades tienen valores predeterminados, por lo que especificarlas es opcional.

Para obtener más información sobre las propiedades compatibles con cada tipo de recurso, consulte los temas de la referencia de tipos de recursos y propiedades de AWS.
```
Properties:
  String: A string value 
  Number: 123
  LiteralList:
    - first-value
    - second-value
  Boolean: true

```
## ID físico

Además del ID lógico, algunos recursos también tienen un ID físico, que es el nombre asignado, como el ID de una instancia de EC2 o el nombre de un bucket de S3. Utilice los ID físicos para identificar recursos fuera de las plantillas de CloudFormation, pero solo después de su creación. Por ejemplo, supongamos que asigna a una instancia de EC2 el ID lógico MyEC2Instance. Cuando CloudFormation crea la instancia, genera y asigna automáticamente un ID físico (como i-1234567890abcdef0). Puede usar este ID físico para identificar la instancia y ver sus propiedades (como el nombre DNS) mediante la consola de Amazon EC2.

Para los buckets de Amazon S3 y muchos otros recursos, CloudFormation genera automáticamente un nombre físico único si no lo especifica explícitamente. Este nombre físico se basa en una combinación del nombre de la pila de CloudFormation, el nombre lógico del recurso especificado en la plantilla de CloudFormation y un ID único. Por ejemplo, si tiene un bucket de Amazon S3 con el nombre lógico MyBucket en una pila llamada MyStack, CloudFormation podría asignarle el siguiente nombre físico: MyStack-MyBucket-abcdefghijk1.

Para los recursos que admiten nombres personalizados, puede asignar sus propios nombres físicos para identificarlos rápidamente. Por ejemplo, puede asignarle a un bucket de S3 que almacena registros el nombre MyPerformanceLogs. Para obtener más información, consulte Tipo de nombre.

## Referencia a recursos

Con frecuencia, es necesario establecer propiedades en un recurso basándose en el nombre o la propiedad de otro. Por ejemplo, se puede crear una instancia de EC2 que utilice grupos de seguridad de EC2 o una distribución de CloudFront respaldada por un bucket de S3. Todos estos recursos se pueden crear en la misma plantilla de CloudFormation.

CloudFormation proporciona funciones intrínsecas que se pueden usar para hacer referencia a otros recursos y sus propiedades. Estas funciones permiten crear dependencias entre recursos y transferir valores de un recurso a otro.

## La función Ref

La función Ref se utiliza comúnmente para recuperar una propiedad de identificación de los recursos definidos dentro de la misma plantilla de CloudFormation. Su valor depende del tipo de recurso. Para la mayoría de los recursos, devuelve el nombre físico del recurso. Sin embargo, para algunos tipos de recursos, puede devolver un valor diferente, como una dirección IP para un recurso AWS::EC2::EIP o un nombre de recurso de Amazon (ARN) para un tema de Amazon SNS.

Los siguientes ejemplos muestran cómo usar la función Ref en las propiedades. En cada uno de estos ejemplos, la función Ref devolverá el nombre real del recurso LogicalResourceName declarado en otra parte de la plantilla. El ejemplo de sintaxis !Ref del ejemplo YAML es simplemente una forma abreviada de escribir la función Ref.
```
Properties:
  PropertyName1:
    Ref: LogicalResourceName
  PropertyName2: !Ref LogicalResourceName
```

## La función Fn::GetAtt

La función Ref es útil si el parámetro o el valor devuelto por un recurso es exactamente el deseado. Sin embargo, es posible que necesite otros atributos de un recurso. Por ejemplo, si desea crear una distribución de CloudFront con un origen S3, debe especificar la ubicación del depósito mediante una dirección de tipo DNS. Algunos recursos tienen atributos adicionales cuyos valores puede usar en su plantilla. Para obtener estos atributos, utilice la función Fn::GetAtt.

Los siguientes ejemplos muestran cómo usar la función GetAtt en las propiedades. La función Fn::GetAtt toma dos parámetros: el nombre lógico del recurso y el nombre del atributo que se va a recuperar. El ejemplo de sintaxis !GetAtt en el ejemplo YAML es simplemente una forma abreviada de escribir la función GetAtt.

```
Properties:
  PropertyName1:
    Fn::GetAtt:
      - LogicalResourceName
      - AttributeName
  PropertyName2: !GetAtt LogicalResourceName.AttributeName
```
## Ejemplo de como se declara un recurso con un nombre personalizado
Los siguientes ejemplos declaran un único recurso de tipo AWS::S3::Bucket con el nombre lógico MyBucket. La propiedad BucketName está establecida en amzn-s3-demo-bucket, que debe reemplazarse por el nombre deseado para su bucket de S3.
```
Resources:
  MyBucket:
    Type: 'AWS::S3::Bucket'
    Properties:
      BucketName: amzn-s3-demo-bucket
```
## Ejemplo de como se referencia a otros recursos con la función Ref

Los siguientes ejemplos muestran una declaración de recurso que define una instancia de EC2 y un grupo de seguridad. El recurso Ec2Instance hace referencia al recurso InstanceSecurityGroup como parte de su propiedad SecurityGroupIds mediante la función Ref. También incluye un grupo de seguridad existente (sg-12a4c434) que no está declarado en la plantilla. Se utilizan cadenas literales para hacer referencia a recursos de AWS existentes.
```
Resources:
  Ec2Instance:
    Type: 'AWS::EC2::Instance'
    Properties:
      SecurityGroupIds:
        - !Ref InstanceSecurityGroup
        - sg-12a4c434
      KeyName: MyKey
      ImageId: ami-1234567890abcdef0
  InstanceSecurityGroup:
    Type: 'AWS::EC2::SecurityGroup'
    Properties:
      GroupDescription: Enable SSH access via port 22
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 22
          ToPort: 22
          CidrIp: 0.0.0.0/0
```
## Ejemplo  de como se referencia a atributos de recursos mediante la función Fn::GetAtt

Los siguientes ejemplos muestran una declaración de recurso que define un recurso de distribución de CloudFront y un bucket de S3. El recurso MyDistribution especifica el nombre DNS del recurso MyBucket mediante la función Fn::GetAtt para obtener el atributo DomainName del bucket. Observará que la función Fn::GetAtt enumera sus dos parámetros en una matriz. Para las funciones que aceptan varios parámetros, se utiliza una matriz para especificarlos.
```
Resources:
  MyBucket:
    Type: 'AWS::S3::Bucket'
  MyDistribution:
    Type: 'AWS::CloudFront::Distribution'
    Properties:
      DistributionConfig:
        Origins:
          - DomainName: !GetAtt 
              - MyBucket
              - DomainName
            Id: MyS3Origin
            S3OriginConfig: {}
        Enabled: 'true'
        DefaultCacheBehavior:
          TargetOriginId: MyS3Origin
          ForwardedValues:
            QueryString: 'false'
          ViewerProtocolPolicy: allow-all
```
