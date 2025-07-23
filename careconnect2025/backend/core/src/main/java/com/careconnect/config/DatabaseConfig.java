package com.careconnect.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnBean;
import org.springframework.boot.autoconfigure.jdbc.DataSourceProperties;
import org.springframework.context.annotation.*;

import com.careconnect.service.ParameterStoreService;
import software.amazon.awssdk.services.ssm.SsmClient;

@Configuration
public class DatabaseConfig {

    @Value("${spring.datasource.url}")
    private String jdbcUrl;

    @Value("${spring.datasource.username}")
    private String userParameter;

    @Value("${spring.datasource.password}")
    private String passwordParameter;

    private final ParameterStoreService parameterService;

    @Autowired(required = false)
    public DatabaseConfig(ParameterStoreService parameterService) {
        this.parameterService = parameterService;
    }

    /**
     * Will get the sensitive value/properties for database connection from SSM Parameter Store
     * With the {@link ConditionalOnBean} if that can be created, Spring will try to auto-configure
     * @return DataSourceProperties
     */
    @Bean
    @DependsOn("ssmClient")
    @Primary
    public DataSourceProperties dataSourceProperties() {
        DataSourceProperties properties = new DataSourceProperties();
        String url = parameterService.getSecureParameter(jdbcUrl);
        String username = parameterService.getSecureParameter(userParameter);
        String password = parameterService.getSecureParameter(passwordParameter);

        properties.setUrl(url);
        properties.setUsername(username);
        properties.setPassword(password);

        return properties;
    }
}
