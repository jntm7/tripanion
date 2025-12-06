import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../config/api_config.dart';
import '../services/flight_service.dart';
import 'flight_results_screen.dart';

class FlightsScreen extends StatefulWidget {
  const FlightsScreen({super.key});

  @override
  State<FlightsScreen> createState() => _FlightsScreenState();
}

class _FlightsScreenState extends State<FlightsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _originController = TextEditingController();
  final _destinationController = TextEditingController();
  bool _isRoundTrip = true;
  DateTime? _departureDate;
  DateTime? _returnDate;
  int _passengers = 1;
  String _travelClass = 'ECONOMY';
  bool _isSearching = false;
  
  // initialize flight service
  late final FlightService _flightService;

  @override
  void initState() {
    super.initState();
    _flightService = FlightService(
      apiKey: ApiConfig.amadeusApiKey,
      apiSecret: ApiConfig.amadeusApiSecret,
    );
  }

  // dispose controllers
  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  // build method
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flight Search'),
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
            _buildTripTypeToggle(),

            const SizedBox(height: 20),

            _buildTextField(
              controller: _originController,
              label: 'From',
              hint: 'Origin City or Airport',
              icon: Icons.flight_takeoff,
            ),

            const SizedBox(height: 16),

            _buildTextField(
              controller: _destinationController,
              label: 'To',
              hint: 'Destination City or Airport',
              icon: Icons.flight_land,
            ),

            const SizedBox(height: 16),

            // date picker
            Row(
              children: [
                Expanded(
                  child: _buildDateField(
                    label: 'Departure',
                    date: _departureDate,
                    onTap: () => _selectDepartureDate(context),
                  ),
                ),
                const SizedBox(width: 12),
                if (_isRoundTrip)
                  Expanded(
                    child: _buildDateField(
                      label: 'Return',
                      date: _returnDate,
                      onTap: () => _selectReturnDate(context),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildPassengerSelector(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildClassSelector(),
                ),
              ],
            ),

            const SizedBox(height: 24),
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
                    : const Text('Search Flights'),
              ),
            ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // trip type toggle
  Widget _buildTripTypeToggle() {
    return Row(
      children: [
        Expanded(
          child: _buildTripTypeButton(
            label: 'Round-trip',
            isSelected: _isRoundTrip,
            onTap: () => setState(() => _isRoundTrip = true),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildTripTypeButton(
            label: 'One-way',
            isSelected: !_isRoundTrip,
            onTap: () => setState(() {
              _isRoundTrip = false;
              _returnDate = null;
            }),
          ),
        ),
      ],
    );
  }

  // trip type button
  Widget _buildTripTypeButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryOrange
              : isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : AppColors.lightGrey.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected
                ? AppColors.white
                : isDark
                    ? Colors.white.withValues(alpha: 0.9)
                    : AppColors.darkGrey,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // origin & destination text fields
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
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
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.primaryOrange),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              if (controller == _originController) {
                return 'Origin city or airport is required';
              } else if (controller == _destinationController) {
                return 'Destination city or airport is required';
              }
              return 'Please enter $label';
            }
            return null;
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

  // passenger selector
  Widget _buildPassengerSelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Passengers',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white.withValues(alpha: 0.9) : AppColors.darkGrey,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
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
              const Icon(Icons.person, color: AppColors.primaryOrange),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _passengers,
                    dropdownColor: isDark ? const Color(0xFF2C2C2C) : AppColors.white,
                    items: List.generate(9, (index) => index + 1)
                        .map((number) => DropdownMenuItem(
                              value: number,
                              child: Text(
                                '$number',
                                style: TextStyle(
                                  color: isDark ? Colors.white.withValues(alpha: 0.9) : AppColors.darkGrey,
                                ),
                              ),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _passengers = value);
                      }
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

  // class selector
  Widget _buildClassSelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Class',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white.withValues(alpha: 0.9) : AppColors.darkGrey,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2C2C2C) : AppColors.white,
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : AppColors.lightGrey,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _travelClass,
              isExpanded: true,
              dropdownColor: isDark ? const Color(0xFF2C2C2C) : AppColors.white,
              items: [
                DropdownMenuItem(
                  value: 'ECONOMY',
                  child: Text(
                    'Economy',
                    style: TextStyle(
                      color: isDark ? Colors.white.withValues(alpha: 0.9) : AppColors.darkGrey,
                    ),
                  ),
                ),
                DropdownMenuItem(
                  value: 'PREMIUM_ECONOMY',
                  child: Text(
                    'Premium',
                    style: TextStyle(
                      color: isDark ? Colors.white.withValues(alpha: 0.9) : AppColors.darkGrey,
                    ),
                  ),
                ),
                DropdownMenuItem(
                  value: 'BUSINESS',
                  child: Text(
                    'Business',
                    style: TextStyle(
                      color: isDark ? Colors.white.withValues(alpha: 0.9) : AppColors.darkGrey,
                    ),
                  ),
                ),
                DropdownMenuItem(
                  value: 'FIRST',
                  child: Text(
                    'First',
                    style: TextStyle(
                      color: isDark ? Colors.white.withValues(alpha: 0.9) : AppColors.darkGrey,
                    ),
                  ),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _travelClass = value);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  // departure date picker
  Future<void> _selectDepartureDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _departureDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _departureDate = picked;
        if (_returnDate != null && _returnDate!.isBefore(picked)) {
          _returnDate = null;
        }
      });
    }
  }

  // return date picker
  Future<void> _selectReturnDate(BuildContext context) async {
    final firstDate = _departureDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _returnDate ?? firstDate,
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() => _returnDate = picked);
    }
  }

  // search handler
  Future<void> _handleSearch() async {
    if (_formKey.currentState!.validate()) {
      if (_departureDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a departure date'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      if (_isRoundTrip && _returnDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a return date'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      setState(() => _isSearching = true);

      // perform the flight search here
      try {
        final flights = await _flightService.searchFlights(
          origin: _originController.text.trim().toUpperCase(),
          destination: _destinationController.text.trim().toUpperCase(),
          departureDate: _departureDate!,
          returnDate: _isRoundTrip ? _returnDate : null,
          adults: _passengers,
          travelClass: _travelClass,
        );

        if (!mounted) return;

        // navigate to results screen with results
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FlightResultsScreen(
              origin: _originController.text.trim().toUpperCase(),
              destination: _destinationController.text.trim().toUpperCase(),
              departureDate: _departureDate!,
              returnDate: _returnDate,
              passengers: _passengers,
              travelClass: _travelClass,
              isRoundTrip: _isRoundTrip,
              flights: flights,
            ),
          ),
        );
      } 
      catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error searching flights: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      } finally {
        if (mounted) {
          setState(() => _isSearching = false);
        }
      }
    }
  }
}
