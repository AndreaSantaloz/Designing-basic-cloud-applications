
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