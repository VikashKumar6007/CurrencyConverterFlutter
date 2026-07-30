import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class RateInfoCardWidget extends StatelessWidget {
  final String fromCurrency;
  final String toCurrency;
  final double rate;
  final double rateChangePercent;
  final double weekHigh;
  final double weekLow;
  final double monthAvg;

  const RateInfoCardWidget({
    super.key,
    required this.fromCurrency,
    required this.toCurrency,
    required this.rate,
    required this.rateChangePercent,
    required this.weekHigh,
    required this.weekLow,
    required this.monthAvg,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TodayRateCard(
            fromCurrency: fromCurrency,
            toCurrency: toCurrency,
            rate: rate,
            rateChange: rateChangePercent,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _RangeCard(
            weekHigh: weekHigh,
            weekLow: weekLow,
            monthAvg: monthAvg,
            toCurrency: toCurrency,
          ),
        ),
      ],
    );
  }
}

class _TodayRateCard extends StatelessWidget {
  final String fromCurrency;
  final String toCurrency;
  final double rate;
  final double rateChange;

  const _TodayRateCard({
    required this.fromCurrency,
    required this.toCurrency,
    required this.rate,
    required this.rateChange,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = rateChange >= 0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.outlineLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.trending_up_rounded,
                  size: 14,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Today\'s Rate',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            rate.toStringAsFixed(4),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1A1C1B),
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                isPositive
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded,
                size: 12,
                color: isPositive ? AppTheme.success : AppTheme.error,
              ),
              const SizedBox(width: 2),
              Expanded(
                child: Text(
                  '${rateChange.abs().toStringAsFixed(2)}% today',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isPositive ? AppTheme.success : AppTheme.error,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '1 $fromCurrency → $toCurrency',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              color: const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }
}

class _RangeCard extends StatelessWidget {
  final double weekHigh;
  final double weekLow;
  final double monthAvg;
  final String toCurrency;

  const _RangeCard({
    required this.weekHigh,
    required this.weekLow,
    required this.monthAvg,
    required this.toCurrency,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.outlineLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.candlestick_chart_rounded,
                  size: 14,
                  color: AppTheme.secondary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '7-Day Range',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _RangeRow(label: 'High', value: weekHigh, color: AppTheme.success),
          const SizedBox(height: 6),
          _RangeRow(label: 'Low', value: weekLow, color: AppTheme.error),
          const SizedBox(height: 6),
          _RangeRow(
            label: 'Avg',
            value: monthAvg,
            color: const Color(0xFF6B7280),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: (weekHigh - weekLow) > 0
                  ? ((monthAvg - weekLow) / (weekHigh - weekLow)).clamp(
                      0.0,
                      1.0,
                    )
                  : 0.5,
              minHeight: 4,
              backgroundColor: AppTheme.outlineLight,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _RangeRow extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _RangeRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 28,
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF9CA3AF),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value.toStringAsFixed(4),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
