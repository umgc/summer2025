# CareConnect App

CareConnect is a full-stack healthcare application designed to streamline communication and coordination between caregivers and patients.
It includes a **Flutter frontend** and a **Spring Boot backend**, supporting authentication, gamification, secure messaging, social networking, and more.

---

## Project Structure

```
care_connect_app/
├── lib/                    # Flutter frontend
├── careconnect-backend/    # Spring Boot backend (Java)
├── pubspec.yaml            # Flutter config
└── README.md               # Project documentation
```

---

## Prerequisites

Please install the following before starting:

* [Flutter SDK](https://docs.flutter.dev/get-started/install)
* [Java JDK 17+](https://adoptopenjdk.net/) (for Spring Boot)
* [PostgreSQL](https://www.postgresql.org/download/)
* Git
* Code editor (e.g., VS Code, Android Studio, IntelliJ IDEA)

---

## 1. Clone the Project

```bash
git clone --branch careconnect-ui-v2 https://github.com/umgc/summer2025.git
cd summer2025
```

---

## 2. Set Up the Flutter Frontend

```bash
cd care_connect_app         # Navigate into the frontend folder
flutter pub get             # Install Flutter dependencies
flutter run                 # Launch the app
```

> Make sure your emulator or physical device is connected and running before launching the app.

---

## 3. Set Up the Spring Boot Backend

```bash
cd careconnect-backend      # Navigate into the backend folder
# Open in IntelliJ IDEA or your preferred Java IDE.
# OR build with Maven:
./mvnw spring-boot:run      # For Linux/Mac
mvnw spring-boot:run        # For Windows
# OR use IntelliJ "Run" button
```

---

## 4. Configuration

A default `application.properties` file is included for initial development and testing.
**Note:** The configuration will be updated soon to comply with best practices (e.g., moving secrets to an ignored sample file and adding setup instructions).

---

## 5. Run the Backend Server

* With Maven wrapper:

  ```bash
  ./mvnw spring-boot:run
  # or on Windows:
  mvnw spring-boot:run
  ```
* Or, in IntelliJ/IDEA:
  Click the green "Run" arrow for `CareconnectBackendApplication`.

The backend runs by default at [http://localhost:8080](http://localhost:8080).

---

## 6. Test the Integration

Once both servers are running:

* Open the Flutter app and register or log in.
* Check the backend console for logs or errors.
* Use Postman (optional) to test API endpoints manually (`http://localhost:8080/api/...`).

---

## Optional Tools

* [**pgAdmin**](https://www.pgadmin.org/download/) – Visual database management for PostgreSQL.
* [**Postman**](https://www.postman.com/downloads/) – For manual API endpoint testing.

---

## Support

For credentials, setup help, or onboarding, contact your team lead or project maintainer.

---

***Note: `application.properties` setup will be improved soon to follow current best practices for secrets and environment management.***
