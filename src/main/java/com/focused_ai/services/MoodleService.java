package com.focused_ai.services;

import java.util.List;
import java.util.Map;
import java.util.NoSuchElementException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.focused_ai.apis.moodle.MoodleApi;
import com.focused_ai.mappers.CourseMapper;
import com.focused_ai.models.domain.CourseList;
import com.focused_ai.models.moodle.MoodleCourseList;
import com.focused_ai.utils.JwtUtil;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class MoodleService {

    @Value("${moodle.login.endpoint}")
    private String moodleLoginEndpoint;

    @Value("${moodle.external.service}")
    private String moodleExternalService;

    private final ObjectMapper objectMapper;
    private final JwtUtil jwtUtil;
    private final MoodleApi apiClient;
    @Autowired
    private CourseMapper courseMapper;

    public Map<String, String> moodleAuthenticate(String moodleUrl, String username, String password) throws Exception {
        System.out.println("MoodleService: Attempting to log in " + username + " through Moodle at " + moodleUrl);

        // Construct the login URL dynamically
        String moodleLoginUrl = moodleUrl + moodleLoginEndpoint;

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
            String tokenResponse = apiClient.moodleLogin(moodleLoginUrl, requestEntity);

            JsonNode tokenJson = objectMapper.readTree(tokenResponse);
            String webServiceToken = tokenJson.get("token").asText();
            System.out.println("Got the user's web service token: " + webServiceToken);
            Map<String, String> userData = moodleAuthorize(moodleUrl, username, webServiceToken);
            return userData;
        } catch (Exception e) {
            System.out.println(e.getMessage());
            throw new Exception("MoodleService: " + e.getMessage());
        }
    }

    public Map<String, String> moodleAuthorize(String moodleUrl, String username, String webServiceToken)
            throws Exception {
        System.out.println("MoodleService: Attempting to get role for " + username);

        try {
            List<Map<String, Object>> users = apiClient.getEnrolledUsers(moodleUrl, 2); // courseid where all users are
                                                                                        // enrolled
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
                    "role", role,
                    "webServiceToken", webServiceToken);
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

    public CourseList getCourses(String jwt) {
        System.out.println("userWSToken " + jwtUtil.extractwebServiceToken(jwt));
        System.out.println("moodleUrl " + jwtUtil.extractMoodleDomain(jwt));

        MoodleCourseList courses = apiClient.getCourses(jwtUtil.extractMoodleDomain(jwt),
                jwtUtil.extractwebServiceToken(jwt));
        if (courses == null) {
            System.out.println("MoodleService: Unable to return courses");
        }
        System.out.println(courses.toString());
        return courseMapper.fromMoodle(courses);
    }
}