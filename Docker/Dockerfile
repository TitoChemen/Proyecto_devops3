# --- ETAPA 1: Construcción (Builder) ---
FROM maven:3.9-eclipse-temurin-21-alpine AS builder
WORKDIR /build

# Copiamos los archivos desde la carpeta backend hacia el contenedor
COPY ../backend/pom.xml .
COPY ../backend/src ./src

# Compilamos el proyecto
RUN mvn clean package -DskipTests

# --- ETAPA 2: Ejecución (Runtime) ---
# Usamos JRE Alpine para que la imagen sea ligera y rápida en AWS
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

# Copiamos el .jar generado en la etapa de construcción
COPY --from=builder /build/target/*.jar app.jar

# Exponemos el puerto que configuraste en tu app
EXPOSE 8081

ENTRYPOINT ["java", "-jar", "app.jar"]