import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyService {
  static const String _baseUrl = 'http://data.fixer.io/api/latest';
  static const String _cacheKey = 'exchange_rates';
  static const String _cacheTimeKey = 'exchange_rates_time';
  static const Duration _cacheDuration = Duration(hours: 24);

  final String _apiKey;
  Map<String, double>? _cachedRates;
  DateTime? _cacheTime;

  CurrencyService({required String apiKey}) : _apiKey = apiKey;

  // supported currencies
  static const List<String> supportedCurrencies = [
    'USD',
    'CAD',
    'EUR',
    'GBP',
    'CNY',
    'JPY',
  ];

  // currency symbols
  static const Map<String, String> currencySymbols = {
    'USD': '\$',
    'CAD': '\$',
    'EUR': '€',
    'GBP': '£',
    'CNY': '¥',
    'JPY': '¥',
  };

  // fetch exchange rates
  Future<Map<String, double>> getExchangeRates() async {
    // check cache first
    if (_cachedRates != null &&
        _cacheTime != null &&
        DateTime.now().difference(_cacheTime!) < _cacheDuration) {
      return _cachedRates!;
    }

    // try loading from shared preferences
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString(_cacheKey);
    final cachedTimeStr = prefs.getString(_cacheTimeKey);

    if (cachedData != null && cachedTimeStr != null) {
      final cacheTime = DateTime.parse(cachedTimeStr);
      if (DateTime.now().difference(cacheTime) < _cacheDuration) {
        _cachedRates = Map<String, double>.from(json.decode(cachedData));
        _cacheTime = cacheTime;
        return _cachedRates!;
      }
    }

    // fetch from API
    try {
      // request other currencies against EUR
      final symbols = supportedCurrencies.where((c) => c != 'EUR').join(',');
      final url = '$_baseUrl?access_key=$_apiKey&symbols=$symbols';

      //print('Fetching rates from: $url');

      final response = await http.get(
        Uri.parse(url),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          final rates = Map<String, double>.from(
            (data['rates'] as Map).map(
              (key, value) => MapEntry(key.toString(), (value as num).toDouble()),
            ),
          );

          // set EUR as 1.0 (base)
          rates['EUR'] = 1.0;

          // cache the rates
          _cachedRates = rates;
          _cacheTime = DateTime.now();

          // save to shared preferences
          await prefs.setString(_cacheKey, json.encode(rates));
          await prefs.setString(_cacheTimeKey, _cacheTime!.toIso8601String());

          return rates;
        } else {
          throw Exception('API error: ${data['error']}');
        }
      } else {
        throw Exception('Failed to fetch rates: ${response.statusCode}');
      }
    } catch (e) {
      // if fetch fails, return cached rates
      if (_cachedRates != null) {
        return _cachedRates!;
      }
      throw Exception('Currency fetch error: $e');
    }
  }

  // convert amount from USD to target currency
  Future<double> convertFromUSD(double amountUSD, String targetCurrency) async {
    if (targetCurrency == 'USD') {
      return amountUSD;
    }

    final rates = await getExchangeRates();
    final usdRate = rates['USD'];
    final targetRate = rates[targetCurrency];

    if (usdRate == null || targetRate == null) {
      throw Exception('Currency $targetCurrency not supported');
    }

    // fixer.io uses EUR as base currency, we convert it to target currency
    return (amountUSD / usdRate) * targetRate;
  }

  // format price with currency symbol
  static String formatPrice(double amount, String currency) {
    final symbol = currencySymbols[currency] ?? currency;

    // format based on currency
    if (currency == 'JPY' || currency == 'CNY') {
      // no decimals for yen and yuan
      return '$symbol${amount.toStringAsFixed(0)}';
    } else {
      return '$symbol${amount.toStringAsFixed(2)}';
    }
  }

  // get currency name
  static String getCurrencyName(String code) {
    const names = {
      'USD': 'US Dollar',
      'CAD': 'Canadian Dollar',
      'JPY': 'Japanese Yen',
      'CNY': 'Chinese Yuan',
      'EUR': 'Euro',
      'GBP': 'British Pound',
    };
    return names[code] ?? code;
  }
}
