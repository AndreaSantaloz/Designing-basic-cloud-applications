# 1. IMAGEN BASE
FROM python:3.10-alpine 
# 2. DIRECTORIO DE TRABAJO
WORKDIR /app 
# 3. COPIA DE CÓDIGO
# Copia la carpeta y archivos desde el contexto (la carpeta 'app' de tu PC)
COPY . . 
# 4. COMANDO DE EJECUCIÓN
# Ejecuta el script usando su ruta ABSOLUTA
CMD ["python", "/app/Model/employee.py"]