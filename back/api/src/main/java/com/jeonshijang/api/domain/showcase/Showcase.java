package com.jeonshijang.api.domain.showcase;

import com.jeonshijang.api.domain.common.BaseEntity;
import com.jeonshijang.api.domain.user.User;
import jakarta.persistence.*;
import lombok.*;

import java.util.ArrayList;
import java.util.List;

@Entity
@Table(
    name = "showcase",
    indexes = @Index(name = "idx_showcase_user_id", columnList = "user_id")
)
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Showcase extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(nullable = false)
    private String name;

    @OneToMany(
        mappedBy = "showcase",
        cascade = CascadeType.ALL,
        orphanRemoval = true,
        fetch = FetchType.LAZY
    )
    private List<ShowcaseItem> items = new ArrayList<>();

    @Builder
    public Showcase(User user, String name) {
        this.user = user;
        this.name = name;
    }

    public void updateName(String name) {
        this.name = name;
    }

    public void replaceItems(List<ShowcaseItem> newItems) {
        this.items.clear();
        this.items.addAll(newItems);
    }
}
