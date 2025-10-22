La sección Descripción (opcional) permite incluir una cadena de texto que describe la plantilla. Esta sección siempre debe ir después de la sección de versión del formato de la plantilla.

El valor de la declaración de descripción debe ser una cadena literal con una longitud de entre 0 y 1024 bytes. No se puede usar un parámetro ni una función para especificar la descripción. El siguiente fragmento es un ejemplo de una declaración de descripción:

## Importante
Durante una actualización de pila, no se puede actualizar la sección Descripción por sí sola. Solo se puede actualizar al incluir cambios que agreguen, modifiquen o eliminen recursos.
```
Description: > Here are some details about the template.
```