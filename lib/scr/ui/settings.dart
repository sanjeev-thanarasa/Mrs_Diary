import 'package:flutter/material.dart';
import 'package:mrs_dth_diary_v1/scr/helpers/passcode_storage.dart';
import 'package:mrs_dth_diary_v1/scr/ui/DashBoard/DashBoard.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/customText.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _passcodeEnabled = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
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
                decoration: const InputDecoration(
                  labelText: 'New 6-digit passcode',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm passcode',
                  border: OutlineInputBorder(),
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
                decoration: const InputDecoration(
                  labelText: 'Current passcode',
                  border: OutlineInputBorder(),
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

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Settings',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
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
          child: ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('Theme'),
            subtitle: const Text('Modern blue iOS-inspired style'),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.account_balance_wallet_outlined),
            title: const Text('எனது கணக்கு விபரங்கள்'),
            subtitle: const Text('My accounts'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => DashBoard(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
