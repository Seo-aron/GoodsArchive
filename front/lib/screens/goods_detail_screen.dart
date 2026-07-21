import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/goods_item.dart';
import '../services/goods_service.dart';

class GoodsDetailScreen extends StatefulWidget {
  final GoodsItem goods;

  const GoodsDetailScreen({super.key, required this.goods});

  @override
  State<GoodsDetailScreen> createState() => _GoodsDetailScreenState();
}

class _GoodsDetailScreenState extends State<GoodsDetailScreen> {
  late GoodsItem _goods;

  @override
  void initState() {
    super.initState();
    _goods = widget.goods;
  }

  String _isoDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _displayDate(DateTime d) => '${d.year}년 ${d.month}월 ${d.day}일';

  Future<void> _showEditDialog() async {
    final nameCtrl = TextEditingController(text: _goods.name);
    final priceCtrl = TextEditingController(
        text: _goods.price != null ? _goods.price!.toInt().toString() : '');
    final memoCtrl = TextEditingController(text: _goods.memo ?? '');
    XFile? pickedImage;
    DateTime? editedPurchasedAt = _goods.purchasedAt != null
        ? DateTime.tryParse(_goods.purchasedAt!)
        : null;
    bool saving = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('굿즈 수정'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 이미지 선택 영역
                GestureDetector(
                  onTap: () async {
                    final source = await showDialog<ImageSource>(
                      context: ctx,
                      builder: (c) => SimpleDialog(
                        title: const Text('이미지 선택'),
                        children: [
                          SimpleDialogOption(
                            onPressed: () => Navigator.pop(c, ImageSource.camera),
                            child: const Text('카메라'),
                          ),
                          SimpleDialogOption(
                            onPressed: () => Navigator.pop(c, ImageSource.gallery),
                            child: const Text('갤러리'),
                          ),
                        ],
                      ),
                    );
                    if (source == null) return;
                    final picked = await ImagePicker().pickImage(source: source, imageQuality: 85);
                    if (picked != null) setDialogState(() => pickedImage = picked);
                  },
                  child: Container(
                    width: double.infinity,
                    height: 140,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          pickedImage != null
                              ? Image.network(pickedImage!.path, fit: BoxFit.cover,
                                  errorBuilder: (context, error, stack) =>
                                      Image.network(_goods.imageUrl, fit: BoxFit.cover))
                              : Image.network(_goods.imageUrl, fit: BoxFit.cover,
                                  errorBuilder: (context, error, stack) => const Icon(Icons.broken_image)),
                          Positioned(
                            right: 8, bottom: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.camera_alt, color: Colors.white, size: 14),
                                  SizedBox(width: 4),
                                  Text('변경', style: TextStyle(color: Colors.white, fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: '이름 *'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '가격 (원)'),
                ),
                const SizedBox(height: 12),
                // 날짜 선택
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: ctx,
                      initialDate: editedPurchasedAt ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                      locale: const Locale('ko', 'KR'),
                      helpText: '구매 날짜 선택',
                      cancelText: '취소',
                      confirmText: '확인',
                    );
                    if (date != null) setDialogState(() => editedPurchasedAt = date);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF5FB),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_outlined,
                            size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 8),
                        Text(
                          editedPurchasedAt != null
                              ? _displayDate(editedPurchasedAt!)
                              : '구매 날짜 (선택)',
                          style: TextStyle(
                            fontSize: 13,
                            color: editedPurchasedAt != null
                                ? Colors.black87
                                : Colors.grey.shade500,
                          ),
                        ),
                        const Spacer(),
                        if (editedPurchasedAt != null)
                          GestureDetector(
                            onTap: () => setDialogState(() => editedPurchasedAt = null),
                            child: Icon(Icons.close,
                                size: 16, color: Colors.grey.shade500),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: memoCtrl,
                  decoration: const InputDecoration(labelText: '메모'),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: saving ? null : () => Navigator.pop(ctx),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: saving
                  ? null
                  : () async {
                      final name = nameCtrl.text.trim();
                      if (name.isEmpty) return;
                      setDialogState(() => saving = true);
                      try {
                        final priceText = priceCtrl.text.trim();
                        final updated = await GoodsService.updateGoods(
                          _goods.id,
                          name: name,
                          price: priceText.isNotEmpty ? double.tryParse(priceText) : null,
                          purchasedAt: editedPurchasedAt != null
                              ? _isoDate(editedPurchasedAt!)
                              : null,
                          memo: memoCtrl.text.trim(),
                          image: pickedImage,
                        );
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (mounted) setState(() => _goods = updated);
                      } catch (e) {
                        setDialogState(() => saving = false);
                        if (ctx.mounted) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            SnackBar(content: Text('수정 실패: $e')),
                          );
                        }
                      }
                    },
              child: saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('저장', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('삭제 확인'),
        content: Text('"${_goods.name}"을(를) 삭제하시겠습니까?\n삭제된 굿즈는 복구할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await GoodsService.deleteGoods(_goods.id);
      if (mounted) Navigator.pop(context, 'deleted');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('삭제 실패: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                _goods.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => Container(
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.broken_image, size: 64, color: Colors.grey),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _goods.name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _goods.formattedPrice,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (_goods.purchasedAt != null) ...[
                    const SizedBox(height: 12),
                    _InfoRow(label: '구매일', value: _goods.purchasedAt!),
                  ],
                  if (_goods.memo != null && _goods.memo!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _InfoRow(label: '메모', value: _goods.memo!),
                  ],
                  const SizedBox(height: 36),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _showEditDialog,
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('수정'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _confirmDelete,
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('삭제'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          child: Text(label,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
        ),
        Expanded(
          child: Text(value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }
}
