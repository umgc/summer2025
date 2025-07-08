# Main Terraform - AWS Infrastructure of Care Connect
This section of the code should be used to manage the underlaying AWS infrastructure for Care Connect. Inside of this folder we have all the initial and general scripts needed to start. Please follow this guide carefully.

**_NB: Keep in mind you could be charged for the resources you are creating on AWS._**


## Start with the [s3_tfstate](./s3_tfstate/README.md) folder at the first run
_Unless you already have your own s3 bucket ready for the state.<br/>In that case you could just update the bucket name for the backend in the `main.tf` file under the general folder._

---
## Here is the high level recommended execution flow:

1. Confirm you have all the pre-requisites
1. Change the bucket name if needed in the main.tf of the ***`s3_tfstate`***, because bucket names are unique in S3 accross all AWS accounts.
1. Execute the scripts under the ***`s3_tfstate`*** folder
1. Execute the scripts under the ***`general`*** folder 


## Pre-requisites
1. You need an AWS user account with the **Access Credentials** for it.
1. Install AWS CLI. Follow this [Install or Update AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
1. [Configure your AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html) - to make it simple we suggestion you to use environment variables [here is the sub link](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html).
1. Install & Configure Terraform [Link](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)


## Follow through with the instructions inside of each folder. 
You will find a README file under each main folder where you can follow through the rest of the process. But remember **`START WITH THE "s3_tfstate" FOLDER AT THE FIRST RUN`**
