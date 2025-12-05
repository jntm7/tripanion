import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';
import '../services/currency_service.dart';

class HomeScreen extends StatefulWidget {
  final Function(int)? onNavigateToTab;

  const HomeScreen({super.key, this.onNavigateToTab});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCurrency = 'CAD';

  @override
  void initState() {
    super.initState();
    _loadCurrencyPreference();
  }

  // load saved currency preference
  Future<void> _loadCurrencyPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedCurrency = prefs.getString('preferred_currency') ?? 'USD';
    });
  }

  // save currency preference
  Future<void> _saveCurrency(String currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('preferred_currency', currency);
    setState(() => _selectedCurrency = currency);
  }

  // build method
  @override
  Widget build(BuildContext context) {
    // get the user name from AuthProvider
    final authProvider = Provider.of<AuthProvider>(context);
    final userName = authProvider.userEmail?.split('@')[0] ?? 'Traveler';

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryOrange.withValues(alpha: 0.08),
                AppColors.secondaryOrange.withValues(alpha: 0.03),
              ],
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeSection(userName),
                const SizedBox(height: 24),
                _buildQuickActionCards(context),
                const SizedBox(height: 24),
                _buildPopularDestinations(context),
                const SizedBox(height: 24),
                _buildSettings(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // welcome banner
  Widget _buildWelcomeSection(String userName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome, $userName!',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryOrange,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Where to next? ✈️',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.darkGrey,
            ),
          ),
        ],
      ),
    );
  }

  // flight & hotel search cards
  Widget _buildQuickActionCards(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: _buildActionCard(
              context: context,
              title: 'Flight\nSearch',
              icon: Icons.flight_takeoff,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primaryOrange, AppColors.secondaryOrange],
              ),
              onTap: () => widget.onNavigateToTab?.call(0),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildActionCard(
              context: context,
              title: 'Hotel\nSearch',
              icon: Icons.hotel,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.accentOrange,
                  AppColors.secondaryOrange.withValues(alpha: 0.8),
                ],
              ),
              onTap: () => widget.onNavigateToTab?.call(1),
            ),
          ),
        ],
      ),
    );
  }
  // action card widget
  Widget _buildActionCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryOrange.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: AppColors.white,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // popular destinations carousel (for hotels)
  Widget _buildPopularDestinations(BuildContext context) {
    final destinations = [
      {'name': 'Tokyo', 'country': 'Japan', 'image': 'tokyo.jpg'},
      {'name': 'Paris', 'country': 'France', 'image': 'paris.jpg'},
      {'name': 'New York', 'country': 'USA', 'image': 'new_york.jpg'},
      {'name': 'London', 'country': 'UK', 'image': 'london.jpg'},
      {'name': 'Sydney', 'country': 'Australia', 'image': 'sydney.jpg'},
      {'name': 'Shanghai', 'country': 'China', 'image': 'shanghai.jpg'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Popular Destinations',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGrey,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: destinations.length,
            itemBuilder: (context, index) {
              final destination = destinations[index];
              return Padding(
                padding: EdgeInsets.only(
                  right: index < destinations.length - 1 ? 12 : 0,
                ),
                child: _buildDestinationCard(
                  context: context,
                  name: destination['name']!,
                  country: destination['country']!,
                  image: destination['image']!,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // destination card thumbnails
  Widget _buildDestinationCard({
    required BuildContext context,
    required String name,
    required String country,
    required String image,
  }) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Search hotels in $name')),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: AssetImage('assets/images/destinations/$image'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.15),
              BlendMode.darken,
            ),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.5),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                country,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // settings section
  Widget _buildSettings() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Settings',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGrey,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AppColors.mediumGrey.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // currency selector
                Row(
                  children: [
                    const Icon(
                      Icons.attach_money,
                      color: AppColors.primaryOrange,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Currency',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkGrey,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.lightGrey),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCurrency,
                          borderRadius: BorderRadius.circular(12),
                          elevation: 8,
                          dropdownColor: AppColors.white,
                          items: CurrencyService.supportedCurrencies
                              .map((currency) => DropdownMenuItem(
                                    value: currency,
                                    child: Text(
                                      currency,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              _saveCurrency(value);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                // dark mode toggle
                Row(
                  children: [
                    const Icon(
                      Icons.dark_mode,
                      color: AppColors.primaryOrange,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Dark Mode',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkGrey,
                        ),
                      ),
                    ),
                    // Dark Mode Switch using ThemeProvider
                    Consumer<ThemeProvider>(
                      builder: (context, themeProvider, child) {
                        return Switch(
                          value: themeProvider.isDarkMode,
                          activeThumbColor: AppColors.primaryOrange,
                          onChanged: (value) {
                            themeProvider.setTheme(value);
                          },
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
