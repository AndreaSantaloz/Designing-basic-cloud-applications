# ==============================================================================
# CONFIGURACIÓN COMPLETA - AMBAS ARQUITECTURAS ACTIVAS
# ==============================================================================
$LambdaECRStackName = "mi-ecr-stack-lambda"
$CoupledECRStackName = "mi-ecr-stack-coupled"
$LambdaStackName = "lambdas-stack"
$CoupledStackName = "coupled-stack"
$Region = "us-east-1"
$LambdaRepoName = "mi-repositorio-lambda"
$CoupledRepoName = "mi-repositorio-coupled"
$LambdaImageName = "mi-aplicacion-lambda"
$CoupledImageName = "mi-aplicacion-coupled"
$LambdaDockerfilePath = "./Decoupled/Dockerfile"
$CoupledDockerfilePath = "./Coupled/Dockerfile"
$TargetPlatform = "linux/amd64"

# Variables para tracking de éxito
$LambdaSuccess = $false
$CoupledSuccess = $false

Write-Host "=== INICIANDO DESPLIEGUE COMPLETO ===" -ForegroundColor Green
Write-Host "ECR SEPARADOS + Lambda (Desacoplada) + ECS+NLB (Acoplada)" -ForegroundColor Cyan
Write-Host "Usando estructuras de carpetas separadas" -ForegroundColor Yellow

# --- Función de manejo de errores ---
function HandleError {
    param([string]$Message)
    Write-Host "ERROR: $Message" -ForegroundColor Red
    exit 1
}

# --- Función para obtener VPC por defecto ---
function Get-DefaultVPC {
    try {
        $vpcs = aws ec2 describe-vpcs --region $Region --filters "Name=isDefault,Values=true" --query 'Vpcs[0].VpcId' --output text
        if ($LASTEXITCODE -eq 0 -and $vpcs -ne "None") {
            return $vpcs
        }
        
        # Si no hay VPC por defecto, obtener la primera VPC disponible
        $vpcs = aws ec2 describe-vpcs --region $Region --query 'Vpcs[0].VpcId' --output text
        if ($LASTEXITCODE -eq 0 -and $vpcs -ne "None") {
            return $vpcs
        }
        
        return $null
    } catch {
        return $null
    }
}

# --- Función para obtener subnets por defecto ---
function Get-DefaultSubnets {
    try {
        $vpcId = Get-DefaultVPC
        if (-not $vpcId) { return $null }
        
        $subnets = aws ec2 describe-subnets --region $Region --filters "Name=vpc-id,Values=$vpcId" --query 'Subnets[?MapPublicIpOnLaunch==`true`].SubnetId' --output json | ConvertFrom-Json
        if ($subnets.Count -ge 2) {
            return $subnets[0..1]  # Retorna las primeras 2 subnets
        }
        return $null
    } catch {
        return $null
    }
}

# --- Función para esperar con timeout ---
function Wait-StackWithTimeout {
    param(
        [string]$StackName,
        [string]$Region,
        [int]$TimeoutMinutes = 30
    )
    
    $startTime = Get-Date
    $timeout = $startTime.AddMinutes($TimeoutMinutes)
    
    Write-Host "   Esperando creacion del stack (timeout: $TimeoutMinutes minutos)..." -ForegroundColor Yellow
    
    while ((Get-Date) -lt $timeout) {
        try {
            $stackStatus = aws cloudformation describe-stacks --stack-name $StackName --region $Region --query 'Stacks[0].StackStatus' --output text 2>$null
            
            if ($LASTEXITCODE -eq 0) {
                if ($stackStatus -eq "CREATE_COMPLETE") {
                    Write-Host "   ✅ Stack $StackName creado exitosamente" -ForegroundColor Green
                    return $true
                }
                elseif ($stackStatus -eq "CREATE_FAILED" -or $stackStatus -like "*_FAILED") {
                    Write-Host "   ❌ Stack $StackName fallo con estado: $stackStatus" -ForegroundColor Red
                    
                    # Obtener eventos de error
                    Write-Host "   Buscando detalles del error..." -ForegroundColor Yellow
                    aws cloudformation describe-stack-events --stack-name $StackName --region $Region --query 'StackEvents[?ResourceStatus==`CREATE_FAILED`]' --output table 2>$null
                    return $false
                }
                elseif ($stackStatus -eq "ROLLBACK_COMPLETE") {
                    Write-Host "   ❌ Stack $StackName hizo rollback completo" -ForegroundColor Red
                    return $false
                }
            }
            
            # Mostrar progreso cada 2 minutos
            $elapsed = [int]((Get-Date) - $startTime).TotalMinutes
            if ($elapsed % 2 -eq 0) {
                Write-Host "   Esperando... ($elapsed minutos transcurridos)" -ForegroundColor Gray
            }
            
            Start-Sleep -Seconds 30
        }
        catch {
            Write-Host "   Error verificando estado del stack: $($_.Exception.Message)" -ForegroundColor Yellow
            Start-Sleep -Seconds 30
        }
    }
    
    Write-Host "   ⚠️  Timeout esperando por el stack $StackName" -ForegroundColor Red
    return $false
}

# --- Verificar permisos primero ---
Write-Host "Verificando permisos..." -ForegroundColor Yellow
try {
    aws sts get-caller-identity | Out-Null
    Write-Host "✅ Autenticacion OK" -ForegroundColor Green
} catch {
    HandleError "No hay permisos de AWS. Verifica tu configuracion."
}

# --- Verificar que las carpetas y archivos existen ---
Write-Host "Verificando estructura de carpetas..." -ForegroundColor Yellow
$requiredFolders = @("./Coupled", "./Decoupled")
$requiredFiles = @(
    "./Decoupled/decoupleapi.yaml",
    "./Decoupled/Dockerfile", 
    "./Decoupled/index.js",
    "./Coupled/coupled-template.yaml",
    "./Coupled/Dockerfile",
    "./Coupled/index.js",
    "ecr-template.yaml"
)

foreach ($folder in $requiredFolders) {
    if (-not (Test-Path $folder)) {
        HandleError "No se encuentra la carpeta: $folder"
    }
}

foreach ($file in $requiredFiles) {
    if (-not (Test-Path $file)) {
        HandleError "No se encuentra el archivo: $file"
    }
}
Write-Host "✅ Estructura de carpetas y archivos verificada" -ForegroundColor Green

# --- Obtener VPC y Subnets por defecto ---
Write-Host "`nObteniendo VPC y subnets por defecto..." -ForegroundColor Yellow
$DefaultVpcId = Get-DefaultVPC
$DefaultSubnets = Get-DefaultSubnets

if (-not $DefaultVpcId) {
    HandleError "No se pudo encontrar una VPC por defecto. Crea una VPC manualmente."
}

if (-not $DefaultSubnets -or $DefaultSubnets.Count -lt 2) {
    HandleError "No se encontraron suficientes subnets publicas (se necesitan al menos 2)."
}

Write-Host "   VPC ID: $DefaultVpcId" -ForegroundColor Cyan
Write-Host "   Subnets: $($DefaultSubnets -join ', ')" -ForegroundColor Cyan

# --- Paso 1A: Crear repositorio ECR para LAMBDA ---
Write-Host "`n1A. CREANDO ECR PARA LAMBDA..." -ForegroundColor Yellow
try {
    Write-Host "   Creando stack de ECR Lambda..." -ForegroundColor Yellow
    aws cloudformation create-stack `
      --stack-name $LambdaECRStackName `
      --template-body file://ecr-template.yaml `
      --region $Region `
      --parameters ParameterKey=RepositoryName,ParameterValue=$LambdaRepoName `
      --capabilities CAPABILITY_NAMED_IAM
    
    if ($LASTEXITCODE -ne 0) {
        HandleError "No se pudo crear el stack de ECR Lambda. Verifica permisos."
    }
    
    if (-not (Wait-StackWithTimeout -StackName $LambdaECRStackName -Region $Region -TimeoutMinutes 10)) {
        HandleError "Fallo la creacion del stack ECR Lambda"
    }
} catch {
    HandleError "Error al crear el stack de ECR Lambda: $($_.Exception.Message)"
}

# --- Paso 1B: Crear repositorio ECR para ACOPLADA ---
Write-Host "`n1B. CREANDO ECR PARA ACOPLADA..." -ForegroundColor Yellow
try {
    Write-Host "   Creando stack de ECR Acoplada..." -ForegroundColor Yellow
    aws cloudformation create-stack `
      --stack-name $CoupledECRStackName `
      --template-body file://ecr-template.yaml `
      --region $Region `
      --parameters ParameterKey=RepositoryName,ParameterValue=$CoupledRepoName `
      --capabilities CAPABILITY_NAMED_IAM
    
    if ($LASTEXITCODE -ne 0) {
        HandleError "No se pudo crear el stack de ECR Acoplada. Verifica permisos."
    }
    
    if (-not (Wait-StackWithTimeout -StackName $CoupledECRStackName -Region $Region -TimeoutMinutes 10)) {
        HandleError "Fallo la creacion del stack ECR Acoplada"
    }
} catch {
    HandleError "Error al crear el stack de ECR Acoplada: $($_.Exception.Message)"
}

# --- Paso 2: Obtener URIs de los ECRs ---
Write-Host "`n2. OBTENIENDO URIs DE LOS ECRs..." -ForegroundColor Yellow

# Obtener URI ECR Lambda
$LambdaECR_URI = aws cloudformation describe-stacks `
    --stack-name $LambdaECRStackName `
    --region $Region `
    --query 'Stacks[0].Outputs[?OutputKey==`RepositoryURI`].OutputValue' `
    --output text

if ([string]::IsNullOrEmpty($LambdaECR_URI)) { 
    HandleError "No se pudo obtener la URI del repositorio ECR Lambda" 
}

# Obtener URI ECR Acoplada
$CoupledECR_URI = aws cloudformation describe-stacks `
    --stack-name $CoupledECRStackName `
    --region $Region `
    --query 'Stacks[0].Outputs[?OutputKey==`RepositoryURI`].OutputValue' `
    --output text

if ([string]::IsNullOrEmpty($CoupledECR_URI)) { 
    HandleError "No se pudo obtener la URI del repositorio ECR Acoplada" 
}

Write-Host "   ECR Lambda: $LambdaECR_URI" -ForegroundColor Cyan
Write-Host "   ECR Acoplada: $CoupledECR_URI" -ForegroundColor Cyan

# --- Paso 3: Login en ECRs ---
Write-Host "`n3. HACIENDO LOGIN EN ECRs..." -ForegroundColor Yellow
try {
    $ecrLogin = aws ecr get-login-password --region $Region
    if ($LASTEXITCODE -ne 0) {
        HandleError "No se pudo obtener password de ECR"
    }
    
    # Login para ambos ECRs (mismo servidor)
    $ECRServer = $LambdaECR_URI.Split("/")[0]
    $ecrLogin | docker login --username AWS --password-stdin $ECRServer
    if ($LASTEXITCODE -ne 0) {
        HandleError "Fallo en el login de Docker a ECR"
    }
    Write-Host "   ✅ Login exitoso para ambos ECRs" -ForegroundColor Green
} catch {
    HandleError "Fallo en el login de Docker a ECR: $($_.Exception.Message)"
}

# --- Paso 4A: Construir imagen Docker para LAMBDA ---
Write-Host "`n4A. CONSTRUYENDO IMAGEN DOCKER PARA LAMBDA..." -ForegroundColor Yellow
try {
    # Verificar si Docker esta funcionando
    docker version 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        HandleError "Docker no esta funcionando. Verifica que el Docker Desktop este ejecutandose."
    }
    
    Write-Host "   Usando Dockerfile: $LambdaDockerfilePath" -ForegroundColor Cyan
    Write-Host "   Contexto: ./Decoupled/" -ForegroundColor Cyan
    Write-Host "   Creando builder multi-platform..." -ForegroundColor Yellow
    docker buildx create --use --name multiarch-builder 2>&1 | Out-Null
    
    Write-Host "   Construyendo imagen Lambda para $TargetPlatform ..." -ForegroundColor Yellow
    docker buildx build --platform $TargetPlatform --load -t $LambdaImageName -f $LambdaDockerfilePath ./Decoupled/
    if ($LASTEXITCODE -ne 0) {
        HandleError "Fallo al construir la imagen Docker para Lambda"
    }
    Write-Host "   ✅ Imagen Lambda construida exitosamente" -ForegroundColor Green
} catch {
    HandleError "Fallo al construir la imagen Docker para Lambda: $($_.Exception.Message)"
}

# --- Paso 4B: Construir imagen Docker para ACOPLADA ---
Write-Host "`n4B. CONSTRUYENDO IMAGEN DOCKER PARA ACOPLADA..." -ForegroundColor Yellow
try {
    Write-Host "   Usando Dockerfile: $CoupledDockerfilePath" -ForegroundColor Cyan
    Write-Host "   Contexto: ./Coupled/" -ForegroundColor Cyan
    Write-Host "   Construyendo imagen Acoplada para $TargetPlatform ..." -ForegroundColor Yellow
    docker buildx build --platform $TargetPlatform --load -t $CoupledImageName -f $CoupledDockerfilePath ./Coupled/
    if ($LASTEXITCODE -ne 0) {
        HandleError "Fallo al construir la imagen Docker para Acoplada"
    }
    Write-Host "   ✅ Imagen Acoplada construida exitosamente" -ForegroundColor Green
} catch {
    HandleError "Fallo al construir la imagen Docker para Acoplada: $($_.Exception.Message)"
}

# --- Paso 5A: Taggear y subir imagen LAMBDA a su ECR ---
Write-Host "`n5A. SUBIENDO IMAGEN LAMBDA A ECR LAMBDA..." -ForegroundColor Yellow
try {
    Write-Host "   Taggeando imagen Lambda..." -ForegroundColor Yellow
    docker tag "${LambdaImageName}:latest" "${LambdaECR_URI}:latest"
    
    Write-Host "   Subiendo imagen Lambda a ECR..." -ForegroundColor Yellow
    docker push "${LambdaECR_URI}:latest"
    
    if ($LASTEXITCODE -ne 0) {
        HandleError "Fallo al subir la imagen Lambda a ECR"
    }
    Write-Host "   ✅ Imagen Lambda subida exitosamente a $LambdaECR_URI" -ForegroundColor Green
} catch {
    HandleError "Fallo al subir la imagen Lambda a ECR: $($_.Exception.Message)"
}

# --- Paso 5B: Taggear y subir imagen ACOPLADA a su ECR ---
Write-Host "`n5B. SUBIENDO IMAGEN ACOPLADA A ECR ACOPLADA..." -ForegroundColor Yellow
try {
    Write-Host "   Taggeando imagen Acoplada..." -ForegroundColor Yellow
    docker tag "${CoupledImageName}:latest" "${CoupledECR_URI}:latest"
    
    Write-Host "   Subiendo imagen Acoplada a ECR..." -ForegroundColor Yellow
    docker push "${CoupledECR_URI}:latest"
    
    if ($LASTEXITCODE -ne 0) {
        HandleError "Fallo al subir la imagen Acoplada a ECR"
    }
    Write-Host "   ✅ Imagen Acoplada subida exitosamente a $CoupledECR_URI" -ForegroundColor Green
} catch {
    HandleError "Fallo al subir la imagen Acoplada a ECR: $($_.Exception.Message)"
}

# --- Paso 6A: Desplegar version DESACOPLADA (Lambda) ---
Write-Host "`n6A. DESPLEGANDO VERSION DESACOPLADA (LAMBDA)..." -ForegroundColor Yellow
try {
    Write-Host "   Creando stack de Lambda..." -ForegroundColor Yellow
    Write-Host "   Usando imagen: ${LambdaECR_URI}:latest" -ForegroundColor Cyan
    
    aws cloudformation create-stack `
      --stack-name $LambdaStackName `
      --template-body file://Decoupled/decoupleapi.yaml `
      --region $Region `
      --parameters ParameterKey=ImageUri,ParameterValue="${LambdaECR_URI}:latest" `
      --capabilities CAPABILITY_IAM
      
    if ($LASTEXITCODE -ne 0) {
        HandleError "No se pudo crear el stack de Lambda. Verifica el template."
    }
    
    if (-not (Wait-StackWithTimeout -StackName $LambdaStackName -Region $Region -TimeoutMinutes 15)) {
        Write-Host "   ⚠️  Continuando con despliegue acoplado a pesar del error en Lambda..." -ForegroundColor Yellow
        $LambdaSuccess = $false
    } else {
        $LambdaSuccess = $true
        Write-Host "   ✅ Stack de Lambda creado exitosamente" -ForegroundColor Green
    }
} catch {
    Write-Host "   ⚠️  Error en despliegue Lambda: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host "   Continuando con arquitectura acoplada..." -ForegroundColor Yellow
    $LambdaSuccess = $false
}

# --- Paso 6B: Desplegar version ACOPLADA (ECS + NLB + VPC Link) ---
Write-Host "`n6B. DESPLEGANDO VERSION ACOPLADA (ECS + NLB + VPC Link)..." -ForegroundColor Yellow
try {
    Write-Host "   Creando stack acoplado (esto puede tomar 15-20 minutos)..." -ForegroundColor Yellow
    Write-Host "   Incluyendo: VPC, ECS, NLB, VPC Link, API Gateway" -ForegroundColor Cyan
    Write-Host "   Usando imagen: ${CoupledECR_URI}:latest" -ForegroundColor Cyan
    Write-Host "   Usando subnets por defecto del template YAML" -ForegroundColor Cyan

    # Crear stack SOLO con los parámetros esenciales - SubnetIds ya tiene valor por defecto
    aws cloudformation create-stack `
      --stack-name $CoupledStackName `
      --template-body file://Coupled/coupled-template.yaml `
      --region $Region `
      --parameters `
        ParameterKey=ImageUri,ParameterValue="${CoupledECR_URI}:latest" `
        ParameterKey=VpcId,ParameterValue=$DefaultVpcId `
        ParameterKey=ImageName,ParameterValue=$CoupledImageName `
        ParameterKey=DBType,ParameterValue="postgresql" `
        ParameterKey=DBHost,ParameterValue="localhost" `
        ParameterKey=DBName,ParameterValue="mydb" `
        ParameterKey=DBUser,ParameterValue="user" `
        ParameterKey=DBPass,ParameterValue="pass" `
        ParameterKey=DBDynamoName,ParameterValue="users-table" `
      --capabilities CAPABILITY_IAM
    
    if ($LASTEXITCODE -ne 0) {
        HandleError "No se pudo crear el stack acoplado. Verifica el template YAML."
    }
    
    Write-Host "   Esperando creacion del stack acoplado..." -ForegroundColor Yellow
    Write-Host "   ⏱️  Esta operacion puede tomar 15-20 minutos por el VPC Link y NLB" -ForegroundColor Yellow
    
    if (-not (Wait-StackWithTimeout -StackName $CoupledStackName -Region $Region -TimeoutMinutes 25)) {
        Write-Host "   ⚠️  Stack acoplado tuvo problemas, pero continuando..." -ForegroundColor Yellow
        $CoupledSuccess = $false
    } else {
        $CoupledSuccess = $true
        Write-Host "   ✅ Stack acoplado creado exitosamente" -ForegroundColor Green
    }
} catch {
    Write-Host "   ❌ Error critico en despliegue acoplado: $($_.Exception.Message)" -ForegroundColor Red
    $CoupledSuccess = $false
}

# --- Paso 7: Obtener resultados de AMBAS arquitecturas ---
Write-Host "`n7. OBTENIENDO RESULTADOS..." -ForegroundColor Yellow

# Resultados para version desacoplada
$LambdaApiUrl = $null
if ($LambdaSuccess) {
    try {
        $LambdaOutputs = aws cloudformation describe-stacks `
            --stack-name $LambdaStackName `
            --region $Region `
            --query 'Stacks[0].Outputs' `
            --output json | ConvertFrom-Json
        
        $LambdaApiUrl = $LambdaOutputs | Where-Object { $_.OutputKey -eq "ApiUrl" } | Select-Object -ExpandProperty OutputValue
        Write-Host "   ✅ Outputs de Lambda obtenidos" -ForegroundColor Green
    } catch {
        Write-Host "   ⚠️  No se pudieron obtener outputs de Lambda" -ForegroundColor Yellow
    }
}

# Resultados para version acoplada  
$CoupledApiUrl = $null
if ($CoupledSuccess) {
    try {
        $CoupledOutputs = aws cloudformation describe-stacks `
            --stack-name $CoupledStackName `
            --region $Region `
            --query 'Stacks[0].Outputs' `
            --output json | ConvertFrom-Json
        
        $CoupledApiUrl = $CoupledOutputs | Where-Object { $_.OutputKey -eq "ApiUrl" } | Select-Object -ExpandProperty OutputValue
        Write-Host "   ✅ Outputs de arquitectura acoplada obtenidos" -ForegroundColor Green
    } catch {
        Write-Host "   ⚠️  No se pudieron obtener outputs de la version acoplada" -ForegroundColor Yellow
    }
}

# Obtener URLs de fallback si es necesario
if ([string]::IsNullOrEmpty($LambdaApiUrl)) { 
    $LambdaApiUrl = (aws cloudformation describe-stacks --stack-name $LambdaStackName --region $Region --query 'Stacks[0].Outputs[?OutputKey==`ApiUrl`].OutputValue' --output text 2>$null)
    if ([string]::IsNullOrEmpty($LambdaApiUrl)) { $LambdaApiUrl = "http://ERROR-LAMBDA-URL" }
}

if ([string]::IsNullOrEmpty($CoupledApiUrl)) { 
    $CoupledApiUrl = (aws cloudformation describe-stacks --stack-name $CoupledStackName --region $Region --query 'Stacks[0].Outputs[?OutputKey==`ApiUrl`].OutputValue' --output text 2>$null)
    if ([string]::IsNullOrEmpty($CoupledApiUrl)) { $CoupledApiUrl = "http://ERROR-COUPLED-URL" }
}

Write-Host "   API Lambda URL: $LambdaApiUrl" -ForegroundColor Cyan
Write-Host "   API Acoplada URL: $CoupledApiUrl" -ForegroundColor Cyan

