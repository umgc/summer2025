# Create the S3 Backend for Terraform
This section has to be executed before all the others.

## Pre-requisites
- **Make sure that you completed the list of prerequisites from [README](../README.md#pre-requisites) outside of that folder**

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
terraform -chdir=terraform_aws/s3_tfstate init
```

- Plan
```
terraform -chdir=terraform_aws/s3_tfstate plan
```

- Apply
```
terraform -chdir=terraform_aws/s3_tfstate apply
```

* Type yes if you want to confirm the changes


**DO NOT USE** `terraform destroy` command or else the AWS resources will be **deleted**.