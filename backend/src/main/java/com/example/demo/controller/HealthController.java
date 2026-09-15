package com.example.demo.controller;

import java.util.Map;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * Post-deploy health probe used by CI/CD active health-check and local rollback demos.
 */
@RestController
public class HealthController {

    @GetMapping({"/health", "/actuator/health"})
    public ResponseEntity<Map<String, String>> health() {
        return ResponseEntity.ok(Map.of(
                "status", "UP",
                "service", "TravelMate",
                "body", "OK"
        ));
    }
}
