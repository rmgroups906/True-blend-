package com.example.ai_analyzer.service;

import com.example.ai_analyzer.dto.*;
import com.example.ai_analyzer.entity.User;
import com.example.ai_analyzer.repository.UserRepository;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    private final String SECRET_KEY = "secret"; // Use a secure key in production

    public AuthResponse signup(SignupRequest request) {
        // Check if email already exists
        Optional<User> existingUserByEmail = userRepository.findByEmail(request.getEmail());
        if (existingUserByEmail.isPresent()) {
            return new AuthResponse("Email already in use", null);
        }

        // Check if phone number already exists
        if (request.getPhoneNumber() != null && !request.getPhoneNumber().trim().isEmpty()) {
            Optional<User> existingUserByPhone = userRepository.findByPhoneNumber(request.getPhoneNumber());
            if (existingUserByPhone.isPresent()) {
                return new AuthResponse("Phone number already in use", null);
            }
        }

        User user = User.builder()
                .email(request.getEmail())
                .password(passwordEncoder.encode(request.getPassword()))
                .phoneNumber(request.getPhoneNumber())
                .build();

        userRepository.save(user);

        String token = generateToken(user.getEmail());

        return new AuthResponse("User registered successfully", token);
    }

    public AuthResponse login(AuthRequest request) {
        Optional<User> userOpt = userRepository.findByEmail(request.getEmail());
        if (userOpt.isEmpty()) {
            return new AuthResponse("Invalid credentials", null);
        }

        User user = userOpt.get();

        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            return new AuthResponse("Invalid credentials", null);
        }

        String token = generateToken(user.getEmail());

        return new AuthResponse("Login successful", token);
    }

    public String resetPassword(ResetPasswordRequest request) {
        // Try to find user by email first, then by phone number
        Optional<User> userOpt = Optional.empty();
        
        if (request.getEmail() != null && !request.getEmail().trim().isEmpty()) {
            userOpt = userRepository.findByEmail(request.getEmail());
        } else if (request.getPhoneNumber() != null && !request.getPhoneNumber().trim().isEmpty()) {
            userOpt = userRepository.findByPhoneNumber(request.getPhoneNumber());
        }
        
        if (userOpt.isEmpty()) {
            return "User not found";
        }

        User user = userOpt.get();
        
        // If new password is provided, update it
        if (request.getNewPassword() != null && !request.getNewPassword().trim().isEmpty()) {
            user.setPassword(passwordEncoder.encode(request.getNewPassword()));
            user.setResetToken(null); // Clear reset token after password change
            userRepository.save(user);
            return "Password reset successfully";
        } else {
            // Generate reset token for email-based reset
            String resetToken = UUID.randomUUID().toString();
            user.setResetToken(resetToken);
            userRepository.save(user);
            return "Password reset token: " + resetToken;
        }
    }

    private String generateToken(String email) {
        return Jwts.builder()
                .setSubject(email)
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + 86400000)) // 1 day
                .signWith(SignatureAlgorithm.HS256, SECRET_KEY)
                .compact();
    }
}
