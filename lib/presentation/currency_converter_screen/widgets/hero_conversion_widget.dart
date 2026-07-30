import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class HeroConversionWidget extends StatefulWidget {
  final double convertedAmount;
  final double inputAmount;
  final String toCurrency;
  final String fromCurrency;
  final double rate;
  final double rateChangePercent;
  final DateTime? lastUpdated;

  const HeroConversionWidget({
    super.key,
    required this.convertedAmount,
    required this.inputAmount,
    required this.toCurrency,
    required this.fromCurrency,
    required this.rate,
    required this.rateChangePercent,
    this.lastUpdated,
  });

  @override
  State<HeroConversionWidget> createState() => _HeroConversionWidgetState();
}

class _HeroConversionWidgetState extends State<HeroConversionWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _valueAnimation;
  double _previousValue = 0;

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
    'MXN': 'Mexican Peso',
    'BRL': 'Brazilian Real',
    'KRW': 'South Korean Won',
    'HKD': 'Hong Kong Dollar',
    'NOK': 'Norwegian Krone',
    'SEK': 'Swedish Krona',
    'DKK': 'Danish Krone',
    'NZD': 'New Zealand Dollar',
    'ZAR': 'South African Rand',
    'TRY': 'Turkish Lira',
    'RUB': 'Russian Ruble',
    'PLN': 'Polish Zloty',
    'THB': 'Thai Baht',
    'IDR': 'Indonesian Rupiah',
    'MYR': 'Malaysian Ringgit',
    'PHP': 'Philippine Peso',
    'CZK': 'Czech Koruna',
    'HUF': 'Hungarian Forint',
    'ILS': 'Israeli Shekel',
    'SAR': 'Saudi Riyal',
    'QAR': 'Qatari Riyal',
    'KWD': 'Kuwaiti Dinar',
    'BHD': 'Bahraini Dinar',
    'OMR': 'Omani Rial',
    'PKR': 'Pakistani Rupee',
    'BDT': 'Bangladeshi Taka',
    'EGP': 'Egyptian Pound',
    'NGN': 'Nigerian Naira',
    'KES': 'Kenyan Shilling',
    'GHS': 'Ghanaian Cedi',
    'MAD': 'Moroccan Dirham',
    'TND': 'Tunisian Dinar',
    'CLP': 'Chilean Peso',
    'COP': 'Colombian Peso',
    'PEN': 'Peruvian Sol',
    'ARS': 'Argentine Peso',
    'VND': 'Vietnamese Dong',
    'TWD': 'Taiwan Dollar',
    'UAH': 'Ukrainian Hryvnia',
    'RON': 'Romanian Leu',
    'BGN': 'Bulgarian Lev',
    'HRK': 'Croatian Kuna',
    'ISK': 'Icelandic Krona',
    'LKR': 'Sri Lankan Rupee',
    'MMK': 'Myanmar Kyat',
    'NPR': 'Nepalese Rupee',
    'JOD': 'Jordanian Dinar',
    'LBP': 'Lebanese Pound',
    'DZD': 'Algerian Dinar',
    'ETB': 'Ethiopian Birr',
    'TZS': 'Tanzanian Shilling',
    'UGX': 'Ugandan Shilling',
    'ZMW': 'Zambian Kwacha',
    'XAF': 'Central African CFA',
    'XOF': 'West African CFA',
    'KZT': 'Kazakhstani Tenge',
    'GEL': 'Georgian Lari',
    'AZN': 'Azerbaijani Manat',
    'AMD': 'Armenian Dram',
    'MDL': 'Moldovan Leu',
    'BYN': 'Belarusian Ruble',
    'MKD': 'Macedonian Denar',
    'ALL': 'Albanian Lek',
    'BAM': 'Bosnia-Herzegovina Mark',
    'RSD': 'Serbian Dinar',
    'UZS': 'Uzbekistani Som',
    'TJS': 'Tajikistani Somoni',
    'KGS': 'Kyrgyzstani Som',
    'TMT': 'Turkmenistani Manat',
    'MNT': 'Mongolian Tögrög',
    'KHR': 'Cambodian Riel',
    'LAK': 'Lao Kip',
    'BND': 'Brunei Dollar',
    'MOP': 'Macanese Pataca',
    'FJD': 'Fijian Dollar',
    'PGK': 'Papua New Guinean Kina',
    'AFN': 'Afghan Afghani',
    'IRR': 'Iranian Rial',
    'IQD': 'Iraqi Dinar',
    'YER': 'Yemeni Rial',
    'MVR': 'Maldivian Rufiyaa',
    'BTN': 'Bhutanese Ngultrum',
    'MGA': 'Malagasy Ariary',
    'SCR': 'Seychellois Rupee',
    'MUR': 'Mauritian Rupee',
    'BWP': 'Botswana Pula',
    'NAD': 'Namibian Dollar',
    'MZN': 'Mozambican Metical',
    'GTQ': 'Guatemalan Quetzal',
    'HNL': 'Honduran Lempira',
    'CRC': 'Costa Rican Colón',
    'DOP': 'Dominican Peso',
    'JMD': 'Jamaican Dollar',
    'TTD': 'Trinidad Dollar',
    'BOB': 'Bolivian Boliviano',
    'PYG': 'Paraguayan Guaraní',
    'UYU': 'Uruguayan Peso',
  };

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
    'MXN': '🇲🇽',
    'BRL': '🇧🇷',
    'KRW': '🇰🇷',
    'HKD': '🇭🇰',
    'NOK': '🇳🇴',
    'SEK': '🇸🇪',
    'DKK': '🇩🇰',
    'NZD': '🇳🇿',
    'ZAR': '🇿🇦',
    'TRY': '🇹🇷',
    'RUB': '🇷🇺',
    'PLN': '🇵🇱',
    'THB': '🇹🇭',
    'IDR': '🇮🇩',
    'MYR': '🇲🇾',
    'PHP': '🇵🇭',
    'SAR': '🇸🇦',
    'QAR': '🇶🇦',
    'KWD': '🇰🇼',
    'BHD': '🇧🇭',
    'OMR': '🇴🇲',
    'PKR': '🇵🇰',
    'BDT': '🇧🇩',
    'EGP': '🇪🇬',
    'NGN': '🇳🇬',
    'KES': '🇰🇪',
    'GHS': '🇬🇭',
    'MAD': '🇲🇦',
    'CLP': '🇨🇱',
    'COP': '🇨🇴',
    'PEN': '🇵🇪',
    'ARS': '🇦🇷',
    'VND': '🇻🇳',
    'TWD': '🇹🇼',
    'UAH': '🇺🇦',
    'ILS': '🇮🇱',
    'JOD': '🇯🇴',
    'LKR': '🇱🇰',
    'NPR': '🇳🇵',
    'KZT': '🇰🇿',
    'GEL': '🇬🇪',
    'AZN': '🇦🇿',
    'AMD': '🇦🇲',
    'UZS': '🇺🇿',
    'TJS': '🇹🇯',
    'KGS': '🇰🇬',
    'TMT': '🇹🇲',
    'MNT': '🇲🇳',
    'MMK': '🇲🇲',
    'KHR': '🇰🇭',
    'LAK': '🇱🇦',
    'BND': '🇧🇳',
    'MOP': '🇲🇴',
    'FJD': '🇫🇯',
    'PGK': '🇵🇬',
    'AFN': '🇦🇫',
    'IRR': '🇮🇷',
    'IQD': '🇮🇶',
    'YER': '🇾🇪',
    'MVR': '🇲🇻',
    'BTN': '🇧🇹',
    'LBP': '🇱🇧',
    'DZD': '🇩🇿',
    'TND': '🇹🇳',
    'LYD': '🇱🇾',
    'SDG': '🇸🇩',
    'ETB': '🇪🇹',
    'TZS': '🇹🇿',
    'UGX': '🇺🇬',
    'RWF': '🇷🇼',
    'BIF': '🇧🇮',
    'DJF': '🇩🇯',
    'SOS': '🇸🇴',
    'MZN': '🇲🇿',
    'AOA': '🇦🇴',
    'ZMW': '🇿🇲',
    'MWK': '🇲🇼',
    'BWP': '🇧🇼',
    'NAD': '🇳🇦',
    'MGA': '🇲🇬',
    'SCR': '🇸🇨',
    'MUR': '🇲🇺',
    'XOF': '🌍',
    'XAF': '🌍',
    'MRU': '🇲🇷',
    'GTQ': '🇬🇹',
    'HNL': '🇭🇳',
    'CRC': '🇨🇷',
    'DOP': '🇩🇴',
    'JMD': '🇯🇲',
    'TTD': '🇹🇹',
    'BOB': '🇧🇴',
    'PYG': '🇵🇾',
    'UYU': '🇺🇾',
    'RON': '🇷🇴',
    'BGN': '🇧🇬',
    'HRK': '🇭🇷',
    'ISK': '🇮🇸',
    'CZK': '🇨🇿',
    'HUF': '🇭🇺',
    'MKD': '🇲🇰',
    'ALL': '🇦🇱',
    'BAM': '🇧🇦',
    'RSD': '🇷🇸',
    'MDL': '🇲🇩',
    'BYN': '🇧🇾',
    'SYP': '🇸🇾',
  };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _previousValue = widget.convertedAmount;
    _valueAnimation = Tween<double>(
      begin: widget.convertedAmount,
      end: widget.convertedAmount,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void didUpdateWidget(HeroConversionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.convertedAmount != widget.convertedAmount) {
      _valueAnimation =
          Tween<double>(
            begin: _previousValue,
            end: widget.convertedAmount,
          ).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
          );
      _controller.forward(from: 0);
      _previousValue = widget.convertedAmount;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatAmount(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(2)}M';
    } else if (value >= 1000) {
      final parts = value.toStringAsFixed(2).split('.');
      final intPart = parts[0];
      final decPart = parts[1];
      final formatted = intPart.replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );
      return '$formatted.$decPart';
    }
    return value.toStringAsFixed(4);
  }

  String _formatTimestamp(DateTime? dt) {
    if (dt == null) return 'Loading…';
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year} · $h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final currencyName = _currencyNames[widget.toCurrency] ?? widget.toCurrency;
    final flag = _currencyFlags[widget.toCurrency] ?? '💱';
    final isPositive = widget.rateChangePercent >= 0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withAlpha(77),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '$flag $currencyName',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withAlpha(191),
                ),
              ),
              const Spacer(),
              _RateChangeBadge(
                change: widget.rateChangePercent.abs(),
                isPositive: isPositive,
              ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedBuilder(
            animation: _valueAnimation,
            builder: (context, _) {
              return Text(
                _formatAmount(_valueAnimation.value),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -1.5,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              );
            },
          ),
          const SizedBox(height: 4),
          Text(
            widget.toCurrency,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white.withAlpha(179),
            ),
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: Colors.white.withAlpha(38)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MetaChip(
                  label:
                      '1 ${widget.fromCurrency} = ${widget.rate.toStringAsFixed(4)} ${widget.toCurrency}',
                ),
              ),
              const SizedBox(width: 8),
              _MetaChip(label: _formatTimestamp(widget.lastUpdated)),
            ],
          ),
        ],
      ),
    );
  }
}

class _RateChangeBadge extends StatelessWidget {
  final double change;
  final bool isPositive;

  const _RateChangeBadge({required this.change, required this.isPositive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(38),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive
                ? Icons.arrow_upward_rounded
                : Icons.arrow_downward_rounded,
            size: 12,
            color: isPositive
                ? const Color(0xFF7FFFC4)
                : const Color(0xFFFF9999),
          ),
          const SizedBox(width: 4),
          Text(
            '${change.toStringAsFixed(2)}%',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isPositive
                  ? const Color(0xFF7FFFC4)
                  : const Color(0xFFFF9999),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final String label;

  const _MetaChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: Colors.white.withAlpha(153),
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
}
