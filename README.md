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
