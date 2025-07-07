# CareConnect App

CareConnect is a full-stack healthcare application designed to streamline communication and coordination between caregivers and patients.
It includes a **Flutter frontend** and a **Spring Boot backend**, supporting authentication, gamification, secure messaging, social networking, and more.

---

## Project Structure

```
care_connect_app/
├── lib/                  
    └── Frontend/           # Flutter frontend 
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

  1. ### Create the Environment Variables file `.env`
  
      * Create a file with the name `.env.local` inside of `careconnect2025/frontend/` folder
      * Add the required environment variables like so:
      
          ```
            DEEPSEEK_API_KEY=your_deepseek_api_key_here
            deepSeek_uri=https://api.deepseek.com/v1/chat/completions
            OPENAI_API_KEY=your_openai_api_key_here
            JWT_SECRET=your_secure_jwt_secret_32_chars_minimum
            CC_BACKEND_TOKEN=your_backend_token_here
            CC_BASE_URL_ANDROID=http://192.168.1.155:8080
            CC_BASE_URL_WEB=http://192.168.1.155:8080
            CC_BASE_URL_OTHER=http://192.168.1.155:8080
          ```
        
      * **IMPORTANT:** Update your code to use the methods from `package:care_connect_app/config/EnvConstant.dart` to get the environment variables you need.
    


  2. ### Run the app


      ```bash
      cd careconnect2025/frontend     # Navigate into the frontend folder
      flutter pub get                 # Install Flutter dependencies
      flutter run                     # Launch the app
      ```

      > Make sure your emulator or physical device is connected and running before launching the app.


  ---


## 3. Run the Backend Server

* With Maven wrapper:

  ```bash
  ./mvnw spring-boot:run
  # or on Windows:
  mvnw spring-boot:run
  ```
* Or, in IntelliJ/IDEA:
  Click the green "Run" arrow for `CareconnectBackendApplication`.

The backend runs by default at [http://localhost:8080](http://localhost:8080).

Read more in the that [README.](../backend/core/README.md)

---

## 4. Test the Integration

Once both servers are running:

* Open the Flutter app and register or log in.
* Check the backend console for logs or errors.
* Use Postman (optional) to test API endpoints manually (`http://localhost:8080/api/...`).

---

