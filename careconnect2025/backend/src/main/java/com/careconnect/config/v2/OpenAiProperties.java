package com.careconnect.config.v2;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Component                      
@ConfigurationProperties(prefix = "openai")
public class OpenAiProperties {

    private String apiKey;


    public String getApiKey() {
        return apiKey;
    }

    public void setApiKey(String apiKey) {
        this.apiKey = apiKey;
    }
}
