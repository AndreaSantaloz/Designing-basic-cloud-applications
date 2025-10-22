La sección opcional "Conditions" contiene instrucciones que definen las circunstancias bajo las cuales se crean o configuran las entidades. Por ejemplo, puede crear una condición y asociarla a un recurso o una salida para que CloudFormation cree dicho recurso o salida solo si la condición es verdadera. De igual forma, puede asociar una condición a una propiedad para que CloudFormation le asigne un valor específico solo si la condición es verdadera. Si la condición es falsa, CloudFormation le asigna un valor alternativo que usted especifique.

Puede usar condiciones cuando desee reutilizar una plantilla para crear recursos en diferentes contextos, como entornos de prueba y producción. Por ejemplo, en su plantilla, puede agregar un parámetro de entrada "EnvironmentType" que acepte "prod" o "test" como entradas. Para el entorno de producción, puede incluir instancias de EC2 con ciertas capacidades, mientras que para el entorno de prueba, puede usar capacidades reducidas para ahorrar dinero. Esta definición de condición le permite definir qué recursos se crean y cómo se configuran para cada tipo de entorno.

## Sintaxis
```
Conditions:
  LogicalConditionName1:
    Intrinsic function:
      ...

  LogicalConditionName2:
    Intrinsic function:
      ...
```
Cómo funcionan las condiciones

Para usar condiciones, siga estos pasos:

Agregue una definición de parámetro: Defina las entradas que evaluarán sus condiciones en la sección "Parámetros" de su plantilla. Las condiciones se evalúan como verdaderas o falsas según los valores de estos parámetros de entrada. Tenga en cuenta que los pseudoparámetros están disponibles automáticamente y no requieren una definición explícita en la sección "Parámetros". Para obtener más información sobre los pseudoparámetros, consulte "Obtener valores de AWS mediante pseudoparámetros".

Agregue una definición de condición: Defina las condiciones en la sección "Condiciones" mediante funciones intrínsecas como "Fn::If" o "Fn::Equals". Estas condiciones determinan cuándo CloudFormation crea los recursos asociados. Las condiciones pueden basarse en:

Valores de entrada o pseudoparámetros

Otras condiciones

Asignación de valores

Sin embargo, no puede hacer referencia a los ID lógicos de los recursos ni a sus atributos en las condiciones.

Asocie condiciones con recursos o salidas: Haga referencia a las condiciones en los recursos o salidas mediante la clave "Condición" y el ID lógico de una condición. Opcionalmente, use "Fn::If" en otras partes de la plantilla (como los valores de propiedad) para establecer valores según una condición. Para obtener más información, consulte Uso de la clave de condición.

CloudFormation evalúa las condiciones al crear o actualizar una pila. Crea entidades asociadas con una condición verdadera e ignora las asociadas con una condición falsa. CloudFormation también reevalúa estas condiciones durante cada actualización de la pila antes de modificar cualquier recurso. Las entidades que permanecen asociadas con una condición verdadera se actualizan, mientras que las que se asocian con una condición falsa se eliminan.
## Importante
Durante una actualización de pila, no se pueden actualizar las condiciones por sí solas. Solo se pueden actualizar las condiciones al incluir cambios que agreguen, modifiquen o eliminen recursos.