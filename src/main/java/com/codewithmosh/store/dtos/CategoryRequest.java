package com.codewithmosh.store.dtos;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class CategoryRequest {
    @NotBlank(message = "Name is required")
    @Size(max = 150, message = "Name must not exceed 150 characters")
    private String name;

    @NotBlank(message = "Slug is required")
    @Size(max = 150, message = "Slug must not exceed 150 characters")
    private String slug;

    @Size(max = 150, message = "Description must not exceed 150 characters")
    private String description;

    private Long parentId;
}
