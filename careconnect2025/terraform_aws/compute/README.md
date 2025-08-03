# Create the compute resources for the backend of CareConnect
This folder contains another Terraform app just to create and integrate the compute(Lambda) needed for the backend of CareConnect.
Only execute these when you are sure that the **general** resources and the **database** were created.

---
Run the similar terraform commands to `init`, `plan` and `apply` the changes of this app.
It also has a module that enable auto deployment to the lambda once a file is drop in the IaC S3 Bucket.

## Challenge
To create a Lambda with zip archive configuration you need to have a zip ready. Also for large zip file you have to provide them through S3. I that case you have to package the backend and upload your file to S3. A workaround is to have a dummy.zip with anything it it on S3 add it in your environment for Lambda, the you can update the Lambda later on. 


## Execution
- ### **Update the backend s3 bucket to hold your state**

- Create a `.tfvars` file with the set of variables expected. To identify those variables check the `variables.tf` file at the same level as the `main.tf` file.

- Run the similar commands suggested in the [**general app**](../general/README.md)

- AWS Commands to upload your zip file to S3 quick

    ```sh
    aws s3 cp target/careconnect-backend-0.0.1-SNAPSHOT-lambda-package.zip s3://cc-iac-us-east-1-641592448579/cc-backend-builds/careconnect-backend-0.0.1-SNAPSHOT-lambda-package.zip --sse aws:kms # Replace this <cc-iac-us-east-1-641592448579> with your bucket name.
    ```