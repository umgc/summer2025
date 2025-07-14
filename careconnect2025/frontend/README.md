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

## AWS Amplify Front-End Deployment

This section covers the steps to deploy the latest front-end code to the AWS Console. This action is normally intended with an automated action through GitHub, but until the repository permissions are set with the UMGC class repository, manual deployments will be taken for now.

### Prequisites
* You will need an AWS account with an AWS Amplify resource created for your account.
*  You will need to have flutter installed for commands

### Steps
1. In your IDE terminal, go into the front-end directory with the command: 
```bash
cd into ./careconnect2025/frontend
```
2. Once in the front-end directory, run the following flutter command to build the web files needed for deployment to AWS Amplify:
```bash
flutter build web --base-href "/"
```
3. In your file explorer, locate the ../frontend/build/web file folder and open the web folder.
4. Select all of the files in the web folder and zip them together into one folder. Save the zip file somewhere where you will remember its location.
5. In your AWS Amplify resource in your AWS account, select the Amplify app you wish to deploy your latest front-end code. The app will list all of the branches you have in the app.
6. Locate the branch you wish to deploy updates and select the 'Deploy Updates' button.
7. Select the "Drag and drop" button. Then select the "Choose .zip folder" button. This will open your file explorer.
8. In your file explorer, locate where you saved your zip file from Step #4 and choose the zip file to deploy.
9. Back in the AWS console, select the "Save a deploy" button. This will start the deployment process.
10. Once the deployment finishes and succeeds, the latest front-end code will be deployed.
11. Done!


