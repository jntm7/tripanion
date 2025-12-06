import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

// AccountScreen shows account info and actions like logout/change password/delete account
// we use a stateless widget here since account information is fetched from AuthProvider
// the account screen doesn't need to maintain its own state
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final creationDate = user?.metadata.creationTime;
    final formattedDate = creationDate != null
      ? DateFormat('MMMM yyyy').format(creationDate)
      : 'Unknown';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppColors.primaryOrange.withValues(alpha: 0.05),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // profile section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryOrange.withValues(alpha: 0.1),
                      AppColors.secondaryOrange.withValues(alpha: 0.05),
                    ],
                  ),
                ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primaryOrange,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 48,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.email ?? 'No email',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white.withValues(alpha: 0.95) : AppColors.darkGrey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: isDark ? Colors.white.withValues(alpha: 0.7) : AppColors.mediumGrey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Joined in: $formattedDate',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white.withValues(alpha: 0.7) : AppColors.mediumGrey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildActionCard(
                    context: context,
                    icon: Icons.lock_outline,
                    title: 'Change Password',
                    subtitle: 'Update your account password',
                    onTap: () => _showChangePasswordDialog(context),
                  ),

                  const SizedBox(height: 12),

                  _buildActionCard(
                    context: context,
                    icon: Icons.logout,
                    title: 'Logout',
                    subtitle: 'Sign out of your account',
                    onTap: () => _handleLogout(context),
                  ),

                  const SizedBox(height: 12),

                  _buildActionCard(
                    context: context,
                    icon: Icons.delete_outline,
                    title: 'Delete Account',
                    subtitle: 'Permanently delete your account',
                    isDestructive: true,
                    onTap: () => _showDeleteAccountDialog(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // action card
  Widget _buildActionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isDestructive
                      ? AppColors.error.withValues(alpha: 0.1)
                      : AppColors.primaryOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isDestructive ? AppColors.error : AppColors.primaryOrange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDestructive
                            ? AppColors.error
                            : isDark
                                ? Colors.white.withValues(alpha: 0.95)
                                : AppColors.darkGrey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.6)
                            : AppColors.mediumGrey,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.4)
                    : AppColors.mediumGrey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // logout handler
  void _handleLogout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await authProvider.signOut();
    }
  }

  // change password dialog
  void _showChangePasswordDialog(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userEmail = authProvider.userEmail ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'A password reset link will be sent to your email address.',
            ),
            const SizedBox(height: 12),
            Text(
              userEmail,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.primaryOrange,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await authProvider.resetPassword(userEmail);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Password reset email sent! Check your inbox.'
                          : 'Failed to send reset email: ${authProvider.errorMessage}',
                    ),
                    backgroundColor: success ? AppColors.success : AppColors.error,
                  ),
                );
              }
            },
            child: const Text('Send Reset Link'),
          ),
        ],
      ),
    );
  }

  // delete account dialog
  void _showDeleteAccountDialog(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userEmail = authProvider.userEmail ?? '';
    final confirmationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final isEmailMatch = confirmationController.text == userEmail;

          return AlertDialog(
            title: const Text(
              'Delete Account',
              style: TextStyle(color: AppColors.error),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Are you sure you want to delete your account?',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                const Text(
                  'This action is permanent and cannot be undone. All your data will be lost.',
                ),
                const SizedBox(height: 16),
                const Text(
                  'Type your email address to confirm:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: confirmationController,
                  decoration: InputDecoration(
                    hintText: userEmail,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Note: You may need to log in again to confirm this action.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.mediumGrey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  confirmationController.dispose();
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isEmailMatch ? AppColors.error : AppColors.mediumGrey,
                ),
                onPressed: isEmailMatch
                    ? () async {
                        Navigator.pop(context);
                        confirmationController.dispose();

                        final success = await authProvider.deleteAccount();

                        if (context.mounted) {
                          if (!success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  authProvider.errorMessage ?? 'Failed to delete account',
                                ),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                          // If success, user will be automatically redirected to login screen
                          // by the AuthWrapper listening to auth state changes
                        }
                      }
                    : null,
                child: const Text('Delete Account'),
              ),
            ],
          );
        },
      ),
    );
  }
}
