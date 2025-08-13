package com.careconnect.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.RestTemplate;
import org.springframework.util.MultiValueMap;
import org.springframework.util.LinkedMultiValueMap;
import java.util.*;
import com.careconnect.dto.PlanDTO;
import com.careconnect.exception.AppException;
import com.careconnect.model.*;
import com.careconnect.repository.SubscriptionRepository;
import com.careconnect.repository.UserRepository;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.util.List;
import java.util.ArrayList;
import java.time.Instant;
import org.springframework.beans.factory.annotation.Autowired;

@Service
public class StripeService {
    @Value("${stripe.secret-key}")
    private String stripeSecretKey;

    private final String BASE_URL = "https://api.stripe.com/v1";
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private SubscriptionRepository subscriptionRepository;

    private HttpHeaders getHeaders() {
        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth(stripeSecretKey);
        headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);
        return headers;
    }
    
    /**
     * Create a Stripe customer for a new caregiver
     */
    public Map<String, Object> createCustomer(String name, String email) {
        RestTemplate restTemplate = new RestTemplate();
        HttpHeaders headers = getHeaders();
        
        MultiValueMap<String, String> map = new LinkedMultiValueMap<>();
        map.add("name", name);
        map.add("email", email);
        
        HttpEntity<MultiValueMap<String, String>> request = new HttpEntity<>(map, headers);
        
        ResponseEntity<String> response = restTemplate.exchange(
            BASE_URL + "/customers", HttpMethod.POST, request, String.class);
            
        try {
            ObjectMapper mapper = new ObjectMapper();
            return mapper.readValue(response.getBody(), Map.class);
        } catch (Exception e) {
            throw new AppException(HttpStatus.INTERNAL_SERVER_ERROR, "Failed to parse Stripe customer response: " + e.getMessage());
        }
    }
    
    /**
     * Create a subscription for a customer
     */
    public Map<String, Object> createSubscription(String customerId, String priceId) {
        RestTemplate restTemplate = new RestTemplate();
        HttpHeaders headers = getHeaders();
        
        MultiValueMap<String, String> map = new LinkedMultiValueMap<>();
        map.add("customer", customerId);
        
        // Check if we're dealing with a plan ID instead of a price ID
        // We need to look up the corresponding Price ID for this Plan
        if (priceId.startsWith("plan_")) {
            System.out.println("Converting Plan ID to Price ID: " + priceId);
            try {
                // Get the plan details to find its associated price
                ResponseEntity<String> planResponse = restTemplate.exchange(
                    BASE_URL + "/products/" + priceId, 
                    HttpMethod.GET, 
                    new HttpEntity<>(headers), 
                    String.class
                );
                
                ObjectMapper mapper = new ObjectMapper();
                Map<String, Object> planDetails = mapper.readValue(planResponse.getBody(), Map.class);
                
                // Extract the default price ID from the plan
                if (planDetails.containsKey("default_price")) {
                    String actualPriceId = (String) planDetails.get("default_price");
                    System.out.println("Found Price ID: " + actualPriceId + " for Plan: " + priceId);
                    priceId = actualPriceId;
                } else {
                    // If there's no default price, try to find prices associated with this product
                    ResponseEntity<String> pricesResponse = restTemplate.exchange(
                        BASE_URL + "/prices?product=" + priceId, 
                        HttpMethod.GET, 
                        new HttpEntity<>(headers), 
                        String.class
                    );
                    
                    Map<String, Object> pricesData = mapper.readValue(pricesResponse.getBody(), Map.class);
                    List<Map<String, Object>> prices = (List<Map<String, Object>>) pricesData.get("data");
                    
                    if (prices != null && !prices.isEmpty()) {
                        String actualPriceId = (String) prices.get(0).get("id");
                        System.out.println("Found first available Price ID: " + actualPriceId + " for Plan: " + priceId);
                        priceId = actualPriceId;
                    } else {
                        System.err.println("Plan does not have any associated prices: " + priceId);
                        throw new AppException(HttpStatus.BAD_REQUEST, "The specified plan does not have any associated prices");
                    }
                }
            } catch (Exception e) {
                System.err.println("Error looking up price for plan: " + e.getMessage());
                throw new AppException(HttpStatus.BAD_REQUEST, "Failed to find price for plan: " + e.getMessage());
            }
        }
        
        // Now we should have a valid price ID (either original or looked up from plan)
        map.add("items[0][price]", priceId);
        
        // Add optional parameters that are commonly used
        map.add("payment_behavior", "default_incomplete"); // Allow incomplete payments (useful for SCA requirements)
        map.add("expand[]", "latest_invoice");
        map.add("expand[]", "latest_invoice.payment_intent");
        
        HttpEntity<MultiValueMap<String, String>> request = new HttpEntity<>(map, headers);
        
        System.out.println("Creating Stripe subscription with parameters: customer=" + customerId + ", price=" + priceId);
        
        try {
            ResponseEntity<String> response = restTemplate.exchange(
                BASE_URL + "/subscriptions", HttpMethod.POST, request, String.class);
                
            System.out.println("Stripe subscription creation response: " + response.getStatusCode());
            
            ObjectMapper mapper = new ObjectMapper();
            Map<String, Object> result = mapper.readValue(response.getBody(), Map.class);
            System.out.println("Subscription ID: " + result.get("id"));
            return result;
        } catch (HttpClientErrorException e) {
            System.err.println("Failed to create Stripe subscription. Status: " + e.getStatusCode());
            System.err.println("Response body: " + e.getResponseBodyAsString());
            
            // Try to extract more specific error messages from Stripe
            try {
                ObjectMapper mapper = new ObjectMapper();
                Map<String, Object> errorResponse = mapper.readValue(e.getResponseBodyAsString(), Map.class);
                if (errorResponse.containsKey("error")) {
                    Map<String, Object> error = (Map<String, Object>) errorResponse.get("error");
                    String message = (String) error.get("message");
                    String code = (String) error.getOrDefault("code", "unknown");
                    String param = (String) error.getOrDefault("param", "");
                    
                    throw new AppException(HttpStatus.BAD_REQUEST, 
                        String.format("Stripe error (%s): %s. Parameter: %s", code, message, param));
                }
            } catch (Exception ex) {
                // If we can't parse the error, just use the original exception message
            }
            
            throw new AppException(HttpStatus.BAD_REQUEST, "Failed to create Stripe subscription: " + e.getMessage());
        } catch (Exception e) {
            System.err.println("Failed to create Stripe subscription: " + e.getMessage());
            e.printStackTrace();
            throw new AppException(HttpStatus.INTERNAL_SERVER_ERROR, "Failed to create Stripe subscription: " + e.getMessage());
        }
    }
    
    /**
     * Update a subscription
     */
    public Map<String, Object> updateSubscription(String subscriptionId, String newPriceId) {
        RestTemplate restTemplate = new RestTemplate();
        HttpHeaders headers = getHeaders();
        
        // First get the current subscription to find the item ID
        ResponseEntity<String> getResponse = restTemplate.exchange(
            BASE_URL + "/subscriptions/" + subscriptionId, HttpMethod.GET, 
            new HttpEntity<>(headers), String.class);
            
        String itemId;
        try {
            ObjectMapper mapper = new ObjectMapper();
            JsonNode root = mapper.readTree(getResponse.getBody());
            itemId = root.path("items").path("data").get(0).path("id").asText();
        } catch (Exception e) {
            throw new AppException(HttpStatus.INTERNAL_SERVER_ERROR, "Failed to get subscription item ID: " + e.getMessage());
        }
        
        // Now update the subscription
        MultiValueMap<String, String> map = new LinkedMultiValueMap<>();
        map.add("items[0][id]", itemId);
        map.add("items[0][price]", newPriceId);
        
        HttpEntity<MultiValueMap<String, String>> request = new HttpEntity<>(map, headers);
        
        ResponseEntity<String> response = restTemplate.exchange(
            BASE_URL + "/subscriptions/" + subscriptionId, HttpMethod.POST, request, String.class);
            
        try {
            ObjectMapper mapper = new ObjectMapper();
            return mapper.readValue(response.getBody(), Map.class);
        } catch (Exception e) {
            throw new AppException(HttpStatus.INTERNAL_SERVER_ERROR, "Failed to parse Stripe subscription update response: " + e.getMessage());
        }
    }
    
    /**
     * Cancel a subscription
     */
    public Map<String, Object> cancelSubscription(String subscriptionId) {
        RestTemplate restTemplate = new RestTemplate();
        HttpHeaders headers = getHeaders();
        
        HttpEntity<String> request = new HttpEntity<>(headers);
        
        ResponseEntity<String> response = restTemplate.exchange(
            BASE_URL + "/subscriptions/" + subscriptionId, HttpMethod.DELETE, request, String.class);
            
        try {
            ObjectMapper mapper = new ObjectMapper();
            return mapper.readValue(response.getBody(), Map.class);
        } catch (Exception e) {
            throw new AppException(HttpStatus.INTERNAL_SERVER_ERROR, "Failed to parse Stripe subscription cancel response: " + e.getMessage());
        }
    }
    
    /**
     * Get customer details
     */
    public Map<String, Object> getCustomer(String customerId) {
        RestTemplate restTemplate = new RestTemplate();
        HttpHeaders headers = getHeaders();
        
        HttpEntity<String> request = new HttpEntity<>(headers);
        
        ResponseEntity<String> response = restTemplate.exchange(
            BASE_URL + "/customers/" + customerId, HttpMethod.GET, request, String.class);
            
        try {
            ObjectMapper mapper = new ObjectMapper();
            return mapper.readValue(response.getBody(), Map.class);
        } catch (Exception e) {
            throw new AppException(HttpStatus.INTERNAL_SERVER_ERROR, "Failed to parse Stripe customer response: " + e.getMessage());
        }
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

    public String getCustomerActiveSubscriptions(String customerId) {
        RestTemplate restTemplate = new RestTemplate();
        
        // Create URL with query parameters
        String url = BASE_URL + "/subscriptions?customer=" + customerId + "&status=active";
        
        HttpEntity<String> entity = new HttpEntity<>(getHeaders());
        ResponseEntity<String> response = restTemplate.exchange(
            url, HttpMethod.GET, entity, String.class);
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

    // In SubscriptionService.java

    public Map<String, Object> upgradeOrDowngradeSubscription(String oldSubscriptionId, String newPriceId) {
        // 1. Get the old subscription to find the customer
        String oldSubJson = getSubscription(oldSubscriptionId);
        Map<String, Object> oldSub;
        try {
            ObjectMapper mapper = new ObjectMapper();
            oldSub = mapper.readValue(oldSubJson, new com.fasterxml.jackson.core.type.TypeReference<Map<String, Object>>() {});
        } catch (Exception e) {
            throw new AppException(HttpStatus.INTERNAL_SERVER_ERROR, "Failed to parse subscription JSON: " + e.getMessage());
        }
        // Extract the customer ID - handling both possible structures from Stripe API
        String customerId;
        Object customerObj = oldSub.get("customer");
        if (customerObj instanceof String) {
            customerId = (String) customerObj;
        } else if (customerObj instanceof Map) {
            @SuppressWarnings("unchecked")
            Map<String, Object> customerMap = (Map<String, Object>) customerObj;
            customerId = (String) customerMap.get("id");
        } else {
            throw new AppException(HttpStatus.INTERNAL_SERVER_ERROR, "Unexpected customer format in subscription");
        }

        // 2. Cancel the old subscription
        cancelSubscription(oldSubscriptionId);

        // 3. Create a new subscription with the new price
        return createSubscription(customerId, newPriceId);
    }
}