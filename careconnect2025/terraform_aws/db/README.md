# Create the database instance for the backend of CareConnect
This folder contains another Terraform app just to create database needed for the backend of CareConnect.<br/>
It helps to isolate the database from the rest of the infrasctructure. Although can be challenging since RDS relies on VPC and Security Group.

## Future consideration
- Change the Database to be serverless with Aurora MySQL.

## Dependencies
- **general**: Terraform application in this repo
    You can create the DB resources when you are sure that the **general** resources were created.

## Execution
- ### **Update the backend s3 bucket to hold your state**

- Create a `.tfvars` file with the set of variables expected. To identify those variables check the `variables.tf` file at the same level as the `main.tf` file.

- Run the similar commands suggested in the [**general app**](../general/README.md)


## Extra
- If you ever need to access the database to run queries. Check the [AWS_DB_QUERY_ACCESS](AWS_DB_QUERY_ACCESS.md) file.