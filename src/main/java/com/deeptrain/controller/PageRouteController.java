package com.deeptrain.controller;

import java.util.List;

import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.deeptrain.dto.PageRouteDto;
import com.deeptrain.service.PageRouteService;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/routes")
@RequiredArgsConstructor
public class PageRouteController {

    private final PageRouteService pageRouteService;

    @GetMapping
    public List<PageRouteDto> getAllRoutes() {
        return pageRouteService.getAllRoutes();
    }

    @GetMapping("/{path}")
    public PageRouteDto getRoute(@PathVariable String path) {
        return pageRouteService.getRoute(path);
    }

    @PostMapping
    public PageRouteDto createRoute(@RequestBody PageRouteDto dto) {
        return pageRouteService.saveRoute(dto);
    }

    @DeleteMapping("/{path}")
    public void deleteRoute(@PathVariable String path) {
        pageRouteService.deleteRoute(path);
    }
}
