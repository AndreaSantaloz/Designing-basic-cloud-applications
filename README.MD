# Diseño de aplicaciones básicas en la nube


## Desarrollo
Antes de nada se va a desarrollar una aplicación gráfica donde se creará,eliminará,buscará y actualizará 
los datos de un cubo.
Una vez explicado esto el diseño de esta aplicación se pensará para su desarrollo en la nube donde se hará una versión acoplada y otra desacoplada.
## Arquitectura Acoplada
Tras decir esto empezamos con la arquitectura acoplada  que es una clase de ordenamiento donde cada componente
individual tiene una alta dependencia directa entre sí.

Esta arquitectura no es muy recomendada por una serie de problemas:
1. Fallo en Cascada: si un componente falla los demás también fallarán
2. Escalibilidad Limitada: Porque implica escalar todo el sistema
3. Dificultad de Mantenimiento: Los cambios o actualizaciones en un componente puede requerir modificaciones o pruebas exahustivas en los 
                                componentes acoplados.

Después de explicar qué es y sus fallas vamos a explicar como se desarrolla.Primero creamos un archivo YAML usando CloudFormation como base
para definir las condiciones,descripciones,versión del formato,mapping,metadatos,saldias,parametros,recursos,reglas y transformaciones.
Empezamos definiendo la ApiGateway que si no sabes es como un portero de discoteca donde controla quien entra y quien no a la fiesta(a la aplicación),además de gestionar la lógica de la API .Este tiene una serie de componentes que necesita que son los siguentes:
1. VPCLink
2. Recursos(Los tipos de url que van a la api y los identificadores de los metodos)
3. Metodos(GET,PUT,POST,DELETE)ç
4. Recurso para desplegar la aplicación (deployment),la puesta en escena(staging) 
   y la monetización/control de acceso de una API REST en Amazon API Gateway.

## Diagrama Arquitectura Acoplada

## Arquitectura Desacoplada

## Diagrama Arquitectura Desacoplada