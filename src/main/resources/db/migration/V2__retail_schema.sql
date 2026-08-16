-- 1. Users
CREATE TABLE users (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    username        VARCHAR(50)  NOT NULL UNIQUE,
    email           VARCHAR(255) NOT NULL UNIQUE,
    password_hash   VARCHAR(255) NOT NULL,
    first_name      VARCHAR(100),
    last_name       VARCHAR(100),
    phone           VARCHAR(20)  UNIQUE,
    status          VARCHAR(20)  NOT NULL DEFAULT 'ACTIVE',
    created_at      DATETIME     NOT NULL,
    updated_at      DATETIME     NOT NULL
);

-- 2. Roles
CREATE TABLE roles (
    id   BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
);

-- 3. user_roles (junction table M:N)
CREATE TABLE user_roles (
    user_id     BIGINT NOT NULL,
    role_id     BIGINT NOT NULL,
    PRIMARY KEY (user_id, role_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE
);

-- 4. Addresses
CREATE TABLE addresses (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id         BIGINT       NOT NULL,
    recipient_name  VARCHAR(150) NOT NULL,
    phone           VARCHAR(20)  NOT NULL,
    address_line    VARCHAR(255) NOT NULL,
    ward            VARCHAR(100),
    district        VARCHAR(100),
    province        VARCHAR(100),
    is_default      BOOLEAN      NOT NULL DEFAULT false,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 5. Categories (self-reference)
CREATE TABLE categories (
    id        BIGINT AUTO_INCREMENT PRIMARY KEY,
    parent_id BIGINT,
    name      VARCHAR(150) NOT NULL,
    slug      VARCHAR(150) NOT NULL UNIQUE,
    FOREIGN KEY (parent_id) REFERENCES categories(id) ON DELETE SET NULL
);

-- 6. Brands
CREATE TABLE brands (
    id   BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL UNIQUE,
    slug VARCHAR(150) NOT NULL UNIQUE
);

-- 7. Products
CREATE TABLE products (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    category_id BIGINT       NOT NULL,
    brand_id    BIGINT,
    name        VARCHAR(255) NOT NULL,
    slug        VARCHAR(255) NOT NULL UNIQUE,
    description TEXT,
    status      VARCHAR(20)  NOT NULL DEFAULT 'ACTIVE',
    created_at  DATETIME     NOT NULL,
    updated_at  DATETIME     NOT NULL,
    FOREIGN KEY (category_id) REFERENCES categories(id),
    FOREIGN KEY (brand_id)    REFERENCES brands(id)
);

-- 8. Product Variants (SKU)
CREATE TABLE product_variants (
    id         BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_id BIGINT         NOT NULL,
    sku        VARCHAR(100)   NOT NULL UNIQUE,
    name       VARCHAR(255),
    price      DECIMAL(15, 2) NOT NULL,
    status     VARCHAR(20)    NOT NULL DEFAULT 'ACTIVE',
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

-- 9. Product Attributes
CREATE TABLE product_attributes (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    category_id BIGINT       NOT NULL,
    name        VARCHAR(100) NOT NULL,
    type        VARCHAR(20)  NOT NULL,
    FOREIGN KEY (category_id) REFERENCES categories(id)
);

-- 10. Product Attribute Values
CREATE TABLE product_attribute_values (
    id           BIGINT AUTO_INCREMENT PRIMARY KEY,
    variant_id   BIGINT       NOT NULL,
    attribute_id BIGINT       NOT NULL,
    value        VARCHAR(255) NOT NULL,
    UNIQUE (variant_id, attribute_id),
    FOREIGN KEY (variant_id)   REFERENCES product_variants(id) ON DELETE CASCADE,
    FOREIGN KEY (attribute_id) REFERENCES product_attributes(id)
);

-- 11. Product Images
CREATE TABLE product_images (
    id            BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_id    BIGINT       NOT NULL,
    image_url     VARCHAR(500) NOT NULL,
    display_order INT          NOT NULL DEFAULT 0,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

-- 12. Variant Images
CREATE TABLE variant_images (
    id            BIGINT AUTO_INCREMENT PRIMARY KEY,
    variant_id    BIGINT       NOT NULL,
    image_url     VARCHAR(500) NOT NULL,
    display_order INT          NOT NULL DEFAULT 0,
    FOREIGN KEY (variant_id) REFERENCES product_variants(id) ON DELETE CASCADE
);

-- 13. Inventory (1-1 with product_variants)
CREATE TABLE inventory (
    variant_id        BIGINT PRIMARY KEY,
    quantity          INT       NOT NULL DEFAULT 0,
    reserved_quantity INT       NOT NULL DEFAULT 0,
    updated_at        DATETIME  NOT NULL,
    FOREIGN KEY (variant_id) REFERENCES product_variants(id) ON DELETE CASCADE
);

-- 14. Inventory Transactions
CREATE TABLE inventory_transactions (
    id               BIGINT AUTO_INCREMENT PRIMARY KEY,
    variant_id       BIGINT       NOT NULL,
    transaction_type VARCHAR(30)  NOT NULL,
    quantity         INT          NOT NULL,
    reference_type   VARCHAR(30),
    reference_id     BIGINT,
    created_at       DATETIME     NOT NULL,
    FOREIGN KEY (variant_id) REFERENCES product_variants(id)
);

-- 15. Carts
CREATE TABLE carts (
    id         BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id    BIGINT,
    session_id VARCHAR(100) UNIQUE,
    created_at DATETIME    NOT NULL,
    updated_at DATETIME    NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CHECK (user_id IS NOT NULL OR session_id IS NOT NULL)
);

-- 16. Cart Items
CREATE TABLE cart_items (
    id        BIGINT AUTO_INCREMENT PRIMARY KEY,
    cart_id   BIGINT NOT NULL,
    variant_id BIGINT NOT NULL,
    quantity  INT    NOT NULL,
    UNIQUE (cart_id, variant_id),
    FOREIGN KEY (cart_id)    REFERENCES carts(id) ON DELETE CASCADE,
    FOREIGN KEY (variant_id) REFERENCES product_variants(id)
);

-- 17. Orders
CREATE TABLE orders (
    id                  BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id             BIGINT         NOT NULL,
    shipping_address_id BIGINT         NOT NULL,
    status              VARCHAR(30)    NOT NULL DEFAULT 'PENDING',
    subtotal            DECIMAL(15, 2) NOT NULL DEFAULT 0,
    discount_amount     DECIMAL(15, 2) NOT NULL DEFAULT 0,
    shipping_fee        DECIMAL(15, 2) NOT NULL DEFAULT 0,
    total_amount        DECIMAL(15, 2) NOT NULL,
    cancel_reason       VARCHAR(500),
    note                TEXT,
    created_at          DATETIME       NOT NULL,
    updated_at          DATETIME       NOT NULL,
    FOREIGN KEY (user_id)             REFERENCES users(id),
    FOREIGN KEY (shipping_address_id) REFERENCES addresses(id)
);

-- 18. Order Items (with snapshot)
CREATE TABLE order_items (
    id           BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id     BIGINT         NOT NULL,
    variant_id   BIGINT         NOT NULL,
    product_name VARCHAR(255)   NOT NULL,
    variant_name VARCHAR(255),
    sku          VARCHAR(100)   NOT NULL,
    quantity     INT            NOT NULL,
    unit_price   DECIMAL(15, 2) NOT NULL,
    FOREIGN KEY (order_id)   REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (variant_id) REFERENCES product_variants(id)
);

-- 19. Order Status History
CREATE TABLE order_status_history (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id    BIGINT       NOT NULL,
    old_status  VARCHAR(30),
    new_status  VARCHAR(30)  NOT NULL,
    changed_by  BIGINT,
    note        VARCHAR(500),
    created_at  DATETIME     NOT NULL,
    FOREIGN KEY (order_id)   REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (changed_by) REFERENCES users(id)
);

-- 20. Payments
CREATE TABLE payments (
    id             BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id       BIGINT         NOT NULL,
    payment_method VARCHAR(30)    NOT NULL,
    status         VARCHAR(30)    NOT NULL DEFAULT 'PENDING',
    amount         DECIMAL(15, 2) NOT NULL,
    created_at     DATETIME       NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id)
);

-- 21. Payment Transactions
CREATE TABLE payment_transactions (
    id               BIGINT AUTO_INCREMENT PRIMARY KEY,
    payment_id       BIGINT         NOT NULL,
    transaction_type VARCHAR(30)    NOT NULL,
    status           VARCHAR(30)    NOT NULL,
    amount           DECIMAL(15, 2) NOT NULL,
    transaction_id   VARCHAR(255)   UNIQUE,
    gateway_response TEXT,
    created_at       DATETIME       NOT NULL,
    FOREIGN KEY (payment_id) REFERENCES payments(id) ON DELETE CASCADE
);

-- 22. Shipments
CREATE TABLE shipments (
    id              BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id        BIGINT       NOT NULL,
    carrier         VARCHAR(100),
    tracking_number VARCHAR(255) UNIQUE,
    status          VARCHAR(30)  NOT NULL DEFAULT 'PENDING',
    shipped_at      DATETIME,
    delivered_at    DATETIME,
    created_at      DATETIME     NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id)
);

-- 23. Shipment Items
CREATE TABLE shipment_items (
    id            BIGINT AUTO_INCREMENT PRIMARY KEY,
    shipment_id   BIGINT NOT NULL,
    order_item_id BIGINT NOT NULL,
    quantity      INT    NOT NULL,
    FOREIGN KEY (shipment_id)   REFERENCES shipments(id) ON DELETE CASCADE,
    FOREIGN KEY (order_item_id) REFERENCES order_items(id)
);

-- 24. Shipment Tracking
CREATE TABLE shipment_tracking (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    shipment_id BIGINT       NOT NULL,
    status      VARCHAR(30)  NOT NULL,
    location    VARCHAR(255),
    note        VARCHAR(500),
    created_at  DATETIME     NOT NULL,
    FOREIGN KEY (shipment_id) REFERENCES shipments(id) ON DELETE CASCADE
);

-- 25. Coupons
CREATE TABLE coupons (
    id                   BIGINT AUTO_INCREMENT PRIMARY KEY,
    code                 VARCHAR(50)    NOT NULL UNIQUE,
    discount_type        VARCHAR(20)    NOT NULL,
    discount_value       DECIMAL(15, 2) NOT NULL,
    min_order_amount     DECIMAL(15, 2),
    max_discount_amount  DECIMAL(15, 2),
    usage_limit          INT,
    usage_limit_per_user INT,
    start_at             DATETIME       NOT NULL,
    end_at               DATETIME       NOT NULL,
    status               VARCHAR(20)    NOT NULL DEFAULT 'ACTIVE'
);

-- 26. Coupon Usage
CREATE TABLE coupon_usage (
    id               BIGINT AUTO_INCREMENT PRIMARY KEY,
    coupon_id        BIGINT         NOT NULL,
    user_id          BIGINT         NOT NULL,
    order_id         BIGINT         NOT NULL,
    discount_amount  DECIMAL(15, 2) NOT NULL,
    used_at          DATETIME       NOT NULL,
    UNIQUE (coupon_id, user_id, order_id),
    FOREIGN KEY (coupon_id) REFERENCES coupons(id),
    FOREIGN KEY (user_id)   REFERENCES users(id),
    FOREIGN KEY (order_id)  REFERENCES orders(id)
);

-- 27. Order Coupons (composite PK)
CREATE TABLE order_coupons (
    order_id         BIGINT         NOT NULL,
    coupon_id        BIGINT         NOT NULL,
    discount_amount  DECIMAL(15, 2) NOT NULL,
    PRIMARY KEY (order_id, coupon_id),
    FOREIGN KEY (order_id)  REFERENCES orders(id)  ON DELETE CASCADE,
    FOREIGN KEY (coupon_id) REFERENCES coupons(id) ON DELETE CASCADE
);

-- 28. Reviews
CREATE TABLE reviews (
    id                   BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id              BIGINT   NOT NULL,
    product_id           BIGINT   NOT NULL,
    rating               TINYINT  NOT NULL,
    comment              TEXT,
    is_verified_purchase BOOLEAN  NOT NULL DEFAULT false,
    parent_id            BIGINT,
    created_at           DATETIME NOT NULL,
    updated_at           DATETIME NOT NULL,
    FOREIGN KEY (user_id)    REFERENCES users(id),
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (parent_id)  REFERENCES reviews(id) ON DELETE CASCADE
);

-- 29. Wishlists
CREATE TABLE wishlists (
    id         BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id    BIGINT   NOT NULL,
    product_id BIGINT   NOT NULL,
    created_at DATETIME NOT NULL,
    UNIQUE (user_id, product_id),
    FOREIGN KEY (user_id)    REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

-- 30. Audit Logs
CREATE TABLE audit_logs (
    id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id     BIGINT,
    action      VARCHAR(50)  NOT NULL,
    entity_type VARCHAR(50)  NOT NULL,
    entity_id   BIGINT,
    old_values  TEXT,
    new_values  TEXT,
    ip_address  VARCHAR(45),
    created_at  DATETIME     NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- =====================================================
-- Indexes for performance
-- =====================================================
CREATE INDEX idx_user_roles_user_id ON user_roles(user_id);
CREATE INDEX idx_user_roles_role_id ON user_roles(role_id);
CREATE INDEX idx_addresses_user_id ON addresses(user_id);
CREATE INDEX idx_products_category_id ON products(category_id);
CREATE INDEX idx_products_brand_id ON products(brand_id);
CREATE INDEX idx_product_variants_product_id ON product_variants(product_id);
CREATE INDEX idx_inventory_transactions_variant_id ON inventory_transactions(variant_id);
CREATE INDEX idx_inventory_transactions_created_at ON inventory_transactions(created_at);
CREATE INDEX idx_carts_user_id ON carts(user_id);
CREATE INDEX idx_cart_items_cart_id ON cart_items(cart_id);
CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_created_at ON orders(created_at);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_payments_order_id ON payments(order_id);
CREATE INDEX idx_payment_transactions_payment_id ON payment_transactions(payment_id);
CREATE INDEX idx_shipments_order_id ON shipments(order_id);
CREATE INDEX idx_shipments_tracking_number ON shipments(tracking_number);
CREATE INDEX idx_reviews_product_id ON reviews(product_id);
CREATE INDEX idx_reviews_user_id ON reviews(user_id);
CREATE INDEX idx_wishlists_user_id ON wishlists(user_id);
CREATE INDEX idx_audit_logs_entity ON audit_logs(entity_type, entity_id);
CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
