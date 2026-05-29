-- ================================================================
-- 개발용 더미 데이터 (백엔드 시작 시 H2 DB에 자동 삽입)
-- Spring Boot ddl-auto: create-drop 이므로 서버 재시작마다 초기화됨
-- ================================================================

-- 테스트 유저 (Kakao 로그인 전 API 테스트용)
INSERT INTO users (kakao_id, nickname, profile_image_url, role, created_at, updated_at)
VALUES (99999, '테스트유저', 'https://k.kakaocdn.net/dn/1ox76/dummy', 'USER', NOW(), NOW());

-- 굿즈 더미 데이터 (user_id = 1 → 위에서 삽입한 테스트 유저)
INSERT INTO goods (user_id, name, image_url, purchased_at, price, memo, created_at, updated_at) VALUES
(1, '레제',   'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=400', '2024-01-15', 45000.00, '반다이 마스터그레이드 Ver.3.0', NOW(), NOW()),
(1, '도로롱 피규어',  'https://images.unsplash.com/photo-1608889174637-3c44f6326f1a?w=400', '2024-02-20', 28000.00, '포켓몬 센터 한정판 20cm', NOW(), NOW()),
(1, '고양이 키링',    'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=400', '2024-03-05', 12000.00, '핸드메이드 뜨개질 키링', NOW(), NOW()),
(1, '포토카드 세트',  'https://images.unsplash.com/photo-1543466835-00a7907e9de1?w=400', '2024-03-12',  8000.00, '공식 포토카드 5종 세트', NOW(), NOW()),
(1, '뽀로로 인형',    'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400', '2024-04-01', 15000.00, '어릴 때부터 갖고 싶었던 25cm', NOW(), NOW());
