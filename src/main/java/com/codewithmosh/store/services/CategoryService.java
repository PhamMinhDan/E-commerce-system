package com.codewithmosh.store.services;

import com.codewithmosh.store.dtos.CategoryRequest;
import com.codewithmosh.store.dtos.CategoryResponse;
import com.codewithmosh.store.entities.Category;
import com.codewithmosh.store.mappers.CategoryMapper;
import com.codewithmosh.store.repositories.CategoryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.NoSuchElementException;

@Service
@RequiredArgsConstructor
public class CategoryService {
    private final CategoryRepository categoryRepository;
    private final CategoryMapper categoryMapper;

    public List<CategoryResponse> getAll(){
        return categoryRepository.findAll()
                .stream()
                .map(categoryMapper::toResponse)
                .toList();
    }

    public CategoryResponse getById(Long id){
        Category category = categoryRepository.findById(id)
                .orElseThrow(() -> new NoSuchElementException("Category with id=" + id + "not found"));
        return categoryMapper.toResponse(category);
    }

    public CategoryResponse create(CategoryRequest request){
        if(categoryRepository.existsBySlug(request.getSlug())){
            throw new IllegalArgumentException("Category with slug='" + request.getSlug() +"' already exists");
        }

        Category parent = null;
        if(request.getParentId() != null){
            parent = categoryRepository.findById(request.getParentId())
                    .orElseThrow(() -> new NoSuchElementException("Parent category with id=" + request.getParentId() + "not found"));
        }

        Category category = categoryMapper.toEntity(request, parent);
        Category saved = categoryRepository.save(category);
        return categoryMapper.toResponse(saved);
    }

    public CategoryResponse update(Long id, CategoryRequest request){
        Category category = categoryRepository.findById(id)
                .orElseThrow(() -> new NoSuchElementException("Category with id=" + id + "not found"));

        if(categoryRepository.existsBySlugAndIdNot(request.getSlug(), id)){
            throw new IllegalArgumentException("Category with slug='" + request.getSlug() + "' already exists");
        }

        Category parent = null;
        if (request.getParentId() != null) {
            parent = categoryRepository.findById(request.getParentId())
                    .orElseThrow(() -> new NoSuchElementException(
                            "Parent category with id=" + request.getParentId() + " not found"));
        }

        categoryMapper.updateEntity(request, category, parent);
        Category saved = categoryRepository.save(category);
        return categoryMapper.toResponse(saved);
    }

    public void delete(Long id){
        Category category = categoryRepository.findById(id)
                .orElseThrow(() -> new  NoSuchElementException(
                        "Category with id=" + id + " not found"));
        categoryRepository.delete(category);
    }

}
