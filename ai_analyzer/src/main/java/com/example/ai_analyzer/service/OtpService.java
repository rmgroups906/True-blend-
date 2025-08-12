// src/main/java/com/example/ai_analyzer/service/OtpService.java
package com.example.ai_analyzer.service;

import org.springframework.stereotype.Service;
import java.util.HashMap;
import java.util.Map;
import java.util.Random;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;

@Service
public class OtpService {
    private final Map<String, OtpData> otpStorage = new HashMap<>();
    private final Map<String, LocalDateTime> lastOtpRequest = new HashMap<>();
    
    private static final int OTP_EXPIRY_MINUTES = 5;
    private static final int RATE_LIMIT_MINUTES = 1;
    private static final int OTP_LENGTH = 6;

    public static class OtpData {
        private final String otp;
        private final LocalDateTime createdAt;
        
        public OtpData(String otp) {
            this.otp = otp;
            this.createdAt = LocalDateTime.now();
        }
        
        public String getOtp() { return otp; }
        public LocalDateTime getCreatedAt() { return createdAt; }
        
        public boolean isExpired() {
            return ChronoUnit.MINUTES.between(createdAt, LocalDateTime.now()) > OTP_EXPIRY_MINUTES;
        }
    }

    public String generateOtp(String phoneNumber) throws RuntimeException {
        // Validate phone number
        if (phoneNumber == null || phoneNumber.trim().isEmpty()) {
            throw new RuntimeException("Phone number is required");
        }
        
        // Check rate limiting
        LocalDateTime lastRequest = lastOtpRequest.get(phoneNumber);
        if (lastRequest != null) {
            long minutesSinceLastRequest = ChronoUnit.MINUTES.between(lastRequest, LocalDateTime.now());
            if (minutesSinceLastRequest < RATE_LIMIT_MINUTES) {
                throw new RuntimeException("Please wait " + (RATE_LIMIT_MINUTES - minutesSinceLastRequest) + " minutes before requesting another OTP");
            }
        }
        
        // Generate OTP
        String otp = generateRandomOtp();
        otpStorage.put(phoneNumber, new OtpData(otp));
        lastOtpRequest.put(phoneNumber, LocalDateTime.now());
        
        // Simulate sending via SMS (in production, integrate with SMS service)
        System.out.println("OTP for " + phoneNumber + ": " + otp);
        
        return otp;
    }

    public boolean verifyOtp(String phoneNumber, String otp) {
        if (phoneNumber == null || phoneNumber.trim().isEmpty()) {
            return false;
        }
        
        if (otp == null || otp.trim().isEmpty()) {
            return false;
        }
        
        OtpData otpData = otpStorage.get(phoneNumber);
        if (otpData == null) {
            return false;
        }
        
        // Check if OTP is expired
        if (otpData.isExpired()) {
            otpStorage.remove(phoneNumber);
            return false;
        }
        
        // Verify OTP
        boolean isValid = otp.equals(otpData.getOtp());
        if (isValid) {
            // Remove OTP after successful verification
            otpStorage.remove(phoneNumber);
        }
        
        return isValid;
    }
    
    private String generateRandomOtp() {
        Random random = new Random();
        StringBuilder otp = new StringBuilder();
        for (int i = 0; i < OTP_LENGTH; i++) {
            otp.append(random.nextInt(10));
        }
        return otp.toString();
    }
    
    // Cleanup expired OTPs (can be called periodically)
    public void cleanupExpiredOtps() {
        otpStorage.entrySet().removeIf(entry -> entry.getValue().isExpired());
    }
}
