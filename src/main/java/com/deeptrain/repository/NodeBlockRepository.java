package com.deeptrain.repository;

import com.deeptrain.dto.NodeBlockDto;
import com.deeptrain.model.NodeBlock;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Collection;
import java.util.List;

public interface NodeBlockRepository extends JpaRepository<NodeBlock, Long> {
    List<NodeBlock> findByDomainIgnoreCase(String domain);
   
    boolean existsById(String id);

    public void deleteById(String id);

    Collection<NodeBlockDto> findByDomain(String domain);

    void deleteByDomainIgnoreCase(String domain);

   

}
