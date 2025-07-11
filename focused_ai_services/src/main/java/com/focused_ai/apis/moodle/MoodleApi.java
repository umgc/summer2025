package com.focused_ai.apis.moodle;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.focused_ai.models.Course;

@Service
public class MoodleApi {
    @Value("${moodle.admin.api.token}")
    private String moodleServiceAccountToken;

    private final RestTemplate restTemplate = new RestTemplate();
    private final ObjectMapper objectMapper = new ObjectMapper();

    public List<Map<String, Object>> getEnrolledUsers(String moodleUrl, int courseId) {
        String wsfunction = "core_enrol_get_enrolled_users";
        
        // Construct the web service URL dynamically
        String moodleWebServiceUrl = moodleUrl.endsWith("/") ? moodleUrl + "webservice/rest/server.php" : moodleUrl + "/webservice/rest/server.php";

        String apiUrl = UriComponentsBuilder.fromUriString(moodleWebServiceUrl)
                .queryParam("wstoken", moodleServiceAccountToken)
                .queryParam("wsfunction", wsfunction)
                .queryParam("moodlewsrestformat", "json")
                .queryParam("courseid", String.valueOf(courseId))
                .build()
                .toUriString();

        ResponseEntity<List<Map<String, Object>>> responseEntity = restTemplate.exchange(
                apiUrl,
                HttpMethod.GET,
                null,
                new ParameterizedTypeReference<List<Map<String, Object>>>() {
                });

        return responseEntity.getBody();
    }

    public List<Course> getCourses(String moodleUrl, String webServiceToken) {
        String wsfunction = "core_course_get_courses";
        
        // Construct the web service URL dynamically
        String moodleWebServiceUrl = moodleUrl.endsWith("/") ? moodleUrl + "webservice/rest/server.php" : moodleUrl + "/webservice/rest/server.php";

        String apiUrl = UriComponentsBuilder.fromUriString(moodleWebServiceUrl)
                .queryParam("wstoken", webServiceToken)
                .queryParam("wsfunction", wsfunction)
                .queryParam("moodlewsrestformat", "json")
                .build()
                .toUriString();

        try {
            // Get the response as a String first
            String jsonResponse = restTemplate.getForObject(apiUrl, String.class);
            System.out.println("Raw JSON response: " + jsonResponse);

            // Deserialize directly to List<Course> - Jackson will ignore unknown fields
            List<Course> courses = objectMapper.readValue(
                    jsonResponse,
                    new TypeReference<List<Course>>() {
                    });

            System.out.println("Parsed courses: " + courses);
            return courses;

        } catch (Exception e) {
            System.err.println("Error parsing courses JSON: " + e.getMessage());
            throw new RuntimeException("Failed to parse courses response", e);
        }
    }
}