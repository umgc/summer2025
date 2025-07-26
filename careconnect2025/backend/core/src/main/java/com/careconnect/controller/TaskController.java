package com.careconnect.controller;

import com.careconnect.model.Task;
import com.careconnect.dto.TaskDto;
import com.careconnect.model.Patient;
import com.careconnect.service.CaregiverService;
import com.careconnect.service.TaskService;
import com.careconnect.dto.CaregiverRegistration;
import com.careconnect.dto.PatientRegistration;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.method.P;
import org.springframework.http.HttpStatus;
// import com.careconnect.util.SecurityUtil;
import org.springframework.web.bind.annotation.*;
// import com.careconnect.security.Role;
import jakarta.servlet.http.HttpServletRequest;

import java.util.List;

@RestController
@RequestMapping("/v1/api/tasks")
public class TaskController {
    @Autowired
    private TaskService taskService;

    @Autowired
    private TaskService auth; // Using TaskService as auth for now

    // 1. List tasks for a patient
    @GetMapping("/patient/{patientId}")
    public ResponseEntity<List<Task>> getTasksByPatient(
            @PathVariable Long patientId,
            HttpServletRequest request) {
            
        List<Task> tasks = taskService.getTasksByPatient(patientId);
        return ResponseEntity.ok(tasks);
    }

    @PostMapping("/patient/{patientId}")
    public ResponseEntity<Task> createTask(@PathVariable Long patientId, @RequestBody TaskDto task, HttpServletRequest request) {
        Task createdTask = auth.createTask(patientId, task);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdTask);
    }

    @GetMapping("/{taskId}")
    public ResponseEntity<Task> getTaskById(@PathVariable Long taskId, HttpServletRequest request) {
        Task task = taskService.getTaskById(taskId);
        return ResponseEntity.ok(task);
    }


    @PutMapping("/{taskId}")
    public ResponseEntity<Task> updateTask(@PathVariable Long taskId, @RequestBody TaskDto task, HttpServletRequest request) {
        Task updatedTask = taskService.updateTask(taskId, task);
        if (updatedTask == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(updatedTask);
    }

    @DeleteMapping("/{taskId}")
    public ResponseEntity<Void> deleteTask(@PathVariable Long taskId, HttpServletRequest request) {
        auth.deleteTask(taskId);
        return ResponseEntity.noContent().build();
    }
}
