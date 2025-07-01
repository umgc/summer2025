package com.deeptrain.service;

import com.deeptrain.dto.StudentStatDto;
import com.deeptrain.mapper.StudentStatMapper;
import com.deeptrain.repository.StudentStatRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class StudentStatService {

    private final StudentStatRepository repository;

    public List<StudentStatDto> getAllStats() {
        return repository.findAll()
                .stream()
                .map(StudentStatMapper::toDto)
                .collect(Collectors.toList());
    }

    public void saveStat(StudentStatDto dto) {
        repository.save(StudentStatMapper.toEntity(dto));
    }
}
