import 'package:flutter/material.dart';
import '../models/goods_item.dart';
import '../services/goods_service.dart';
import '../services/showcase_service.dart';

// 선반 내 아이템 상태
class _ItemState {
  int shelfNumber;
  double xPosition; // 0.0~1.0 선반 너비 기준
  double yPosition; // 0.0~1.0 선반 높이 기준
  double scale;

  _ItemState({
    required this.shelfNumber,
    required this.xPosition,
    required this.yPosition,
    required this.scale,
  });
}

class ShowcaseScreen extends StatefulWidget {
  const ShowcaseScreen({super.key});

  @override
  State<ShowcaseScreen> createState() => _ShowcaseScreenState();
}

class _ShowcaseScreenState extends State<ShowcaseScreen> {
  List<GoodsItem> _goods = [];
  // goodsId → 현재 페이지에서의 배치 상태
  // _pageItems[page][goodsId] = _ItemState
  final Map<int, Map<int, _ItemState>> _pageItems = {};
  int _currentPage = 1;
  int _maxPages = 3;
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

      final pageItems = <int, Map<int, _ItemState>>{};
      for (int p = 1; p <= showcase.maxPages; p++) {
        pageItems[p] = {};
      }
      for (final item in showcase.items) {
        final p = item.pageNumber;
        if (pageItems.containsKey(p)) {
          pageItems[p]![item.goodsId] = _ItemState(
            shelfNumber: item.shelfNumber,
            xPosition: item.xPosition,
            yPosition: item.yPosition,
            scale: item.scale,
          );
        }
      }

      setState(() {
        _goods = goods;
        _showcaseId = showcase.id;
        _maxPages = showcase.maxPages;
        _pageItems.clear();
        _pageItems.addAll(pageItems);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Map<int, _ItemState> get _currentItems => _pageItems[_currentPage] ?? {};

  List<MapEntry<int, _ItemState>> _shelfItems(int shelf) => _currentItems.entries
      .where((e) => e.value.shelfNumber == shelf)
      .toList();

  bool _isPlacedAnyPage(int goodsId) =>
      _pageItems.values.any((pageMap) => pageMap.containsKey(goodsId));

  void _addToShelf(int goodsId, int shelf) {
    setState(() {
      _pageItems[_currentPage]![goodsId] = _ItemState(
        shelfNumber: shelf,
        xPosition: 0.1,
        yPosition: 0.5,
        scale: 1.0,
      );
    });
  }

  void _removeFromPage(int goodsId) {
    setState(() => _pageItems[_currentPage]!.remove(goodsId));
  }

  void _moveToShelf(int goodsId, int shelf) {
    setState(() {
      final current = _currentItems[goodsId];
      if (current != null) current.shelfNumber = shelf;
    });
  }

  Future<void> _save() async {
    if (_showcaseId == null) return;
    setState(() => _saving = true);
    try {
      final items = <PlaceItemDto>[];
      _pageItems.forEach((page, goodsMap) {
        goodsMap.forEach((goodsId, state) {
          items.add(PlaceItemDto(
            goodsId: goodsId,
            pageNumber: page,
            shelfNumber: state.shelfNumber,
            xPosition: state.xPosition,
            yPosition: state.yPosition,
            scale: state.scale,
          ));
        });
      });
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

  void _showAddDialog(int goodsId) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('어느 층에 올릴까요?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () { _addToShelf(goodsId, 1); Navigator.pop(context); },
              child: const Text('1층'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () { _addToShelf(goodsId, 2); Navigator.pop(context); },
              child: const Text('2층'),
            ),
          ],
        ),
      ),
    );
  }

  void _showItemMenu(int goodsId, int currentShelf) {
    final otherShelf = currentShelf == 1 ? 2 : 1;
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _goods.firstWhere((g) => g.id == goodsId).name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () { _moveToShelf(goodsId, otherShelf); Navigator.pop(context); },
              child: Text('$otherShelf층으로 이동'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent),
              onPressed: () { _removeFromPage(goodsId); Navigator.pop(context); },
              child: const Text('전시장에서 제거'),
            ),
          ],
        ),
      ),
    );
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
              : _buildBody(),
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
              setState(() { _loading = true; _error = null; });
              _loadData();
            },
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        _buildPageTabs(),
        Expanded(child: _buildCabinet()),
        _buildCollectionPanel(),
      ],
    );
  }

  Widget _buildPageTabs() {
    final cs = Theme.of(context).colorScheme;
    return Container(
      color: const Color(0xFFF4FBFF),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_maxPages, (i) {
          final page = i + 1;
          final isActive = _currentPage == page;
          return GestureDetector(
            onTap: () => setState(() => _currentPage = page),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isActive ? cs.primary : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isActive ? cs.primary : const Color(0xFFCCDDEE),
                  width: 1.5,
                ),
                boxShadow: isActive
                    ? [BoxShadow(
                        color: cs.primary.withAlpha(60),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )]
                    : null,
              ),
              alignment: Alignment.center,
              child: Text(
                '$page',
                style: TextStyle(
                  color: isActive ? Colors.white : cs.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCabinet() {
    return Container(
      // 배경 — 앱 기본 배경색
      color: const Color(0xFFF4FBFF),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          // 유리장 외부 테두리 — 얇은 실버/화이트
          border: Border.all(color: const Color(0xFFCCDDEE), width: 2),
          // 유리 내부 — 밝은 흰빛
          color: const Color(0xFFF0F8FF),
          boxShadow: [
            // 외부 그림자
            BoxShadow(
              color: Colors.blueGrey.withAlpha(40),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
            // 내부 빛 느낌
            const BoxShadow(
              color: Colors.white,
              blurRadius: 0,
              spreadRadius: -2,
            ),
          ],
        ),
        child: Stack(
          children: [
            // 유리 좌측 세로 반사 — 빛이 한쪽에서 들어오는 느낌
            Positioned(
              top: 0, left: 0, bottom: 0,
              width: 20,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.white.withAlpha(160),
                      Colors.white.withAlpha(0),
                    ],
                  ),
                ),
              ),
            ),
            // 유리 상단 수평 하이라이트
            Positioned(
              top: 0, left: 0, right: 0, height: 3,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(10)),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withAlpha(220),
                      Colors.white.withAlpha(80),
                      Colors.white.withAlpha(0),
                    ],
                  ),
                ),
              ),
            ),
            // 선반 영역
            Column(
              children: [
                Expanded(child: _buildShelfArea(2)),
                _buildShelfDivider(),
                Expanded(child: _buildShelfArea(1)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShelfDivider() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 유리 선반판 — 투명한 파란빛 유리
        Container(
          height: 10,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFFFFF),       // 상단 하이라이트 (흰색)
                Color(0xCCDDEEFF),       // 유리 본체 (연한 파랑 반투명)
                Color(0x99BBCCDD),       // 하단 (살짝 어둡게)
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 4,
                offset: Offset(0, 3),
              ),
            ],
          ),
        ),
        // 선반 아래 그림자
        Container(
          height: 5,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.blueGrey.withAlpha(40),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShelfArea(int shelf) {
    final items = _shelfItems(shelf);
    return LayoutBuilder(
      builder: (context, constraints) {
        final W = constraints.maxWidth;
        final H = constraints.maxHeight;
        return Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // 빈 층 안내
            if (items.isEmpty)
              Center(
                child: Text(
                  '$shelf층 — 아래 컬렉션에서 굿즈를 추가하세요',
                  style: TextStyle(
                      color: Colors.blueGrey.withAlpha(90), fontSize: 11),
                ),
              ),
            // 층 번호 레이블
            Positioned(
              top: 6,
              left: 10,
              child: Text(
                '$shelf층',
                style: TextStyle(
                    color: Colors.blueGrey.withAlpha(120),
                    fontSize: 10,
                    fontWeight: FontWeight.w600),
              ),
            ),
            // 굿즈 아이템들
            ...items.map((entry) {
              final goodsId = entry.key;
              final state = entry.value;
              final goods =
                  _goods.firstWhere((g) => g.id == goodsId,
                      orElse: () => _goods.first);
              return _DraggableShelfItem(
                key: ValueKey('${_currentPage}_${shelf}_$goodsId'),
                goods: goods,
                state: state,
                shelfWidth: W,
                shelfHeight: H,
                onPositionChanged: (nx, ny) {
                  setState(() {
                    state.xPosition = nx;
                    state.yPosition = ny;
                  });
                },
                onScaleChanged: (ns) {
                  setState(() => state.scale = ns);
                },
                onLongPress: () => _showItemMenu(goodsId, shelf),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildCollectionPanel() {
    return Container(
      height: 130,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            child: Row(
              children: [
                Text(
                  '내 컬렉션',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '탭해서 추가 · 길게 눌러 층 변경/제거',
                  style: TextStyle(
                      fontSize: 10, color: Colors.grey.shade400),
                ),
              ],
            ),
          ),
          Expanded(
            child: _goods.isEmpty
                ? const Center(
                    child: Text('등록된 굿즈가 없습니다',
                        style: TextStyle(fontSize: 12)))
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    itemCount: _goods.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final g = _goods[index];
                      final isPlaced = _isPlacedAnyPage(g.id);
                      return _CollectionItem(
                        goods: g,
                        isPlaced: isPlaced,
                        onTap: isPlaced
                            ? null
                            : () => _showAddDialog(g.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── 선반 위 드래그 가능 아이템 ───────────────────────────
class _DraggableShelfItem extends StatefulWidget {
  static const double baseSize = 68.0;

  final GoodsItem goods;
  final _ItemState state;
  final double shelfWidth;
  final double shelfHeight;
  final void Function(double x, double y) onPositionChanged;
  final void Function(double scale) onScaleChanged;
  final VoidCallback onLongPress;

  const _DraggableShelfItem({
    super.key,
    required this.goods,
    required this.state,
    required this.shelfWidth,
    required this.shelfHeight,
    required this.onPositionChanged,
    required this.onScaleChanged,
    required this.onLongPress,
  });

  @override
  State<_DraggableShelfItem> createState() => _DraggableShelfItemState();
}

class _DraggableShelfItemState extends State<_DraggableShelfItem> {
  double _baseScale = 1.0;

  double get _itemSize => _DraggableShelfItem.baseSize * widget.state.scale;

  @override
  Widget build(BuildContext context) {
    final left =
        widget.state.xPosition * widget.shelfWidth - _itemSize / 2;
    final top =
        widget.state.yPosition * widget.shelfHeight - _itemSize / 2;

    return Positioned(
      left: left.clamp(0, (widget.shelfWidth - _itemSize).clamp(0, double.infinity)),
      top: top.clamp(0, (widget.shelfHeight - _itemSize).clamp(0, double.infinity)),
      child: GestureDetector(
        onLongPress: widget.onLongPress,
        onScaleStart: (_) => _baseScale = widget.state.scale,
        onScaleUpdate: (details) {
          if (details.pointerCount >= 2) {
            final ns = (_baseScale * details.scale).clamp(0.4, 2.5);
            widget.onScaleChanged(ns);
          } else {
            final nx = (widget.state.xPosition +
                    details.focalPointDelta.dx / widget.shelfWidth)
                .clamp(0.02, 0.98);
            final ny = (widget.state.yPosition +
                    details.focalPointDelta.dy / widget.shelfHeight)
                .clamp(0.02, 0.98);
            widget.onPositionChanged(nx, ny);
          }
        },
        child: SizedBox(
          width: _itemSize,
          height: _itemSize,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: _itemSize,
                height: _itemSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFCCDDEE), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.blueGrey.withAlpha(50),
                        blurRadius: 6,
                        offset: const Offset(0, 3)),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    widget.goods.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) => Container(
                      color: const Color(0xFFDDEEF5),
                      child: const Icon(Icons.broken_image,
                          color: Colors.blueGrey, size: 28),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── 컬렉션 패널 아이템 ────────────────────────────────────
class _CollectionItem extends StatelessWidget {
  static const double size = 60.0;

  final GoodsItem goods;
  final bool isPlaced;
  final VoidCallback? onTap;

  const _CollectionItem({
    required this.goods,
    required this.isPlaced,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: isPlaced ? 0.35 : 1.0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isPlaced
                      ? Colors.grey.shade300
                      : Theme.of(context)
                          .colorScheme
                          .primary
                          .withAlpha(120),
                  width: 1.5,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  goods.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) => Container(
                    color: Colors.grey.shade100,
                    child: const Icon(Icons.broken_image, size: 24),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 2),
            SizedBox(
              width: size,
              child: Text(
                goods.name,
                style: const TextStyle(fontSize: 9),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
