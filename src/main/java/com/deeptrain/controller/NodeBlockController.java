package com.deeptrain.controller;

import com.deeptrain.dto.NodeBlockDto;
import com.deeptrain.service.NodeBlockService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/nodes")
public class NodeBlockController {

    private final NodeBlockService service;

    public NodeBlockController(NodeBlockService service) {
        this.service = service;
    }

    @PostMapping
    public ResponseEntity<NodeBlockDto> create(@Valid @RequestBody NodeBlockDto dto) {
        return ResponseEntity.ok(service.save(dto));
    }

    @PutMapping("/{id}")
    public ResponseEntity<NodeBlockDto> update(@PathVariable String id, @Valid @RequestBody NodeBlockDto dto) {
        dto.setId(id);
        return ResponseEntity.ok(service.update(dto));
    }

    @GetMapping
    public ResponseEntity<List<NodeBlockDto>> getAll() {
        return ResponseEntity.ok(service.getAll());
    }

    @GetMapping("/domain/{domain}")
    public ResponseEntity<List<NodeBlockDto>> getByDomain(@PathVariable String domain) {
        return ResponseEntity.ok(service.getByDomain(domain));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable String id) {
        service.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}
