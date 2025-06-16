
FROM eclipse-temurin:17-jdk
WORKDIR /app
COPY target/deeptrain-backend.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]