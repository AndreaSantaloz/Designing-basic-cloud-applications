
La segunda es Parameters
Utilice la sección opcional "Parámetros" para personalizar sus plantillas. Con los parámetros, puede introducir valores personalizados en su plantilla cada vez que cree o actualice una pila. Al usar parámetros en sus plantillas, puede crear plantillas reutilizables y flexibles que se adapten a escenarios específicos.

Al definir parámetros del tipo adecuado, puede elegir entre una lista de identificadores de recursos existentes al usar la consola para crear su pila. Para obtener más información, consulte "Especificar recursos existentes en tiempo de ejecución con los tipos de parámetros proporcionados por CloudFormation".

Los parámetros son una forma popular de especificar valores de propiedad de los recursos de la pila. Sin embargo, puede haber configuraciones que dependan de la región o que sean algo complejas de entender para los usuarios debido a otras condiciones o dependencias. En estos casos, puede que le convenga incluir cierta lógica en la propia plantilla para que los usuarios puedan especificar valores más simples (o ninguno) para obtener los resultados deseados, por ejemplo, mediante una asignación. Para obtener más información, consulte "Sintaxis de asignaciones de plantillas de CloudFormation".
```
Parameters:
  ParameterLogicalID:
    Description: Information about the parameter
    Type: DataType
    Default: value
    AllowedValues:
      - value1
      - value2
```
Un parámetro contiene una lista de atributos que definen su valor y las restricciones que lo rigen. El único atributo obligatorio es "Tipo", que puede ser una cadena, un número o un tipo de parámetro proporcionado por CloudFormation. También puede agregar un atributo "Descripción" que describe el tipo de valor que debe especificar. El nombre y la descripción del parámetro aparecen en la página "Especificar parámetros" al usar la plantilla en el asistente "Crear pila".

### Nota
-------
De forma predeterminada, la consola de CloudFormation ordena los parámetros de entrada alfabéticamente por su ID lógico. Para anular este orden predeterminado y agrupar los parámetros relacionados, puede usar la clave de metadatos AWS::CloudFormation::Interface en su plantilla. Para obtener más información, consulte Organización de parámetros de CloudFormation con metadatos de AWS::CloudFormation::Interface.

---------

Para los parámetros con valores predeterminados, CloudFormation utiliza estos valores a menos que los usuarios especifiquen otro. Si se omite el atributo predeterminado, los usuarios deben especificar un valor para ese parámetro. Sin embargo, exigir al usuario que introduzca un valor no garantiza su validez. Para validar el valor de un parámetro, se pueden declarar restricciones o especificar un tipo de parámetro específico de AWS.

Para los parámetros sin valores predeterminados, los usuarios deben especificar un valor de nombre de clave al crear la pila. De lo contrario, CloudFormation no podrá crear la pila y generará una excepción:


### Requisitos generales para los parámetros

Al usar parámetros, se aplican los siguientes requisitos:

Se puede tener un máximo de 200 parámetros en una plantilla de CloudFormation.

Cada parámetro debe tener un nombre lógico (también llamado ID lógico) alfanumérico y único entre todos los nombres lógicos de la plantilla.

Cada parámetro debe tener asignado un tipo de parámetro compatible con CloudFormation. Para obtener más información, consulte Tipo.

Cada parámetro debe tener un valor asignado en tiempo de ejecución para que CloudFormation aprovisione correctamente la pila. Opcionalmente, puede especificar un valor predeterminado para que CloudFormation lo utilice, a menos que se proporcione otro valor.

Los parámetros deben declararse y referenciarse desde la misma plantilla. Puede referenciarse desde las secciones Recursos y Salidas de la plantilla.

### Propiedades

1. AllowedPattern
    Una expresión regular que representa los patrones que permiten los tipos String o CommaDelimitedList. Al aplicarse a un parámetro de tipo String, el patrón debe coincidir con todo el valor del parámetro proporcionado. Al aplicarse a un parámetro de tipo CommaDelimitedList, el patrón debe coincidir con cada valor de la lista.

2. AllowedValues
    Una matriz que contiene la lista de valores permitidos para el parámetro. Al aplicarse a un parámetro de tipo String, el valor del parámetro debe ser uno de los valores permitidos. Al aplicarse a un parámetro de tipo CommaDelimitedList, cada valor de la lista debe ser uno de los valores permitidos especificados.
    #### Nota
    Si está usando YAML y desea utilizar cadenas Sí y No para AllowedValues, utilice comillas simples para evitar que el analizador YAML considere estos valores booleanos.

3. ConstraintDescription
    Una cadena que explica una restricción cuando se infringe. Por ejemplo, sin una descripción de la restricción, un parámetro con un patrón permitido de [A-Za-z0-9]+ muestra el siguiente mensaje de error cuando el usuario especifica un valor no válido:El parámetro de entrada mal formado,            MyParameter, debe coincidir con el patrón       [A-Za-z0-9]+.Al agregar una descripción de la            restricción, como "solo debe contener       letras (mayúsculas y minúsculas) y          números", puede mostrar el siguiente       mensaje de error personalizado:
    El parámetro de entrada mal formado,            MyParameter, solo debe contener letras          mayúsculas y minúsculas, y números.

            
4. Default
    Un valor del tipo adecuado que la plantilla debe usar si no se especifica ningún valor al crear una pila. Si define restricciones para el parámetro, debe especificar un valor que las cumpla.
5. Description
    Una cadena de hasta 4000 caracteres que describe el parámetro.
6. MaxLength
    Un valor entero que determina la mayor cantidad de caracteres que desea permitir para los tipos de cadena.
7. MaxValue
    Un valor numérico que determina el valor numérico más grande que desea permitir para los tipos de número.
8. MinLength
    Un valor entero que determina la minima cantidad de caracteres que desea permitir para los tipos de cadena.
9. MinValue
        Un valor numérico que determina el valor numérico más pequeño que desea permitir para los tipos de número.
10. NoEcho
Si se debe enmascarar el valor del parámetro para evitar que se muestre en la consola, las herramientas de línea de comandos o la API. Si se establece el atributo NoEcho como verdadero, CloudFormation devuelve el valor del parámetro enmascarado como asteriscos (*****) para cualquier llamada que describa la pila o sus eventos, excepto para la información almacenada en las ubicaciones especificadas a continuación.
11. Type
El tipo de dato del parámetro (DataType).
Obligatorio: Sí
CloudFormation admite los siguientes tipos de parámetros:
Cadena
Una cadena literal. Puede usar los siguientes atributos para declarar restricciones: LongitudMínima, LongitudMáxima, ValorPredeterminado, ValoresPermitidos y PatrónPermitido.

Un entero o un valor de punto flotante. CloudFormation valida el valor del parámetro como un número; sin embargo, al usar el parámetro en otra parte de la plantilla (por ejemplo, mediante la función intrínseca Ref), el valor del parámetro se convierte en una cadena.

Puede usar los siguientes atributos para declarar restricciones: ValorMínima, ValorMáxima, ValorPredeterminado y ValoresPermitidos.

Por ejemplo, los usuarios podrían especificar "8888".
Lista<Número>

Una matriz de enteros o valores de punto flotante separados por comas. CloudFormation valida el valor del parámetro como un número; sin embargo, al usar el parámetro en otra parte de la plantilla (por ejemplo, mediante la función intrínseca Ref), el valor del parámetro se convierte en una lista de cadenas. Una matriz de cadenas literales separadas por comas. El número total de cadenas debe ser uno más que el número total de comas. Además, cada cadena miembro se recorta con espacios.

Por ejemplo, si los usuarios especifican "test,dev,prod", una referencia resultaría en ["test","dev","prod"].

Tipos de parámetros específicos de AWS

Valores de AWS, como los nombres de pares de claves de Amazon EC2 y los ID de VPC. Para obtener más información, consulte Especificar recursos existentes en tiempo de ejecución.
Tipos de parámetros de Systems Manager

Parámetros que corresponden a los parámetros existentes en el almacén de parámetros de Systems Manager. Al especificar una clave de parámetro de Systems Manager como valor del tipo de parámetro de Systems Manager, CloudFormation recupera el valor más reciente del almacén de parámetros para usarlo en la pila. Para obtener más información, consulte Especificar recursos existentes en tiempo de ejecución.