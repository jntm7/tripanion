import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../theme/app_theme.dart';
import '../models/airport.dart';
import '../services/hotel_service.dart';
import '../config/api_config.dart';
import 'hotel_results_screen.dart';

// HotelsScreen provides a form for searching hotels with parameters
// we use StatefulWidget because we need to manage form state and user inputs
// for the autocomplete, we reuse the Airport model which already has the city and country fields
class HotelsScreen extends StatefulWidget {
  const HotelsScreen({super.key});

  @override
  State<HotelsScreen> createState() => _HotelsScreenState();
}

class _HotelsScreenState extends State<HotelsScreen> {
  final _formKey = GlobalKey<FormState>();

  final _locationController = TextEditingController();

  DateTime? _checkinDate;
  DateTime? _checkoutDate;
  int _rooms = 1;
  int _adults = 2;
  int _children = 0;
  bool _isSearching = false;

  // hotel service
  late final HotelService _hotelService;

  // city data for autocomplete using airports data
  List<Airport> _cities = [];
  // loading state of city data, again not sure why it's flagged as unused
  bool _isLoadingCities = true;
  Airport? _selectedCity;

  @override
  void initState() {
    super.initState();
    _hotelService = HotelService(apiKey: ApiConfig.liteApiKey);
    _loadCities();
  }

  // load cities from airports JSON
  Future<void> _loadCities() async {
    try {
      final String response = await rootBundle.loadString('assets/data/airports.json');
      final List<dynamic> data = json.decode(response);
      setState(() {
        _cities = data.map((json) => Airport.fromJson(json)).toList();
        _isLoadingCities = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCities = false;
      });
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hotel Search'),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppColors.primaryOrange.withValues(alpha: 0.05),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: _buildSearchForm(),
            ),
          ),
        ),
      ),
    );
  }

  // search form
  Widget _buildSearchForm() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            _buildCityAutocomplete(),

            const SizedBox(height: 16),

            // date picker
            Row(
              children: [
                Expanded(
                  child: _buildDateField(
                    label: 'Check-in',
                    date: _checkinDate,
                    onTap: () => _selectCheckinDate(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDateField(
                    label: 'Check-out',
                    date: _checkoutDate,
                    onTap: () => _selectCheckoutDate(context),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            _buildCounterField(
              label: 'Rooms',
              value: _rooms,
              onIncrement: () => setState(() => _rooms++),
              onDecrement: () => setState(() {
                if (_rooms > 1) _rooms--;
              }),
            ),

            const SizedBox(height: 16),

            // guests
            Row(
              children: [
                Expanded(
                  child: _buildCounterField(
                    label: 'Adults',
                    value: _adults,
                    onIncrement: () => setState(() => _adults++),
                    onDecrement: () => setState(() {
                      if (_adults > 1) _adults--;
                    }),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildCounterField(
                    label: 'Children',
                    value: _children,
                    onIncrement: () => setState(() => _children++),
                    onDecrement: () => setState(() {
                      if (_children > 0) _children--;
                    }),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // search button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSearching ? null : _handleSearch,
                child: _isSearching
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : const Text('Search Hotels'),
              ),
            ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // city autocomplete field
  Widget _buildCityAutocomplete() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Destination',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white.withValues(alpha: 0.9) : AppColors.darkGrey,
          ),
        ),
        const SizedBox(height: 8),
        Autocomplete<Airport>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<Airport>.empty();
            }
            return _cities.where((Airport city) {
              final searchLower = textEditingValue.text.toLowerCase();
              return city.city.toLowerCase().contains(searchLower) ||
                     city.name.toLowerCase().contains(searchLower) ||
                     city.iataCode.toLowerCase().contains(searchLower);
            }).take(5);
          },
          displayStringForOption: (Airport city) => '${city.city}, ${city.country}',
          fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
            _locationController.text = controller.text;
            return TextFormField(
              controller: controller,
              focusNode: focusNode,
              decoration: InputDecoration(
                hintText: 'Enter city name',
                prefixIcon: const Icon(Icons.location_on, color: AppColors.primaryOrange),
              ),
              validator: (value) {
                if (_selectedCity == null) {
                  return 'Please select a city from the dropdown';
                }
                return null;
              },
              onEditingComplete: onEditingComplete,
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  width: MediaQuery.of(context).size.width - 64,
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final city = options.elementAt(index);
                      return ListTile(
                        leading: const Icon(Icons.location_city, color: AppColors.primaryOrange),
                        title: Text(
                          city.city,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text('${city.country} (${city.iataCode})'),
                        onTap: () => onSelected(city),
                      );
                    },
                  ),
                ),
              ),
            );
          },
          onSelected: (Airport city) {
            setState(() {
              _selectedCity = city;
              _locationController.text = '${city.city}, ${city.country}';
            });
          },
        ),
      ],
    );
  }

  // date field
  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white.withValues(alpha: 0.9) : AppColors.darkGrey,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2C2C2C) : AppColors.white,
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : AppColors.lightGrey,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 20, color: AppColors.primaryOrange),
                const SizedBox(width: 12),
                Text(
                  date != null
                      ? '${date.month}/${date.day}/${date.year}'
                      : 'Select date',
                  style: TextStyle(
                    color: date != null
                        ? (isDark ? Colors.white.withValues(alpha: 0.9) : AppColors.darkGrey)
                        : AppColors.mediumGrey,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // counter field
  Widget _buildCounterField({
    required String label,
    required int value,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white.withValues(alpha: 0.9) : AppColors.darkGrey,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2C2C2C) : AppColors.white,
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : AppColors.lightGrey,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: onDecrement,
                icon: const Icon(Icons.remove_circle_outline),
                color: AppColors.primaryOrange,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              Text(
                '$value',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white.withValues(alpha: 0.9) : AppColors.darkGrey,
                ),
              ),
              IconButton(
                onPressed: onIncrement,
                icon: const Icon(Icons.add_circle_outline),
                color: AppColors.primaryOrange,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // checkin date picker
  Future<void> _selectCheckinDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _checkinDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _checkinDate = picked;
        if (_checkoutDate != null && _checkoutDate!.isBefore(picked)) {
          _checkoutDate = null;
        }
      });
    }
  }

  // checkout date picker
  Future<void> _selectCheckoutDate(BuildContext context) async {
    final firstDate = _checkinDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _checkoutDate ?? firstDate.add(const Duration(days: 1)),
      firstDate: firstDate.add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() => _checkoutDate = picked);
    }
  }

  // search handler
  Future<void> _handleSearch() async {
    if (_formKey.currentState!.validate()) {
      if (_checkinDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a check-in date'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      if (_checkoutDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a check-out date'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      setState(() => _isSearching = true);

      try {
        // Search hotels using liteAPI
        final hotels = await _hotelService.searchHotels(
          cityName: _selectedCity!.city,
          countryCode: _selectedCity!.country,
          checkin: _checkinDate!,
          checkout: _checkoutDate!,
          adults: _adults,
          rooms: _rooms,
          children: _children,
        );

        if (mounted) {
          setState(() => _isSearching = false);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HotelResultsScreen(
                city: _selectedCity!.city,
                country: _selectedCity!.country,
                checkinDate: _checkinDate!,
                checkoutDate: _checkoutDate!,
                rooms: _rooms,
                adults: _adults,
                children: _children,
                hotels: hotels,
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isSearching = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to search hotels: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }
}
