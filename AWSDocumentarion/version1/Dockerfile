FROM public.ecr.aws/lambda/python:3.9

# Copiar archivos al contenedor
COPY app.py ${LAMBDA_TASK_ROOT}
COPY requirements.txt .

# Instalar dependencias si existen
RUN pip install -r requirements.txt

# Comando para Lambda
CMD ["app.lambda_handler"]