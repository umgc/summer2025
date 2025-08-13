# Build stage
FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /app
COPY . .
RUN mvn clean package -DskipTests -Pdefault

# Run stage (Debian-based JDK image)
FROM eclipse-temurin:17-jdk
WORKDIR /app

# Copy the jar from the build stage
COPY --from=build /app/target/*.jar app.jar


# Export environment variables from .env file
RUN apt-get update && apt-get install -y curl

COPY .env /app/.env
COPY env-entry.sh /app/env-entry.sh
RUN chmod +x /app/env-entry.sh
ENTRYPOINT ["/app/env-entry.sh"]