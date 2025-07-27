# Create the compute resources for the backend of CareConnect
This folder contains another Terraform app just to create and integrate the compute(Lambda) needed for the backend of CareConnect.
Only execute these when you are sure that the **general** resources and the **database** were created.

---
Run the similar terraform commands to `init`, `plan` and `apply` the changes of this app.
It also has a module that enable auto deployment to the lambda once a file is drop in the S3 Bucket