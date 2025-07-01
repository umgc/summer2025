package com.deeptrain.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.deeptrain.model.StudentStat;

public interface StudentStatRepository extends JpaRepository<StudentStat, Long>  {

}

