La sección opcional "Mappings" le ayuda a crear pares clave-valor que pueden usarse para especificar valores según ciertas condiciones o dependencias.

Un uso común de la sección "Mappings" es establecer valores según la región de AWS donde se implementa la pila. Esto se puede lograr mediante el pseudoparámetro AWS::Region. Este pseudoparámetro es un valor que CloudFormation resuelve en la región donde se crea la pila. CloudFormation resuelve los pseudoparámetros al crear la pila.

Para recuperar valores en un mapa, puede usar la función intrínseca Fn::FindInMap en la sección "Recursos" de su plantilla.

## Síntaxis
```
Mappings: 
  MappingLogicalName: 
    Key1: 
      Name: Value1
    Key2: 
      Name: Value2
    Key3: 
      Name: Value3
```