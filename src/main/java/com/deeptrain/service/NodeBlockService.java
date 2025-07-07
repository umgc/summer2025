package com.deeptrain.service;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;

import com.deeptrain.model.NodeBlock;
import com.deeptrain.repository.NodeBlockRepository;




@Service
public class NodeBlockService {

    private final WebClient webClient;

    @Autowired
    private NodeBlockRepository repository;

    public List<NodeBlock> saveAll(List<NodeBlock> blocks) {
        return repository.saveAll(blocks);
    }

    public List<NodeBlock> getAll() {
        return repository.findAll();
    }

    public NodeBlockService(@Value("${deepseek.api.url}") String baseUrl,
                     @Value("${deepseek.api.key}") String apiKey) {
        this.webClient = WebClient.builder()
                .baseUrl(baseUrl)
                .defaultHeader("Authorization", "Bearer " + apiKey)
                .build();
    }

    public String generateScenarioFromPrompt(String prompt) {
      try {
       
       return webClient.post()
            .uri("/completions")
            .bodyValue(Map.of(
                "model", "deepseek-chat",
                "prompt", prompt,
                "max_tokens", 300
            ))
            .retrieve()
            .bodyToMono(String.class)
            .block();
    } catch (Exception e) {
        return "Error generating response: " + e.getMessage();
  
      }
    }


}