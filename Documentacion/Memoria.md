# Memoria de la primera práctica de computación en la nube

## Autora 
Andrea Santana López

## ¿Qué se va a hacer?
Se va a implementar en amazon web service un aplicación con dos tipos de arquitectura: la acoplada o  monolíto y la desacoplada o microservicios.

## ¿De qué se basa la aplciación?
Es una aplicación de testeo de usuarios donde se realiza un CRUD(create,read,upload and delete) de usuarios.

## ¿En qué consiste la arquitectura acoplada/monolito?

Se basa en una arquitectura donde se hace una serie de recursos el APIGATEWAY con un VPCLink,recursos y metodos,un load balancer para gestionar el trafico de entrada/salida,un ECS fargate para ejecutar la aplicación web y un ECR donde ira almacenado la imagen de docker.