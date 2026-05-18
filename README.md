# 🚀 Sistema de Gestión de Despachos e Infraestructura DevOps - Innovatech Chile

[cite_start]Este repositorio contiene la solución contenerizada y el flujo de automatización CI/CD para el despliegue del sistema de la empresa Innovatech Chile, cumpliendo estrictamente con los estándares y requerimientos técnicos exigidos en la Evaluación Parcial N°2[cite: 12, 26].

---

## 🛠️ 1. Arquitectura del Stack (Docker Compose)

[cite_start]El stack completo de servicios se administra de forma conjunta y centralizada mediante un archivo `docker-compose.yml`, aislando los componentes en una red interna tipo bridge (`red-interna`)[cite: 30, 92, 139]:

- [cite_start]**`proyecto-db`**: Contenedor con motor de base de datos MySQL 8.0, expuesto internamente en el puerto 3306[cite: 62].
- **`service-ventas`**: API REST construida en Spring Boot (Java 17), expuesta en el puerto 8080.
- **`service-despachos`**: API REST construida en Spring Boot (Java 17), expuesta en el puerto 8081.
- [cite_start]**`frontend`**: Aplicación web SPA montada sobre un servidor de producción optimizado con Nginx, expuesta en el puerto 80[cite: 56].

---

## 💾 2. Estrategia de Persistencia de Datos

[cite_start]Para garantizar la continuidad operativa del sistema y evitar la pérdida de información crítica tras el reinicio o la caída de los contenedores, se implementó un **Named Volume (Volumen con nombre)** administrado directamente por el daemon de Docker[cite: 33, 34, 101]:

```yaml
volumes:
  mysql_data:
```

---

## ⚙️ 3. Optimización de Contenedores (Dockerfile)

Cada microservicio implementa buenas prácticas de Dockerización en sus respectivos archivos para asegurar rendimiento y seguridad:

- [cite_start]**Multi-Stage Build**: Se separó la etapa de construcción de la de ejecución final[cite: 29, 91]. [cite_start]Esto permite que las imágenes en producción sean ultra-livianas (entornos Alpine), reduciendo el consumo de almacenamiento en las instancias t2.micro de AWS[cite: 91, 129, 140].
- [cite_start]**Principio de Mínimo Privilegio (Usuario No-Root)**: En el servicio de despachos, la imagen no ejecuta sus procesos como `root`[cite: 91, 129]. Se configuró la creación de un grupo y usuario exclusivo sin privilegios:
  ```dockerfile
  RUN addgroup -S devopsgroup && adduser -S devopsuser -G devopsgroup
  USER devopsuser
  ```

---

## 🚀 4. Pipeline de Integración y Despliegue Continuo (CI/CD)

[cite_start]La automatización completa del ciclo de vida del software está implementada en GitHub Actions mediante el workflow en `.github/workflows/ci.yml`[cite: 39, 104].

### Flujo de Trabajo:

1. [cite_start]**Disparador (Trigger)**: Se activa de manera exclusiva al realizar un `push` sobre la rama `deploy`[cite: 44, 113, 145].
2. [cite_start]**Etapa de Build & Push**: Autentica de forma segura usando GitHub Secrets (`AWS_ACCESS_KEY_ID`, etc.) [cite: 43, 114, 146][cite_start], compila y publica las imágenes en Amazon ECR[cite: 41, 111, 147].
3. [cite_start]**Etapa de Deploy (SSH & SCP)**: Conexión segura mediante SSH para transferir el `docker-compose.yml`[cite: 42, 112]. [cite_start]Descarga las nuevas versiones (`docker compose pull`) y levanta los servicios (`docker compose up -d`) en la EC2[cite: 42, 112, 148].

---

## 🏃‍♂️ 5. Instrucciones para Ejecución Local

Para levantar todo el ecosistema de manera local, ejecute en la raíz del proyecto:

```bash
docker compose up -d --build
```

---

## 📅 6. Gestión de Proyecto y Cultura DevOps (Trello)

Para la planificación, asignación de tareas y trazabilidad del trabajo en dupla, se aplicaron prácticas de metodologías ágiles mediante un tablero Kanban en Trello. Esto nos permitió gestionar el ciclo de vida del desarrollo (desde la dockerización hasta el despliegue continuo) con total visibilidad.

👉 **[Acceder al Tablero de Trello del Proyecto](https://trello.com/invite/b/69aefef59cf3eab029cee866/ATTI8c958a86b45801b7b99f603c4e2da4c6FC4B08EB/innovatech-sistema-despachos-ventas)**

---
