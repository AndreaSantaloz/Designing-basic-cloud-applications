FROM node:18-alpine
WORKDIR /app

# Copiar package.json desde la MISMA carpeta
COPY package*.json ./
RUN npm install --production

# Copiar el código de la aplicación
COPY . .

EXPOSE 8080
CMD [ "node", "index.js" ]