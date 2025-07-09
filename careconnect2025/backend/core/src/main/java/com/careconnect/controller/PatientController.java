package com.careconnect.controller;

import com.careconnect.model.Caregiver;
import com.careconnect.model.Patient;
import com.careconnect.security.service.PatientService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/v1/api/patients")
public class PatientController {

    @Autowired
    private PatientService patientService;

    // 1. List caregivers associated with a patient
    @GetMapping("/{patientId}/caregivers")
    public ResponseEntity<List<Caregiver>> getCaregiversByPatient(@PathVariable Long patientId) {
        List<Caregiver> caregivers = patientService.getCaregiversByPatient(patientId);
        return ResponseEntity.ok(caregivers);
    }

    // 2. Get patient details
    @GetMapping("/{patientId}")
    public ResponseEntity<Patient> getPatient(@PathVariable Long patientId) {
        Patient patient = patientService.getPatientById(patientId);
        return ResponseEntity.ok(patient);
    }

    @PutMapping("/{patientId}")
    public ResponseEntity<Patient> updatePatient(@PathVariable Long patientId, @RequestBody Patient updatedPatient) {
    Patient patient = patientService.updatePatient(patientId, updatedPatient);
    return ResponseEntity.ok(patient);
}
}