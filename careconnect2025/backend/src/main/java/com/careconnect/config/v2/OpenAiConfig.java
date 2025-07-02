package com.careconnect.config.v2;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import com.theokanning.openai.service.OpenAiService;
import org.springframework.context.annotation.Profile;

@Configuration
public class OpenAiConfig {

    @Bean
    public OpenAiService openAiService(OpenAiProperties props) {
        return new OpenAiService(props.getApiKey());
    }
}
