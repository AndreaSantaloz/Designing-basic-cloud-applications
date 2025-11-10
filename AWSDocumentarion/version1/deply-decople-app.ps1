# deploy.ps1 - Script de despliegue para PowerShell
Write-Host "=== DESPLIEGUE ENTREGAUNOCN ===" -ForegroundColor Green

# Configuración
$STACK_NAME = "entregauno-docker-lambda"
$IMAGE_TAG = "latest"
$REGION = "us-east-1"

# Obtener Account ID
$ACCOUNT_ID = aws sts get-caller-identity --query Account --output text
Write-Host "Account ID: $ACCOUNT_ID" -ForegroundColor Cyan
Write-Host "Region: $REGION" -ForegroundColor Cyan

# PRIMERO crear el repositorio ECR manualmente
Write-Host "Creando repositorio ECR..." -ForegroundColor Yellow
aws ecr create-repository --repository-name entregauno-lambda-docker --region $REGION

# Autenticarse en ECR
Write-Host "Autenticando en ECR..." -ForegroundColor Yellow
$loginCommand = aws ecr get-login-password --region $REGION
$loginCommand | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com

# Construir y subir la imagen Docker
Write-Host "Construyendo imagen Docker..." -ForegroundColor Yellow
docker build -t entregauno-lambda-docker .

Write-Host "Etiquetando imagen..." -ForegroundColor Yellow
docker tag entregauno-lambda-docker:latest ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/entregauno-lambda-docker:${IMAGE_TAG}

Write-Host "Subiendo imagen a ECR..." -ForegroundColor Yellow
docker push ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/entregauno-lambda-docker:${IMAGE_TAG}

Write-Host "Imagen subida exitosamente!" -ForegroundColor Green

# AHORA desplegar CloudFormation (la imagen ya existe en ECR)
Write-Host "Desplegando stack de CloudFormation..." -ForegroundColor Yellow
aws cloudformation deploy `
    --stack-name $STACK_NAME `
    --template-file template2.yaml `
    --parameter-overrides ImageTag=$IMAGE_TAG `
    --capabilities CAPABILITY_NAMED_IAM `
    --region $REGION

Write-Host "=== DESPLIEGUE COMPLETADO ===" -ForegroundColor Green
Write-Host "Repositorio ECR: ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/entregauno-lambda-docker" -ForegroundColor Cyan
Write-Host "Stack CloudFormation: $STACK_NAME" -ForegroundColor Cyan
Write-Host "Función Lambda: entregauno-docker-lambda" -ForegroundColor Cyan