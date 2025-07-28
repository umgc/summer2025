# **CareConnect CORE Backend App**
This is the first backend app after the prototype of CareConnect that is ready for testing. 
This README will help you set it up on your local computer.

## **Table Of Contents**
<!-- TOC -->
* [**CareConnect CORE Backend App**](#careconnect-core-backend-app)
  * [**Table Of Contents**](#table-of-contents)
  * [Context of most of those instructions](#context-of-most-of-those-instructions)
  * [Prerequisite](#prerequisite)
  * [Quick Setup (Recommended)](#quick-setup-recommended)
    * [1. Environment Configuration](#1-environment-configuration)
    * [2. Start the Application](#2-start-the-application)
      * [Linux/macOS](#linuxmacos)
      * [Windows](#windows)
  * [Alternative Setup (IDE Configuration)](#alternative-setup-ide-configuration)
  * [Features Included](#features-included)
    * [🔔 Firebase Push Notifications](#-firebase-push-notifications)
    * [🔐 Authentication & Security](#-authentication--security)
    * [🏥 Healthcare Features](#-healthcare-features)
    * [📧 Multi-Provider Email Support](#-multi-provider-email-support)
    * [💳 Payment Integration](#-payment-integration)
    * [🤖 AI Integration](#-ai-integration)
    * [☁️ Cloud Storage](#-cloud-storage)
  * [API Documentation](#api-documentation)
  * [Optional Tools](#optional-tools)
  * [Support](#support)
  * [Deployment on AWS](#deployment-on-aws)
<!-- TOC -->

## Context of most of those instructions

- They are generate based on a Linux (Ubuntu) VM.
- Intellij IDEA was used (You can get a student license through UMGC)

Although, the following would be similar to most platforms an IDEs you want to use.

## Prerequisite
- Install Git you can follow this link.
- Install MySQL Server and needed Driver.
- Clone the code (your branch if you are planning on make changes to the code).

## Quick Setup (Recommended)

### 1. Environment Configuration
Set up your environment variables using the new simplified approach:

```bash
# Copy the environment template
cp .env.example .env

# Edit with your actual credentials
nano .env  # or use your preferred editor
```

**Required variables** (minimum to start the application):
- `JDBC_URI` - Your MySQL connection string
- `DB_USER` - Your database username  
- `DB_PASSWORD` - Your database password
- `SECURITY_JWT_SECRET` - JWT secret key (256+ bits)

**Firebase variables** (required for notifications):
- `FIREBASE_PROJECT_ID=careconnectcapstone`
- `FIREBASE_SENDER_ID=663999888931`
- Download `firebase-service-account.json` to `src/main/resources/`

📖 **For detailed setup instructions, see [README-ENV.md](README-ENV.md)**

### 2. Start the Application

#### Linux/macOS
```bash
chmod +x load-env.sh
./load-env.sh mvn spring-boot:run
```

#### Windows
```cmd
load-env.bat mvn spring-boot:run
```

## Alternative Setup (IDE Configuration)

If you prefer to use your IDE's run configuration instead of the `.env` approach:

1. Open your IDE and open the ***`core`*** project/folder with your IDE

2. Add your env variables
    
    - By Default advanced IDE like Intellij just generate a Run Configuration for you 
    based of the file with the entrypoint/touchpoint.<br/>To keep things simple just edit it.
        1. Go to the name of the main class show on the top right see image below. Click on `Edit Configurations...`
        ![Edit Configuration](_readme/Edit_Config.png)
    
        2. With the Run Configuration of the name of the class selected make sure `Environment Variables` is showing up.
        
            - If you do not see `Environment Variables`<br/>Click on the `Modify options` dropdown and check `Environment Variables`. See below
            ![Modify options](_readme/Modify_options.png)

        3. Add your variables in the `Environment Variables` field. The minimum required variables:
        ```
        JDBC_URI=jdbc:mysql://localhost:3306/careconnect;DB_USER=root;DB_PASSWORD=<YOUR_PASSWORD>;SECURITY_JWT_SECRET=<YOUR_JWT_SECRET>;FIREBASE_PROJECT_ID=careconnectcapstone;FIREBASE_SENDER_ID=663999888931
        ```
        
        The format is simple `KEY=value;NEW_KEY=value` <br/>You can also use a file if you prefer or add the variable with the GUI. 
        
        - Click on the last button of the `Environment Variables` field. You should see a screen like below, fill it out line by line.
                ![Add Environment Variables with GUI](_readme/Add_Variable_w_GUI.png)

3. Add AWS Secret and Region (Configure AWS CLI)

   There are multiples way you can do that.<br/>
   You need to have `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION` setup in your environment variables. You can also do that in the IDE or make it global in your System Environment variable.
   Go to for more details [Configure your AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html) - to make it simple we suggest you to use environment variables [here is the sub link](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html).

4. Retrieving properties from SSM Parameter Store

   This configuration is more for AWS deployment. 
    - When you are deploying on AWS make your property equal the full name of the Parameter you define in Parameter store.<br/>
        ```
        JDBC_URI=JDBC_URI
        DB_USER=DB_USER
        DB_PASSWORD=DB_PASSWORD
        SECURITY_JWT_SECRET=SEC_JWT_SECRET
        ...
        ```
    - On your local computer: You can leave full value of the property from your local because if the `ParameterStoreService` cannot retrieve the parameter it would return the initial value your provided.
        ```
        JDBC_URI=jdbc:mysql://localhost:3306/careconnect
        DB_USER=root
        DB_PASSWORD=root
        SECURITY_JWT_SECRET=your_jwt_secret
        ...
        ```


## Features Included

### 🔔 Firebase Push Notifications
- Real-time notifications for patient-caregiver interactions
- Medical alerts and vital sign monitoring
- Multi-platform support (Android, iOS, Web)
- **Setup**: Place `firebase-service-account.json` in `src/main/resources/`

### 🔐 Authentication & Security
- JWT-based authentication with role-based access
- Google OAuth integration
- Password reset functionality
- Account verification via email

### 🏥 Healthcare Features
- Patient and caregiver management
- Vital signs tracking with automated alerts
- Medication reminders
- Family member connections

### 📧 Multi-Provider Email Support
- Resend, SendGrid, or Mailgun integration
- Email verification and notifications
- Password reset emails

### 💳 Payment Integration
- Stripe payment processing
- Subscription management
- Webhook handling

### 🤖 AI Integration
- OpenAI API integration for intelligent features

### ☁️ Cloud Storage
- AWS S3 integration for file storage
- Local file storage option

---

## API Documentation

Once the application is running, you can access:
- **Swagger UI**: http://localhost:8080/swagger-ui.html
- **API Docs**: http://localhost:8080/v3/api-docs

## Optional Tools

* [**Postman**](https://www.postman.com/downloads/) or [**Bruno**](https://www.usebruno.com/downloads) – For manual API endpoint testing.
* MySQL Workbench - To manipulate your database

---

## Support

For credentials, setup help, or onboarding, contact your team lead or project maintainer.

📖 **For detailed environment setup, see [README-ENV.md](README-ENV.md)**  
🔥 **For Firebase notifications, see [FIREBASE_NOTIFICATIONS.md](FIREBASE_NOTIFICATIONS.md)**

---


## Deployment on AWS
This can be done after creating the infrastructure resources using the Terraform scripts. Follow the README(s) for more on the Terraform scripts. 

1. Install and Configure your AWS Cli. Jump to step 2 if you have done that already.
2. Build the project and upload the zip file to AWS S3. 
   ```
   aws s3 cp target/careconnect-backend-0.0.1-SNAPSHOT-lambda-package.zip s3://<S3_BUCKET_NAME>/cc-backend-jars/careconnect-backend-0.0.1-SNAPSHOT-lambda-package.zip --sse aws:kms
    ```

3. If this the first deployment and initial resource creation. Once the file is uploaded use the Terraform compute application's scripts to create the Lambda.<br/>
The Terraform compute app will create the Lambda with the S3 file, create a new Lambda version, create the API Gateway integration with the Lambda version.

4. If this is a subsequent deployment, you can use these commands to update the function and create a new version. 
   <br/>You might still need to go to the console to complete the API Gateway integration update, or once the zip is in S3 you can skip those commands and do the rest on the Console.
    <br>Ideally an automated flow will be provided, and you won't need to do anything after the file is upload to S3.
```sh
# This is to update the function. Please replace your <S3_BUCKET_NAME>.
aws lambda update-function-code --function-name cc_main_backend \
    --s3-bucket <S3_BUCKET_NAME> --s3-key cc-backend-jars/careconnect-backend-0.0.1-SNAPSHOT-lambda-package.zip

# This is to publish a new version for the lambda after the code is updated.  Please update the description to be meaningful to your version.
aws lambda publish-version --function-name cc_main_backend --description "M3 Deployment"

# This is to update the API Gateway Integration. Please replace the <API Id>, <INTEGRATION_ID>, <AWS_ACCOUNT_ID> and <VERSION_NUMBER>.
aws apigatewayv2 update-integration \
    --api-id <API_DI> \
    --integration-id <INTEGRATION_ID> \
    --integration-uri arn:aws:lambda:us-east-1:<AWS_ACCOUNT_ID>:function:cc_main_backend:<VERSION_NUMBER>
```