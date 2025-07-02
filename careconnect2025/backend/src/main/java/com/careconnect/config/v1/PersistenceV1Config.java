package com.careconnect.config.v1;
import org.springframework.context.annotation.Profile;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories; 
import org.springframework.boot.autoconfigure.domain.EntityScan;          


@Configuration
@Profile("v1")
@EntityScan("com.careconnect.model.v1")
@EnableJpaRepositories("com.careconnect.repository.v1")
public class PersistenceV1Config { }