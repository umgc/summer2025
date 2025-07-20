package com.focused_ai.mappers;

import com.focused_ai.models.domain.*;
import com.focused_ai.models.google.*;
import com.focused_ai.models.moodle.*;
import org.springframework.stereotype.Component;
import java.util.stream.Collectors;

@Component
public class UserMapper {

    public UserProfile fromGoogle(GoogleUserProfile googleProfile) {
        UserProfile profile = new UserProfile();
        profile.setId(googleProfile.getId());
        profile.setEmailAddress(googleProfile.getEmailAddress());
        return profile;
    }

    public UserProfile fromMoodle(MoodleUserProfile moodleProfile) {
        UserProfile profile = new UserProfile();
        profile.setId(moodleProfile.getId());
        profile.setEmailAddress(moodleProfile.getUsername());
        return profile;
    }

    public Teacher fromGoogle(GoogleTeacher googleTeacher) {
        Teacher teacher = new Teacher();
        teacher.setUserId(googleTeacher.getUserId());
        return teacher;
    }

    public Teacher fromMoodle(MoodleTeacher moodleTeacher) {
        Teacher teacher = new Teacher();
        teacher.setUserId(String.valueOf(moodleTeacher.getUserId()));
        return teacher;
    }

    public TeacherList fromGoogle(GoogleTeacherList googleList) {
        TeacherList teacherList = new TeacherList();
        teacherList.setTeachers(googleList.getTeachers().stream()
                .map(this::fromGoogle)
                .collect(Collectors.toList()));
        return teacherList;
    }

    public TeacherList fromMoodle(MoodleTeacherList moodleList) {
        TeacherList teacherList = new TeacherList();
        teacherList.setTeachers(moodleList.getTeachers().stream()
                .map(this::fromMoodle)
                .collect(Collectors.toList()));
        return teacherList;
    }

    public Student fromGoogle(GoogleStudent googleStudent) {
        Student student = new Student();
        student.setUserId(googleStudent.getUserId());
        return student;
    }

    public Student fromMoodle(MoodleStudent moodleStudent) {
        Student student = new Student();
        student.setUserId(String.valueOf(moodleStudent.getUserId()));
        return student;
    }

    public StudentList fromGoogle(GoogleStudentList googleList) {
        StudentList studentList = new StudentList();
        studentList.setStudents(googleList.getStudents().stream()
                .map(this::fromGoogle)
                .collect(Collectors.toList()));
        return studentList;
    }

    public StudentList fromMoodle(MoodleStudentList moodleList) {
        StudentList studentList = new StudentList();
        studentList.setStudents(moodleList.getStudents().stream()
                .map(this::fromMoodle)
                .collect(Collectors.toList()));
        return studentList;
    }
}