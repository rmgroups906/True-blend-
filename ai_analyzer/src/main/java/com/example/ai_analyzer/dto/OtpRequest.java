// src/main/java/com/example/ai_analyzer/dto/OtpRequest.java
package com.example.ai_analyzer.dto;

import lombok.Data;

@Data
public class OtpRequest {
    private String phoneNumber;
    private String otp;
}
