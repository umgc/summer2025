# Create the base resources for Care Connect
This will create all the base resources needed for the infrastructure of Care Connect

## Pre-requisites
1. **Make sure that you completed the list of prerequisites from [README](../README.md#pre-requisites) outside of that folder**
1. **Make sure you [Create the backend first](../s3_tfstate/README.md)** _if you did not have a bucket created previously for this._
1. **Make sure the bucket name for your s3 backend for the state is correct. It should match the name of the bucket you create in the _`s3_tfstate`_ project**
1. **Get a variable file ready to run the commands. This is needed to prevent data breach. Your variable file can look like the file below [general.tfvars](#variable-file-sample)**



## Run these commands
**Recomended**: Change directory to the `general` folder. It is better to run those commands from the folder where the `main.tf` file is.<br/>

```bash
# On Linux
cd careconnect2025/terraform_aws/general
```

```cmd
# On Windows
cd careconnect2025\terraform_aws\general
```

You can still use the `-chdir` argument if you are not running the commands from where them `main.tf` file is. [See below](#extra)

- Init
```
terraform init
```

- Plan
```
terraform plan -var-file=general.tfvars
```

- Apply
```
terraform apply -var-file=general.tfvars
```

* Type yes if you want to confirm the changes


<br>

---

### Extra
1. Use the below command to format the scripts
    ```
    terraform fmt --recursive
    ```
2. Use `-chdir` to run the command from a folder other than where the `main.tf` file is. You have to provide a path relative to where the `main.tf` file is.
    ```
    terraform -chdir=terraform_aws fmt --recursive
    ```
3. **DO NOT USE** `terraform destroy` command or else the AWS resources will be **deleted**. Unless you really what to tear down the resources you created.



### Variable file sample
`general.tfvars`
``` 

rds_user_param_name = "cc-rds-username"
rds_pass_param_name = "cc-rds-password"

rds_username = "ccrdsadmin"
rds_password = "mynonsecretpassword"

core_task_env_vars = [
  {
    "name"  = "RDS_USER_PARAM_NAME"
    "value" = "cc-rds-username"
    }, {
    "name"  = "RDS_PASS_PARAM_NAME"
    "value" = "cc-rds-password"
    }, {
    "name"  = "AWS_REGION"
    "value" = "us-east-1"
    }, {
    "name"  = "task_role_arn"
    "value" = "arn:aws:iam::641592448579:role/CCAPPROLE" # Replace with actual task role ARN
  }
]

```
Save this file inside of the general folder and use it as an argument in the command lines as above.
