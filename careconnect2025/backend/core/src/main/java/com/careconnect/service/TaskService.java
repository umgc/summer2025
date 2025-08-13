package com.careconnect.service;

import com.careconnect.model.Patient;
import com.careconnect.model.Task;
import com.careconnect.dto.TaskDto;
import com.careconnect.exception.AppException;
import org.springframework.transaction.annotation.Transactional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.careconnect.repository.*;

import org.springframework.http.HttpStatus;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;

@Service
@Transactional
public class TaskService {
    
    @Autowired
    private TaskRepository taskRepository;

    @Autowired
    private PatientRepository patientRepository;

    public Task getTaskById(Long taskId) {
        return taskRepository.findById(taskId)
                .orElseThrow(() -> new AppException(HttpStatus.NOT_FOUND, "Task not found"));
    }

    public List<Task> getTasksByPatient(Long patientId) {
        Optional<List<Task>> tasksOpt = taskRepository.findByPatientId(patientId);
        return tasksOpt.orElseGet(ArrayList::new);
    }
    
    public Task createTask(Long patientId, TaskDto task) {
        // Get the patient and ensure it exists
        Patient patient = patientRepository.findById(patientId).orElseThrow(
            () -> new AppException(HttpStatus.NOT_FOUND, "Patient not found")
        );
        System.out.println("Creating task for patient: " + patient.getId());
        System.out.println("Task details: " + task);
        Task newTask = Task.builder()
                .name(task.getName())
                .description(task.getDescription())
                .date(task.getDate())
                .timeOfDay(task.getTimeOfDay())
                .isCompleted(task.isCompleted())
                .frequency(task.getFrequency())
                .taskInterval(task.getInterval())
                .doCount(task.getCount())
                .daysOfWeek(task.getDaysOfWeek())
                .taskType(task.getTaskType())
                .patient(patient)
                .build();
        System.out.println("New task created: " + newTask);
        ObjectMapper mapper = new ObjectMapper();
        mapper.enable(SerializationFeature.INDENT_OUTPUT);
        try {
            String jsonString = mapper.writeValueAsString(newTask);
            System.out.println("Serialized task: " + jsonString);
            return taskRepository.save(newTask);
        } catch (Exception e) {
            throw new AppException(HttpStatus.INTERNAL_SERVER_ERROR,
                    "Failed to create task: " + e.getMessage());
        }
    }

    public Task updateTask(Long taskId, TaskDto task) {
        Task existingTask = getTaskById(taskId);
        // Update fields as necessary
        existingTask.setName(task.getName());
        existingTask.setDescription(task.getDescription());
        existingTask.setDate(task.getDate());
        existingTask.setTimeOfDay(task.getTimeOfDay());
        existingTask.setCompleted(task.isCompleted());
        existingTask.setTaskType(task.getTaskType());
        existingTask.setFrequency(task.getFrequency());
        existingTask.setTaskInterval(task.getInterval());
        existingTask.setDoCount(task.getCount());
        existingTask.setDaysOfWeek(task.getDaysOfWeek());

        // Save the updated task
        return taskRepository.save(existingTask);   
    }

    public boolean deleteTask(Long taskId) {
        Task task = getTaskById(taskId);
        taskRepository.delete(task);
        return true;
    }

    public boolean existsById(Long taskId) {
        return taskRepository.findById(taskId).isPresent();
    }

    public List<Task> getAllTasks() {
        List<Task> tasks = taskRepository.findAll();
        if (tasks.isEmpty()) {
            throw new AppException(HttpStatus.NOT_FOUND, "No tasks found");
        }
        return tasks;
    }

    // Additional methods for TaskService can be added here
}
