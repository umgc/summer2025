package com.careconnect;


import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;


@SpringBootApplication
public class CareconnectBackendApplication {

	public static void main(String[] args) {
		SpringApplication app = new SpringApplication(CareconnectBackendApplication.class);
        String profile = System.getProperty("profile", "v1");
        app.setAdditionalProfiles(profile);
        app.run(args);

	}
}
