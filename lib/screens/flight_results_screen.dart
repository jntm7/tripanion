import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FlightResultsScreen extends StatefulWidget {
  final String origin;
  final String destination;
  final DateTime departureDate;
  final DateTime? returnDate;
  final int passengers;
  final String travelClass;
  final bool isRoundTrip;

  const FlightResultsScreen({
    super.key,
    required this.origin,
    required this.destination,
    required this.departureDate,
    this.returnDate,
    required this.passengers,
    required this.travelClass,
    required this.isRoundTrip,
  });

  @override
  State<FlightResultsScreen> createState() => _FlightResultsScreenState();
}

class _FlightResultsScreenState extends State<FlightResultsScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _flights = [];

  @override
  void initState() {
    super.initState();
    _searchFlights();
  }

  // search flights
  Future<void> _searchFlights() async {
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _flights = [
        {
          'airline': 'United Airlines',
          'flightNumber': 'UA 123',
          'departureTime': '08:00 AM',
          'arrivalTime': '11:30 AM',
          'duration': '3h 30m',
          'stops': 0,
          'price': 245.00,
        },
        {
          'airline': 'Delta Air Lines',
          'flightNumber': 'DL 456',
          'departureTime': '10:15 AM',
          'arrivalTime': '02:00 PM',
          'duration': '3h 45m',
          'stops': 0,
          'price': 289.00,
        },
        {
          'airline': 'American Airlines',
          'flightNumber': 'AA 789',
          'departureTime': '02:30 PM',
          'arrivalTime': '06:15 PM',
          'duration': '3h 45m',
          'stops': 1,
          'price': 198.00,
        },
      ];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flight Results'),
      ),
      body: Column(
        children: [
          _buildSearchSummary(),
          Expanded(
            child: _isLoading ? _buildLoadingState() : _buildResultsList(),
          ),
        ],
      ),
    );
  }

  // search summary
  Widget _buildSearchSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.mediumGrey.withOpacity(0.1),
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
                  '${widget.origin} � ${widget.destination}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGrey,
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
            '${_formatDate(widget.departureDate)}${widget.isRoundTrip && widget.returnDate != null ? ' - ${_formatDate(widget.returnDate!)}' : ''} " ${widget.passengers} passenger${widget.passengers > 1 ? 's' : ''} " ${_formatClass(widget.travelClass)}',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.mediumGrey,
            ),
          ),
        ],
      ),
    );
  }

  // loading state
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primaryOrange),
          SizedBox(height: 16),
          Text(
            'Searching for flights...',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.mediumGrey,
            ),
          ),
        ],
      ),
    );
  }

  // results list
  Widget _buildResultsList() {
    if (_flights.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.mediumGrey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No flights found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.darkGrey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try adjusting your search criteria',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.mediumGrey,
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
      padding: const EdgeInsets.all(14),
      itemCount: _flights.length,
      itemBuilder: (context, index) {
        final flight = _flights[index];
        return _buildFlightCard(flight);
      },
    );
  }

  // flight card
  Widget _buildFlightCard(Map<String, dynamic> flight) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('View details for ${flight['flightNumber']}')),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.lightGrey.withOpacity(0.3),
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
                          flight['airline'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkGrey,
                          ),
                        ),
                        Text(
                          flight['flightNumber'],
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.mediumGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${flight['price'].toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryOrange,
                        ),
                      ),
                      const Text(
                        'per person',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.mediumGrey,
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
                          flight['departureTime'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGrey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.origin,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.mediumGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          flight['duration'],
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.mediumGrey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 40,
                              height: 2,
                              color: AppColors.lightGrey,
                            ),
                            if (flight['stops'] > 0) ...[
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.warning.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${flight['stops']} stop${flight['stops'] > 1 ? 's' : ''}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.warning,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 2),
                            ],
                            Container(
                              width: 40,
                              height: 2,
                              color: AppColors.lightGrey,
                            ),
                          ],
                        ),
                        if (flight['stops'] == 0)
                          const SizedBox(
                            height: 14,
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
                          flight['arrivalTime'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGrey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.destination,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.mediumGrey,
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
