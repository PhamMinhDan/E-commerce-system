package com.codewithmosh.store.repositories;

import com.codewithmosh.store.entities.ShipmentTracking;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ShipmentTrackingRepository extends JpaRepository<ShipmentTracking, Long> {
    List<ShipmentTracking> findByShipmentIdOrderByCreatedAtAsc(Long shipmentId);
}