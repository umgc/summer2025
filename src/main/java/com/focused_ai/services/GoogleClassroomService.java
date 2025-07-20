package com.focused_ai.services;

import com.focused_ai.apis.google.GoogleClassroomApi;
import com.focused_ai.mappers.CourseMapper;
import com.focused_ai.mappers.UserMapper;
import com.focused_ai.models.google.*;
import com.focused_ai.utils.JwtUtil;
import com.focused_ai.models.domain.*;

import lombok.RequiredArgsConstructor;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class GoogleClassroomService {

    private final GoogleClassroomApi apiClient;
    private final JwtUtil jwtUtil;

    @Autowired
    private CourseMapper courseMapper;

    @Autowired
    private UserMapper userMapper;

    public Map<String, String> googleAuthenticate(String serverAuthCode, String userId) {
        Map<String, String> tokenResponse = apiClient.exchangeAuthCode(serverAuthCode);
        String accessToken = tokenResponse.get("access_token");
        String refreshToken = tokenResponse.get("refresh_token");
        String expiry = tokenResponse.get("expires_in");
        String role = googleAuthorize(accessToken);

        return Map.of(
                "role", role,
                "accessToken", accessToken,
                "refreshToken", refreshToken,
                "expiry", expiry);
    }

    public String googleAuthorize(String accessToken) {
        GoogleUserProfile googleUserProfile = apiClient.getUserProfile(accessToken);
        UserProfile userProfile = userMapper.fromGoogle(googleUserProfile);
        return determineUserRole(userProfile, accessToken);
    }

    private String determineUserRole(UserProfile userProfile, String accessToken) {
        GoogleCourseList googleCourseList = apiClient.getCourses(accessToken);
        CourseList courseList = courseMapper.fromGoogle(googleCourseList);

        if (courseList.getCourses() == null || courseList.getCourses().isEmpty()) {
            return "unknown";
        }

        String firstCourseId = courseList.getCourses().get(0).getId();
        return checkUserRoleInCourse(userProfile, firstCourseId, accessToken);
    }

    private String checkUserRoleInCourse(UserProfile userProfile, String courseId, String accessToken) {
        GoogleTeacherList googleTeacherList = apiClient.getCourseTeachers(courseId, accessToken);
        TeacherList teacherList = userMapper.fromGoogle(googleTeacherList);

        boolean isTeacher = teacherList.getTeachers().stream()
                .anyMatch(teacher -> teacher.getUserId().equals(userProfile.getId()));

        if (isTeacher) {
            return "teacher";
        }

        GoogleStudentList googleStudentList = apiClient.getCourseStudents(courseId, accessToken);
        StudentList studentList = userMapper.fromGoogle(googleStudentList);
        boolean isStudent = studentList.getStudents().stream()
                .anyMatch(student -> student.getUserId().equals(userProfile.getId()));
        
        return isStudent ? "student" : "unknown";
    }

    public CourseList getCourses(String jwt) {
        if (jwtUtil.isTokenExpired(jwt)) {
            throw new RuntimeException("Invalid token for user: " + jwtUtil.extractUserId(jwt));
        }

        GoogleCourseList googleCourseList = apiClient.getCourses(jwtUtil.extractGoogleAccessToken(jwt));
        return courseMapper.fromGoogle(googleCourseList);
    }
}