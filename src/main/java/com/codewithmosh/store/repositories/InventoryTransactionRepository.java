package com.codewithmosh.store.repositories;

import com.codewithmosh.store.entities.InventoryTransaction;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface InventoryTransactionRepository extends JpaRepository<InventoryTransaction, Long> {
    List<InventoryTransaction> findByVariantIdOrderByCreatedAtDesc(Long variantId);
}