import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../models/personality_card.dart';
import '../services/card_collection_service.dart';
import '../ui/app_tokens.dart';
import '../widgets/hologram_card.dart';

class CardCollectionScreen extends StatefulWidget {
  final bool isKo;

  const CardCollectionScreen({super.key, required this.isKo});

  @override
  State<CardCollectionScreen> createState() => _CardCollectionScreenState();
}

class _CardCollectionScreenState extends State<CardCollectionScreen> {
  List<PersonalityCard> _cards = [];
  CardRarity? _filter;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    final cards = await CardCollectionService.load();
    if (mounted) {
      setState(() {
        _cards = cards;
        _loading = false;
      });
    }
  }

  List<PersonalityCard> get _filteredCards {
    if (_filter == null) return _cards;
    return _cards.where((c) => c.rarity == _filter).toList();
  }

  Map<CardRarity, int> get _stats {
    final stats = <CardRarity, int>{
      CardRarity.r: 0,
      CardRarity.sr: 0,
      CardRarity.ssr: 0,
      CardRarity.legend: 0,
    };
    for (final card in _cards) {
      stats[card.rarity] = (stats[card.rarity] ?? 0) + 1;
    }
    return stats;
  }

  Future<void> _deleteCard(String id) async {
    await CardCollectionService.delete(id);
    await _loadCards();
  }

  void _showCardDetail(PersonalityCard card) {
    final shareKey = GlobalKey();

    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Card
            RepaintBoundary(
              key: shareKey,
              child: HologramCard(
                card: card,
                isKo: widget.isKo,
                width: 320,
                height: 450,
                interactive: true,
              ),
            ),
            const SizedBox(height: 20),
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ActionButton(
                  icon: Icons.share,
                  label: widget.isKo ? '공유' : 'Share',
                  color: AppColors.purple500,
                  onTap: () => _shareCard(shareKey),
                ),
                const SizedBox(width: 16),
                _ActionButton(
                  icon: Icons.delete_outline,
                  label: widget.isKo ? '삭제' : 'Delete',
                  color: AppColors.red500,
                  onTap: () {
                    Navigator.pop(ctx);
                    _confirmDelete(card);
                  },
                ),
                const SizedBox(width: 16),
                _ActionButton(
                  icon: Icons.close,
                  label: widget.isKo ? '닫기' : 'Close',
                  color: AppColors.gray500,
                  onTap: () => Navigator.pop(ctx),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareCard(GlobalKey key) async {
    try {
      final boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/hexaco_card.png');
      await file.writeAsBytes(byteData.buffer.asUint8List());

      await Share.shareXFiles(
        [XFile(file.path)],
        text: widget.isKo
            ? '나의 HEXACO 성격 카드! 🃏\nhttps://hexacotest.vercel.app'
            : 'My HEXACO Personality Card! 🃏\nhttps://hexacotest.vercel.app',
      );
    } catch (_) {}
  }

  void _confirmDelete(PersonalityCard card) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          widget.isKo ? '카드 삭제' : 'Delete Card',
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          widget.isKo
              ? '이 카드를 삭제하시겠습니까?\n삭제하면 복구할 수 없습니다.'
              : 'Delete this card?\nThis cannot be undone.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              widget.isKo ? '취소' : 'Cancel',
              style: const TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteCard(card.id);
            },
            child: Text(
              widget.isKo ? '삭제' : 'Delete',
              style: const TextStyle(color: AppColors.red500),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stats = _stats;
    final filtered = _filteredCards;

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.isKo ? '카드 보관함' : 'Card Collection',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '${_cards.length}${widget.isKo ? '장' : ' cards'}',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.purple500),
            )
          : Column(
              children: [
                // Stats bar
                _StatsBar(stats: stats, isKo: widget.isKo),
                const SizedBox(height: 8),
                // Filter chips
                _FilterChips(
                  stats: stats,
                  selected: _filter,
                  isKo: widget.isKo,
                  onChanged: (f) => setState(() => _filter = f),
                ),
                const SizedBox(height: 12),
                // Card grid
                Expanded(
                  child: filtered.isEmpty
                      ? _EmptyState(isKo: widget.isKo, hasFilter: _filter != null)
                      : GridView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.71,
                          ),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final card = filtered[index];
                            return GestureDetector(
                              onTap: () => _showCardDetail(card),
                              onLongPress: () => _confirmDelete(card),
                              child: HologramCard(
                                card: card,
                                isKo: widget.isKo,
                                width: 160,
                                height: 225,
                                interactive: false,
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

class _StatsBar extends StatelessWidget {
  final Map<CardRarity, int> stats;
  final bool isKo;

  const _StatsBar({required this.stats, required this.isKo});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(label: 'R', count: stats[CardRarity.r] ?? 0, color: const Color(0xFF94A3B8)),
          _StatItem(label: 'SR', count: stats[CardRarity.sr] ?? 0, color: const Color(0xFF3B82F6)),
          _StatItem(label: 'SSR', count: stats[CardRarity.ssr] ?? 0, color: const Color(0xFFA855F7)),
          _StatItem(label: 'LEGEND', count: stats[CardRarity.legend] ?? 0, color: const Color(0xFFFBBF24)),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _StatItem({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: color,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$count',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _FilterChips extends StatelessWidget {
  final Map<CardRarity, int> stats;
  final CardRarity? selected;
  final bool isKo;
  final ValueChanged<CardRarity?> onChanged;

  const _FilterChips({
    required this.stats,
    required this.selected,
    required this.isKo,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _chip(null, isKo ? '전체' : 'All', Colors.white),
          _chip(CardRarity.legend, 'LEGEND', const Color(0xFFFBBF24)),
          _chip(CardRarity.ssr, 'SSR', const Color(0xFFA855F7)),
          _chip(CardRarity.sr, 'SR', const Color(0xFF3B82F6)),
          _chip(CardRarity.r, 'R', const Color(0xFF94A3B8)),
        ],
      ),
    );
  }

  Widget _chip(CardRarity? rarity, String label, Color color) {
    final isSelected = selected == rarity;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => onChanged(rarity),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.2) : AppColors.darkCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? color : AppColors.darkBorder,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isSelected ? color : Colors.white54,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isKo;
  final bool hasFilter;

  const _EmptyState({required this.isKo, required this.hasFilter});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasFilter ? Icons.filter_list_off : Icons.collections_bookmark_outlined,
            size: 64,
            color: Colors.white12,
          ),
          const SizedBox(height: 16),
          Text(
            hasFilter
                ? (isKo ? '해당 등급의 카드가 없습니다' : 'No cards of this rarity')
                : (isKo ? '아직 뽑은 카드가 없습니다' : 'No cards yet'),
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white38,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (!hasFilter) ...[
            const SizedBox(height: 8),
            Text(
              isKo ? '테스트 결과에서 카드를 뽑아보세요!' : 'Draw cards from your test results!',
              style: const TextStyle(fontSize: 13, color: Colors.white24),
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
