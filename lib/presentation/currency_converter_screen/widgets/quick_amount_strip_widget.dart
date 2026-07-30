import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class QuickAmountStripWidget extends StatelessWidget {
  final double selectedAmount;
  final ValueChanged<double> onAmountSelected;

  const QuickAmountStripWidget({
    super.key,
    required this.selectedAmount,
    required this.onAmountSelected,
  });

  static const List<Map<String, dynamic>> _quickAmounts = [
    {'label': '100', 'value': 100.0},
    {'label': '500', 'value': 500.0},
    {'label': '1K', 'value': 1000.0},
    {'label': '2K', 'value': 2000.0},
    {'label': '5K', 'value': 5000.0},
    {'label': '10K', 'value': 10000.0},
    {'label': '25K', 'value': 25000.0},
    {'label': '50K', 'value': 50000.0},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Quick amounts',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B7280),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _quickAmounts.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final item = _quickAmounts[i];
              final isSelected = selectedAmount == item['value'];
              return _QuickAmountChip(
                label: item['label'] as String,
                value: item['value'] as double,
                isSelected: isSelected,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onAmountSelected(item['value'] as double);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _QuickAmountChip extends StatefulWidget {
  final String label;
  final double value;
  final bool isSelected;
  final VoidCallback onTap;

  const _QuickAmountChip({
    required this.label,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_QuickAmountChip> createState() => _QuickAmountChipState();
}

class _QuickAmountChipState extends State<_QuickAmountChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _scaleController.reverse(),
      onTapUp: (_) {
        _scaleController.forward();
        widget.onTap();
      },
      onTapCancel: () => _scaleController.forward(),
      child: AnimatedBuilder(
        animation: _scaleController,
        builder: (context, child) =>
            Transform.scale(scale: _scaleController.value, child: child),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: widget.isSelected ? AppTheme.primary : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: widget.isSelected
                  ? AppTheme.primary
                  : AppTheme.outlineLight,
              width: widget.isSelected ? 1.5 : 1,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.primary.withAlpha(64),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withAlpha(10),
                      blurRadius: 6,
                      offset: const Offset(0, 1),
                    ),
                  ],
          ),
          child: Text(
            widget.label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: widget.isSelected ? Colors.white : const Color(0xFF424B47),
            ),
          ),
        ),
      ),
    );
  }
}
