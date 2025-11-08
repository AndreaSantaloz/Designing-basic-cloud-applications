# ==============================================================================
# CONFIGURACIÓN
# ==============================================================================
$StackName = "mi-ecr-stack"
$Region = "us-east-1"
$RepoName = "mi-repositorio-ecr"
$ImageName = "mi-aplicacion"
$DockerfilePath = "."
$TargetPlatform = "linux/amd64"  # Forzamos x86_64 para Lambda
$LambdaFunctionName = "users-lambda"
$LambdaMemory = 512
$LambdaTimeout = 60
$RoleArn = "arn:aws:iam::637423399710:role/LabRole"
# ==============================================================================

Write-Host "=== Iniciando despliegue completo de Imagen Docker a ECR ===" -ForegroundColor Green
Write-Host "Arquitectura de construcción forzada: $TargetPlatform`n" -ForegroundColor Cyan

# --- Función de manejo de errores ---
function HandleError {
    param([string]$Message)
    Write-Host "❌ ERROR: $Message" -ForegroundColor Red
    exit 1
}

# --- Paso 1: Crear o actualizar repositorio ECR con CloudFormation ---
Write-Host "1. Creando o actualizando ECR con CloudFormation..." -ForegroundColor Yellow
try {
    aws cloudformation create-stack `
      --stack-name $StackName `
      --template-body file://ecr-template.yaml `
      --region $Region `
      --parameters ParameterKey=RepositoryName,ParameterValue=$RepoName `
      --capabilities CAPABILITY_NAMED_IAM | Out-Null
} catch {
    Write-Host "   El stack posiblemente ya existe. Continuando..." -ForegroundColor DarkYellow
}

# Esperar a que el stack esté listo
Write-Host "   Esperando a que el stack esté listo..." -ForegroundColor Yellow
try {
    aws cloudformation wait stack-create-complete --stack-name $StackName --region $Region
} catch {
    HandleError "El stack de CloudFormation no se creó correctamente."
}

# --- Paso 2: Obtener URI del ECR ---
Write-Host "`n2. Obteniendo URI del ECR..." -ForegroundColor Yellow
$ECR_URI = aws cloudformation describe-stacks `
    --stack-name $StackName `
    --region $Region `
    --query 'Stacks[0].Outputs[?OutputKey==`RepositoryURI`].OutputValue' `
    --output text

if ([string]::IsNullOrEmpty($ECR_URI)) { HandleError "No se pudo obtener la URI del repositorio ECR." }
Write-Host "   ECR URI: $ECR_URI" -ForegroundColor Cyan

# --- Paso 3: Login en ECR ---
Write-Host "`n3. Haciendo login en ECR..." -ForegroundColor Yellow
try {
    $Password = aws ecr get-login-password --region $Region
    $ECRServer = $ECR_URI.Split("/")[0]
    echo $Password | docker login --username AWS --password-stdin $ECRServer
} catch {
    HandleError "Fallo en el login de Docker a ECR."
}

# --- Paso 4: Construir imagen Docker plana x86_64 compatible Lambda ---
Write-Host "`n4. Construyendo imagen Docker (Plataforma: $TargetPlatform)..." -ForegroundColor Yellow
try {
    docker buildx create --use | Out-Null
    docker buildx build --platform $TargetPlatform --load -t $ImageName $DockerfilePath
} catch {
    HandleError "Fallo al construir la imagen Docker. Asegúrate de usar base image compatible con x86_64."
}

# --- Paso 5: Taggear la imagen para ECR ---
Write-Host "`n5. Taggeando imagen..." -ForegroundColor Yellow
try {
    docker tag "${ImageName}:latest" "${ECR_URI}:latest"
} catch {
    HandleError "Fallo al etiquetar la imagen."
}

# --- Paso 6: Subir imagen a ECR ---
Write-Host "`n6. Subiendo imagen a ECR..." -ForegroundColor Yellow
try {
    docker push "${ECR_URI}:latest"
} catch {
    HandleError "Fallo al subir la imagen a ECR."
}

Write-Host "`n✅ Imagen subida correctamente: ${ECR_URI}:latest" -ForegroundColor Green

# --- Paso 7: Crear la Lambda ---
Write-Host "`n7. Creando la función Lambda..." -ForegroundColor Yellow
try {
    aws lambda create-function `
      --function-name $LambdaFunctionName `
      --package-type Image `
      --code ImageUri="${ECR_URI}:latest" `
      --role $RoleArn `
      --timeout $LambdaTimeout `
      --memory-size $LambdaMemory `
      --region $Region `
      --architectures x86_64
} catch {
    HandleError "Error al crear la Lambda. Verifica que la imagen esté construida como plana x86_64."
}

Write-Host "`n🎉 Lambda creada correctamente usando la imagen Docker." -ForegroundColor Green
