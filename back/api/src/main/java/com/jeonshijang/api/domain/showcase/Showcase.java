package com.jeonshijang.api.domain.showcase;

import com.jeonshijang.api.domain.common.BaseEntity;
import com.jeonshijang.api.domain.user.User;
import jakarta.persistence.*;
import lombok.*;

import java.util.ArrayList;
import java.util.List;

/**
 * 역할: '전시장(Showcase)'의 정보를 담는 도메인 엔티티입니다.
 */
@Entity
@Table(
    name = "showcase",
    indexes = @Index(name = "idx_showcase_user_id", columnList = "user_id") // user_id로 조회가 많을 것을 대비한 인덱스 설정
)
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Showcase extends BaseEntity { // BaseEntity를 상속받아 생성일(createdAt)과 수정일(updatedAt)을 자동으로 관리합니다.

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY) // 핵심: 전시장은 특정 사용자(User)에게 속해있음을 나타내는 다대일 관계입니다.
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(nullable = false)
    private String name; // 전시장 이름

    @OneToMany( // 핵심: 하나의 전시장은 여러 개의 전시장 아이템(ShowcaseItem)을 가질 수 있음을 나타내는 일대다 관계입니다.
        mappedBy = "showcase", // ShowcaseItem 엔티티의 'showcase' 필드에 의해 매핑됨을 명시합니다.
        cascade = CascadeType.ALL, // 핵심: Showcase가 저장/삭제될 때, 관련된 모든 ShowcaseItem도 함께 저장/삭제됩니다. (영속성 전이)
        orphanRemoval = true, // 핵심: Showcase의 items 컬렉션에서 ShowcaseItem이 제거되면, 해당 아이템은 DB에서도 삭제됩니다. (고아 객체 제거)
        fetch = FetchType.LAZY
    )
    private List<ShowcaseItem> items = new ArrayList<>();

    @Builder
    public Showcase(User user, String name) {
        this.user = user;
        this.name = name;
    }

    /**
     * 역할: 전시장 이름을 수정합니다.
     */
    public void updateName(String name) {
        this.name = name;
    }

    /**
     * 역할: 전시장 내부의 모든 아이템을 새로운 아이템 목록으로 교체합니다.
     * 핵심: orphanRemoval=true 설정 덕분에, 기존 items 리스트에서 제거된 아이템들은 DB에서도 자동으로 삭제됩니다.
     */
    public void replaceItems(List<ShowcaseItem> newItems) {
        this.items.clear(); // 기존 아이템 목록을 모두 비웁니다.
        this.items.addAll(newItems); // 새로운 아이템 목록을 추가합니다.
    }
}
