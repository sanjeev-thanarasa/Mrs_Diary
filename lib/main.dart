import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passcode_screen/passcode_screen.dart';
import 'package:mrs_dth_diary_v1/scr/providers/village.dart';
import 'package:mrs_dth_diary_v1/scr/helpers/passcode_storage.dart';
import 'package:mrs_dth_diary_v1/scr/helpers/app_settings.dart';
import 'package:mrs_dth_diary_v1/scr/ui/homePage.dart';
import 'package:provider/provider.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/responsive.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  await Firebase.initializeApp();
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider.value(value: VillageProvider.initialize()),
    ChangeNotifierProvider(create: (_) => AppSettings()..load()),
  ], child: const _AppShell()));
}

class _AppShell extends StatelessWidget {
  const _AppShell();

  ThemeData _buildTheme(Brightness brightness) {
    final base =
        brightness == Brightness.light ? ThemeData.light() : ThemeData.dark();
    return base.copyWith(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: brightness,
      ),
      textTheme: base.textTheme.apply(
        fontFamily: 'TamilArima2',
      ),
      primaryTextTheme: base.primaryTextTheme.apply(
        fontFamily: 'TamilArima2',
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppSettings>(
      builder: (context, settings, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'MRS Diary ^1.0.1',
          locale: settings.locale,
          builder: (context, child) {
            final mediaQuery = MediaQuery.of(context);
            final scale = ResponsiveScale(mediaQuery.size).textScale();
            final themedChild = MediaQuery(
              data: mediaQuery.copyWith(
                textScaler: TextScaler.linear(scale),
              ),
              child: child ?? const SizedBox.shrink(),
            );
            return RefreshConfiguration(
              headerBuilder: () => WaterDropHeader(
                waterDropColor: Theme.of(context).colorScheme.primary,
                idleIcon: Icon(
                  Icons.refresh_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
                complete: Icon(
                  Icons.check_circle_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              footerBuilder: () => ClassicFooter(
                loadingText: 'Loading...',
                idleText: 'Pull to load more',
                canLoadingText: 'Release to load',
                noDataText: 'No more data',
              ),
              child: ScrollConfiguration(
                behavior: const _AppScrollBehavior(),
                child: themedChild,
              ),
            );
          },
          theme: _buildTheme(Brightness.light),
          darkTheme: _buildTheme(Brightness.dark),
          themeMode: settings.themeMode,
          home: const MyApp(),
        );
      },
    );
  }
}

class _AppScrollBehavior extends MaterialScrollBehavior {
  const _AppScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    final platform = getPlatform(context);
    if (platform == TargetPlatform.iOS || platform == TargetPlatform.macOS) {
      return const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics());
    }
    return const ClampingScrollPhysics();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness:
          brightness == Brightness.dark ? Brightness.light : Brightness.dark,
      statusBarBrightness: Platform.isAndroid ? brightness : Brightness.light,
      systemNavigationBarColor:
          brightness == Brightness.dark ? Colors.black : Colors.white,
      systemNavigationBarDividerColor: Colors.grey,
      systemNavigationBarIconBrightness:
          brightness == Brightness.dark ? Brightness.light : Brightness.dark,
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
