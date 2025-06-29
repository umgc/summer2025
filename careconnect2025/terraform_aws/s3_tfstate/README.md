# Create the S3 Backend for Terraform
This section has to be executed before all the others.

## Pre-requisites
- **Make sure that you completed the list of prerequisites from [README](../README.md#pre-requisites) outside of that folder**

## Run these commands

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