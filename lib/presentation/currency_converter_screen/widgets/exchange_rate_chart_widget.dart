import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class ExchangeRateChartWidget extends StatefulWidget {
  final String fromCurrency;
  final String toCurrency;
  final Map<String, List<double>> chartData;

  const ExchangeRateChartWidget({
    super.key,
    required this.fromCurrency,
    required this.toCurrency,
    required this.chartData,
  });

  @override
  State<ExchangeRateChartWidget> createState() =>
      _ExchangeRateChartWidgetState();
}

class _ExchangeRateChartWidgetState extends State<ExchangeRateChartWidget>
    with SingleTickerProviderStateMixin {
  int _selectedPeriod = 0; // 0=7D, 1=1M, 2=3M, 3=1Y
  final List<String> _periods = ['7D', '1M', '3M', '1Y'];
  late AnimationController _chartController;
  late Animation<double> _chartAnimation;

  static const Map<String, List<String>> _xLabels = {
    '7D': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    '1M': ['W1', 'W2', 'W3', 'W4'],
    '3M': ['Apr', 'May', 'Jun'],
    '1Y': [
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
    ],
  };

  @override
  void initState() {
    super.initState();
    _chartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _chartAnimation = CurvedAnimation(
      parent: _chartController,
      curve: Curves.easeOutCubic,
    );
    _chartController.forward();
  }

  @override
  void didUpdateWidget(ExchangeRateChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fromCurrency != widget.fromCurrency ||
        oldWidget.toCurrency != widget.toCurrency ||
        oldWidget.chartData != widget.chartData) {
      _chartController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _chartController.dispose();
    super.dispose();
  }

  List<double> get _currentData {
    final period = _periods[_selectedPeriod];
    final data = widget.chartData[period];
    if (data != null && data.isNotEmpty) return data;
    // Fallback empty data
    return [1.0, 1.0];
  }

  @override
  Widget build(BuildContext context) {
    final data = _currentData;
    final minVal = data.reduce((a, b) => a < b ? a : b);
    final maxVal = data.reduce((a, b) => a > b ? a : b);
    final range = maxVal - minVal;
    final padding = range > 0 ? range * 0.3 : maxVal * 0.01;

    return Container(
      padding: const EdgeInsets.all(20),
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
              Text(
                '${widget.fromCurrency}/${widget.toCurrency} Rate',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1C1B),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.outlineLight),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(_periods.length, (i) {
                    final isSelected = i == _selectedPeriod;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedPeriod = i);
                        _chartController.forward(from: 0);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutCubic,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(
                          _periods[i],
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: AnimatedBuilder(
              animation: _chartAnimation,
              builder: (context, _) {
                return LineChart(
                  LineChartData(
                    minX: 0,
                    maxX: (data.length - 1).toDouble(),
                    minY: minVal - padding,
                    maxY: maxVal + padding,
                    clipData: const FlClipData.all(),
                    gridData: FlGridData(
                      drawVerticalLine: false,
                      horizontalInterval: range > 0 ? range / 3 : 0.01,
                      getDrawingHorizontalLine: (_) => FlLine(
                        color: AppTheme.outlineLight,
                        strokeWidth: 1,
                        dashArray: [4, 4],
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 52,
                          getTitlesWidget: (value, meta) {
                            return Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Text(
                                value.toStringAsFixed(4),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 9,
                                  color: const Color(0xFF9CA3AF),
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 24,
                          interval: _selectedPeriod == 0
                              ? 1
                              : (data.length / 4).ceilToDouble(),
                          getTitlesWidget: (value, meta) {
                            final labels =
                                _xLabels[_periods[_selectedPeriod]] ?? [];
                            final idx = value.toInt();
                            if (_selectedPeriod == 0 && idx < labels.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  labels[idx],
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9,
                                    color: const Color(0xFF9CA3AF),
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                    ),
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        tooltipBgColor: const Color(0xFF1A1C1B),
                        tooltipRoundedRadius: 8,
                        getTooltipItems: (spots) => spots
                            .map(
                              (s) => LineTooltipItem(
                                s.y.toStringAsFixed(4),
                                GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      handleBuiltInTouches: true,
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: List.generate(data.length, (i) {
                          final animatedY =
                              (minVal - padding) +
                              (data[i] - (minVal - padding)) *
                                  _chartAnimation.value;
                          return FlSpot(i.toDouble(), animatedY);
                        }),
                        isCurved: true,
                        curveSmoothness: 0.3,
                        color: AppTheme.primary,
                        barWidth: 2,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, bar, index) {
                            if (index == data.length - 1) {
                              return FlDotCirclePainter(
                                radius: 4,
                                color: AppTheme.primary,
                                strokeWidth: 2,
                                strokeColor: Colors.white,
                              );
                            }
                            return FlDotCirclePainter(
                              radius: 0,
                              color: Colors.transparent,
                              strokeWidth: 0,
                              strokeColor: Colors.transparent,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primary.withAlpha(46),
                              AppTheme.primary.withAlpha(0),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
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
