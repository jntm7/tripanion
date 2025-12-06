import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../models/flight.dart';
import '../utils/flight_utils.dart';
import '../services/currency_service.dart';
import '../config/api_config.dart';

class FlightResultsScreen extends StatefulWidget {
  final String origin;
  final String destination;
  final DateTime departureDate;
  final DateTime? returnDate;
  final int passengers;
  final String travelClass;
  final bool isRoundTrip;
  final List<FlightOffer> flights;

  const FlightResultsScreen({
    super.key,
    required this.origin,
    required this.destination,
    required this.departureDate,
    this.returnDate,
    required this.passengers,
    required this.travelClass,
    required this.isRoundTrip,
    required this.flights,
  });

  @override
  State<FlightResultsScreen> createState() => _FlightResultsScreenState();
}

class _FlightResultsScreenState extends State<FlightResultsScreen> {
  late CurrencyService _currencyService;
  String _selectedCurrency = 'USD';
  double _conversionRate = 1.0;

  @override
  void initState() {
    super.initState();
    _currencyService = CurrencyService(apiKey: ApiConfig.fixerApiKey);
    _loadCurrency();
  }

  // load saved currency preference and exchange rates
  Future<void> _loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCurrency = prefs.getString('preferred_currency') ?? 'USD';

    if (savedCurrency != 'USD') {
      try {
        final rates = await _currencyService.getExchangeRates();
        final usdRate = rates['USD'];
        final targetRate = rates[savedCurrency];

        if (usdRate != null && targetRate != null) {
          _conversionRate = targetRate / usdRate;
        }
      } catch (e) {
        //print('Failed to load exchange rates: $e');
      }
    }

    if (mounted) {
      setState(() {
        _selectedCurrency = savedCurrency;
      });
    }
  }

  // convert price to selected currency (synchronous)
  String _getConvertedPrice(String usdPrice) {
    final price = double.tryParse(usdPrice) ?? 0.0;
    final convertedPrice = price * _conversionRate;
    return CurrencyService.formatPrice(convertedPrice, _selectedCurrency);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flight Results'),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppColors.primaryOrange.withValues(alpha: 0.05),
        child: Column(
          children: [
            _buildSearchSummary(),
            Expanded(
              child: _buildResultsList(),
            ),
          ],
        ),
      ),
    );
  }

  // search summary
  Widget _buildSearchSummary() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : AppColors.white,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : AppColors.mediumGrey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${widget.origin} → ${widget.destination}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white.withValues(alpha: 0.95) : AppColors.darkGrey,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Edit'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${_formatDate(widget.departureDate)}${widget.isRoundTrip && widget.returnDate != null ? ' - ${_formatDate(widget.returnDate!)}' : ''} • ${widget.passengers} passenger${widget.passengers > 1 ? 's' : ''} • ${_formatClass(widget.travelClass)}',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white.withValues(alpha: 0.7) : AppColors.mediumGrey,
            ),
          ),
        ],
      ),
    );
  }

  // results list
  Widget _buildResultsList() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (widget.flights.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: isDark ? Colors.white.withValues(alpha: 0.4) : AppColors.mediumGrey,
            ),
            const SizedBox(height: 16),
            Text(
              'No flights found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white.withValues(alpha: 0.95) : AppColors.darkGrey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search criteria',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white.withValues(alpha: 0.7) : AppColors.mediumGrey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('New Search'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.flights.length,
      itemBuilder: (context, index) {
        final flight = widget.flights[index];
        return _buildFlightCard(flight);
      },
    );
  }

  // flight card
  Widget _buildFlightCard(FlightOffer flight) {
    final outbound = flight.itineraries.first;
    final firstSegment = outbound.firstSegment;
    final lastSegment = outbound.lastSegment;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('View details for flight ${flight.id}')),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : AppColors.lightGrey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.flight,
                      color: AppColors.primaryOrange,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          getAirlineName(firstSegment.carrierCode),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white.withValues(alpha: 0.95) : AppColors.darkGrey,
                          ),
                        ),
                        Text(
                          firstSegment.flightNumber,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white.withValues(alpha: 0.6) : AppColors.mediumGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _getConvertedPrice(flight.price),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryOrange,
                        ),
                      ),
                      Text(
                        '$_selectedCurrency per person',
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? Colors.white.withValues(alpha: 0.6) : AppColors.mediumGrey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatDateShort(firstSegment.departureTime),
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.white.withValues(alpha: 0.6) : AppColors.mediumGrey,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          formatTime(firstSegment.departureTime),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white.withValues(alpha: 0.95) : AppColors.darkGrey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          firstSegment.departureIataCode,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white.withValues(alpha: 0.6) : AppColors.mediumGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        Text(
                          formatDuration(outbound.duration),
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white.withValues(alpha: 0.6) : AppColors.mediumGrey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Container(
                                height: 2,
                                color: AppColors.lightGrey,
                              ),
                            ),
                            if (outbound.numberOfStops > 0) ...[
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.warning.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${outbound.numberOfStops} stop${outbound.numberOfStops > 1 ? 's' : ''}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.warning,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                            ],
                            Expanded(
                              child: Container(
                                height: 2,
                                color: AppColors.lightGrey,
                              ),
                            ),
                          ],
                        ),
                        if (outbound.numberOfStops == 0)
                          const SizedBox(
                            height: 16,
                            child: Text(
                              'Nonstop',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.success,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatDateShort(lastSegment.arrivalTime),
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.white.withValues(alpha: 0.6) : AppColors.mediumGrey,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          formatTime(lastSegment.arrivalTime),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white.withValues(alpha: 0.95) : AppColors.darkGrey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          lastSegment.arrivalIataCode,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white.withValues(alpha: 0.6) : AppColors.mediumGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // date formatter
  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }

  // short date formatter for flight cards
  String _formatDateShort(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }

  // class formatter
  String _formatClass(String travelClass) {
    switch (travelClass) {
      case 'ECONOMY':
        return 'Economy';
      case 'PREMIUM_ECONOMY':
        return 'Premium Economy';
      case 'BUSINESS':
        return 'Business';
      case 'FIRST':
        return 'First';
      default:
        return travelClass;
    }
  }
}
