# CareConnect App

CareConnect is a full-stack healthcare application designed to streamline communication and coordination between caregivers and patients. It includes a **Flutter frontend** and a **Node.js backend**, with support for authentication, gamification, secure messaging, and more.

---

## Project Structure

```
care_connect_app/
├── lib/                   # Flutter frontend
├── careconnect-backend/   # Node.js backend
├── pubspec.yaml           # Flutter config
└── README.md              # Project documentation
```

---

## Prerequisites

Please install the following before starting:

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Node.js (v18+)](https://nodejs.org/)
- Git
- Code editor (e.g., VS Code or Android Studio)

---

## 1. Clone the Project

```bash
git clone https://github.com/YOUR_USERNAME/careconnect.git
cd care_connect_app
```

---

## 2. Set Up the Flutter Frontend

```bash
cd care_connect_app       # Navigate into the frontend folder
flutter pub get           # Install Flutter dependencies
flutter run               # Launch the app
```

> Make sure your emulator or physical device is connected and running before launching the app.

---

## 3. Set Up the Node.js Backend

```bash
cd careconnect-backend    # Navigate into the backend folder
npm install               # Install backend dependencies
```

---

## 4. Create a `.env` File

In the `careconnect-backend/` folder, create a file named `.env` and paste the following content:

```env
DATABASE_URL=your_postgresql_connection_string
SESSION_SECRET=your_random_session_secret
AWS_ACCESS_KEY_ID=your_aws_key
AWS_SECRET_ACCESS_KEY=your_aws_secret
S3_BUCKET_NAME=your_bucket_name
```

> These values are sensitive. Request them from the team lead and do **not** commit your `.env` file to GitHub.

---

## 5. Run the Backend Server

```bash
node index.js
```

> If successful, you should see:  
> `Server started on http://localhost:3000`

---

## 6. Test the Integration

Once both servers are running:

- Open the Flutter app and register or log in.
- Check the backend terminal for logs or errors.
- Use Postman (optional) to test API endpoints manually.

---

## Optional Tools

- [**pgAdmin**](https://www.pgadmin.org/download/) – To visually manage the PostgreSQL database.
- [**Postman**](https://www.postman.com/downloads/) – To test backend endpoints without the frontend.

---

## .env.example

```env
DATABASE_URL=postgres://username:password@host:port/database
SESSION_SECRET=your_session_secret
AWS_ACCESS_KEY_ID=your_aws_access_key
AWS_SECRET_ACCESS_KEY=your_aws_secret_key
S3_BUCKET_NAME=your_s3_bucket_name
```

---

## Support

For `.env` credentials or setup help, reach out to the team lead or project maintainer.

---
