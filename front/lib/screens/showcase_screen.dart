import 'package:flutter/material.dart';
import '../models/goods_item.dart';
import '../models/showcase_data.dart';
import '../services/goods_service.dart';
import '../services/showcase_service.dart';

class ShowcaseScreen extends StatefulWidget {
  const ShowcaseScreen({super.key});

  @override
  State<ShowcaseScreen> createState() => _ShowcaseScreenState();
}

class _ShowcaseScreenState extends State<ShowcaseScreen> {
  List<GoodsItem> _goods = [];
  // goodsId -> 캔버스 내 상대 좌표 (0.0 ~ 1.0)
  Map<int, Offset> _positions = {};
  int? _showcaseId;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final goods = await GoodsService.getGoods();
      final showcase = await ShowcaseService.getMyShowcase();

      final savedPositions = <int, Offset>{};
      for (final item in showcase.items) {
        savedPositions[item.goodsId] =
            Offset(item.positionX, item.positionY);
      }

      // 저장된 위치 없는 굿즈는 격자 배치
      int i = 0;
      for (final g in goods) {
        if (!savedPositions.containsKey(g.id)) {
          savedPositions[g.id] = Offset(
            0.15 + (i % 3) * 0.3,
            0.1 + (i ~/ 3) * 0.25,
          );
          i++;
        }
      }

      setState(() {
        _goods = goods;
        _showcaseId = showcase.id;
        _positions = savedPositions;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    if (_showcaseId == null) return;
    setState(() => _saving = true);
    try {
      final items = _goods
          .map((g) => PlaceItemDto(
                goodsId: g.id,
                positionX: (_positions[g.id] ?? const Offset(0.5, 0.5)).dx,
                positionY: (_positions[g.id] ?? const Offset(0.5, 0.5)).dy,
                scale: 1.0,
              ))
          .toList();
      await ShowcaseService.placeItems(_showcaseId!, items);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('전시장이 저장되었습니다!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장 실패: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('전시장 꾸미기',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (!_loading && _error == null)
            _saving
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                : TextButton(
                    onPressed: _save,
                    child: const Text('저장',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError()
              : _buildCanvas(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text('데이터를 불러올 수 없습니다',
              style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              setState(() {
                _loading = true;
                _error = null;
              });
              _loadData();
            },
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  Widget _buildCanvas() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        return Stack(
          children: [
            // 배경
            Container(
              width: w,
              height: h,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                ),
              ),
            ),
            // 안내 텍스트
            Positioned(
              top: 12,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '피규어를 드래그해서 배치하세요',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ),
              ),
            ),
            // 굿즈 아이템 (드래그 가능)
            ..._goods.map((goods) {
              return _DraggableGoodsItem(
                goods: goods,
                position: _positions[goods.id] ?? const Offset(0.5, 0.5),
                canvasWidth: w,
                canvasHeight: h,
                onPositionChanged: (newPos) {
                  setState(() => _positions[goods.id] = newPos);
                },
              );
            }),
          ],
        );
      },
    );
  }
}

class _DraggableGoodsItem extends StatelessWidget {
  static const double _itemSize = 72.0;

  final GoodsItem goods;
  final Offset position; // 0.0 ~ 1.0 상대 좌표
  final double canvasWidth;
  final double canvasHeight;
  final ValueChanged<Offset> onPositionChanged;

  const _DraggableGoodsItem({
    required this.goods,
    required this.position,
    required this.canvasWidth,
    required this.canvasHeight,
    required this.onPositionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final left = position.dx * canvasWidth - _itemSize / 2;
    final top = position.dy * canvasHeight - _itemSize / 2;

    return Positioned(
      left: left.clamp(0, canvasWidth - _itemSize),
      top: top.clamp(0, canvasHeight - _itemSize),
      child: GestureDetector(
        onPanUpdate: (details) {
          final newDx =
              (position.dx + details.delta.dx / canvasWidth).clamp(0.05, 0.95);
          final newDy =
              (position.dy + details.delta.dy / canvasHeight).clamp(0.05, 0.95);
          onPositionChanged(Offset(newDx, newDy));
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: _itemSize,
              height: _itemSize,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white24, width: 1.5),
                boxShadow: const [
                  BoxShadow(color: Colors.black45, blurRadius: 8)
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: Image.network(
                  goods.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFF2A2A4A),
                    child: const Icon(Icons.broken_image,
                        color: Colors.white38, size: 28),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                goods.name,
                style: const TextStyle(color: Colors.white70, fontSize: 9),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
