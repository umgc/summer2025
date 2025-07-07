package com.careconnect.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.util.MultiValueMap;
import org.springframework.util.LinkedMultiValueMap;
import java.util.*;
import com.careconnect.dto.PlanDTO;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.util.List;
import java.util.ArrayList;

@Service
public class StripeService {
    @Value("${stripe.secret-key}")
    private String stripeSecretKey;

    private final String BASE_URL = "https://api.stripe.com/v1";

    private HttpHeaders getHeaders() {
        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth(stripeSecretKey);
        headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);
        return headers;
    }

  
    public List<PlanDTO> listPlans() {
        RestTemplate restTemplate = new RestTemplate();
        HttpEntity<String> entity = new HttpEntity<>(getHeaders());
        ResponseEntity<String> response = restTemplate.exchange(
            BASE_URL + "/plans", HttpMethod.GET, entity, String.class);

        try {
            ObjectMapper mapper = new ObjectMapper();
            JsonNode root = mapper.readTree(response.getBody());
            JsonNode data = root.get("data");
            List<PlanDTO> plans = new ArrayList<>();
            if (data != null && data.isArray()) {
                for (JsonNode node : data) {
                    plans.add(new PlanDTO(
                        node.get("id").asText(),
                        node.get("active").asBoolean(),
                        node.get("amount").asInt(),
                        node.get("currency").asText(),
                        node.get("interval").asText(),
                        node.get("interval_count").asInt(),
                        node.get("product").asText(),
                        node.has("nickname") && !node.get("nickname").isNull() ? node.get("nickname").asText() : null
                    ));
                }
            }
            return plans;
        } catch (Exception e) {
            throw new RuntimeException("Failed to parse plans", e);
        }
    }

    public String listProducts() {
        RestTemplate restTemplate = new RestTemplate();
        HttpEntity<String> entity = new HttpEntity<>(getHeaders());
        ResponseEntity<String> response = restTemplate.exchange(
            BASE_URL + "/products", HttpMethod.GET, entity, String.class);
        return response.getBody();
    }

    public String listSubscriptions(String customerId) {
        RestTemplate restTemplate = new RestTemplate();
        HttpHeaders headers = getHeaders();
        String url = BASE_URL + "/subscriptions";
        if (customerId != null && !customerId.isEmpty()) {
            url += "?customer=" + customerId;
        }
        HttpEntity<String> entity = new HttpEntity<>(headers);
        ResponseEntity<String> response = restTemplate.exchange(
            url, HttpMethod.GET, entity, String.class);
        return response.getBody();
    }

    public String getSubscription(String subscriptionId) {
        RestTemplate restTemplate = new RestTemplate();
        HttpEntity<String> entity = new HttpEntity<>(getHeaders());
        ResponseEntity<String> response = restTemplate.exchange(
            BASE_URL + "/subscriptions/" + subscriptionId, HttpMethod.GET, entity, String.class);
        return response.getBody();
    }

    public String cancelSubscription(String subscriptionId) {
        RestTemplate restTemplate = new RestTemplate();
        HttpHeaders headers = getHeaders();
        HttpEntity<String> entity = new HttpEntity<>(headers);
        String url = BASE_URL + "/subscriptions/" + subscriptionId;
        ResponseEntity<String> response = restTemplate.exchange(
            url, HttpMethod.DELETE, entity, String.class
        );
        return response.getBody();
    }

    public String searchSubscriptions(String query) {
        RestTemplate restTemplate = new RestTemplate();
        HttpHeaders headers = getHeaders();
        MultiValueMap<String, String> params = new LinkedMultiValueMap<>();
        params.add("query", query);
        HttpEntity<MultiValueMap<String, String>> entity = new HttpEntity<>(params, headers);
        ResponseEntity<String> response = restTemplate.exchange(
            BASE_URL + "/subscriptions/search", HttpMethod.GET, entity, String.class);
        return response.getBody();
    }
}