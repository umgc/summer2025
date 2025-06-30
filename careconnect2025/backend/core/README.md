# CareConnect CORE Backend App
This is the first backend app after the prototype of CareConnect that is ready for testing. 
This README will help you set it up on your local computer.


## Context of those instructions

- They are generate based on a Linux (Ubuntu) VM.
- Intellij IDEA was used (You can get a student license through UMGC)

Although, the following would be similar to most platforms an IDEs you want to use.

## Prerequisite
- Install Git you can follow this link.
- Install MySQL Server and needed Driver.
- Clone the code (your branch if you are planning on make changes to the code).


## Environment Setup
1. Open your IDE and open the ***`core`*** project/folder with your IDE
   2. Add your env variables
    
       - By Default advanced IDE like Intellij just generate a Run Configuration for you 
       based of the file with the entrypoint/touchpoint.<br/>To keep things simple just edit it.
           1. Go to the name of the main class show on the top right see image below. Click on `Edit Configurations...`
           ![img.png](_readme/Edit_Config.png)
      
           2. With the Run Configuration of the name of the class selected make sure `Environment Variables` is showing up.
           
               - If you do not see `Environment Variables`<br/>Click on the `Modify options` dropdown and check `Environment Variables`. See below
               ![img_1.png](_readme/Modify_options.png)

           3. Add your variables in the `Environment Variables` field, like so. The values in the example should match what you can use.
           ```
            ADMIN_EMAIL=bomplar@gmail.com;ADMIN_EMAIL_PASSWORD=<SENSITIVE>;DB_PASSWORD=<ADD YOUR USER DB PASSWORD HERE>;DB_USER=root;JDBC_URI=jdbc:mysql://localhost:3306/careconnect;MAIL_HOSTNAME=smtp.gmail.com;MAIL_PORT=587
           ```
         
            The format is simple `KEY=value;NEW_KEY=value` <br/>You can also use a file if you prefer or add the variable with the GUI. 
          
            - Click on the last button of the `Envirionment Variables` field. You should see a screen like below, fill it out like by line.
                   ![img_3.png](_readme/Add_Variable_w_GUI.png)