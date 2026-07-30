import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ExchangeRateService {
  static final ExchangeRateService _instance = ExchangeRateService._internal();
  factory ExchangeRateService() => _instance;
  ExchangeRateService._internal();

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  // Free API — no key required
  static const String _baseUrl = 'https://open.er-api.com/v6/latest';

  // Cache
  final Map<String, Map<String, double>> _ratesCache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheDuration = Duration(minutes: 30);

  // Historical data cache
  final Map<String, List<double>> _historicalCache = {};

  /// Fetch latest rates for a base currency
  Future<Map<String, double>> getRates(String baseCurrency) async {
    final now = DateTime.now();
    final cached = _ratesCache[baseCurrency];
    final timestamp = _cacheTimestamps[baseCurrency];

    if (cached != null &&
        timestamp != null &&
        now.difference(timestamp) < _cacheDuration) {
      return cached;
    }

    try {
      final response = await _dio.get('$_baseUrl/$baseCurrency');
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        if (data['result'] == 'success') {
          final rates = Map<String, double>.from(
            (data['rates'] as Map<String, dynamic>).map(
              (k, v) => MapEntry(k, (v as num).toDouble()),
            ),
          );
          _ratesCache[baseCurrency] = rates;
          _cacheTimestamps[baseCurrency] = now;
          return rates;
        }
      }
    } catch (e) {
      debugPrint('ExchangeRateService error: $e');
    }

    // Return cached even if stale, or empty map
    return cached ?? {};
  }

  /// Get a single conversion rate
  Future<double> getRate(String from, String to) async {
    if (from == to) return 1.0;
    final rates = await getRates(from);
    return rates[to] ?? 1.0;
  }

  /// Convert an amount
  Future<double> convert(double amount, String from, String to) async {
    final rate = await getRate(from, to);
    return amount * rate;
  }

  /// Get all available currency codes
  Future<List<String>> getAvailableCurrencies() async {
    final rates = await getRates('USD');
    final currencies = rates.keys.toList()..sort();
    return currencies;
  }

  /// Generate simulated historical data based on current rate
  /// Uses the current rate as anchor and creates realistic variation
  List<double> generateHistoricalData(double currentRate, int points) {
    final List<double> data = [];
    // Work backwards from current rate with small random-like variation
    double rate = currentRate;
    final variation = currentRate * 0.015; // 1.5% variation range

    for (int i = points - 1; i >= 0; i--) {
      // Use deterministic pseudo-variation based on index
      final factor = ((i * 7 + 3) % 17) / 17.0; // 0..1 deterministic
      final delta = (factor - 0.5) * variation;
      data.insert(0, double.parse((rate + delta * (i / points)).toStringAsFixed(6)));
    }
    // Ensure last point is current rate
    if (data.isNotEmpty) data[data.length - 1] = currentRate;
    return data;
  }

  /// Get historical-like data for chart (generated from current rate)
  Future<Map<String, List<double>>> getChartData(
    String from,
    String to,
  ) async {
    final currentRate = await getRate(from, to);
    final cacheKey = '$from/$to';

    if (_historicalCache.containsKey(cacheKey)) {
      // Update last point with fresh rate
      final cached = _historicalCache[cacheKey]!;
      cached[cached.length - 1] = currentRate;
    }

    return {
      '7D': generateHistoricalData(currentRate, 7),
      '1M': generateHistoricalData(currentRate, 30),
      '3M': generateHistoricalData(currentRate, 18),
      '1Y': generateHistoricalData(currentRate, 12),
    };
  }

  /// Get rate change percentage (simulated based on rate magnitude)
  double getRateChangePercent(double rate) {
    // Deterministic pseudo-change based on rate value
    final magnitude = (rate * 100).toInt() % 100;
    final change = (magnitude - 50) / 100.0; // -0.5% to +0.5%
    return double.parse(change.toStringAsFixed(2));
  }

  /// Get 7-day high/low/avg based on current rate
  Map<String, double> getRangeStats(double currentRate) {
    final variation = currentRate * 0.02; // 2% range
    return {
      'high': double.parse((currentRate + variation * 0.8).toStringAsFixed(6)),
      'low': double.parse((currentRate - variation * 0.7).toStringAsFixed(6)),
      'avg': double.parse((currentRate + variation * 0.05).toStringAsFixed(6)),
    };
  }

  void clearCache() {
    _ratesCache.clear();
    _cacheTimestamps.clear();
    _historicalCache.clear();
  }
}
