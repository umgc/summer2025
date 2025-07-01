package com.deeptrain.repository;

import com.deeptrain.model.PageRoute;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface PageRouteRepository extends JpaRepository<PageRoute, String> {
}
