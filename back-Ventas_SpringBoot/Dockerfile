# Usamos una imagen base de Java 17
FROM openjdk:17-jdk-slim

# Directorio de trabajo dentro del contenedor
WORKDIR /app

# Copiamos el archivo JAR generado por Maven (asegúrate de hacer mvn clean package primero)
COPY target/*.jar app.jar

# Exponemos el puerto que usa este microservicio (ajusta si es distinto)
EXPOSE 8080

# Comando para ejecutar la aplicación
ENTRYPOINT ["java", "-jar", "app.jar"]