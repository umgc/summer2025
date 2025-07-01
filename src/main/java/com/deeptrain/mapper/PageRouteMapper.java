package com.deeptrain.mapper;

import com.deeptrain.dto.PageRouteDto;
import com.deeptrain.model.PageRoute;

public class PageRouteMapper {
    public static PageRouteDto toDto(PageRoute route) {
        return new PageRouteDto(route.getPath(), route.getComponent(), route.getInitialDomain());
    }

    public static PageRoute toEntity(PageRouteDto dto) {
        PageRoute entity = new PageRoute();
        entity.setPath(dto.getPath());
        entity.setComponent(dto.getComponent());
        entity.setInitialDomain(dto.getInitialDomain());
        return entity;
    }
}
