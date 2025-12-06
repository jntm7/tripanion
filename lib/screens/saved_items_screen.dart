import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/saved_item.dart';
import '../providers/saved_items_provider.dart';

class SavedItemsScreen extends StatelessWidget {
  const SavedItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Items'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(context, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear_all',
                child: Text('Clear All'),
              ),
              const PopupMenuItem(
                value: 'clear_flights',
                child: Text('Clear Flights'),
              ),
              const PopupMenuItem(
                value: 'clear_hotels',
                child: Text('Clear Hotels'),
              ),
            ],
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppColors.primaryOrange.withValues(alpha: 0.05),
        child: Consumer<SavedItemsProvider>(
          builder: (context, savedItemsProvider, child) {
            final savedItems = savedItemsProvider.savedItems;

            if (savedItems.isEmpty) {
              return _buildEmptyState(context);
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: savedItems.length,
              itemBuilder: (context, index) {
                final item = savedItems[index];
                return _buildSavedItemCard(context, item, savedItemsProvider);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_border,
            size: 80,
            color: isDark ? Colors.white.withValues(alpha: 0.4) : AppColors.mediumGrey,
          ),
          const SizedBox(height: 24),
          Text(
            'No Saved Items',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white.withValues(alpha: 0.95) : AppColors.darkGrey,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Save flights and hotels to view them here',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white.withValues(alpha: 0.7) : AppColors.mediumGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedItemCard(
    BuildContext context,
    SavedItem item,
    SavedItemsProvider provider,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final timeAgo = _formatTimeAgo(item.savedAt);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // header
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
                  child: Icon(
                    item.type == SavedItemType.flight
                        ? Icons.flight
                        : Icons.hotel,
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
                    item.type == SavedItemType.flight
                      ? '${item.origin} → ${item.destination}'
                      : item.hotelName ?? 'Unknown Location',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white.withValues(alpha: 0.95) : AppColors.darkGrey,
                    ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                    timeAgo,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white.withValues(alpha: 0.6) : AppColors.mediumGrey,
                    ),
                    ),
                  ],
                  ),
                ),
                IconButton(
                  onPressed: () => _confirmDelete(context, item, provider),
                  icon: Icon(
                    Icons.delete_outline,
                    color: isDark ? Colors.white.withValues(alpha: 0.6) : AppColors.mediumGrey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),

            // Details section
            if (item.type == SavedItemType.flight) ...[
              _buildDetailRow(
                context,
                icon: Icons.airline_seat_recline_normal,
                label: item.airline ?? 'Unknown Airline',
                isDark: isDark,
              ),
              const SizedBox(height: 8),
              _buildDetailRow(
                context,
                icon: Icons.confirmation_number,
                label: item.flightNumber ?? 'N/A',
                isDark: isDark,
              ),
              const SizedBox(height: 8),
              _buildDetailRow(
                context,
                icon: Icons.event,
                label: _formatDate(item.departureDate) +
                    (item.returnDate != null ? ' - ${_formatDate(item.returnDate!)}' : ''),
                isDark: isDark,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailRow(
                      context,
                      icon: Icons.people,
                      label: '${item.passengers} passenger${item.passengers! > 1 ? 's' : ''}',
                      isDark: isDark,
                    ),
                  ),
                  Expanded(
                    child: _buildDetailRow(
                      context,
                      icon: Icons.class_,
                      label: _formatClass(item.travelClass ?? 'ECONOMY'),
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
            ] else ...[
              _buildDetailRow(
                context,
                icon: Icons.hotel,
                label: item.hotelName ?? 'Unknown Hotel',
                isDark: isDark,
              ),
              const SizedBox(height: 8),
              _buildDetailRow(
                context,
                icon: Icons.event,
                label: _formatDate(item.departureDate) +
                    (item.returnDate != null ? ' - ${_formatDate(item.returnDate!)}' : ''),
                isDark: isDark,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailRow(
                      context,
                      icon: Icons.nights_stay,
                      label: '${item.nights} night${item.nights! > 1 ? 's' : ''}, ${item.rooms} room${item.rooms! > 1 ? 's' : ''}',
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildDetailRow(
                context,
                icon: Icons.people,
                label: '${item.guests} guest${item.guests! > 1 ? 's' : ''}',
                isDark: isDark,
              ),
            ],

            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),

            // Price section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Price',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white.withValues(alpha: 0.7) : AppColors.mediumGrey,
                  ),
                ),
                Text(
                  '${item.price} ${item.currency}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryOrange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isDark ? Colors.white.withValues(alpha: 0.6) : AppColors.mediumGrey,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white.withValues(alpha: 0.9) : AppColors.darkGrey,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _confirmDelete(
    BuildContext context,
    SavedItem item,
    SavedItemsProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Saved Item'),
        content: Text(
          'Are you sure you want to remove this ${item.type == SavedItemType.flight ? 'flight' : 'hotel'} from your saved items?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.removeSavedItem(item.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Item removed from saved items'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    final provider = Provider.of<SavedItemsProvider>(context, listen: false);

    String title;
    String message;
    VoidCallback onConfirm;

    switch (action) {
      case 'clear_all':
        title = 'Clear All Items';
        message = 'Are you sure you want to remove all saved items?';
        onConfirm = () => provider.clearAllSavedItems();
        break;
      case 'clear_flights':
        title = 'Clear All Flights';
        message = 'Are you sure you want to remove all saved flights?';
        onConfirm = () => provider.clearByType(SavedItemType.flight);
        break;
      case 'clear_hotels':
        title = 'Clear All Hotels';
        message = 'Are you sure you want to remove all saved hotels?';
        onConfirm = () => provider.clearByType(SavedItemType.hotel);
        break;
      default:
        return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              onConfirm();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Items cleared'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime savedAt) {
    final difference = DateTime.now().difference(savedAt);

    if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return 'Saved $months month${months > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return 'Saved ${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return 'Saved ${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return 'Saved ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Saved just now';
    }
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

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
