

# ☁️ Práctica de Computación en la Nube: Arquitecturas Acopladas y Desacopladas

## 📝 Introducción y Objetivo

El objetivo de esta práctica es desarrollar una **aplicación de gestión de usuarios (CRUD: Crear, Leer, Actualizar, Eliminar)** implementándola bajo dos modelos de arquitectura distintos: **Acoplada** y **Desacoplada**.

Para ello, se han utilizado los siguientes componentes de código:

* **Templates de CloudFormation (YAML):**
    * `coupled-template.yaml` (Carpeta `/Coupled`): Define la arquitectura acoplada (ECS + NLB).
    * `decoupleapi.yaml` (Carpeta `/Decoupled`): Define la arquitectura desacoplada (Lambda + API Gateway).
    * `ecr-template.yaml`: Se utiliza dos veces para crear los repositorios **Amazon ECR** necesarios para alojar las imágenes Docker de ambas aplicaciones.
* **Código de Aplicación:** Cada arquitectura tiene su propia lógica (`index.js`, `package.json`) y definición de contenedor (`Dockerfile`).
* **Script de Automatización:** El *script* de PowerShell `finaldecouple.ps1` automatiza la creación de ambas arquitecturas en AWS.

Finalmente, una interfaz de usuario local interactuará con las URLs de ambas APIs para demostrar que la misma funcionalidad de *backend* puede ser ofrecida por arquitecturas radicalmente diferentes.

***

## 🐳 Arquitectura Acoplada: ECS, NLB y VPC Link

Este modelo define un servicio de usuarios tradicional basado en contenedores, utilizando **Amazon ECS con Fargate** como *backend*.

### Componentes Clave

* **Infraestructura de Red y Carga:**
    * **VPC, Subnets y Security Groups:** Se configuran para aislar y permitir el tráfico (`ECSSecurityGroup` permite el puerto **8080**).
    * **Network Load Balancer (NLB):** Un balanceador de carga interno (`users-nlb`) distribuye el tráfico.
    * **Target Group y Listener:** Dirigen el tráfico TCP del puerto 8080 hacia las tareas ECS, con chequeos de salud HTTP en `/health`.
* **Cómputo (ECS/Fargate):**
    * **ECS Cluster y Service:** Ejecuta la aplicación en contenedores Fargate (`users-cluster`, `users-service`).
    * **Task Definition:** Define los recursos (CPU/Memoria), la imagen Docker (`ImageUri`) y las credenciales de base de datos como **variables de entorno** (aunque en el ejemplo solo DynamoDB se usa, se incluyen variables simuladas para DB tradicional).
* **Acceso (API Gateway):**
    * **VPC Link:** Establece una conexión privada (`users-vpc-link`) para que **API Gateway** pueda alcanzar el **NLB interno**.
    * **Métodos HTTP (`HTTP_PROXY`):** El *frontend* de API Gateway se configura para actuar como *proxy* a través de la conexión **VPC\_LINK** hacia el NLB, enviando el tráfico a las rutas `/users` y `/users/{id}` del servicio ECS.

***

## 🚀 Arquitectura Desacoplada: Lambda y API Gateway (*Serverless*)

Este modelo utiliza un enfoque **"sin servidor" (*serverless*)** donde la escalabilidad y el mantenimiento son gestionados por AWS.

### Componentes Clave

* **Base de Datos:**
    * **DynamoDB (`UsersTable`):** Almacena los datos de usuario. Se utiliza `user_id` como clave y facturación bajo demanda (**PAY\_PER\_REQUEST**).
* **Lógica de Negocio (AWS Lambda):**
    * **Lambda Function (`UsersLambda`):** Define el *backend*. Se implementa utilizando una **Imagen de Contenedor** (`ImageUri`) para facilitar la portabilidad.
    * Recibe el nombre de la tabla DynamoDB como **variable de entorno**.
* **Acceso (API Gateway):**
    * **Lambda Invoke Permission:** Permiso crucial que autoriza a la API Gateway a invocar la función Lambda.
    * **Métodos HTTP (`AWS_PROXY`):** Todos los métodos CRUD (GET, POST, PUT, DELETE) se integran con la **misma función Lambda** mediante el tipo **`AWS_PROXY`**.
        * La solicitud HTTP completa se reenvía a la Lambda, que es responsable de **enrutar internamente** la petición (ej. `GET /users` vs `POST /users`).

***

## 📦 Creación de Repositorios (ECR-Template.YAML)

Este *template* se usa como molde para crear los registros de imágenes.

### Componentes Clave

* **ECR Repository:** Crea un registro privado para almacenar imágenes Docker.
* **Configuración:** Permite la **mutabilidad de *tags*** (`MUTABLE`) y activa el **escaneo de vulnerabilidades** (`ScanOnPush: true`) en cada subida de imagen.
* **Output:** Genera la **URI completa** del repositorio, necesaria para subir y referenciar la imagen en los *templates* de Lambda y ECS.

***

## ⚙️ Flujo de Despliegue (Script `finaldecouple.ps1`)

El *script* automatiza la orquestación de la infraestructura:

1.  **Validación:** Verifica permisos de AWS, la existencia de *Dockerfiles* y la disponibilidad de una **VPC por defecto** y dos subredes públicas.
2.  **Preparación de ECR:** Crea dos repositorios ECR separados (uno para Lambda, otro para ECS).
3.  **Construcción y *Push* de Imágenes:**
    * Realiza el *login* en ECR.
    * **Construye** las imágenes Docker por separado, usando sus respectivos *Dockerfiles* y contextos.
    * **Taggea** y **sube** cada imagen a su repositorio ECR asignado.
4.  **Despliegue Paralelo (CloudFormation):**
    * Lanza el *stack* de la **Arquitectura Desacoplada** (Lambda).
    * Lanza el *stack* de la **Arquitectura Acoplada** (ECS/NLB).
5.  **Finalización:** Espera la creación de ambos *stacks* y extrae las **URLs de las APIs** para la prueba final.

---




Buena — te doy un **análisis numérico y práctico** (con supuestos claros) para que tengas una idea razonable de **cuánto costaría mantener cada arquitectura 1 año** en us-east-1 usando los componentes del script (API Gateway + backend + DynamoDB + ECR + NLB/Fargate cuando aplica).

> **Importante:** estas son **estimaciones**. Cambios en tráfico, tamaño de payload, configuración de tareas Fargate, CloudWatch, backups, VPC endpoints, transferencias de datos inter-AZ o inter-región, snapshots, logs, etc. **pueden alterar** las cifras ± mucho. Yo dejo todos los supuestos explícitos para que puedas ajustarlos.

---

# 1) Supuestos usados (claros y reproducibles)

* Región: **us-east-1**.
* Escenarios de tráfico (requests *por mes*):

  * **Low:** 100.000 req/mes
  * **Medium:** 1.000.000 req/mes
  * **High:** 10.000.000 req/mes
* **Lambda** (desacoplada): memoria **0.5 GB**, duración promedio **200 ms** por invocación. Precio de cómputo: **$0.0000166667 / GB-s** y **$0.20 / 1M requests** (us-east-1). 
* **API Gateway (HTTP API)**: **~$1.00 / 1M requests** (primeros tramos). 
* **DynamoDB (On-Demand)**: costo por operaciones: **$0.625 / 1M writes**, **$0.125 / 1M reads**; asumí **0.5 write + 0.5 read** por request (mix 50/50). Storage supuse **1 GB** para la tabla (puedes ajustar). 

* **ECR**: storage **$0.10 / GB-mes**; supuse **10 GB** total (ambos repositorios). ([Amazon Web Services, Inc.][4])
* **ECS / Fargate (acoplada)**: para servir tráfico constante hecho estos supuestos de capacidad (24/7):

  * **Low:** 1 task (0.25 vCPU, 0.5 GB)
  * **Medium:** 2 tasks (cada una 0.25 vCPU, 0.5 GB)
  * **High:** 4 tasks (0.25 vCPU, 0.5 GB)
    Precios por segundo: **vCPU $0.000011244 / vCPU-s**, **mem $0.000001235 / GB-s** (Linux/x86). ([Amazon Web Services, Inc.][5])
* **NLB (Network Load Balancer)**: cargo fijo **$0.0225 / hr** 


---

# 2) Resultado: coste anual estimado (por arquitectura y escenario)

**Resumen anual (1 año)** — redondeado:

|       Escenario | Lambda (Serverless) — 1 año | ECS / Fargate + NLB — 1 año |
| --------------: | --------------------------: | --------------------------: |
|  Low (100k/mes) |             **≈ $19 / año** |            **≈ $318 / año** |
| Medium (1M/mes) |             **≈ $54 / año** |            **≈ $446 / año** |
|  High (10M/mes) |            **≈ $404 / año** |            **≈ $870 / año** |


 Explicación rápida: para tráfico **bajo/esporádico** Lambda suele ser mucho más barato porque pagas por invocación (+ API GW), mientras que Fargate/ECS incurre en coste fijo 24/7 (tareas + NLB). A medida que sube el tráfico sostenido, la diferencia se reduce; en algunos niveles el container puede volverse competitivo si necesitas baja latencia y conexiones persistentes. (Cálculos y fórmulas basadas en los precios oficiales citados arriba). 
