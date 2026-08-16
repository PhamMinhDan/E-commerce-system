package com.codewithmosh.store.entities;

import jakarta.persistence.*;
import lombok.*;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Objects;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "order_coupons")
@IdClass(OrderCoupon.OrderCouponId.class)
public class OrderCoupon {
    @Id
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "order_id", nullable = false)
    private Order order;

    @Id
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "coupon_id", nullable = false)
    private Coupon coupon;

    @Column(name = "discount_amount", nullable = false, precision = 15, scale = 2)
    private BigDecimal discountAmount;

    @Getter
    @Setter
    @NoArgsConstructor
    @AllArgsConstructor
    public static class OrderCouponId implements Serializable {
        private Long order;
        private Long coupon;

        @Override
        public boolean equals(Object o) {
            if (this == o) return true;
            if (!(o instanceof OrderCouponId that)) return false;
            return Objects.equals(order, that.order) && Objects.equals(coupon, that.coupon);
        }

        @Override
        public int hashCode() {
            return Objects.hash(order, coupon);
        }
    }
}