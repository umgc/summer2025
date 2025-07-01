package com.deeptrain.service;

import com.deeptrain.dto.NodeBlockDto;
import com.deeptrain.mapper.NodeBlockMapper;
import com.deeptrain.model.NodeBlock;
import com.deeptrain.repository.NodeBlockRepository;

import lombok.RequiredArgsConstructor;

import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

import com.deeptrain.dto.SessionDto;

//import com.deeptrain.dto.SessionDto;

@Service
@RequiredArgsConstructor
public class SessionService {

    private final NodeBlockRepository repository;

    public List<NodeBlockDto> saveScenario(String domain, List<NodeBlockDto> nodes) {
        List<NodeBlock> entities = nodes.stream()
                .map(NodeBlockMapper::toEntity)
                .peek(e -> e.setDomain(domain))
                .collect(Collectors.toList());

        List<NodeBlock> saved = repository.saveAll(entities);
        return saved.stream()
                .map(NodeBlockMapper::toDto)
                .collect(Collectors.toList());
    }

    public List<NodeBlockDto> loadScenario(String domain) {
        return repository.findByDomainIgnoreCase(domain).stream()
                .map(NodeBlockMapper::toDto)
                .collect(Collectors.toList());
    }

    public void clearScenario(String domain) {
        repository.deleteByDomainIgnoreCase(domain);
    }

    public void clearSession(String sessionId) {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    public SessionDto startSession(String sessionId) {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    public SessionDto getSession(String sessionId) {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    
}
