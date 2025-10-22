Los metadatos almacenan información adicional mediante objetos JSON o YAML. Los tipos de metadatos a nivel de plantilla que puede usar en su plantilla incluyen:

Metadatos personalizados

Almacenan pares clave-valor definidos por el usuario. Por ejemplo, puede proporcionar información adicional que no afecte a la creación de recursos, pero que ofrezca contexto adicional sobre la infraestructura, el equipo o las especificaciones de la implementación.
AWS::CloudFormation::Interface

Define la agrupación y el orden de los parámetros de entrada cuando se muestran en la consola de CloudFormation. De forma predeterminada, la consola de CloudFormation ordena los parámetros alfabéticamente por su ID lógico.
AWS::CloudFormation::Designer

AWS CloudFormation Designer (Designer) finalizó su ciclo de vida el 5 de febrero de 2025.

## Importante
Durante una actualización de pila, no se puede actualizar la sección Metadatos por sí sola. Solo se puede actualizar cuando se incluyen cambios que agregan, modifican o eliminan recursos.

CloudFormation no transforma, modifica ni censura la información incluida en la sección Metadatos. Por ello, se recomienda encarecidamente no utilizar esta sección para almacenar información confidencial, como contraseñas o secretos.

## Síntaxis
```
Metadata:
  Instances:
    Description: "Information about the instances"
  Databases: 
    Description: "Information about the databases"
```