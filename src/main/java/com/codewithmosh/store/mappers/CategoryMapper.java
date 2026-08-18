package com.codewithmosh.store.mappers;

import com.codewithmosh.store.dtos.CategoryRequest;
import com.codewithmosh.store.dtos.CategoryResponse;
import com.codewithmosh.store.entities.Category;
import org.springframework.stereotype.Component;

@Component
public class CategoryMapper {
    public Category toEntity(CategoryRequest request, Category parent){
        return Category.builder()
                .name(request.getName())
                .slug(request.getSlug())
                .description(request.getDescription())
                .parent(parent)
                .build();
    }

    public CategoryResponse toResponse(Category category){
        Long parentId = null;
        if(category.getParent() != null){
            parentId = category.getParent().getId();
        }

        return CategoryResponse.builder()
                .id(category.getId())
                .name(category.getName())
                .slug(category.getSlug())
                .description(category.getDescription())
                .parentId(parentId)
                .createdAt(category.getCreateAt())
                .updatedAt(category.getUpdateAt())
                .build();
    }

    public Category updateEntity(CategoryRequest request, Category category, Category parent){
        category.setName(request.getName());
        category.setSlug(request.getSlug());
        category.setDescription(request.getDescription());
        category.setParent(parent);
        return category;
    }


}
