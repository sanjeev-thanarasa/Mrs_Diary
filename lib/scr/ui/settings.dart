import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mrs_dth_diary_v1/scr/helpers/app_settings.dart';
import 'package:mrs_dth_diary_v1/scr/helpers/auth_service.dart';
import 'package:mrs_dth_diary_v1/scr/helpers/passcode_storage.dart';
import 'package:mrs_dth_diary_v1/scr/ui/DashBoard/MyAccountsScreen.dart';
import 'package:mrs_dth_diary_v1/scr/ui/notes_screen.dart';
import 'package:mrs_dth_diary_v1/scr/ui/records_screen.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/customText.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/responsive.dart';
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
        final rs = context.rs;
        return Padding(
          padding: EdgeInsets.only(
            left: rs.rw(20),
            right: rs.rw(20),
            top: rs.rh(12),
            bottom: MediaQuery.of(context).viewInsets.bottom + rs.rh(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: rs.rh(4)),
              Text(
                'Set App Passcode',
                style: TextStyle(
                  fontSize: rs.sp(18),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: rs.rh(16)),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                maxLength: 6,
                obscureText: true,
                style: TextStyle(color: Colors.black, fontSize: rs.sp(14)),
                decoration: InputDecoration(
                  labelText: 'New 6-digit passcode',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(
                    color: Colors.black,
                    fontSize: rs.sp(13.5),
                  ),
                  floatingLabelStyle: TextStyle(
                    color: Colors.black,
                    fontSize: rs.sp(13.5),
                  ),
                ),
              ),
              SizedBox(height: rs.rh(12)),
              TextField(
                controller: confirmController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                obscureText: true,
                style: TextStyle(color: Colors.black, fontSize: rs.sp(14)),
                decoration: InputDecoration(
                  labelText: 'Confirm passcode',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(
                    color: Colors.black,
                    fontSize: rs.sp(13.5),
                  ),
                  floatingLabelStyle: TextStyle(
                    color: Colors.black,
                    fontSize: rs.sp(13.5),
                  ),
                ),
              ),
              SizedBox(height: rs.rh(16)),
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
                  child: Text(
                    'Save Passcode',
                    style: TextStyle(fontSize: rs.sp(14.5)),
                  ),
                ),
              ),
              SizedBox(height: rs.rh(12)),
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
        final rs = context.rs;
        return AlertDialog(
          title: Text(
            'Disable Passcode',
            style: TextStyle(fontSize: rs.sp(17.5)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter your current passcode to disable security.',
                style: TextStyle(fontSize: rs.sp(13.5)),
              ),
              SizedBox(height: rs.rh(12)),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                maxLength: 6,
                obscureText: true,
                style: TextStyle(color: Colors.black, fontSize: rs.sp(14)),
                decoration: InputDecoration(
                  labelText: 'Current passcode',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(
                    color: Colors.black,
                    fontSize: rs.sp(13.5),
                  ),
                  floatingLabelStyle: TextStyle(
                    color: Colors.black,
                    fontSize: rs.sp(13.5),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel', style: TextStyle(fontSize: rs.sp(13.5))),
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
              child: Text('Disable', style: TextStyle(fontSize: rs.sp(13.5))),
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
    final user = FirebaseAuth.instance.currentUser;
    final rs = context.rs;
    final switchScale = rs.textScale(min: 0.85, max: 1.0);

    return ListView(
      padding: EdgeInsets.all(rs.r(16)),
      children: [
        Text(
          'Profile settings',
          style: TextStyle(
            fontSize: rs.sp(20),
            fontWeight: FontWeight.bold,
            color: kIndigoDark,
          ),
        ),
        SizedBox(height: rs.rh(12)),
        Card(
          child: Padding(
            padding: EdgeInsets.all(rs.r(14)),
            child: Row(
              children: [
                CircleAvatar(
                  radius: rs.r(24),
                  backgroundColor: kPrimaryLightColor,
                  backgroundImage: user?.photoURL != null
                      ? NetworkImage(user!.photoURL!)
                      : null,
                  child: user?.photoURL == null
                      ? Icon(
                          Icons.person,
                          color: kPrimaryColor,
                          size: rs.r(24),
                        )
                      : null,
                ),
                SizedBox(width: rs.rw(12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.displayName ?? 'Guest user',
                        style: TextStyle(
                          fontSize: rs.sp(15.5),
                          fontWeight: FontWeight.w700,
                          color: kIndigoDark,
                        ),
                      ),
                      SizedBox(height: rs.rh(4)),
                      Text(
                        user?.email ?? 'No email',
                        style: TextStyle(
                          fontSize: rs.sp(12),
                          fontWeight: FontWeight.w600,
                          color: kIndigoLight,
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton.tonal(
                  onPressed: () async {
                    await AuthService().signOut();
                  },
                  child: Text('Logout', style: TextStyle(fontSize: rs.sp(13))),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: rs.rh(16)),
        Text(
          'Settings',
          style: TextStyle(
            fontSize: rs.sp(22.5),
            fontWeight: FontWeight.bold,
            color: kIndigoDark,
          ),
        ),
        SizedBox(height: rs.rh(10)),
        Card(
          child: Padding(
            padding: EdgeInsets.all(rs.r(12)),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.lock_outline, size: rs.r(20)),
                  title: Text(
                    'App Passcode',
                    style: TextStyle(fontSize: rs.sp(15.5)),
                  ),
                  subtitle: Text(
                    _passcodeEnabled
                        ? 'Passcode required on app open'
                        : 'No passcode set',
                    style: TextStyle(fontSize: rs.sp(13)),
                  ),
                  trailing: Transform.scale(
                    scale: switchScale,
                    alignment: Alignment.centerRight,
                    child: Switch.adaptive(
                      value: _passcodeEnabled,
                      onChanged: _togglePasscode,
                    ),
                  ),
                ),
                if (_passcodeEnabled)
                  ListTile(
                    leading: Icon(Icons.password_outlined, size: rs.r(20)),
                    title: Text(
                      'Change passcode',
                      style: TextStyle(fontSize: rs.sp(15.5)),
                    ),
                    onTap: _showSetPasscodeSheet,
                  ),
              ],
            ),
          ),
        ),
        SizedBox(height: rs.rh(1)),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.translate_rounded, size: rs.r(20)),
                title:
                    Text('Language', style: TextStyle(fontSize: rs.sp(15.5))),
                subtitle: Text(
                  appSettings.locale.languageCode == 'ta'
                      ? 'Tamil & English'
                      : 'English',
                  style: TextStyle(fontSize: rs.sp(13)),
                ),
                onTap: () => _showComingSoonAlert(context, 'Language'),
              ),
              ListTile(
                leading: Icon(Icons.dark_mode_outlined, size: rs.r(20)),
                title:
                    Text('Dark mode', style: TextStyle(fontSize: rs.sp(15.5))),
                subtitle: Text(
                  appSettings.isDarkMode
                      ? 'Dark mode enabled'
                      : 'Light mode enabled',
                  style: TextStyle(fontSize: rs.sp(13)),
                ),
                trailing: Transform.scale(
                  scale: switchScale,
                  alignment: Alignment.centerRight,
                  child: Switch.adaptive(
                    value: appSettings.isDarkMode,
                    onChanged: (value) =>
                        _showComingSoonAlert(context, 'Dark mode'),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: rs.rh(1)),
        Card(
          child: ListTile(
            leading: Icon(Icons.note_alt_outlined, size: rs.r(20)),
            title: Text('Note App', style: TextStyle(fontSize: rs.sp(15.5))),
            subtitle: Text(
              'Open your notes',
              style: TextStyle(fontSize: rs.sp(13)),
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const NotesScreen(),
                ),
              );
            },
          ),
        ),
        SizedBox(height: rs.rh(1)),
        Card(
          child: ListTile(
            leading:
                Icon(Icons.account_balance_wallet_outlined, size: rs.r(20)),
            title: Text(
              'எனது கணக்கு விவரங்கள்',
              style: TextStyle(fontSize: rs.sp(15.5)),
            ),
            subtitle: Text(
              'View topup summary and payments',
              style: TextStyle(fontSize: rs.sp(13)),
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MyAccountsScreen(),
                ),
              );
            },
          ),
        ),
        SizedBox(height: rs.rh(1)),
        Card(
          child: ListTile(
            leading: Icon(Icons.assessment_outlined, size: rs.r(20)),
            title: Text(
              'Records & Reports',
              style: TextStyle(fontSize: rs.sp(15.5)),
            ),
            subtitle: Text(
              'Monthly, daily reports and transaction history',
              style: TextStyle(fontSize: rs.sp(13)),
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const RecordsScreen(),
                ),
              );
            },
          ),
        ),
        SizedBox(height: rs.rh(3)),
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
            borderRadius: BorderRadius.circular(rs.r(16)),
            // boxShadow: [
            //   BoxShadow(
            //     color: kPrimaryColor.withValues(alpha: 0.18),
            //     blurRadius: rs.r(12),
            //     offset: Offset(0, rs.rh(6)),
            //   ),
            // ],
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: white,
              child: Icon(
                Icons.psychology_rounded,
                color: kPrimaryColor,
                size: rs.r(20),
              ),
            ),
            title: Text(
              'Developed by',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: rs.sp(15.5),
              ),
            ),
            subtitle: Text(
              'SANJEEV THANANRASA',
              style: TextStyle(fontSize: rs.sp(13)),
            ),
            trailing: Icon(Icons.arrow_forward_ios_rounded, size: rs.r(14)),
            onTap: () => _showDeveloperDialog(context),
          ),
        ),
        SizedBox(height: rs.rh(3)),
        Card(
          child: ListTile(
            leading: Icon(Icons.info_outline_rounded, size: rs.r(20)),
            title: Text('About App', style: TextStyle(fontSize: rs.sp(15.5))),
            subtitle: Text(
              'MRS DIARY · v2.1.0',
              style: TextStyle(fontSize: rs.sp(13)),
            ),
          ),
        ),
        SizedBox(height: rs.rh(1)),
        Card(
          child: ListTile(
            leading: Icon(Icons.exit_to_app_rounded, size: rs.r(20)),
            title: Text('Exit', style: TextStyle(fontSize: rs.sp(15.5))),
            subtitle: Text(
              'Close the app',
              style: TextStyle(fontSize: rs.sp(13)),
            ),
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
        title: Text(
          'Coming Soon',
          style: TextStyle(fontSize: context.rs.sp(17.5)),
        ),
        content: Text(
          'The $feature feature will be available soon.',
          style: TextStyle(
            color: kIndigoDark,
            fontSize: context.rs.sp(13.5),
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(fontSize: context.rs.sp(13.5))),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmExit(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Exit', style: TextStyle(fontSize: context.rs.sp(17.5))),
        content: Text(
          'Do you want to close the app?',
          style: TextStyle(
            fontFamily: 'TamilArima2',
            color: Colors.blueGrey,
            fontSize: context.rs.sp(13.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(fontSize: context.rs.sp(13.5)),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child:
                Text('Exit', style: TextStyle(fontSize: context.rs.sp(13.5))),
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
        final rs = context.rs;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(rs.r(20)),
          ),
          contentPadding:
              EdgeInsets.fromLTRB(rs.rw(20), rs.rh(20), rs.rw(20), rs.rh(12)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(rs.r(16)),
                child: _buildShimmerImage(
                  'assets/images/sanjeev.jpg',
                  height: rs.r(110),
                  width: rs.r(110),
                ),
              ),
              SizedBox(height: rs.rh(16)),
              Text(
                'Sanjeev Thananrasa',
                style: TextStyle(
                  fontSize: rs.sp(16.5),
                  fontWeight: FontWeight.w700,
                  color: kIndigoDark,
                ),
              ),
              SizedBox(height: rs.rh(6)),
              Text(
                'Software Engineer',
                style: TextStyle(color: kIndigoLight, fontSize: rs.sp(13.5)),
              ),
              SizedBox(height: rs.rh(14)),
              _buildContactRow(Icons.phone_outlined, '+94 77 970 2687'),
              SizedBox(height: rs.rh(8)),
              _buildContactRow(
                  Icons.email_outlined, 'sanjeev.thanarasa@gmail.com'),
              SizedBox(height: rs.rh(8)),
              _buildContactRow(
                  Icons.location_on_outlined, 'Colombo, Sri Lanka'),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close', style: TextStyle(fontSize: rs.sp(13.5))),
            ),
          ],
        );
      },
    );
  }

  Widget _buildContactRow(IconData icon, String value) {
    final rs = context.rs;
    return Row(
      children: [
        Icon(icon, size: rs.r(18), color: kPrimaryColor),
        SizedBox(width: rs.rw(8)),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: kIndigoDark,
              fontSize: rs.sp(12.5),
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
