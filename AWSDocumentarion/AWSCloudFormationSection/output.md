La sección opcional "Outputs" declara los valores de salida de la pila. Estos valores se pueden usar de varias maneras:

Capturar detalles importantes sobre los recursos: una salida es una forma práctica de capturar información importante sobre los recursos. Por ejemplo, puede generar el nombre del bucket de S3 para una pila para facilitar su búsqueda. Puede ver los valores de salida en la pestaña "Salidas" de la consola de CloudFormation o mediante el comando describe-stacks de la CLI.

Referencias entre pilas: puede importar valores de salida a otras pilas para crear referencias entre ellas. Esto resulta útil cuando necesita compartir recursos o configuraciones entre varias pilas.
## Importante
CloudFormation no censura ni ofusca la información incluida en la sección "Salidas". Recomendamos encarecidamente no usar esta sección para generar información confidencial, como contraseñas o secretos.

Los valores de salida están disponibles una vez finalizada la operación de la pila. Los valores de salida de la pila no están disponibles cuando el estado de la pila es "EN PROGRESO". No recomendamos establecer dependencias entre el entorno de ejecución del servicio y el valor de salida de la pila, ya que podrían no estar disponibles en todo momento.

## Síntasis formato YAML

```
Outputs:
  OutputLogicalID:
    Description: Information about the value
    Value: Value to return
    Export:
      Name: Name of resource to export
```
Campos de Outputs

La sección "Output" puede incluir los siguientes campos:

#### ID lógico (también llamado nombre lógico)

Un identificador para la salida actual. El ID lógico debe ser alfanumérico (a-z, A-Z, 0-9) y único dentro de la plantilla.

#### Descripción (opcional)

Un tipo de cadena que describe el valor de salida. El valor de la declaración de descripción debe ser una cadena literal con una longitud de entre 0 y 1024 bytes. No se puede usar un parámetro ni una función para especificar la descripción.

#### Value (obligatorio)

El valor de la propiedad devuelta por el comando describe-stacks. El valor de una salida puede incluir literales, referencias a parámetros, pseudoparámetros, un valor de mapeo o funciones intrínsecas.

#### Export (opcional)

El nombre de la salida del recurso que se exportará para una referencia entre pilas.

Puede usar funciones intrínsecas para personalizar el valor "Nombre" de una exportación.

Para obtener más información, consulte Obtener salidas exportadas de una pila de CloudFormation implementada. Para asociar una condición con una salida, defínala en la sección "Condiciones" de la plantilla.

## Ejemplos
### Salida de la pila
En el siguiente ejemplo, la salida BackupLoadBalancerDNSName devuelve el nombre DNS del recurso con el ID lógico BackupLoadBalancer solo cuando la condición CreateProdResources es verdadera. La salida InstanceID devuelve el ID de la instancia de EC2 con el ID lógico EC2Instance.
```
Outputs:
  BackupLoadBalancerDNSName:
    Description: The DNSName of the backup load balancer
    Value: !GetAtt BackupLoadBalancer.DNSName
    Condition: CreateProdResources
  InstanceID:
    Description: The Instance ID
    Value: !Ref EC2Instance
```