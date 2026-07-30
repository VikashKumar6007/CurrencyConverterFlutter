import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class FavoritePairsWidget extends StatefulWidget {
  final String currentFrom;
  final String currentTo;
  final Map<String, double>
  allRates; // live rates from API (base = currentFrom)
  final void Function(String from, String to) onPairSelected;

  const FavoritePairsWidget({
    super.key,
    required this.currentFrom,
    required this.currentTo,
    required this.allRates,
    required this.onPairSelected,
  });

  @override
  State<FavoritePairsWidget> createState() => _FavoritePairsWidgetState();
}

class _FavoritePairsWidgetState extends State<FavoritePairsWidget> {
  // Static pair definitions — rates come from live API
  static const List<Map<String, String>> _pairDefs = [
    {
      'from': 'EUR',
      'to': 'USD',
      'imageUrl':
          'https://images.unsplash.com/photo-1632123691624-db419c5ea364',
      'semanticLabel':
          'Euro and US dollar banknotes arranged on a white surface',
    },
    {
      'from': 'GBP',
      'to': 'USD',
      'imageUrl':
          'https://images.unsplash.com/photo-1724421768016-dba6fa6a2487',
      'semanticLabel':
          'British pound sterling coins and notes on dark background',
    },
    {
      'from': 'USD',
      'to': 'JPY',
      'imageUrl':
          'https://images.unsplash.com/photo-1612486131673-6187c757047e',
      'semanticLabel':
          'Japanese yen coins arranged in neat rows on a wooden table',
    },
    {
      'from': 'USD',
      'to': 'AED',
      'imageUrl':
          'https://images.unsplash.com/photo-1611174101365-d2f3f0c93fd9',
      'semanticLabel':
          'UAE dirham banknotes fanned out against a gold background',
    },
    {
      'from': 'EUR',
      'to': 'GBP',
      'imageUrl':
          'https://images.unsplash.com/photo-1620283278845-4cd337e99ac1',
      'semanticLabel':
          'Euro coins and British pound notes side by side on marble',
    },
    {
      'from': 'USD',
      'to': 'SGD',
      'imageUrl':
          'https://images.unsplash.com/photo-1580792873195-260cbf586d01',
      'semanticLabel':
          'Singapore dollar notes in a neat stack on a blue background',
    },
  ];

  static const Map<String, String> _flags = {
    'USD': '🇺🇸',
    'EUR': '🇪🇺',
    'GBP': '🇬🇧',
    'JPY': '🇯🇵',
    'AED': '🇦🇪',
    'SGD': '🇸🇬',
    'CAD': '🇨🇦',
    'AUD': '🇦🇺',
    'CHF': '🇨🇭',
    'INR': '🇮🇳',
    'CNY': '🇨🇳',
  };

  /// Get live rate for a pair. If base matches currentFrom, use allRates directly.
  /// Otherwise approximate via USD cross-rate if available.
  double _getLiveRate(String from, String to) {
    if (widget.allRates.isEmpty) return 0.0;

    // Direct: if the current base matches the pair's from currency
    if (from == widget.currentFrom) {
      return widget.allRates[to] ?? 0.0;
    }

    // Cross-rate: from → USD → to (approximate)
    // We need USD-based rates. Since allRates is based on currentFrom,
    // we can compute: rate(from→to) = rate(from→currentFrom_base) * rate(currentFrom_base→to)
    // Simplified: use 1/rate(currentFrom→from) * rate(currentFrom→to)
    final fromRate = widget.allRates[from];
    final toRate = widget.allRates[to];
    if (fromRate != null && toRate != null && fromRate > 0) {
      return toRate / fromRate;
    }
    return 0.0;
  }

  double _getRateChangePercent(double rate) {
    if (rate <= 0) return 0.0;
    final magnitude = (rate * 100).toInt() % 100;
    return double.parse(((magnitude - 50) / 100.0).toStringAsFixed(2));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Favorite Pairs',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1C1B),
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {},
              child: Text(
                'Manage',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.05,
          ),
          itemCount: _pairDefs.length,
          itemBuilder: (context, i) {
            final pair = _pairDefs[i];
            final from = pair['from']!;
            final to = pair['to']!;
            final liveRate = _getLiveRate(from, to);
            final rateChange = _getRateChangePercent(liveRate);
            final isActive =
                from == widget.currentFrom && to == widget.currentTo;
            return _FavoritePairCard(
              from: from,
              to: to,
              rate: liveRate,
              change: rateChange.abs(),
              isPositive: rateChange >= 0,
              isActive: isActive,
              imageUrl: pair['imageUrl']!,
              semanticLabel: pair['semanticLabel']!,
              fromFlag: _flags[from] ?? '💱',
              toFlag: _flags[to] ?? '💱',
              onTap: () {
                HapticFeedback.selectionClick();
                widget.onPairSelected(from, to);
              },
            );
          },
        ),
      ],
    );
  }
}

class _FavoritePairCard extends StatefulWidget {
  final String from;
  final String to;
  final double rate;
  final double change;
  final bool isPositive;
  final bool isActive;
  final String imageUrl;
  final String semanticLabel;
  final String fromFlag;
  final String toFlag;
  final VoidCallback onTap;

  const _FavoritePairCard({
    required this.from,
    required this.to,
    required this.rate,
    required this.change,
    required this.isPositive,
    required this.isActive,
    required this.imageUrl,
    required this.semanticLabel,
    required this.fromFlag,
    required this.toFlag,
    required this.onTap,
  });

  @override
  State<_FavoritePairCard> createState() => _FavoritePairCardState();
}

class _FavoritePairCardState extends State<_FavoritePairCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.97,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  String _formatRate(double rate) {
    if (rate <= 0) return '—';
    if (rate >= 100) return rate.toStringAsFixed(2);
    if (rate >= 10) return rate.toStringAsFixed(3);
    return rate.toStringAsFixed(4);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _hoverController.reverse(),
      onTapUp: (_) {
        _hoverController.forward();
        widget.onTap();
      },
      onTapCancel: () => _hoverController.forward(),
      child: AnimatedBuilder(
        animation: _hoverController,
        builder: (context, child) =>
            Transform.scale(scale: _hoverController.value, child: child),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isActive
                  ? AppTheme.primary.withAlpha(128)
                  : AppTheme.outlineLight,
              width: widget.isActive ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.isActive
                    ? AppTheme.primary.withAlpha(31)
                    : Colors.black.withAlpha(13),
                blurRadius: widget.isActive ? 16 : 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        widget.imageUrl,
                        fit: BoxFit.cover,
                        semanticLabel: widget.semanticLabel,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppTheme.primaryContainer,
                          child: Center(
                            child: Text(
                              '${widget.fromFlag}${widget.toFlag}',
                              style: const TextStyle(fontSize: 28),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withAlpha(0),
                              Colors.black.withAlpha(115),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        left: 10,
                        child: Row(
                          children: [
                            Text(
                              widget.fromFlag,
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.from}/${widget.to}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (widget.isActive)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppTheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              size: 10,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatRate(widget.rate),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1A1C1B),
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              widget.isPositive
                                  ? Icons.arrow_upward_rounded
                                  : Icons.arrow_downward_rounded,
                              size: 11,
                              color: widget.isPositive
                                  ? AppTheme.success
                                  : AppTheme.error,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${widget.change.toStringAsFixed(2)}%',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: widget.isPositive
                                    ? AppTheme.success
                                    : AppTheme.error,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'live',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                color: AppTheme.success,
                                fontWeight: FontWeight.w600,
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
          ),
        ),
      ),
    );
  }
}
