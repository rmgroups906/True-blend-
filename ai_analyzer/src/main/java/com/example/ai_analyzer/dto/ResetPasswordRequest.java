package com.example.ai_analyzer.dto;

import lombok.Data;

@Data
public class ResetPasswordRequest {
    private String email;
    private String phoneNumber;
    private String newPassword;
}
