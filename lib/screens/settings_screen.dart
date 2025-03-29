import 'package:flutter/material.dart';
import 'package:lingowise/services/settings_service.dart';
import 'package:lingowise/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:lingowise/theme/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _settingsService = SettingsService();
  final _authService = AuthService();
  bool _notificationsEnabled = true;
  bool _messageSoundEnabled = true;
  bool _messageVibrationEnabled = true;
  bool _onlineStatusVisible = true;
  bool _typingIndicatorEnabled = true;
  bool _readReceiptsEnabled = true;
  String _selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _notificationsEnabled = _settingsService.getNotificationsEnabled();
      _messageSoundEnabled = _settingsService.getMessageSoundEnabled();
      _messageVibrationEnabled = _settingsService.getMessageVibrationEnabled();
      _onlineStatusVisible = _settingsService.getOnlineStatusVisible();
      _typingIndicatorEnabled = _settingsService.getTypingIndicatorEnabled();
      _readReceiptsEnabled = _settingsService.getReadReceiptsEnabled();
      _selectedLanguage = _settingsService.getLanguage();
    });
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildLanguageSelector() {
    return ListTile(
      title: const Text('Language'),
      subtitle: Text(_selectedLanguage.toUpperCase()),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Select Language'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('English'),
                  onTap: () {
                    setState(() => _selectedLanguage = 'en');
                    _settingsService.setLanguage('en');
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('Spanish'),
                  onTap: () {
                    setState(() => _selectedLanguage = 'es');
                    _settingsService.setLanguage('es');
                    Navigator.pop(context);
                  },
                ),
                // Add more languages as needed
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemeSelector() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return ListTile(
          title: const Text('Theme'),
          subtitle: Text(themeProvider.themeMode.toString().split('.').last),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Select Theme'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: const Text('System'),
                      onTap: () {
                        themeProvider.setThemeMode(ThemeMode.system);
                        _settingsService.setThemeMode(ThemeMode.system);
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      title: const Text('Light'),
                      onTap: () {
                        themeProvider.setThemeMode(ThemeMode.light);
                        _settingsService.setThemeMode(ThemeMode.light);
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      title: const Text('Dark'),
                      onTap: () {
                        themeProvider.setThemeMode(ThemeMode.dark);
                        _settingsService.setThemeMode(ThemeMode.dark);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _buildSection(
            'Appearance',
            [
              _buildThemeSelector(),
              _buildLanguageSelector(),
            ],
          ),
          _buildSection(
            'Notifications',
            [
              _buildSwitchTile(
                title: 'Push Notifications',
                subtitle: 'Receive notifications for new messages',
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() => _notificationsEnabled = value);
                  _settingsService.setNotificationsEnabled(value);
                },
              ),
              _buildSwitchTile(
                title: 'Message Sound',
                subtitle: 'Play sound for new messages',
                value: _messageSoundEnabled,
                onChanged: (value) {
                  setState(() => _messageSoundEnabled = value);
                  _settingsService.setMessageSoundEnabled(value);
                },
              ),
              _buildSwitchTile(
                title: 'Message Vibration',
                subtitle: 'Vibrate for new messages',
                value: _messageVibrationEnabled,
                onChanged: (value) {
                  setState(() => _messageVibrationEnabled = value);
                  _settingsService.setMessageVibrationEnabled(value);
                },
              ),
            ],
          ),
          _buildSection(
            'Chat Settings',
            [
              _buildSwitchTile(
                title: 'Online Status',
                subtitle: 'Show when you are online',
                value: _onlineStatusVisible,
                onChanged: (value) {
                  setState(() => _onlineStatusVisible = value);
                  _settingsService.setOnlineStatusVisible(value);
                },
              ),
              _buildSwitchTile(
                title: 'Typing Indicator',
                subtitle: 'Show when others are typing',
                value: _typingIndicatorEnabled,
                onChanged: (value) {
                  setState(() => _typingIndicatorEnabled = value);
                  _settingsService.setTypingIndicatorEnabled(value);
                },
              ),
              _buildSwitchTile(
                title: 'Read Receipts',
                subtitle: 'Show when messages are read',
                value: _readReceiptsEnabled,
                onChanged: (value) {
                  setState(() => _readReceiptsEnabled = value);
                  _settingsService.setReadReceiptsEnabled(value);
                },
              ),
            ],
          ),
          _buildSection(
            'Account',
            [
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Sign Out'),
                onTap: () => _authService.signOut(),
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Clear All Settings'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Clear Settings'),
                      content: const Text(
                        'Are you sure you want to clear all settings? This action cannot be undone.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _settingsService.clearAllSettings();
                            _loadSettings();
                            Navigator.pop(context);
                          },
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
} 