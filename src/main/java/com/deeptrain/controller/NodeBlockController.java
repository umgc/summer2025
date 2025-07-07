package com.deeptrain.controller;

import com.deeptrain.dto.NodeBlockDTO;
import com.deeptrain.model.NodeBlock;
import com.deeptrain.service.NodeBlockService;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/scenario")
@CrossOrigin(origins = "*")
public class NodeBlockController {

    @Autowired
    private NodeBlockService service;

    @PostMapping("/save")
    public List<NodeBlock> saveScenario(@RequestBody List<NodeBlock> blocks) {
        return service.saveAll(blocks);
    }

    @GetMapping("/all")
    public List<NodeBlock> getAll() {
        return service.getAll();
    }

    @PostMapping("/generate")
    public String  generateScenario(@RequestBody NodeBlockDTO dto) {
        String prompt = dto.getLessonContent();
        System.out.println("Prompt ---> " + dto.getLessonContent());
        return service.generateScenarioFromPrompt(prompt);
    }

    


}