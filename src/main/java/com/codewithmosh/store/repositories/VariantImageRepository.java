package com.codewithmosh.store.repositories;

import com.codewithmosh.store.entities.VariantImage;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface VariantImageRepository extends JpaRepository<VariantImage, Long> {
    List<VariantImage> findByVariantIdOrderByDisplayOrderAsc(Long variantId);
}