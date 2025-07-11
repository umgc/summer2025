package com.focused_ai.services;

import java.util.List;
import java.util.Map;
import java.util.NoSuchElementException;
import java.util.concurrent.ConcurrentHashMap;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestTemplate;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.focused_ai.apis.moodle.MoodleApi;
import com.focused_ai.models.Course;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class MoodleService {

    private final Map<String, String> moodleTokenCache = new ConcurrentHashMap<>();
    private final Map<String, String> moodleUrlCache = new ConcurrentHashMap<>();

    @Value("${moodle.external.service}")
    private String moodleExternalService;

    private final RestTemplate restTemplate = new RestTemplate();
    private final ObjectMapper objectMapper;
    private final MoodleApi apiClient;

    public String getwebServiceToken(String userId) {
        return moodleTokenCache.get(userId);
    }

    public void storewebServiceToken(String userId, String webServiceToken) {
        moodleTokenCache.put(userId, webServiceToken);
        System.out.println("Successfully stored token " + webServiceToken + " with user " + userId);
    }

    public String getMoodleUrl(String userId) {
        return moodleUrlCache.get(userId);
    }

    public void storeMoodleUrl(String userId, String moodleUrl) {
        moodleUrlCache.put(userId, moodleUrl);
        System.out.println("Successfully stored Moodle URL " + moodleUrl + " with user " + userId);
    }

    public Map<String, String> moodleAuthenticate(String moodleUrl, String username, String password) throws Exception {
        System.out.println("MoodleService: Attempting to log in " + username + " through Moodle at " + moodleUrl);

        // Construct the login URL dynamically
        String moodleLoginUrl = moodleUrl.endsWith("/") ? moodleUrl + "login/token.php" : moodleUrl + "/login/token.php";

        MultiValueMap<String, String> formData = new LinkedMultiValueMap<>();
        formData.add("username", username);
        formData.add("password", password);
        formData.add("service", moodleExternalService);

        // Set the Content-Type header explicitly
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);

        // Create the HttpEntity with the form data and headers
        HttpEntity<MultiValueMap<String, String>> requestEntity = new HttpEntity<>(formData, headers);

        try {
            String tokenResponse = restTemplate.postForObject(moodleLoginUrl, requestEntity, String.class);

            JsonNode tokenJson = objectMapper.readTree(tokenResponse);
            String webServiceToken = tokenJson.get("token").asText();
            System.out.println("Got the user's web service token: " + webServiceToken);

            Map<String, String> userData = moodleAuthorize(moodleUrl, username);

            storewebServiceToken(userData.get("id"), webServiceToken);
            storeMoodleUrl(userData.get("id"), moodleUrl);

            return userData;
        } catch (Exception e) {
            throw new Exception("MoodleService: " + e.getMessage());
        }
    }

    public Map<String, String> moodleAuthorize(String moodleUrl, String username) throws Exception {
        System.out.println("MoodleService: Attempting to get role for " + username);

        try {
            List<Map<String, Object>> users = apiClient.getEnrolledUsers(moodleUrl, 2); // courseid where all users are enrolled
            if (users == null) {
                throw new IllegalStateException("Empty response from Moodle: core_enrol_get_enrolled_users");
            }

            Map<String, Object> user = findUserByUsername(users, username);
            String id = String.valueOf(user.get("id"));
            String role = extractUserRole(user, username);

            if (role.equals("editingteacher")) {
                role = "teacher";
            }

            System.out.println("MoodleService: users role: " + role);

            return Map.of(
                    "id", id,
                    "role", role);
        } catch (Exception e) {
            throw new Exception("MoodleService: Unable to determine user role: " + e.getMessage());
        }
    }

    private Map<String, Object> findUserByUsername(List<Map<String, Object>> users, String username) {
        for (Map<String, Object> u : users) {
            if (u.containsKey("username") && u.get("username").equals(username)) {
                return u;
            }
        }
        throw new NoSuchElementException("User " + username + " was not found in the enrolled users list.");
    }

    private String extractUserRole(Map<String, Object> user, String username) {
        List<Map<String, Object>> roles = (List<Map<String, Object>>) user.get("roles");
        if (roles == null || roles.isEmpty()) {
            throw new NoSuchElementException("Role for user " + username + " was not found");
        }
        return String.valueOf(roles.get(0).get("shortname"));
    }

    public List<Course> getCourses(String userId) throws Exception {
        System.out.println("userId " + userId);
        String userWSToken = getwebServiceToken(userId);
        String moodleUrl = getMoodleUrl(userId);
        System.out.println("userWSToken " + userWSToken);
        System.out.println("moodleUrl " + moodleUrl);

        List<Course> courses = apiClient.getCourses(moodleUrl, userWSToken);
        if (courses == null) {
            System.out.println("MoodleService: Unable to return courses");
        }
        System.out.println(courses.toString());
        return courses;
    }
}