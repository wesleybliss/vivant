import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vivant/providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          _buildSectionHeader(context, 'Appearance'),
          _buildSettingTile(
            context,
            title: 'Theme Mode',
            subtitle: _getThemeModeLabel(settings.themeMode),
            icon: Icons.brightness_6_outlined,
            onTap: () => _showThemeDialog(context, settings),
          ),
          
          _buildSectionHeader(context, 'Regional'),
          _buildSettingTile(
            context,
            title: 'Language',
            subtitle: 'English',
            icon: Icons.language_rounded,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Currently only English is supported.')),
              );
            },
          ),
          _buildSettingTile(
            context,
            title: 'Distance Units',
            subtitle: settings.distanceUnit.label,
            icon: Icons.straighten_rounded,
            onTap: () => _showDistanceUnitDialog(context, settings),
          ),

          _buildSectionHeader(context, 'Search Defaults'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Minimum Rating',
                      style: textTheme.bodyLarge,
                    ),
                    Text(
                      settings.minRating == 0 ? 'Any' : '${settings.minRating.toStringAsFixed(1)}+',
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: settings.minRating,
                  min: 0,
                  max: 5.0,
                  divisions: 50,
                  label: settings.minRating.toStringAsFixed(1),
                  onChanged: (value) => settings.setMinRating(value),
                ),
                Text(
                  'Default minimum rating for new searches.',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          _buildSectionHeader(context, 'Account & Privacy'),
          _buildSettingTile(
            context,
            title: 'Clear Search History',
            subtitle: 'Remove all past search entries',
            icon: Icons.history_rounded,
            onTap: () {
              // Future implementation
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Search history cleared.')),
              );
            },
          ),
          _buildSettingTile(
            context,
            title: 'Privacy Policy',
            icon: Icons.privacy_tip_outlined,
            onTap: () {},
          ),

          const SizedBox(height: 40),
          Center(
            child: Text(
              'Vivant v1.0.0',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required String title,
    String? subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }

  String _getThemeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System (Auto)';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  void _showThemeDialog(BuildContext context, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Theme'),
        content: RadioGroup<ThemeMode>(
          groupValue: settings.themeMode,
          onChanged: (value) {
            if (value != null) {
              settings.setThemeMode(value);
              Navigator.pop(context);
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: ThemeMode.values.map((mode) {
              return RadioListTile<ThemeMode>(
                title: Text(_getThemeModeLabel(mode)),
                value: mode,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showDistanceUnitDialog(BuildContext context, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Distance Units'),
        content: RadioGroup<DistanceUnit>(
          groupValue: settings.distanceUnit,
          onChanged: (value) {
            if (value != null) {
              settings.setDistanceUnit(value);
              Navigator.pop(context);
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: DistanceUnit.values.map((unit) {
              return RadioListTile<DistanceUnit>(
                title: Text(unit.label),
                value: unit,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
