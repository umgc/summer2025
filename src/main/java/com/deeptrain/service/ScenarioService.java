package com.deeptrain.service;
import com.deeptrain.dto.ScenarioDTO;
import com.deeptrain.model.Scenario;
import com.deeptrain.repository.ScenarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class ScenarioService {

    @Autowired
    private ScenarioRepository scenarioRepository;

    public Scenario saveScenario(ScenarioDTO dto) {
        System.out.println("Saving Scenario -> Title: " + dto.title + ", Domain: " + dto.domain);
        Scenario s = new Scenario();
        s.setDomain(dto.domain);
        s.setTitle(dto.title);
        s.setSerializedBlocks(dto.serializedBlocks);
        return scenarioRepository.save(s);
    }

    public List<Scenario> getAllScenarios() {
        return scenarioRepository.findAll();
    }

    public Optional<Scenario> getScenarioById(Long id) {
        return scenarioRepository.findById(id);
    }

    public Optional<Scenario> updateScenario(Long id, ScenarioDTO dto) {
        
        return scenarioRepository.findById(id).map(existing -> {
            existing.setDomain(dto.domain);
            existing.setTitle(dto.title);
            existing.setSerializedBlocks(dto.serializedBlocks);
            return scenarioRepository.save(existing);
        });
    }

    public void deleteScenario(Long id) {
        scenarioRepository.deleteById(id);
    }
}
