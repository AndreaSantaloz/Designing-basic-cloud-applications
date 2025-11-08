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

# --- Paso 1: Crear o actualizar repositorio ECR ---
Write-Host "`n1. CREANDO O ACTUALIZANDO ECR..." -ForegroundColor Yellow
try {
    # Verificar si el stack existe
    $ECRStackExists = aws cloudformation describe-stacks --stack-name $ECRStackName --region $Region 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "   Creando nuevo stack de ECR..." -ForegroundColor Yellow
        $result = aws cloudformation create-stack `
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
    } else {
        Write-Host "   ✅ El stack de ECR ya existe" -ForegroundColor DarkYellow
    }
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
    # Verificar que Dockerfile existe
    if (-not (Test-Path "Dockerfile")) {
        HandleError "No se encuentra Dockerfile en el directorio actual"
    }
    
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
    $LambdaStackExists = aws cloudformation describe-stacks --stack-name $LambdaStackName --region $Region 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "   Creando nuevo stack de Lambda..." -ForegroundColor Yellow
        aws cloudformation create-stack `
          --stack-name $LambdaStackName `
          --template-body file://api.yaml `
          --region $Region `
          --parameters ParameterKey=ImageUri,ParameterValue="${ECR_URI}:latest" `
          --capabilities CAPABILITY_IAM
          
        if ($LASTEXITCODE -ne 0) {
            HandleError "No se pudo crear el stack de Lambda. Verifica el template."
        }
        
        Write-Host "   Esperando a que el stack de Lambda esté listo..." -ForegroundColor Yellow
        aws cloudformation wait stack-create-complete --stack-name $LambdaStackName --region $Region
        Write-Host "   ✅ Stack de Lambda creado" -ForegroundColor Green
    } else {
        Write-Host "   Actualizando stack existente de Lambda..." -ForegroundColor Yellow
        aws cloudformation update-stack `
          --stack-name $LambdaStackName `
          --template-body file://api.yaml `
          --region $Region `
          --parameters ParameterKey=ImageUri,ParameterValue="${ECR_URI}:latest" `
          --capabilities CAPABILITY_IAM
          
        Write-Host "   Esperando a que la actualización termine..." -ForegroundColor Yellow
        aws cloudformation wait stack-update-complete --stack-name $LambdaStackName --region $Region
        Write-Host "   ✅ Stack de Lambda actualizado" -ForegroundColor Green
    }
} catch {
    HandleError "Error al desplegar el stack de Lambda: $($_.Exception.Message)"
}

# --- Paso 7: Obtener resultados ---
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
Write-Host "`n" + "="*50 -ForegroundColor Cyan
Write-Host "DESPLIEGUE COMPLETADO EXITOSAMENTE" -ForegroundColor Green
Write-Host "="*50 -ForegroundColor Cyan

if ($Outputs) {
    foreach ($output in $Outputs) {
        switch ($output.OutputKey) {
            "ApiUrl" { 
                Write-Host "`nURL DE LA API: $($output.OutputValue)" -ForegroundColor Yellow
                Write-Host "   Frontend: $($output.OutputValue)/" -ForegroundColor White
                Write-Host "   API: $($output.OutputValue)/users" -ForegroundColor White
            }
            "LambdaFunctionName" { 
                Write-Host "LAMBDA: $($output.OutputValue)" -ForegroundColor Cyan
            }
            "ApiKeyValue" { 
                Write-Host "API KEY: $($output.OutputValue)" -ForegroundColor Magenta
                Write-Host "   Header: x-api-key: $($output.OutputValue)" -ForegroundColor White
            }
        }
    }
} else {
    Write-Host "`nObtén los outputs manualmente con:" -ForegroundColor Yellow
    Write-Host "aws cloudformation describe-stacks --stack-name $LambdaStackName --region $Region" -ForegroundColor White
}

Write-Host "`nENDPOINTS DISPONIBLES:" -ForegroundColor Green
Write-Host "   GET    /users          - Listar usuarios" -ForegroundColor White
Write-Host "   POST   /users          - Crear usuario" -ForegroundColor White
Write-Host "   GET    /users/{id}     - Obtener usuario" -ForegroundColor White
Write-Host "   PUT    /users/{id}     - Actualizar usuario" -ForegroundColor White
Write-Host "   DELETE /users/{id}     - Eliminar usuario" -ForegroundColor White

Write-Host "`nRECUERDA INCLUIR EL HEADER: x-api-key" -ForegroundColor Yellow
Write-Host "`nTu API esta lista para usar!" -ForegroundColor Green