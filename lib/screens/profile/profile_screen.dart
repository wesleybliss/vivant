import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vivant/providers/auth_provider.dart';
import 'package:vivant/providers/lists_provider.dart';
import 'package:vivant/screens/settings/settings_screen.dart';
import 'package:vivant/utils/logger.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final listsProvider = Provider.of<ListsProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final userInfo = authProvider.authService.getCurrentUserInfo();
    final displayName = userInfo?['displayName'] ?? 'Traveler';
    final email = userInfo?['email'] ?? 'No email available';
    final photoURL = userInfo?['photoURL'];

    final totalLists = listsProvider.lists.length;
    final totalSavedPlaces = listsProvider.lists.fold<int>(
      0,
      (sum, list) => sum + (list.placeCount ?? 0),
    );

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            stretch: true,
            backgroundColor: colorScheme.surface,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primaryContainer.withValues(alpha: 0.8),
                      colorScheme.secondaryContainer.withValues(alpha: 0.4),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    Hero(
                      tag: 'profile-pic',
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colorScheme.onPrimaryContainer.withValues(alpha: 0.2),
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: colorScheme.secondaryContainer,
                          backgroundImage: photoURL != null ? NetworkImage(photoURL) : null,
                          child: photoURL == null
                              ? Icon(Icons.person, size: 50, color: colorScheme.onSecondaryContainer)
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      displayName,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      email,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Section
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context,
                          'Lists',
                          totalLists.toString(),
                          Icons.list_alt_rounded,
                          colorScheme.primaryContainer,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          'Saved Places',
                          totalSavedPlaces.toString(),
                          Icons.bookmark_added_rounded,
                          colorScheme.secondaryContainer,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Settings Section
                  Text(
                    'Preferences',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildMenuTile(
                    context,
                    'Settings',
                    Icons.settings_outlined,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SettingsScreen()),
                      );
                    },
                  ),
                  _buildMenuTile(
                    context,
                    'Notifications',
                    Icons.notifications_outlined,
                    null,
                  ),
                  _buildMenuTile(
                    context,
                    'Appearance',
                    Icons.palette_outlined,
                    null,
                  ),

                  const SizedBox(height: 32),

                  // Support Section
                  Text(
                    'Support',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildMenuTile(
                    context,
                    'Help Center',
                    Icons.help_outline_rounded,
                    null,
                  ),
                  _buildMenuTile(
                    context,
                    'About Vivant',
                    Icons.info_outline_rounded,
                    () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'Vivant',
                        applicationVersion: '1.0.0',
                        applicationIcon: Icon(
                          Icons.explore_rounded,
                          color: colorScheme.primary,
                          size: 48,
                        ),
                        children: [
                          const Text('Discover and save your favorite places with ease.'),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 40),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _handleLogout(context, authProvider),
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('Sign Out'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.error,
                        side: BorderSide(color: colorScheme.errorContainer),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      'v1.0.0',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color backgroundColor,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colorScheme.onSurfaceVariant),
          const SizedBox(height: 12),
          Text(
            value,
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback? onTap,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(icon, color: colorScheme.onSurfaceVariant),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right_rounded, size: 20),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Future<void> _handleLogout(BuildContext context, AuthProvider authProvider) async {
    final colorScheme = Theme.of(context).colorScheme;
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await authProvider.signOut();
        // The main_navigation_screen or home_screen should handle the redirect 
        // because it listens to auth state changes.
      } catch (e) {
        Logger.error('Failed to logout: $e');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to sign out: $e')),
          );
        }
      }
    }
  }
}
