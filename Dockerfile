FROM public.ecr.aws/lambda/nodejs:18

WORKDIR ${LAMBDA_TASK_ROOT}

COPY package*.json ./
RUN npm install

# Copiar backend y frontend
COPY index.js ./


CMD [ "index.handler" ]