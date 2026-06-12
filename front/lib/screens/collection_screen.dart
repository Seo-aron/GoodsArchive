import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/goods_item.dart';
import '../services/goods_service.dart';
import 'goods_detail_screen.dart';

class CollectionScreen extends StatefulWidget {
  const CollectionScreen({super.key});

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  late Future<List<GoodsItem>> _goodsFuture;

  @override
  void initState() {
    super.initState();
    _goodsFuture = GoodsService.getGoods();
  }

  void _refresh() {
    setState(() {
      _goodsFuture = GoodsService.getGoods();
    });
  }

  Future<void> _showAddGoodsSheet() async {
    final added = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _AddGoodsSheet(),
    );
    if (added == true) _refresh();
  }

  Future<void> _openDetail(GoodsItem goods) async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => GoodsDetailScreen(goods: goods)),
    );
    if (result == 'deleted' || result == 'updated') _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 컬렉션', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh, tooltip: '새로고침'),
        ],
      ),
      body: FutureBuilder<List<GoodsItem>>(
        future: _goodsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off, size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text('서버에 연결할 수 없습니다', style: TextStyle(color: Colors.grey.shade600)),
                  const SizedBox(height: 4),
                  Text('백엔드가 실행 중인지 확인하세요',
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                  const SizedBox(height: 16),
                  TextButton(onPressed: _refresh, child: const Text('다시 시도')),
                ],
              ),
            );
          }

          final goods = snapshot.data!;

          if (goods.isEmpty) {
            return const _EmptyCollectionView();
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    Text('총 ${goods.length}개',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: goods.length,
                  itemBuilder: (context, index) {
                    return _GoodsCard(
                      goods: goods[index],
                      onTap: () => _openDetail(goods[index]),
                    );
                  },
                ),
              ),
            ],
          );
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

// ─────────────────────────────────────────────
// 등록 바텀시트 (StatefulWidget으로 분리해 이미지 상태 관리)
// ─────────────────────────────────────────────
class _AddGoodsSheet extends StatefulWidget {
  const _AddGoodsSheet();

  @override
  State<_AddGoodsSheet> createState() => _AddGoodsSheetState();
}

class _AddGoodsSheetState extends State<_AddGoodsSheet> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _memoController = TextEditingController();
  final _picker = ImagePicker();
  XFile? _selectedImage;
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('사진 추가'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, ImageSource.camera),
            child: const Row(children: [
              Icon(Icons.camera_alt),
              SizedBox(width: 12),
              Text('카메라로 촬영'),
            ]),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, ImageSource.gallery),
            child: const Row(children: [
              Icon(Icons.photo_library),
              SizedBox(width: 12),
              Text('갤러리에서 선택'),
            ]),
          ),
        ],
      ),
    );
    if (source == null) return;

    final image = await _picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1080,
    );
    if (image != null && mounted) setState(() => _selectedImage = image);
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('피규어 이름을 입력해주세요')),
      );
      return;
    }
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사진을 선택해주세요')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final priceText = _priceController.text.trim();
      final price = priceText.isNotEmpty ? double.tryParse(priceText) : null;

      await GoodsService.registerGoods(
        image: _selectedImage!,
        name: name,
        price: price,
        memo: _memoController.text.trim(),
      );

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('등록 실패: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('새 피규어 추가',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            // 이미지 영역
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                clipBehavior: Clip.hardEdge,
                child: _selectedImage != null
                    ? Image.file(File(_selectedImage!.path), fit: BoxFit.cover)
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo_outlined,
                              size: 36, color: Colors.grey.shade400),
                          const SizedBox(height: 8),
                          Text('사진 추가 (탭)',
                              style: TextStyle(color: Colors.grey.shade500)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: '피규어 이름 *',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '구매 가격 (원)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _memoController,
              decoration: InputDecoration(
                labelText: '메모',
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
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('등록하기', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 굿즈 카드
// ─────────────────────────────────────────────
class _GoodsCard extends StatelessWidget {
  final GoodsItem goods;
  final VoidCallback onTap;

  const _GoodsCard({required this.goods, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                    goods.formattedPrice,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
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
          Text('아직 등록된 피규어가 없어요',
              style: TextStyle(color: Colors.grey.shade500)),
          const SizedBox(height: 8),
          Text('+ 버튼을 눌러 첫 번째 피규어를 추가해보세요',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
        ],
      ),
    );
  }
}
