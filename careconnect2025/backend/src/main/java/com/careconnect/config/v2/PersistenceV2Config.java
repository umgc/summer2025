package com.careconnect.config.v2;
import org.springframework.context.annotation.Profile;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories; 
import org.springframework.boot.autoconfigure.domain.EntityScan;       

@Configuration
@Profile("v2")
@EntityScan("com.careconnect.model.v2")
@EnableJpaRepositories("com.careconnect.repository.v2")
public class PersistenceV2Config { }