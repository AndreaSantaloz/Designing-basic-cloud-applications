# Configuración
$StackName = "mi-ecr-stack"
$Region = "us-east-1"
$RepoName = "mi-repositorio-ecr"
$ImageName = "mi-aplicacion"
$DockerfilePath = "."

Write-Host "=== Iniciando despliegue completo ===" -ForegroundColor Green

# Paso 1: Crear el ECR con CloudFormation,ECS
Write-Host "1. Creando ECR con CloudFormation..." -ForegroundColor Yellow
aws cloudformation create-stack --stack-name $StackName --template-body file://template.yaml --region $Region --parameters ParameterKey=RepositoryName,ParameterValue=$RepoName

# Esperar a que el ECR se cree
Write-Host "   Esperando a que el ECR esté listo..." -ForegroundColor Yellow
aws cloudformation wait stack-create-complete --stack-name $StackName --region $Region

# Paso 2: Obtener la URI del ECR
Write-Host "2. Obteniendo URI del ECR..." -ForegroundColor Yellow
$ECR_URI = aws cloudformation describe-stacks --stack-name $StackName --region $Region --query 'Stacks[0].Outputs[?OutputKey==`RepositoryURI`].OutputValue' --output text

Write-Host "   ECR URI: $ECR_URI" -ForegroundColor Cyan

# Paso 3: Login a ECR (CORREGIDO para PowerShell)
Write-Host "3. Haciendo login en ECR..." -ForegroundColor Yellow
$Password = aws ecr get-login-password --region $Region
echo $Password | docker login --username AWS --password-stdin $ECR_URI

# Paso 4: Construir la imagen Docker
Write-Host "4. Construyendo imagen Docker..." -ForegroundColor Yellow
docker build -t $ImageName $DockerfilePath

# Paso 5: Taggear la imagen con ECR
Write-Host "5. Taggeando imagen..." -ForegroundColor Yellow
docker tag ${ImageName}:latest "${ECR_URI}:latest"

# Paso 6: Subir imagen a ECR
Write-Host "6. Subiendo imagen a ECR..." -ForegroundColor Yellow
docker push "${ECR_URI}:latest"

Write-Host "=== Despliegue completado ===" -ForegroundColor Green
Write-Host "Imagen disponible en: $ECR_URI:latest" -ForegroundColor Cyan

exit 0


