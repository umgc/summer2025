package com.deeptrain.controller;

import com.deeptrain.dto.StudentStatDto;
import com.deeptrain.service.StudentStatService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/student-stats")
@RequiredArgsConstructor
@CrossOrigin
public class StudentStatController {

    private final StudentStatService service;

    @GetMapping
    public List<StudentStatDto> getStats() {
        return service.getAllStats();
    }

    @PostMapping
    public void addStat(@RequestBody StudentStatDto dto) {
        service.saveStat(dto);
    }
}
