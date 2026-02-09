import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mrs_dth_diary_v1/scr/helpers/app_settings.dart';
import 'package:mrs_dth_diary_v1/scr/helpers/passcode_storage.dart';
import 'package:mrs_dth_diary_v1/scr/ui/DashBoard/MyAccountsScreen.dart';
import 'package:mrs_dth_diary_v1/scr/ui/records_screen.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/customText.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/styles.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  bool _passcodeEnabled = false;
  bool _loading = true;
  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _loadSettings();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final enabled = await PasscodeStorage.isEnabled();
    if (!mounted) return;
    setState(() {
      _passcodeEnabled = enabled;
      _loading = false;
    });
  }

  Future<void> _togglePasscode(bool value) async {
    if (value) {
      final success = await _showSetPasscodeSheet();
      if (!mounted) return;
      setState(() => _passcodeEnabled = success);
    } else {
      final disabled = await _confirmDisablePasscode();
      if (!mounted) return;
      if (disabled) {
        setState(() => _passcodeEnabled = false);
      }
    }
  }

  Future<bool> _showSetPasscodeSheet() async {
    final controller = TextEditingController();
    final confirmController = TextEditingController();
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 12,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              const Text(
                'Set App Passcode',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                maxLength: 6,
                obscureText: true,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  labelText: 'New 6-digit passcode',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: Colors.black),
                  floatingLabelStyle: TextStyle(color: Colors.black),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                obscureText: true,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  labelText: 'Confirm passcode',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: Colors.black),
                  floatingLabelStyle: TextStyle(color: Colors.black),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    final passcode = controller.text.trim();
                    final confirm = confirmController.text.trim();
                    if (passcode.length != 6 || confirm.length != 6) {
                      _showMessage('Passcode must be 6 digits.');
                      return;
                    }
                    if (passcode != confirm) {
                      _showMessage('Passcodes do not match.');
                      return;
                    }
                    await PasscodeStorage.setPasscode(passcode);
                    if (!context.mounted) return;
                    Navigator.pop(context, true);
                  },
                  child: const Text('Save Passcode'),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
    return result ?? false;
  }

  Future<bool> _confirmDisablePasscode() async {
    final stored = await PasscodeStorage.getPasscode();
    final controller = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Disable Passcode'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter your current passcode to disable security.'),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                maxLength: 6,
                obscureText: true,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  labelText: 'Current passcode',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: Colors.black),
                  floatingLabelStyle: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (controller.text.trim() != stored) {
                  _showMessage('Incorrect passcode.');
                  return;
                }
                await PasscodeStorage.disablePasscode();
                if (!context.mounted) return;
                Navigator.pop(context, true);
              },
              child: const Text('Disable'),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: CText(msg: message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final appSettings = context.watch<AppSettings>();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Settings',
          style: TextStyle(
              fontSize: 26, fontWeight: FontWeight.bold, color: kIndigoDark),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text('App Passcode'),
                  subtitle: Text(
                    _passcodeEnabled
                        ? 'Passcode required on app open'
                        : 'No passcode set',
                  ),
                  trailing: Switch.adaptive(
                    value: _passcodeEnabled,
                    onChanged: _togglePasscode,
                  ),
                ),
                if (_passcodeEnabled)
                  ListTile(
                    leading: const Icon(Icons.password_outlined),
                    title: const Text('Change passcode'),
                    onTap: _showSetPasscodeSheet,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.translate_rounded),
                title: const Text('Language'),
                subtitle: Text(
                  appSettings.locale.languageCode == 'ta' ? 'Tamil' : 'English',
                ),
                onTap: () => _showComingSoonAlert(context, 'Language'),
              ),
              ListTile(
                leading: const Icon(Icons.dark_mode_outlined),
                title: const Text('Dark mode'),
                subtitle: Text(
                  appSettings.isDarkMode
                      ? 'Dark mode enabled'
                      : 'Light mode enabled',
                ),
                trailing: Switch.adaptive(
                  value: appSettings.isDarkMode,
                  onChanged: (value) =>
                      _showComingSoonAlert(context, 'Dark mode'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.account_balance_wallet_outlined),
            title: const Text('எனது கணக்கு விவரங்கள்'),
            subtitle: const Text('View topup summary and payments'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MyAccountsScreen(),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.assessment_outlined),
            title: const Text('Records & Reports'),
            subtitle:
                const Text('Monthly, daily reports and transaction history'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const RecordsScreen(),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                kPrimaryLightColor,
                kPrimaryLightColor.withValues(alpha: 0.7)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: kPrimaryColor.withValues(alpha: 0.18),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: white,
              child: const Icon(Icons.psychology_rounded, color: kPrimaryColor),
            ),
            title: const Text(
              'Developed by',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: const Text('SANJEEV THANANRASA'),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            onTap: () => _showDeveloperDialog(context),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: const Text('About App'),
            subtitle: const Text('MRS DIARY · v2.0'),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.exit_to_app_rounded),
            title: const Text('Exit'),
            subtitle: const Text('Close the app'),
            onTap: () => _confirmExit(context),
          ),
        ),
      ],
    );
  }

  Future<void> _showComingSoonAlert(
      BuildContext context, String feature) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Coming Soon'),
        content: Text(
          'The $feature feature will be available soon.',
          style: const TextStyle(color: kIndigoDark),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmExit(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit'),
        content: const Text(
          'Do you want to close the app?',
          style: TextStyle(fontFamily: 'TamilArima2', color: Colors.blueGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Exit'),
          ),
        ],
      ),
    );

    if (result == true) {
      if (Platform.isAndroid) {
        SystemNavigator.pop();
      }
    }
  }

  Future<void> _showDeveloperDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _buildShimmerImage(
                  'assets/images/sanjeev.jpg',
                  height: 120,
                  width: 120,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Sanjeev Thananrasa',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: kIndigoDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Software Engineer',
                style: TextStyle(color: kIndigoLight),
              ),
              const SizedBox(height: 14),
              _buildContactRow(Icons.phone_outlined, '+94 77 970 2687'),
              const SizedBox(height: 8),
              _buildContactRow(
                  Icons.email_outlined, 'sanjeev.thanarasa@gmail.com'),
              const SizedBox(height: 8),
              _buildContactRow(
                  Icons.location_on_outlined, 'Colombo, Sri Lanka'),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildContactRow(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: kPrimaryColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: kIndigoDark,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerImage(
    String assetPath, {
    required double height,
    required double width,
  }) {
    return SizedBox(
      height: height,
      width: width,
      child: Image.asset(
        assetPath,
        height: height,
        width: width,
        fit: BoxFit.cover,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded || frame != null) {
            return child;
          }
          return _buildShimmerBox(height: height, width: width);
        },
      ),
    );
  }

  Widget _buildShimmerBox({required double height, required double width}) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        final shimmerPosition = _shimmerController.value * 2 - 1;
        return Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: kPrimaryLightColor.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: ShaderMask(
              shaderCallback: (rect) {
                return LinearGradient(
                  colors: [
                    kPrimaryLightColor.withValues(alpha: 0.2),
                    white.withValues(alpha: 0.9),
                    kPrimaryLightColor.withValues(alpha: 0.2),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                  begin: Alignment(-1.0 + shimmerPosition, -1.0),
                  end: Alignment(1.0 + shimmerPosition, 1.0),
                ).createShader(rect);
              },
              blendMode: BlendMode.srcATop,
              child: Container(color: white.withValues(alpha: 0.6)),
            ),
          ),
        );
      },
    );
  }
}
