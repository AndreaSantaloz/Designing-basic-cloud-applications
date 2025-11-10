# ==============================================================================
# CONFIGURACIÓN SERVERLESS - ARQUITECTURA LAMBDA
# ==============================================================================
$LambdaECRStackName = "mi-ecr-stack-lambda"
$LambdaStackName = "lambdas-stack"
$Region = "us-east-1"
$LambdaRepoName = "mi-repositorio-lambda"
$LambdaImageName = "mi-aplicacion-lambda"
$LambdaDockerfilePath = "./Decoupled/Dockerfile"
$TargetPlatform = "linux/amd64"

Write-Host "=== INICIANDO DESPLIEGUE SERVERLESS (LAMBDA) ===" -ForegroundColor Green
Write-Host "ECR + Lambda + API Gateway" -ForegroundColor Cyan

# --- Función de manejo de errores ---
function HandleError {
    param([string]$Message)
    Write-Host "ERROR: $Message" -ForegroundColor Red
    exit 1
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
$requiredFiles = @(
    "./Decoupled/decoupleapi.yaml",
    "./Decoupled/Dockerfile", 
    "./Decoupled/index.js",
    "ecr-template.yaml"
)

foreach ($file in $requiredFiles) {
    if (-not (Test-Path $file)) {
        HandleError "No se encuentra el archivo: $file"
    }
}
Write-Host "✅ Estructura de archivos verificada" -ForegroundColor Green

# --- Paso 1: Crear repositorio ECR para LAMBDA ---
Write-Host "`n1. CREANDO ECR PARA LAMBDA..." -ForegroundColor Yellow
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

# --- Paso 2: Obtener URI del ECR ---
Write-Host "`n2. OBTENIENDO URI DEL ECR..." -ForegroundColor Yellow

$LambdaECR_URI = aws cloudformation describe-stacks `
    --stack-name $LambdaECRStackName `
    --region $Region `
    --query 'Stacks[0].Outputs[?OutputKey==`RepositoryURI`].OutputValue' `
    --output text

if ([string]::IsNullOrEmpty($LambdaECR_URI)) { 
    HandleError "No se pudo obtener la URI del repositorio ECR Lambda" 
}

Write-Host "   ECR Lambda: $LambdaECR_URI" -ForegroundColor Cyan

# --- Paso 3: Login en ECR ---
Write-Host "`n3. HACIENDO LOGIN EN ECR..." -ForegroundColor Yellow
try {
    $ecrLogin = aws ecr get-login-password --region $Region
    if ($LASTEXITCODE -ne 0) {
        HandleError "No se pudo obtener password de ECR"
    }
    
    # Login para ECR
    $ECRServer = $LambdaECR_URI.Split("/")[0]
    $ecrLogin | docker login --username AWS --password-stdin $ECRServer
    if ($LASTEXITCODE -ne 0) {
        HandleError "Fallo en el login de Docker a ECR"
    }
    Write-Host "   ✅ Login exitoso para ECR" -ForegroundColor Green
} catch {
    HandleError "Fallo en el login de Docker a ECR: $($_.Exception.Message)"
}

# --- Paso 4: Construir imagen Docker para LAMBDA ---
Write-Host "`n4. CONSTRUYENDO IMAGEN DOCKER PARA LAMBDA..." -ForegroundColor Yellow
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

# --- Paso 5: Taggear y subir imagen LAMBDA a ECR ---
Write-Host "`n5. SUBIENDO IMAGEN LAMBDA A ECR..." -ForegroundColor Yellow
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

# --- Paso 6: Desplegar version SERVERLESS (Lambda) ---
Write-Host "`n6. DESPLEGANDO VERSION SERVERLESS (LAMBDA)..." -ForegroundColor Yellow
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
        HandleError "Fallo la creacion del stack Lambda"
    }
    
    Write-Host "   ✅ Stack de Lambda creado exitosamente" -ForegroundColor Green
} catch {
    HandleError "Error en despliegue Lambda: $($_.Exception.Message)"
}

# --- Paso 7: Obtener URL de la API Lambda ---
Write-Host "`n7. OBTENIENDO URL DE LA API LAMBDA..." -ForegroundColor Yellow

$LambdaApiUrl = $null
try {
    $LambdaApiUrl = aws cloudformation describe-stacks `
        --stack-name $LambdaStackName `
        --region $Region `
        --query 'Stacks[0].Outputs[?OutputKey==`ApiUrl`].OutputValue' `
        --output text

    if ([string]::IsNullOrEmpty($LambdaApiUrl)) { 
        $LambdaApiUrl = "http://ERROR-LAMBDA-URL"
        Write-Host "   ⚠️  No se pudo obtener la URL de la API Lambda" -ForegroundColor Yellow
    } else {
        Write-Host "   ✅ URL de API Lambda obtenida" -ForegroundColor Green
    }
} catch {
    Write-Host "   ⚠️  No se pudieron obtener outputs de Lambda" -ForegroundColor Yellow
    $LambdaApiUrl = "http://ERROR-LAMBDA-URL"
}

Write-Host "   API Lambda URL: $LambdaApiUrl" -ForegroundColor Cyan

# --- Paso 8: Generar archivo de prueba y lanzar ---
Write-Host "`n8. GENERANDO ARCHIVO DE PRUEBA Y LANZANDO..." -ForegroundColor Yellow

function Generate-TestFile {
    param([string]$ApiUrl)
    
    $BaseHtmlPath = "./frontend/index.html"
    
    if (-not (Test-Path $BaseHtmlPath)) {
        Write-Host "   ⚠️  No se encontró el archivo HTML base, creando uno básico..." -ForegroundColor Yellow
        
        # Crear un archivo HTML básico si no existe
        $BasicHtml = @"
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestión de Usuarios (SERVERLESS - LAMBDA)</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .container { max-width: 800px; margin: 0 auto; }
        .form-group { margin-bottom: 15px; }
        label { display: block; margin-bottom: 5px; }
        input, button { padding: 8px; margin: 5px 0; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Gestión de Usuarios (SERVERLESS - LAMBDA)</h1>
        
        <div class="form-group">
            <h3>Agregar Usuario</h3>
            <input type="text" id="name" placeholder="Nombre" />
            <input type="email" id="email" placeholder="Email" />
            <button onclick="addUser()">Agregar Usuario</button>
        </div>

        <div class="form-group">
            <h3>Buscar Usuario</h3>
            <input type="text" id="searchId" placeholder="ID de usuario" />
            <button onclick="getUser()">Buscar Usuario</button>
        </div>

        <div>
            <h3>Lista de Usuarios</h3>
            <button onclick="getAllUsers()">Cargar Todos los Usuarios</button>
            <table id="usersTable">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Nombre</th>
                        <th>Email</th>
                        <th>Acciones</th>
                    </tr>
                </thead>
                <tbody id="usersTableBody">
                </tbody>
            </table>
        </div>

        <div id="response" style="margin-top: 20px; padding: 10px; background-color: #f9f9f9; border-radius: 5px;"></div>
    </div>

    <script>
        const API_URL = '$ApiUrl';

        async function addUser() {
            const name = document.getElementById('name').value;
            const email = document.getElementById('email').value;
            
            try {
                const response = await fetch(API_URL + '/users', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify({ name, email })
                });
                
                const result = await response.json();
                document.getElementById('response').innerHTML = '<strong>Respuesta:</strong> ' + JSON.stringify(result);
                
                // Limpiar campos
                document.getElementById('name').value = '';
                document.getElementById('email').value = '';
                
                // Recargar lista
                getAllUsers();
            } catch (error) {
                document.getElementById('response').innerHTML = '<strong>Error:</strong> ' + error.message;
            }
        }

        async function getUser() {
            const id = document.getElementById('searchId').value;
            
            try {
                const response = await fetch(API_URL + '/users/' + id);
                const result = (await response.json()).data;
                document.getElementById('response').innerHTML = '<strong>Respuesta:</strong> ' + JSON.stringify(result);
            } catch (error) {
                document.getElementById('response').innerHTML = '<strong>Error:</strong> ' + error.message;
            }
        }

        async function getAllUsers() {
            try {
                const response = await fetch(API_URL + '/users');
                const users = (await response.json()).data;
                
                const tableBody = document.getElementById('usersTableBody');
                tableBody.innerHTML = '';
                
                users.forEach(user => {
                    const row = tableBody.insertRow();
                    row.insertCell(0).textContent = user.id || user.userId;
                    row.insertCell(1).textContent = user.name;
                    row.insertCell(2).textContent = user.email;
                    
                    const actionsCell = row.insertCell(3);
                    actionsCell.innerHTML = '<button onclick="deleteUser(\'' + (user.id || user.userId) + '\')">Eliminar</button>';
                });
                
                document.getElementById('response').innerHTML = '<strong>Total usuarios:</strong> ' + users.length;
            } catch (error) {
                document.getElementById('response').innerHTML = '<strong>Error:</strong> ' + error.message;
            }
        }

        async function deleteUser(id) {
            try {
                const response = await fetch(API_URL + '/users/' + id, {
                    method: 'DELETE'
                });
                
                const result = await response.json();
                document.getElementById('response').innerHTML = '<strong>Respuesta:</strong> ' + JSON.stringify(result);
                
                // Recargar lista
                getAllUsers();
            } catch (error) {
                document.getElementById('response').innerHTML = '<strong>Error:</strong> ' + error.message;
            }
        }

        // Cargar usuarios al iniciar
        getAllUsers();
    </script>
</body>
</html>
"@
        $BasicHtml | Out-File $BaseHtmlPath -Encoding UTF8
    } else {
        $BaseContent = Get-Content $BaseHtmlPath -Raw
    }
    
    # Generar archivo para Lambda
    if (Test-Path $BaseHtmlPath) {
        $BaseContent = Get-Content $BaseHtmlPath -Raw
        $LambdaContent = $BaseContent -replace "const API_URL = 'http://localhost:3000';", "const API_URL = '$ApiUrl';"
        $LambdaContent = $LambdaContent -replace "Gestión de Usuarios", "Gestión de Usuarios (SERVERLESS - LAMBDA)"
    } else {
        $LambdaContent = $BasicHtml
    }
    
    $LambdaFilePath = ".\lambda-serverless-test.html"
    $LambdaContent | Out-File $LambdaFilePath -Encoding UTF8
    Write-Host "   ✅ Archivo de prueba Lambda generado: $LambdaFilePath" -ForegroundColor Green

    return $LambdaFilePath
}

# Generar archivo de prueba
$TestFile = Generate-TestFile -ApiUrl $LambdaApiUrl

# Lanzar la prueba Serverless (Lambda)
if (Test-Path $TestFile) {
    Write-Host "   🌐 Abriendo Frontend Serverless..." -ForegroundColor Green
    Start-Process $TestFile
}

Write-Host "`n=== DESPLIEGUE SERVERLESS COMPLETADO ===" -ForegroundColor Green
