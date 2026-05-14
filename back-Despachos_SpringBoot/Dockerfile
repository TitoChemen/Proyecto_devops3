FROM openjdk:17-jdk-slim
WORKDIR /app
COPY target/*.jar app.jar

# Exponemos un puerto distinto para evitar colisiones en local
EXPOSE 8081

ENTRYPOINT ["java", "-jar", "app.jar"]