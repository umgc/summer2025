package com.deeptrain.service;

import com.deeptrain.dto.PageRouteDto;
import com.deeptrain.mapper.PageRouteMapper;
import com.deeptrain.model.PageRoute;
import com.deeptrain.repository.PageRouteRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class PageRouteService {

    private final PageRouteRepository routeRepository;

    public List<PageRouteDto> getAllRoutes() {
        return routeRepository.findAll().stream()
                .map(PageRouteMapper::toDto)
                .collect(Collectors.toList());
    }

    public PageRouteDto getRoute(String path) {
        return routeRepository.findById(path)
                .map(PageRouteMapper::toDto)
                .orElse(null);
    }

    public PageRouteDto saveRoute(PageRouteDto dto) {
        PageRoute saved = routeRepository.save(PageRouteMapper.toEntity(dto));
        return PageRouteMapper.toDto(saved);
    }

    public void deleteRoute(String path) {
        routeRepository.deleteById(path);
    }
}
