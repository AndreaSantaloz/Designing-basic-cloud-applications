# ==============================================================================
# CONFIGURACIÓN COMPLETA
# ==============================================================================
$ECRStackName = "mi-ecr-stack"
$LambdaStackName = "lambdas-stack"
$Region = "us-east-1"
$RepoName = "mi-repositorio-ecr"
$ImageName = "mi-aplicacion"
$DockerfilePath = "."
$TargetPlatform = "linux/amd64"

Write-Host "=== INICIANDO DESPLIEGUE COMPLETO ===" -ForegroundColor Green
Write-Host "ECR + Lambda + API Gateway" -ForegroundColor Cyan

# --- Función de manejo de errores ---
function HandleError {
    param([string]$Message)
    Write-Host "ERROR: $Message" -ForegroundColor Red
    exit 1
}

# --- Verificar permisos primero ---
Write-Host "Verificando permisos..." -ForegroundColor Yellow
try {
    aws sts get-caller-identity | Out-Null
    Write-Host "✅ Autenticación OK" -ForegroundColor Green
} catch {
    HandleError "No hay permisos de AWS. Verifica tu configuración."
}

# --- Paso 1: Crear repositorio ECR ---
Write-Host "`n1. CREANDO ECR..." -ForegroundColor Yellow
try {
    Write-Host "   Creando stack de ECR..." -ForegroundColor Yellow
    aws cloudformation create-stack `
      --stack-name $ECRStackName `
      --template-body file://ecr-template.yaml `
      --region $Region `
      --parameters ParameterKey=RepositoryName,ParameterValue=$RepoName `
      --capabilities CAPABILITY_NAMED_IAM
    
    if ($LASTEXITCODE -ne 0) {
        HandleError "No se pudo crear el stack de ECR. Verifica permisos."
    }
    
    Write-Host "   Esperando a que el stack de ECR esté listo..." -ForegroundColor Yellow
    aws cloudformation wait stack-create-complete --stack-name $ECRStackName --region $Region
    Write-Host "   ✅ Stack de ECR creado" -ForegroundColor Green
} catch {
    HandleError "Error al crear el stack de ECR: $($_.Exception.Message)"
}

# --- Paso 2: Obtener URI del ECR ---
Write-Host "2. OBTENIENDO URI DEL ECR..." -ForegroundColor Yellow
$ECR_URI = aws cloudformation describe-stacks `
    --stack-name $ECRStackName `
    --region $Region `
    --query 'Stacks[0].Outputs[?OutputKey==`RepositoryURI`].OutputValue' `
    --output text

if ([string]::IsNullOrEmpty($ECR_URI)) { 
    HandleError "No se pudo obtener la URI del repositorio ECR" 
}

Write-Host "   ECR URI: $ECR_URI" -ForegroundColor Cyan

# --- Paso 3: Login en ECR ---
Write-Host "3. HACIENDO LOGIN EN ECR..." -ForegroundColor Yellow
try {
    $ecrLogin = aws ecr get-login-password --region $Region
    if ($LASTEXITCODE -ne 0) {
        HandleError "No se pudo obtener password de ECR"
    }
    
    $ECRServer = $ECR_URI.Split("/")[0]
    $ecrLogin | docker login --username AWS --password-stdin $ECRServer
    Write-Host "   ✅ Login exitoso" -ForegroundColor Green
} catch {
    HandleError "Fallo en el login de Docker a ECR"
}

# --- Paso 4: Construir imagen Docker ---
Write-Host "4. CONSTRUYENDO IMAGEN DOCKER..." -ForegroundColor Yellow
try {
    docker buildx create --use 2>&1 | Out-Null
    docker buildx build --platform $TargetPlatform --load -t $ImageName $DockerfilePath
    if ($LASTEXITCODE -ne 0) {
        HandleError "Fallo al construir la imagen Docker"
    }
    Write-Host "   ✅ Imagen construida exitosamente" -ForegroundColor Green
} catch {
    HandleError "Fallo al construir la imagen Docker: $($_.Exception.Message)"
}

# --- Paso 5: Taggear y subir imagen a ECR ---
Write-Host "5. SUBIENDO IMAGEN A ECR..." -ForegroundColor Yellow
try {
    docker tag "${ImageName}:latest" "${ECR_URI}:latest"
    docker push "${ECR_URI}:latest"
    Write-Host "   ✅ Imagen subida exitosamente" -ForegroundColor Green
} catch {
    HandleError "Fallo al subir la imagen a ECR"
}

# --- Paso 6: Desplegar Lambda y API Gateway ---
Write-Host "6. DESPLEGANDO LAMBDA Y API GATEWAY..." -ForegroundColor Yellow
try {
    Write-Host "   Creando stack de Lambda..." -ForegroundColor Yellow
    aws cloudformation create-stack `
      --stack-name $LambdaStackName `
      --template-body file://decoupleapi.yaml `
      --region $Region `
      --parameters ParameterKey=ImageUri,ParameterValue="${ECR_URI}:latest" `
      --capabilities CAPABILITY_IAM
      
    if ($LASTEXITCODE -ne 0) {
        HandleError "No se pudo crear el stack de Lambda. Verifica el template."
    }
    
    Write-Host "   Esperando a que el stack de Lambda esté listo..." -ForegroundColor Yellow
    aws cloudformation wait stack-create-complete --stack-name $LambdaStackName --region $Region
    Write-Host "   ✅ Stack de Lambda creado" -ForegroundColor Green
} catch {
    HandleError "Error al desplegar el stack de Lambda: $($_.Exception.Message)"
}

# --- Paso 7: Obtener resultados de CloudFormation ---
Write-Host "7. OBTENIENDO RESULTADOS..." -ForegroundColor Yellow
try {
    $Outputs = aws cloudformation describe-stacks `
        --stack-name $LambdaStackName `
        --region $Region `
        --query 'Stacks[0].Outputs' `
        --output json | ConvertFrom-Json
        
    if (-not $Outputs) {
        Write-Host "   ⚠️  No se pudieron obtener outputs" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ⚠️  Error al obtener outputs: $($_.Exception.Message)" -ForegroundColor Yellow
}

# --- MOSTRAR RESULTADOS FINALES ---
Write-Host "`n" + "="*60 -ForegroundColor Green
Write-Host "DESPLIEGUE COMPLETADO EXITOSAMENTE" -ForegroundColor Green
Write-Host "="*60 -ForegroundColor Green

if ($Outputs) {
    foreach ($output in $Outputs) {
        switch ($output.OutputKey) {
            "ApiUrl" { 
                Write-Host "`nURL DE LA API: $($output.OutputValue)" -ForegroundColor Yellow
                Write-Host "   Frontend: frontend/index.html" -ForegroundColor White
                Write-Host "   Endpoint principal: $($output.OutputValue)/users" -ForegroundColor White
            }
            "LambdaFunctionName" { 
                Write-Host "LAMBDA: $($output.OutputValue)" -ForegroundColor Cyan
            }
        }
    }
}

Write-Host "`nINSTRUCCIONES RAPIDAS:" -ForegroundColor Green
Write-Host "   1. Abre frontend/index.html en tu navegador" -ForegroundColor White
Write-Host "   2. Asegurate de actualizar la URL de la API en el frontend" -ForegroundColor White
Write-Host "   3. Prueba los endpoints con tu frontend" -ForegroundColor White

Write-Host "`nTu API esta lista para usar!" -ForegroundColor Green