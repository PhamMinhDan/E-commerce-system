package com.codewithmosh.store.repositories;

import com.codewithmosh.store.entities.Category;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;

public interface CategoryRepository extends JpaRepository<Category, Long> {
    Optional<Category> findBySlug(String slug);
    List<Category> findByParentId(Long parentId);
    boolean existsBySlug(String slug);
    boolean existsBySlugAndIdNot(String slug, Long id);
    List<Category> findByParentIsNull();
    @Query("SELECT c FROM Category c WHERE c.parent.id = :parentId")
    List<Category> findChildren(Long parentId);
}