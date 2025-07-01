package com.deeptrain.service;

import com.deeptrain.dto.NodeBlockDto;
import com.deeptrain.mapper.NodeBlockMapper;
import com.deeptrain.model.NodeBlock;
import com.deeptrain.repository.NodeBlockRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class NodeBlockService {

    private final NodeBlockRepository repository;

    public NodeBlockService(NodeBlockRepository repository) {
        this.repository = repository;
    }

    public NodeBlockDto save(NodeBlockDto dto) {
        NodeBlock saved = repository.save(NodeBlockMapper.toEntity(dto));
        return NodeBlockMapper.toDto(saved);
    }

    public List<NodeBlockDto> getAll() {
        return repository.findAll().stream()
                .map(NodeBlockMapper::toDto)
                .collect(Collectors.toList());
    }

    public List<NodeBlockDto> getByDomain(String domain) {
        return repository.findByDomainIgnoreCase(domain).stream()
                .map(NodeBlockMapper::toDto)
                .collect(Collectors.toList());
    }

    public void deleteById(String id) {
        repository.deleteById(id);
    }

    public NodeBlockDto update(NodeBlockDto dto) {
        if (!repository.existsById(dto.getId())) {
            throw new IllegalArgumentException("Node not found");
        }
        NodeBlock updated = repository.save(NodeBlockMapper.toEntity(dto));
        return NodeBlockMapper.toDto(updated);
    }
}
