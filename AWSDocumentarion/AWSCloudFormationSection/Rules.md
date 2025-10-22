La sección Rules es una parte opcional de una plantilla de CloudFormation que permite una lógica de validación personalizada. Cuando se incluye, esta sección contiene funciones de reglas que validan los valores de los parámetros antes de que CloudFormation cree o actualice cualquier recurso.

Las reglas son útiles cuando las restricciones de parámetros estándar son insuficientes. Por ejemplo, si se habilita SSL, se deben proporcionar tanto un certificado como un nombre de dominio. Una regla puede garantizar que se cumplan estas dependencias.
## Sintaxis
```
Rules:
  LogicalRuleName1:
    RuleCondition:
      rule-specific intrinsic function: Value
    Assertions:
      - Assert:
          rule-specific intrinsic function: Value
        AssertDescription: Information about this assert
      - Assert:
          rule-specific intrinsic function: Value
        AssertDescription: Information about this assert
  LogicalRuleName2:
    Assertions:
      - Assert:
          rule-specific intrinsic function: Value
        AssertDescription: Information about this assert
```