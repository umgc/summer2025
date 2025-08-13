# Run queries against the RDS instance
This document gives instructions on how to run queries against our RDS instance, since it is in a **private network**.
This resources are not provided as part of the Infrastructure script, since it is not encouraged, not required to go run queries straight to the database.

## Pre-requisites
- An EC2 instance was setup in the VPC as the RDS with a ROLE that give SSM Session Manager access to the EC2. Please choose the cheapest EC2 setup possible. 
    - Use Amazon Linux AMI.
    - For the role you have to:
        - Add the EC2 service in your Trust relationships
        - Attach at least these two AWS policies **AmazonRDSReadOnlyAccess**, **AmazonSSMManagedInstanceCore**
- Proper Security Group configurations are in place to enable access to the RDS from the Security Group of the EC2.

    ### To start a session on your local computer
    - Install AWS CLI. Follow this [Install or Update AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
    - [Configure your AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html) - to make it simple we suggestion you to use environment variables [here is the sub link](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html).
    - Install [SSM Session Manager plugin](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html). Choose your OS for the install.

---

## Start a Session on the EC2 with SSM
- Two options: Console and Local Terminal.

    ### To Start a session on the Console
    - Go to the System Manager service
    - On the left bar go to Session Manager
    - Click on Start Session
    - Choose the EC2 Instance in the Target instance section. _Choose the one with access to the RDS if you see multiple instances_ `cc_dev_door`
    - Click on Start session

    ### To start a session on your local computer

    - Get the EC2 instance ID.
    - Run the commnand: 
    ```sh
    aws ssm start-session --target "i-0cd1d04d06d2b1765" # Replace <i-0cd1d04d06d2b1765> with the id of the EC2 you created.
    ``` 


## Connect to the DB
This is as any CLI connection to a Database.

- Run the command: 
```sh
mysql -h cc-db.c4sssktnk4dz.us-east-1.rds.amazonaws.com -u ccrdsadmin -p # Replace the RDS endpoint with yours
```

You can get the password from the ENV variables file in the SharePoint drive of the group project.

## Terminate Session

- When you are done remember to end the session. Although all session got idle timeout after 20mns, we encourage teminating the session to avoid unnecessary charge.

    ### On the Console
    - Go to the Session Manger in the SSM Service
    - Select the session
    - Click **_Terminate_** from the top of the table

    ### On your local computer
- Exit the MySQL session if it is on with the command: `exit`
- Exit the session with the command: `aws ssm terminate-session --session-id sweniac-9euny6klh9xzofkdgeg74d7rry`