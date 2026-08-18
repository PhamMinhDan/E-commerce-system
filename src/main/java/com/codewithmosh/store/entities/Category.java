package com.codewithmosh.store.entities;

import jakarta.persistence.*;
import lombok.*;
import org.apache.logging.log4j.CloseableThreadContext;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
@Entity
@Table(name = "categories", indexes = {
        @Index(name = "idx_category_slug", columnList = "slug"),
        @Index(name = "idx_category_parent", columnList = "parent_id")
})
public class Category {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "parent_id")
    private Category parent;

    @Column(nullable = false, length = 150)
    private String name;

    @Column(nullable = false, unique = true, length = 150)
    private String slug;

    @Column(length = 50)
    private String description;

    @Column(name = "is_deleted", nullable = false)
    @Builder.Default
    private Boolean isDeleted = false;

    @Column(name = "create_at", nullable = false, updatable = false)
    private Instant createAt;

    @Column(name = "update_at", nullable = false)
    private Instant updateAt;

    @OneToMany(mappedBy = "parent")
    @Builder.Default
    private List<Category> children = new ArrayList<>();

    @PrePersist
    protected void onCreate(){
        Instant now = Instant.now();
        this.createAt = now;
        this.updateAt = now;
    }

    @PreUpdate
    protected void onUpdate(){
        this.updateAt = Instant.now();
    }
}