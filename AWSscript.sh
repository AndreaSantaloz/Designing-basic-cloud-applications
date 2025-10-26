#Crea un repositorio 
aws ecr create-repository --repository-name name  --region region

#Etiquetar la imagen de Docker
docker tag nameImagen aws_account_id.dkr.ecr.region.amazonaws.com/name.repository

#Ejecute el comando aws ecr get-login-password. Especifique el Registro URI al que 
#desea autenticar. Para obtener más información, consulte Registro Autenticación 
#en la Guía del usuario del registro de contenedores de Amazon Elastic.

aws ecr get-login-password --region region | docker login --username AWS --password-stdin aws_account_id.dkr.ecr.region.amazonaws.com

#Empuje la imagen a Amazon ECR con el repositoryUriValor de la Paso anterior.
docker push aws_account_id.dkr.ecr.region.amazonaws.com/hello-repository

#Limpieza para que no me cobren

#Para continuar con la creación de una definición de tarea de Amazon ECS 
#y el lanzamiento de una tarea con su Imagen del contenedor, vaya a los siguientes pasos.
#Cuando termines de experimentar Con su imagen de Amazon ECR, puede eliminar el repositorio 
#para que no se le cobre por la imagen Almacenamiento.


aws ecr delete-repository --repository-name hello-repository --region region --force