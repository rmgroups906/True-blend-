package com.example.ai_analyzer.service;

import com.example.ai_analyzer.utils.MultipartInputStreamFileResource;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.*;

@Service
public class AnalysisService {

    private final String PYTHON_API_URL = "http://127.0.0.1:5000/analyze";

    public Map<String, Object> analyzeImage(MultipartFile image, String category) {
        Map<String, Object> responseMap = new HashMap<>();

        try {
            // Prepare headers
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.MULTIPART_FORM_DATA);

            // Prepare body with image
            LinkedMultiValueMap<String, Object> body = new LinkedMultiValueMap<>();
            body.add("image", new MultipartInputStreamFileResource(image.getInputStream(), image.getOriginalFilename()));

            // Build request entity
            HttpEntity<LinkedMultiValueMap<String, Object>> requestEntity = new HttpEntity<>(body, headers);

            // Send request
            RestTemplate restTemplate = new RestTemplate();
            ResponseEntity<String> response = restTemplate.postForEntity(PYTHON_API_URL, requestEntity, String.class);

            // Parse response
            if (response.getStatusCode() == HttpStatus.OK) {
                ObjectMapper mapper = new ObjectMapper();
                List<Map<String, Object>> pythonData = mapper.readValue(response.getBody(), List.class);

                List<Map<String, Object>> ingredientsList = new ArrayList<>();

                for (Map<String, Object> item : pythonData) {
                    Map<String, Object> ingredientInfo = new HashMap<>();
                    ingredientInfo.put("ingredient", item.get("ingredient"));
                    ingredientInfo.put("evaluation", item.get("evaluation"));
                    ingredientsList.add(ingredientInfo);
                }

                responseMap.put("status", "success");
                responseMap.put("ingredients", ingredientsList);

            } else {
                responseMap.put("status", "error");
                responseMap.put("message", "Python service failed with status: " + response.getStatusCodeValue());
            }

        } catch (IOException e) {
            responseMap.put("status", "error");
            responseMap.put("message", "Error processing image: " + e.getMessage());
        } catch (Exception ex) {
            responseMap.put("status", "error");
            responseMap.put("message", "Unexpected error: " + ex.getMessage());
        }

        return responseMap;
    }
}
