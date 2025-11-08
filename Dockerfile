FROM public.ecr.aws/lambda/nodejs:18

# Copiar archivos de la aplicación
COPY package*.json ./
RUN npm install

# Copiar el código
COPY . .

# Comando que Lambda ejecutará
CMD [ "lambda.handler" ]