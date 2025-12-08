import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/hotel.dart';
import '../models/saved_item.dart';
import '../services/currency_service.dart';
import '../config/api_config.dart';
import '../providers/saved_items_provider.dart';

// HotelResultsScreen displays a list of hotel search results
// uses StatefulWidget because it needs to manage currency conversion state
// similar to FlightResultsScreen
class HotelResultsScreen extends StatefulWidget {
  final String city;
  final String country;
  final DateTime checkinDate;
  final DateTime checkoutDate;
  final int rooms;
  final int adults;
  final int children;
  final List<HotelOffer> hotels;

  const HotelResultsScreen({
    super.key,
    required this.city,
    required this.country,
    required this.checkinDate,
    required this.checkoutDate,
    required this.rooms,
    required this.adults,
    required this.children,
    required this.hotels,
  });

  @override
  State<HotelResultsScreen> createState() => _HotelResultsScreenState();
}

class _HotelResultsScreenState extends State<HotelResultsScreen> {
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
        // Failed to load exchange rates
      }
    }

    if (mounted) {
      setState(() {
        _selectedCurrency = savedCurrency;
      });
    }
  }

  // convert price to selected currency
  String _getConvertedPrice(String usdPrice) {
    final price = double.tryParse(usdPrice) ?? 0.0;
    final convertedPrice = price * _conversionRate;
    return CurrencyService.formatPrice(convertedPrice, _selectedCurrency);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hotel Results'),
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
    final nights = widget.checkoutDate.difference(widget.checkinDate).inDays;

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
                  '${widget.city}, ${widget.country}',
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
            '${_formatDate(widget.checkinDate)} - ${_formatDate(widget.checkoutDate)} • $nights night${nights > 1 ? 's' : ''} • ${widget.rooms} room${widget.rooms > 1 ? 's' : ''} • ${widget.adults + widget.children} guest${(widget.adults + widget.children) > 1 ? 's' : ''}',
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

    if (widget.hotels.isEmpty) {
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
              'No hotels found',
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
      itemCount: widget.hotels.length,
      itemBuilder: (context, index) {
        final hotel = widget.hotels[index];
        return _buildHotelCard(hotel);
      },
    );
  }

  // hotel card
  Widget _buildHotelCard(HotelOffer hotel) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nights = widget.checkoutDate.difference(widget.checkinDate).inDays;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // Hotel details will be implemented later
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
                      Icons.hotel,
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
                          hotel.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white.withValues(alpha: 0.95) : AppColors.darkGrey,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            ...List.generate(
                              5,
                              (index) => Icon(
                                index < hotel.stars ? Icons.star : Icons.star_border,
                                size: 14,
                                color: AppColors.warning,
                              ),
                            ),
                            if (hotel.rating > 0) ...[
                              const SizedBox(width: 6),
                              Text(
                                hotel.rating.toStringAsFixed(1),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.white.withValues(alpha: 0.6) : AppColors.mediumGrey,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                hotel.address,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white.withValues(alpha: 0.7) : AppColors.mediumGrey,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Consumer<SavedItemsProvider>(
                    builder: (context, savedItemsProvider, child) {
                      final isSaved = savedItemsProvider.isSaved(hotel.id);
                      return IconButton(
                        onPressed: () {
                          final savedItem = SavedItem.fromHotel(
                            id: hotel.id,
                            origin: widget.city,
                            destination: widget.city,
                            departureDate: widget.checkinDate,
                            returnDate: widget.checkoutDate,
                            price: hotel.price,
                            currency: _selectedCurrency,
                            hotelName: hotel.name,
                            nights: nights,
                            rooms: widget.rooms,
                            guests: widget.adults + widget.children,
                          );
                          savedItemsProvider.toggleSavedItem(savedItem);
                        },
                        icon: Icon(
                          isSaved ? Icons.bookmark : Icons.bookmark_border,
                          color: isSaved ? AppColors.primaryOrange : (isDark ? Colors.white.withValues(alpha: 0.6) : AppColors.mediumGrey),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _getConvertedPrice(hotel.price),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryOrange,
                        ),
                      ),
                      Text(
                        '$nights Nights ($_selectedCurrency)',
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? Colors.white.withValues(alpha: 0.6) : AppColors.mediumGrey,
                        ),
                      ),
                    ],
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
}
