import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_theme.dart';
import '../../services/exchange_rate_service.dart';
import './widgets/currency_input_card_widget.dart';
import './widgets/exchange_rate_chart_widget.dart';
import './widgets/favorite_pairs_widget.dart';
import './widgets/hero_conversion_widget.dart';
import './widgets/quick_amount_strip_widget.dart';
import './widgets/rate_info_card_widget.dart';
import './widgets/swap_button_widget.dart';

class CurrencyConverterScreen extends StatefulWidget {
  const CurrencyConverterScreen({super.key});

  @override
  State<CurrencyConverterScreen> createState() =>
      _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen>
    with TickerProviderStateMixin {
  // State
  String _fromCurrency = 'USD';
  String _toCurrency = 'EUR';
  double _inputAmount = 1000.0;
  bool _isSwapping = false;
  bool _isLoading = true;
  String? _errorMessage;

  // Live data
  Map<String, double> _rates = {};
  double _rateChangePercent = 0.0;
  Map<String, double> _rangeStats = {'high': 0, 'low': 0, 'avg': 0};
  Map<String, List<double>> _chartData = {};
  DateTime? _lastUpdated;

  final ExchangeRateService _rateService = ExchangeRateService();

  late AnimationController _entranceController;
  late List<Animation<double>> _cardAnimations;

  double get _convertedAmount {
    final rate = _rates[_toCurrency] ?? 1.0;
    return _inputAmount * rate;
  }

  double get _currentRate {
    return _rates[_toCurrency] ?? 1.0;
  }

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _cardAnimations = List.generate(6, (i) {
      final start = (i * 0.12).clamp(0.0, 1.0);
      final end = (start + 0.5).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _entranceController,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      );
    });

    _fetchRates();
  }

  Future<void> _fetchRates() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final rates = await _rateService.getRates(_fromCurrency);
      if (rates.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Unable to fetch rates. Retrying…';
        });
        return;
      }

      final currentRate = rates[_toCurrency] ?? 1.0;
      final chartData = await _rateService.getChartData(
        _fromCurrency,
        _toCurrency,
      );
      final rangeStats = _rateService.getRangeStats(currentRate);
      final rateChange = _rateService.getRateChangePercent(currentRate);

      setState(() {
        _rates = rates;
        _chartData = chartData;
        _rangeStats = rangeStats;
        _rateChangePercent = rateChange;
        _lastUpdated = DateTime.now();
        _isLoading = false;
      });

      _entranceController.forward(from: 0);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load rates. Tap to retry.';
      });
    }
  }

  Future<void> _refreshRates() async {
    _rateService.clearCache();
    await _fetchRates();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  void _onAmountChanged(double amount) {
    setState(() => _inputAmount = amount);
  }

  void _onFromCurrencyChanged(String currency) async {
    setState(() {
      _fromCurrency = currency;
      _isLoading = true;
    });
    await _fetchRates();
  }

  void _onToCurrencyChanged(String currency) {
    setState(() {
      _toCurrency = currency;
      final currentRate = _rates[currency] ?? 1.0;
      _rateChangePercent = _rateService.getRateChangePercent(currentRate);
      _rangeStats = _rateService.getRangeStats(currentRate);
    });
    _rateService.getChartData(_fromCurrency, currency).then((data) {
      if (mounted) setState(() => _chartData = data);
    });
  }

  void _onSwap() async {
    setState(() => _isSwapping = true);
    await Future.delayed(const Duration(milliseconds: 300));
    final temp = _fromCurrency;
    setState(() {
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
      _isSwapping = false;
      _isLoading = true;
    });
    await _fetchRates();
  }

  void _onQuickAmount(double amount) {
    HapticFeedback.selectionClick();
    setState(() => _inputAmount = amount);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isLargeTablet = size.width >= 840;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: _isLoading && _rates.isEmpty
            ? _buildLoadingState(theme)
            : _errorMessage != null && _rates.isEmpty
            ? _buildErrorState(theme)
            : isLargeTablet
            ? _buildTabletLayout(theme)
            : _buildPhoneLayout(theme),
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppTheme.primary),
          const SizedBox(height: 16),
          Text(
            'Fetching live rates…',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    return Center(
      child: GestureDetector(
        onTap: _fetchRates,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 48,
              color: const Color(0xFF9CA3AF),
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Something went wrong',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Retry',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneLayout(ThemeData theme) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _buildFloatingAppBar(theme)),
        SliverToBoxAdapter(
          child: _buildAnimated(
            0,
            HeroConversionWidget(
              convertedAmount: _convertedAmount,
              toCurrency: _toCurrency,
              fromCurrency: _fromCurrency,
              inputAmount: _inputAmount,
              rate: _currentRate,
              rateChangePercent: _rateChangePercent,
              lastUpdated: _lastUpdated,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: _buildAnimated(
            1,
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: _buildInputSection(theme),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: _buildAnimated(
            2,
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: RateInfoCardWidget(
                fromCurrency: _fromCurrency,
                toCurrency: _toCurrency,
                rate: _currentRate,
                rateChangePercent: _rateChangePercent,
                weekHigh: _rangeStats['high'] ?? 0,
                weekLow: _rangeStats['low'] ?? 0,
                monthAvg: _rangeStats['avg'] ?? 0,
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: _buildAnimated(
            3,
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: ExchangeRateChartWidget(
                fromCurrency: _fromCurrency,
                toCurrency: _toCurrency,
                chartData: _chartData,
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: _buildAnimated(
            4,
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
              child: QuickAmountStripWidget(
                selectedAmount: _inputAmount,
                onAmountSelected: _onQuickAmount,
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: _buildAnimated(
            5,
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: FavoritePairsWidget(
                currentFrom: _fromCurrency,
                currentTo: _toCurrency,
                allRates: _rates,
                onPairSelected: (from, to) {
                  if (from != _fromCurrency) {
                    _onFromCurrencyChanged(from);
                  } else {
                    _onToCurrencyChanged(to);
                  }
                  setState(() {
                    _fromCurrency = from;
                    _toCurrency = to;
                  });
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildFloatingAppBar(theme)),
              SliverToBoxAdapter(
                child: HeroConversionWidget(
                  convertedAmount: _convertedAmount,
                  toCurrency: _toCurrency,
                  fromCurrency: _fromCurrency,
                  inputAmount: _inputAmount,
                  rate: _currentRate,
                  rateChangePercent: _rateChangePercent,
                  lastUpdated: _lastUpdated,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                  child: _buildInputSection(theme),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: QuickAmountStripWidget(
                    selectedAmount: _inputAmount,
                    onAmountSelected: _onQuickAmount,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
        Container(width: 1, color: AppTheme.outlineLight),
        Expanded(
          flex: 6,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                  child: RateInfoCardWidget(
                    fromCurrency: _fromCurrency,
                    toCurrency: _toCurrency,
                    rate: _currentRate,
                    rateChangePercent: _rateChangePercent,
                    weekHigh: _rangeStats['high'] ?? 0,
                    weekLow: _rangeStats['low'] ?? 0,
                    monthAvg: _rangeStats['avg'] ?? 0,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: ExchangeRateChartWidget(
                    fromCurrency: _fromCurrency,
                    toCurrency: _toCurrency,
                    chartData: _chartData,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                  child: FavoritePairsWidget(
                    currentFrom: _fromCurrency,
                    currentTo: _toCurrency,
                    allRates: _rates,
                    onPairSelected: (from, to) {
                      if (from != _fromCurrency) {
                        _onFromCurrencyChanged(from);
                      } else {
                        _onToCurrencyChanged(to);
                      }
                      setState(() {
                        _fromCurrency = from;
                        _toCurrency = to;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingAppBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppTheme.outlineLight, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'CurrencyConverter',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1C1B),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Live indicator
          if (_lastUpdated != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryContainer,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppTheme.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Live',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(width: 8),
          _AppBarIconButton(icon: Icons.refresh_rounded, onTap: _refreshRates),
          const SizedBox(width: 8),
          _AppBarIconButton(icon: Icons.tune_rounded, onTap: () {}),
        ],
      ),
    );
  }

  Widget _buildInputSection(ThemeData theme) {
    return Column(
      children: [
        CurrencyInputCardWidget(
          label: 'You send',
          currency: _fromCurrency,
          amount: _inputAmount,
          isEditable: true,
          onAmountChanged: _onAmountChanged,
          onCurrencyChanged: _onFromCurrencyChanged,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: SwapButtonWidget(isSwapping: _isSwapping, onSwap: _onSwap),
        ),
        CurrencyInputCardWidget(
          label: 'They receive',
          currency: _toCurrency,
          amount: _convertedAmount,
          isEditable: false,
          onAmountChanged: (_) {},
          onCurrencyChanged: _onToCurrencyChanged,
        ),
      ],
    );
  }

  Widget _buildAnimated(int index, Widget child) {
    if (index >= _cardAnimations.length) return child;
    return AnimatedBuilder(
      animation: _cardAnimations[index],
      builder: (context, _) {
        final value = _cardAnimations[index].value;
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
    );
  }
}

class _AppBarIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _AppBarIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppTheme.outlineLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF424B47)),
      ),
    );
  }
}
