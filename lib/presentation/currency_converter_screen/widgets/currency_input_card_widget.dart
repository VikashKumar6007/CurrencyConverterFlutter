import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class CurrencyInputCardWidget extends StatefulWidget {
  final String label;
  final String currency;
  final double amount;
  final bool isEditable;
  final ValueChanged<double> onAmountChanged;
  final ValueChanged<String> onCurrencyChanged;

  const CurrencyInputCardWidget({
    super.key,
    required this.label,
    required this.currency,
    required this.amount,
    required this.isEditable,
    required this.onAmountChanged,
    required this.onCurrencyChanged,
  });

  @override
  State<CurrencyInputCardWidget> createState() =>
      _CurrencyInputCardWidgetState();
}

class _CurrencyInputCardWidgetState extends State<CurrencyInputCardWidget> {
  late TextEditingController _textController;
  bool _isFocused = false;

  static const List<String> _availableCurrencies = [
    'USD',
    'EUR',
    'GBP',
    'JPY',
    'AED',
    'SGD',
    'CAD',
    'AUD',
    'CHF',
    'INR',
    'CNY',
  ];

  static const Map<String, String> _currencyFlags = {
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

  static const Map<String, String> _currencyNames = {
    'USD': 'US Dollar',
    'EUR': 'Euro',
    'GBP': 'British Pound',
    'JPY': 'Japanese Yen',
    'AED': 'UAE Dirham',
    'SGD': 'Singapore Dollar',
    'CAD': 'Canadian Dollar',
    'AUD': 'Australian Dollar',
    'CHF': 'Swiss Franc',
    'INR': 'Indian Rupee',
    'CNY': 'Chinese Yuan',
  };

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: _formatInput(widget.amount));
  }

  @override
  void didUpdateWidget(CurrencyInputCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isFocused && oldWidget.amount != widget.amount) {
      _textController.text = _formatInput(widget.amount);
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  String _formatInput(double value) {
    if (value == value.truncateToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(2);
  }

  void _showCurrencyPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CurrencyPickerSheet(
        selectedCurrency: widget.currency,
        currencies: _availableCurrencies,
        flags: _currencyFlags,
        names: _currencyNames,
        onSelected: (c) {
          Navigator.pop(ctx);
          widget.onCurrencyChanged(c);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final flag = _currencyFlags[widget.currency] ?? '💱';
    final name = _currencyNames[widget.currency] ?? widget.currency;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _isFocused
            ? AppTheme.primaryContainer.withAlpha(77)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isFocused
              ? AppTheme.primary.withAlpha(102)
              : AppTheme.outlineLight,
          width: _isFocused ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Currency selector
          GestureDetector(
            onTap: _showCurrencyPicker,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.backgroundLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.outlineLight),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(flag, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.currency,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A1C1B),
                        ),
                      ),
                      Text(
                        name,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: Color(0xFF6B7280),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Amount input
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  widget.label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 4),
                widget.isEditable
                    ? Focus(
                        onFocusChange: (focused) =>
                            setState(() => _isFocused = focused),
                        child: TextField(
                          controller: _textController,
                          textAlign: TextAlign.right,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                          ],
                          onChanged: (v) {
                            final parsed = double.tryParse(v);
                            if (parsed != null) widget.onAmountChanged(parsed);
                          },
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1A1C1B),
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      )
                    : Text(
                        _formatDisplay(widget.amount),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                        textAlign: TextAlign.right,
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDisplay(double value) {
    if (value >= 1000) {
      return value
          .toStringAsFixed(2)
          .replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]},',
          );
    }
    return value.toStringAsFixed(2);
  }
}

class _CurrencyPickerSheet extends StatelessWidget {
  final String selectedCurrency;
  final List<String> currencies;
  final Map<String, String> flags;
  final Map<String, String> names;
  final ValueChanged<String> onSelected;

  const _CurrencyPickerSheet({
    required this.selectedCurrency,
    required this.currencies,
    required this.flags,
    required this.names,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.outlineLight,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Text(
              'Select Currency',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A1C1B),
              ),
            ),
          ),
          const Divider(height: 1, color: AppTheme.outlineLight),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: currencies.length,
              separatorBuilder: (_, __) => const Divider(
                height: 1,
                color: AppTheme.outlineVariantLight,
                indent: 72,
              ),
              itemBuilder: (_, i) {
                final code = currencies[i];
                final isSelected = code == selectedCurrency;
                return InkWell(
                  onTap: () => onSelected(code),
                  splashColor: AppTheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Text(
                          flags[code] ?? '💱',
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                code,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1A1C1B),
                                ),
                              ),
                              Text(
                                names[code] ?? code,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle_rounded,
                            color: AppTheme.primary,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
