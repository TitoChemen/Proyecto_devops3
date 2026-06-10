# 🚀 Aprovisionamiento de Infraestructura y Despliegue Automatizado - Innovatech Chile (EP3)

Este repositorio contiene el código de Infraestructura como Código (IaC) en Terraform, la configuración de contenedores y el pipeline automatizado de CI/CD para el despliegue orquestado del sistema de la empresa Innovatech Chile. Este proyecto cumple con los requerimientos avanzados de orquestación en la nube utilizando **Amazon EKS** para la Evaluación Parcial N°3.

---

## 🗺️ 1. Diagrama de Arquitectura de Red (EKS)

El diseño de la infraestructura ha evolucionado desde contenedores en una instancia EC2 única hacia un clúster de Kubernetes altamente disponible y escalable:

```text
       [ INTERNET ]
            │
            │ (Puerto 80)
            ▼
┌──────────────────────────────────────────────────┐
│ AWS EKS (innovatech-cluster)                     │
│                                                  │
│  ┌────────────────────────────────────────────┐  │
│  │ LoadBalancer (Servicio Público Frontend)   │  │
│  └──────┬─────────────────────────────────────┘  │
│         │ (Tráfico HTTP)                         │
│         ▼                                        │
│  ┌──────────────┐   (Red Interna ClusterIP)      │
│  │  Frontend    │ ────────────────────┐          │
│  │ (Pods React) │                     ▼          │
│  └──────────────┘              ┌──────────────┐  │
│                                │   Backends   │  │
│  [ Horizontal Pod Autoscaler]  │(Pods Spring) │  │
│  [   Metrics Server AWS     ]  └──────────────┘  │
│                                                  │
└──────────────────────────────────────────────────┘

📁 2. Estructura del Repositorio
A continuación se detalla la organización de los archivos del proyecto en la rama deploy

📂 proyecto-devops3/
 ├── 📂 .github/
 │    └── 📂 workflows/
 │         └── 📄 ci.yml                  # Pipeline de GitHub Actions (Build, ECR Push, EKS Deploy)
 ├── 📂 back-Despachos_SpringBoot/        # Microservicio de Despachos (Backend Java/Spring)
 ├── 📂 back-Ventas_SpringBoot/           # Microservicio de Ventas (Backend Java/Spring)
 ├── 📂 front_despacho/                   # Aplicación Single Page (Frontend React)
 ├── 📂 k8s/                              # Manifiestos de Kubernetes (Opcional/Generados)
 │    ├── 📄 deployments.yaml             # Configuración de Pods y Réplicas
 │    ├── 📄 services.yaml                # LoadBalancers y ClusterIPs
 │    └── 📄 hpa.yaml                     # Horizontal Pod Autoscaler
 ├── 📂 infra/                            # Código de Infraestructura como Código (IaC)
 │    ├── 📄 main.tf                      # Recursos principales (EKS, VPC, Subnets, ECR)
 │    └── 📄 outputs.tf                   # Salidas de datos (Nombre Clúster, URLs Repos)
 └── 📄 README.md                         # Documentación técnica principal


 🛠️ 3. Componentes del Stack y Orquestación
El stack de servicios ahora es administrado de forma nativa por Kubernetes, aislando la comunicación interna y exponiendo solo lo necesario:

Backends (Ventas y Despachos): APIs REST en Spring Boot, desplegadas como Pods en EKS y comunicadas de forma interna a través de servicios tipo ClusterIP.

Frontend: Aplicación optimizada expuesta de cara al público mediante un balanceador de carga (LoadBalancer) provisto automáticamente por AWS EKS.

Seguridad (Secrets): Las credenciales sensibles, como las contraseñas de las bases de datos, son inyectadas a los Pods mediante Kubernetes Secrets, evitando la exposición en texto plano en el repositorio.

⚙️ 4. Escalabilidad y Monitoreo (HPA)
Para garantizar la disponibilidad ante picos de tráfico, el clúster implementa:

Metrics Server: Recopila datos de uso de recursos en tiempo real de los nodos y pods.

Horizontal Pod Autoscaler (HPA): Configurado para escalar automáticamente el número de réplicas de los microservicios si el consumo de CPU o Memoria supera el umbral establecido.

🚀 5. Pipeline de Integración y Despliegue Continuo (CI/CD)
La automatización completa está implementada en GitHub Actions.

Flujo de Trabajo:

Trigger: Se activa al realizar un push o merge sobre la rama deploy.

Build & Push a ECR: Compila las imágenes de Docker optimizadas (Multi-stage build) y las publica en los repositorios privados de Amazon ECR.

Deploy a EKS: Actualiza el contexto de kubectl, aplica los manifiestos actualizados y fuerza un reinicio progresivo (Rolling Update) en el clúster sin interrumpir el servicio.

💻 6. Guía de Despliegue Paso a Paso
A. Despliegue de Infraestructura (Terraform)
Para aprovisionar los recursos en AWS, navegue a la carpeta de infraestructura y ejecute:

cd infra/terraform
terraform init
terraform plan
terraform apply


B. Conexión y Configuración del Clúster EKS
Una vez que Terraform termine, conecte su terminal al clúster e instale las dependencias clave:

# 1. Actualizar Kubeconfig
aws eks update-kubeconfig --region us-east-1 --name innovatech-cluster

# 2. Crear Secreto de Base de Datos
kubectl create secret generic db-passwords --from-literal=mysql-root-password=root

# 3. Instalar Metrics Server (Requerido para Autoscaling)
kubectl apply -f [https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml](https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml)

C. Validación
Verifique que los servicios estén corriendo y obtenga la URL pública de la aplicación:

kubectl get pods
kubectl get svc frontend-svc

D. Destrucción del Entorno
Para no consumir créditos de AWS Academy, elimine la infraestructura al terminar:

terraform destroy --auto-approve


📅 7. Gestión de Proyecto y Cultura DevOps (Trello)
Para la planificación, asignación de tareas y trazabilidad del trabajo en dupla, se aplicaron prácticas de metodologías ágiles mediante un tablero Kanban en Trello.

https://trello.com/invite/b/69aefef59cf3eab029cee866/ATTI8c958a86b45801b7b99f603c4e2da4c6FC4B08EB/innovatech-sistema-despachos-ventas

