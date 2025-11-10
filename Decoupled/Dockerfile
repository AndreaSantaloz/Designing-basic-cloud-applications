FROM public.ecr.aws/lambda/nodejs:18
WORKDIR ${LAMBDA_TASK_ROOT}

# Copiar package.json desde la MISMA carpeta
COPY package*.json ./
RUN npm install --production

# Copiar el código de la aplicación  
COPY . .

CMD [ "index.handler" ]