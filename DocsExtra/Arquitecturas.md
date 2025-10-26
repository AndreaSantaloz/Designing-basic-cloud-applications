# 🏗️ Arquitectura Acoplada vs Desacoplada en AWS

En **Amazon Web Services (AWS)** —y en arquitectura de sistemas en general— los términos **arquitectura acoplada** y **arquitectura desacoplada** describen **cómo interactúan y dependen entre sí los componentes de una aplicación**.

---

## 🔗 Arquitectura Acoplada

Una **arquitectura acoplada (tightly coupled)** es aquella donde los componentes están **fuertemente interconectados** y **dependen directamente unos de otros**.

### 🔍 Características
- Los componentes deben **estar disponibles al mismo tiempo** para que el sistema funcione.
- Un cambio en un componente puede **afectar directamente a los demás**.
- La comunicación suele ser **sincrónica** (por ejemplo, una llamada directa HTTP/REST).
- Dificulta la **escalabilidad y la resiliencia**.

### 🧩 Ejemplo en AWS
Supón una aplicación web donde:
- El servidor web (EC2) llama directamente al servidor de base de datos (RDS) para cada solicitud.
- Si la base de datos falla o se retrasa, la aplicación completa se detiene.

**Problema:**  
Si la base de datos está sobrecargada, todo el sistema sufre, y escalar o actualizar uno de los componentes es difícil.

---

## ☁️ Arquitectura Desacoplada

Una **arquitectura desacoplada (loosely coupled)** separa los componentes de modo que **no dependen directamente entre sí**.  
En AWS, esto se logra mediante **servicios intermedios de mensajería o colas**, **funciones serverless**, o **APIs administradas**.

### 🔍 Características
- Los componentes pueden **funcionar y escalar de forma independiente**.
- Comunicación generalmente **asíncrona** (no necesitan respuesta inmediata).
- Aumenta la **resiliencia** y **flexibilidad**.
- Facilita la **evolución** del sistema (puedes cambiar un componente sin romper todo).

### 🧩 Ejemplo en AWS
Supón una aplicación de procesamiento de imágenes:

1. El usuario sube una imagen a **Amazon S3**.  
2. Esto genera un evento que activa una **AWS Lambda**.  
3. La Lambda envía un mensaje a una cola en **Amazon SQS**.  
4. Otro servicio (por ejemplo, un worker en **ECS**) procesa la imagen cuando puede.

**Ventajas:**
- Si un servicio está temporalmente inactivo, los mensajes se acumulan en la cola.  
- Cada parte escala de forma independiente (por ejemplo, Lambda escala automáticamente).  
- No hay dependencias directas entre componentes.

---

## ⚖️ Comparación rápida

| Aspecto | Arquitectura Acoplada | Arquitectura Desacoplada |
|----------|-----------------------|---------------------------|
| **Comunicación** | Directa (sincrónica) | Indirecta (asíncrona) |
| **Dependencias** | Fuertes | Mínimas |
| **Escalabilidad** | Limitada | Alta |
| **Resiliencia** | Baja | Alta |
| **Ejemplo AWS** | EC2 ↔ RDS | S3 → Lambda → SQS → ECS |

---

> 💡 **Conclusión:**  
> En AWS, las arquitecturas **desacopladas** son preferibles para aplicaciones modernas, escalables y tolerantes a fallos.  
> Usar servicios como **SQS**, **SNS**, **EventBridge**, **Lambda** y **S3** permite construir sistemas **resilientes y fácilmente mantenibles**.

---
