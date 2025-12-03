import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
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

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flight Search'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: _buildSearchForm(),
        ),
      ),
    );
  }

  // search form
  Widget _buildSearchForm() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.mediumGrey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
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

  Widget _buildTripTypeButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryOrange
              : AppColors.lightGrey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? AppColors.white : AppColors.darkGrey,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // text field
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.darkGrey,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.darkGrey,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border.all(color: AppColors.lightGrey),
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
                    color: date != null ? AppColors.darkGrey : AppColors.mediumGrey,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Passengers',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.darkGrey,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border.all(color: AppColors.lightGrey),
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
                    items: List.generate(9, (index) => index + 1)
                        .map((num) => DropdownMenuItem(
                              value: num,
                              child: Text('$num'),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Class',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.darkGrey,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border.all(color: AppColors.lightGrey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _travelClass,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 'ECONOMY', child: Text('Economy')),
                DropdownMenuItem(value: 'PREMIUM_ECONOMY', child: Text('Premium')),
                DropdownMenuItem(value: 'BUSINESS', child: Text('Business')),
                DropdownMenuItem(value: 'FIRST', child: Text('First')),
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
  void _handleSearch() {
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

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FlightResultsScreen(
            origin: _originController.text,
            destination: _destinationController.text,
            departureDate: _departureDate!,
            returnDate: _returnDate,
            passengers: _passengers,
            travelClass: _travelClass,
            isRoundTrip: _isRoundTrip,
          ),
        ),
      );
    }
  }
}
