import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

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
  final bool _isSearching = false;

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
            _buildTextField(
              controller: _locationController,
              label: 'Destination',
              hint: 'City or Hotel Name',
              icon: Icons.location_on,
            ),

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

  // text field
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
              return 'City or Hotel Name is required';
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
  void _handleSearch() {
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

      // TODO: navigate to hotel results screen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hotel search will be implemented with liteAPI'),
        ),
      );
    }
  }
}
