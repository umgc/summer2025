# Create the base resources for Care Connect
This will create all the base resources needed for the infrastructure of Care Connect

## Pre-requisites
1. **Make sure that you completed the list of prerequisites from [README](../README.md#pre-requisites) outside of that folder**
1. **Make sure you [Create the backend first](../s3_tfstate/README.md)**

## Run these commands

- Init
```
terraform -chdir=terraform_aws/general init
```

- Plan
```
terraform -chdir=terraform_aws/general plan
```

- Apply
```
terraform -chdir=terraform_aws/general apply
```

* Type yes if you want to confirm the changes


### Extra
Use the below command to format the scripts
```
terraform -chdir=terraform_aws fmt --recursive
```