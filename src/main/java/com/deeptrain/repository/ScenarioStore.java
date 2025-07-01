package com.deeptrain.repository;

import com.deeptrain.model.Scenario;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ScenarioStore extends JpaRepository<Scenario, String> {

    public void remove(String toLowerCase);
    // You can define custom queries here if needed

   
}

