# Create the database instance for the backend of CareConnect
This folder contains another Terraform app just to create database needed for the backend of CareConnect.<br/>
It helps to isolate the database from the rest of the infrasctructure. 

## Dependencies
- **general**: Terraform application in this repo
    You can create these resources when you are sure that the **general** resources were created.

## Execution
Run the similar commands suggested in the [**general app**](../general/README.md)

## For Isolation
If you want to only 