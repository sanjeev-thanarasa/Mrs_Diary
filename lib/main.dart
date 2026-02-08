import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passcode_screen/passcode_screen.dart';
import 'package:mrs_dth_diary_v1/scr/providers/village.dart';
import 'package:mrs_dth_diary_v1/scr/helpers/passcode_storage.dart';
import 'package:mrs_dth_diary_v1/scr/ui/homePage.dart';
import 'package:provider/provider.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/responsive.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: VillageProvider.initialize()),
      ],
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'MRS Diary ^1.0.1',
          builder: (context, child) {
            final mediaQuery = MediaQuery.of(context);
            final scale = ResponsiveScale(mediaQuery.size).textScale();
            return MediaQuery(
              data: mediaQuery.copyWith(
                textScaler: TextScaler.linear(scale),
              ),
              child: child ?? const SizedBox.shrink(),
            );
          },
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.light,
            ),
            textTheme: ThemeData.light()
                .textTheme
                .apply(
                  fontFamily: 'TamilArima',
                )
                .copyWith(
                  bodySmall: const TextStyle(fontFamily: 'TamilArima2'),
                  bodyMedium: const TextStyle(fontFamily: 'TamilArima2'),
                  bodyLarge: const TextStyle(fontFamily: 'TamilArima'),
                  labelSmall: const TextStyle(fontFamily: 'Lobster'),
                  labelMedium: const TextStyle(fontFamily: 'Lobster'),
                  labelLarge: const TextStyle(fontFamily: 'Lobster'),
                ),
            primaryTextTheme: ThemeData.light()
                .primaryTextTheme
                .apply(
                  fontFamily: 'TamilArima',
                )
                .copyWith(
                  bodySmall: const TextStyle(fontFamily: 'TamilArima2'),
                  bodyMedium: const TextStyle(fontFamily: 'TamilArima2'),
                  bodyLarge: const TextStyle(fontFamily: 'TamilArima'),
                  labelSmall: const TextStyle(fontFamily: 'Lobster'),
                  labelMedium: const TextStyle(fontFamily: 'Lobster'),
                  labelLarge: const TextStyle(fontFamily: 'Lobster'),
                ),
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: <TargetPlatform, PageTransitionsBuilder>{
                TargetPlatform.android: ZoomPageTransitionsBuilder(),
              },
            ),
            appBarTheme: const AppBarTheme(
              centerTitle: false,
              elevation: 0,
              scrolledUnderElevation: 0,
            ),
          ),
          home: const MyApp())));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness:
          Platform.isAndroid ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarDividerColor: Colors.grey,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    return const AppRoot();
  }
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> with WidgetsBindingObserver {
  final StreamController<bool> _verificationNotifier =
      StreamController<bool>.broadcast();
  bool _lockVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAndLock());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _verificationNotifier.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAndLock();
    }
  }

  Future<void> _checkAndLock() async {
    if (_lockVisible) return;
    final enabled = await PasscodeStorage.isEnabled();
    final passcode = await PasscodeStorage.getPasscode();
    if (!enabled || passcode == null || passcode.isEmpty) return;
    if (!mounted) return;

    _lockVisible = true;
    await Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          return PasscodeScreen(
            title: const Text(
              'Unlock MRS Diary',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            passwordEnteredCallback: (enteredPasscode) {
              final isValid = enteredPasscode == passcode;
              _verificationNotifier.add(isValid);
              if (isValid) {
                Navigator.maybePop(context);
              }
            },
            cancelButton: const SizedBox.shrink(),
            deleteButton: const Text(
              'Delete',
              style: TextStyle(color: Colors.white),
            ),
            shouldTriggerVerification: _verificationNotifier.stream,
            backgroundColor: Colors.black.withValues(alpha: 0.82),
            passwordDigits: 6,
          );
        },
      ),
    );
    _lockVisible = false;
  }

  @override
  Widget build(BuildContext context) {
    return HomePage();
  }
}
