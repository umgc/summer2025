# ---------- build stage ----------
FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /app
COPY . .
RUN mvn -q -DskipTests clean package

# ---------- runtime stage ----------
FROM eclipse-temurin:17-jre-alpine
ENV SPRING_PROFILES_ACTIVE=prod \
    TZ=UTC
WORKDIR /app
COPY --from=build /app/target/*SNAPSHOT.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","app.jar"]
