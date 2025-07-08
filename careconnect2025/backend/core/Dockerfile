# Build stage
FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /app
COPY . .
RUN mvn clean package -DskipTests

# Run stage (Debian-based JDK image)
FROM eclipse-temurin:17-jdk
WORKDIR /app

# Copy the jar from the build stage
COPY --from=build /app/target/*.jar app.jar

# Copy the .env file into the image
COPY .env .env

# Export environment variables from .env file
RUN apt-get update && apt-get install -y curl
RUN echo "export $(cat .env | xargs)" >> /etc/profile

# Run the app with environment variables loaded
ENTRYPOINT ["/bin/bash", "-c", ". /etc/profile && java -jar app.jar"]
