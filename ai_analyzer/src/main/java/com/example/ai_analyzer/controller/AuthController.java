package com.example.ai_analyzer.controller;

import com.example.ai_analyzer.dto.*;
import com.example.ai_analyzer.service.AuthService;
import com.example.ai_analyzer.service.OtpService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
@CrossOrigin(origins = "*") // Required for Flutter frontend access
public class AuthController {

    private final AuthService authService;
    private final OtpService otpService; // Inject OTP service

    @PostMapping("/signup")
    public ResponseEntity<AuthResponse> signup(@RequestBody SignupRequest request) {
        AuthResponse response = authService.signup(request);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@RequestBody AuthRequest request) {
        AuthResponse response = authService.login(request);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/reset-password")
    public ResponseEntity<String> resetPassword(@RequestBody ResetPasswordRequest request) {
        String message = authService.resetPassword(request);
        return ResponseEntity.ok(message);
    }

    // Send OTP
    @PostMapping("/send-otp")
    public ResponseEntity<Map<String, Object>> sendOtp(@RequestBody OtpRequest request) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            if (request.getPhoneNumber() == null || request.getPhoneNumber().trim().isEmpty()) {
                response.put("success", false);
                response.put("message", "Phone number is required");
                return ResponseEntity.badRequest().body(response);
            }
            
            String otp = otpService.generateOtp(request.getPhoneNumber());
            response.put("success", true);
            response.put("message", "OTP sent successfully");
            response.put("otp", otp); // Remove this in production - only for testing
            
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            response.put("success", false);
            response.put("message", e.getMessage());
            return ResponseEntity.badRequest().body(response);
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Failed to send OTP. Please try again.");
            return ResponseEntity.internalServerError().body(response);
        }
    }

    // Verify OTP
    @PostMapping("/verify-otp")
    public ResponseEntity<Map<String, Object>> verifyOtp(@RequestBody OtpRequest request) {
        Map<String, Object> response = new HashMap<>();
        
        try {
            if (request.getPhoneNumber() == null || request.getPhoneNumber().trim().isEmpty()) {
                response.put("success", false);
                response.put("message", "Phone number is required");
                return ResponseEntity.badRequest().body(response);
            }
            
            if (request.getOtp() == null || request.getOtp().trim().isEmpty()) {
                response.put("success", false);
                response.put("message", "OTP is required");
                return ResponseEntity.badRequest().body(response);
            }
            
            boolean isValid = otpService.verifyOtp(request.getPhoneNumber(), request.getOtp());
            
            if (isValid) {
                response.put("success", true);
                response.put("message", "OTP verified successfully");
                return ResponseEntity.ok(response);
            } else {
                response.put("success", false);
                response.put("message", "Invalid or expired OTP");
                return ResponseEntity.badRequest().body(response);
            }
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Failed to verify OTP. Please try again.");
            return ResponseEntity.internalServerError().body(response);
        }
    }
}
