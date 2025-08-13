package com.careconnect.repository;

import com.careconnect.model.User;
import com.careconnect.model.Task;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface TaskRepository extends JpaRepository<Task, Long> {
    Optional<List<Task>> findByPatient(User user);
    Optional<List<Task>> findByPatientId(Long patientId);
    
}
