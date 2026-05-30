package com.jeonshijang.api.domain.common;

import jakarta.persistence.Column;
import jakarta.persistence.EntityListeners;
import jakarta.persistence.MappedSuperclass;
import lombok.Getter;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;

/**
 * 역할: 모든 엔티티 공통 속성(생성일, 수정일)을 정의하는 부모 클래스입니다.
 */
@Getter
@MappedSuperclass // 핵심: 자식 엔티티에게 이 클래스의 필드를 컬럼으로 물려줍니다.
@EntityListeners(AuditingEntityListener.class) // 핵심: 엔티티 생성/수정 시 자동으로 시간을 기록해주는 JPA Auditing 기능을 활성화합니다.
public abstract class BaseEntity {

    @CreatedDate // 핵심: 엔티티가 최초 생성될 때의 시간을 자동으로 저장합니다.
    @Column(updatable = false)
    private LocalDateTime createdAt;

    @LastModifiedDate // 핵심: 엔티티가 수정될 때마다의 시간을 자동으로 갱신하여 저장합니다.
    private LocalDateTime updatedAt;
}
