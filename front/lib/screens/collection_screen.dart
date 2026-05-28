import 'package:flutter/material.dart';

// 더미 데이터 모델 — Step 4 백엔드 연동 시 API 응답으로 교체 예정
class _GoodsItem {
  final String name;
  final int price;
  final String imageUrl;
  const _GoodsItem({required this.name, required this.price, required this.imageUrl});
}

final _dummyGoods = [
  _GoodsItem(name: '건담 RX-78', price: 45000, imageUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=200'),
  _GoodsItem(name: '포켓몬 피규어', price: 28000, imageUrl: 'https://images.unsplash.com/photo-1608889174637-3c44f6326f1a?w=200'),
  _GoodsItem(name: '고양이 키링', price: 12000, imageUrl: 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=200'),
  _GoodsItem(name: '포토카드 세트', price: 8000, imageUrl: 'https://images.unsplash.com/photo-1543466835-00a7907e9de1?w=200'),
];

class CollectionScreen extends StatefulWidget {
  const CollectionScreen({super.key});

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  void _showAddGoodsSheet() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 키보드가 올라와도 시트가 밀려 올라감
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '새 피규어 추가',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // 이미지 선택 영역 — Step 4 연동 시 ImagePicker로 교체
              GestureDetector(
                onTap: () {}, // TODO: 카메라/갤러리 선택
                child: Container(
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo_outlined, size: 36, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      Text('사진 추가', style: TextStyle(color: Colors.grey.shade500)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: '피규어 이름',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: '구매 가격 (원)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  // TODO: Step 4 백엔드 POST /api/goods 연동
                  Navigator.pop(context);
                },
                child: const Text('등록하기', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 컬렉션', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '총 ${_dummyGoods.length}개',
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
      body: _dummyGoods.isEmpty
          ? const _EmptyCollectionView()
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: _dummyGoods.length,
              itemBuilder: (context, index) {
                return _GoodsCard(goods: _dummyGoods[index]);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddGoodsSheet,
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _GoodsCard extends StatelessWidget {
  final _GoodsItem goods;
  const _GoodsCard({required this.goods});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                goods.imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goods.name,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '₩${goods.price.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},')}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCollectionView extends StatelessWidget {
  const _EmptyCollectionView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('아직 등록된 피규어가 없어요', style: TextStyle(color: Colors.grey.shade500)),
          const SizedBox(height: 8),
          Text('+ 버튼을 눌러 첫 번째 피규어를 추가해보세요', style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
        ],
      ),
    );
  }
}
