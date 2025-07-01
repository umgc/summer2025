package com.deeptrain.service;

import org.springframework.stereotype.Service;

import com.deeptrain.client.DeepSeekClient;
import com.deeptrain.dto.SimulationResponseDto;
import com.deeptrain.model.DeepSeekResponse;
import com.deeptrain.model.SimulationResponse;
import com.deeptrain.repository.SimulationResponseRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class SimulationService {
    private final SimulationResponseRepository repository;
     private final DeepSeekClient deepSeekClient;
    private boolean isCorrect;

    public SimulationResponse submitResponse(SimulationResponseDto dto) {
        SimulationResponse response = new SimulationResponse();
        response.setUserId(dto.getUserId());
        response.setQuestionId(dto.getQuestionId());
        response.setUserAnswer(dto.getUserAnswer());

     
        String prompt = "Question ID: " + dto.getQuestionId() + ", Answer: " + dto.getUserAnswer();
         DeepSeekResponse feedback = deepSeekClient.evaluate(prompt);
        response.setCorrect(isCorrect);
        response.setScore(isCorrect ? 10 : 0);
        response.setFeedback(isCorrect ? "Correct! Great job." : "Incorrect. The correct answer was B.");

        return repository.save(response);
    }

    public String runScenario(String scenarioId) {
        throw new UnsupportedOperationException("Not supported yet.");
    }
}
