package com.codewithmosh.store.repositories;

import com.codewithmosh.store.entities.ProductAttributeValue;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ProductAttributeValueRepository extends JpaRepository<ProductAttributeValue, Long> {
    List<ProductAttributeValue> findByVariantId(Long variantId);
}