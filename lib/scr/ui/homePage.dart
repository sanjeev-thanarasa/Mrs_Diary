import 'package:flutter/material.dart';
import 'package:mrs_dth_diary_v1/scr/providers/village.dart';
import 'package:mrs_dth_diary_v1/scr/helpers/fcm_service.dart';
import 'package:mrs_dth_diary_v1/scr/ui/astrology_screen.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/homeCard.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/showRaviInfoDialog.dart'
    show showRaviInfoDialog;
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/responsive.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:uuid/uuid.dart';

import '../widgets/ShowPopUpAlertBox.dart';
import 'CreateNewUserPage.dart';
import 'DishTypesPage.dart';
import 'searchUsers.dart';
import 'todayPaymentNotifications.dart';
import 'settings.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static int _lastSelectedIndex = 0;
  int _selectedIndex = _lastSelectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = _lastSelectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final rs = context.rs;
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            Home(),
            const SearchUsersScreen(),
            const AstrologyScreen(),
            const SettingsScreen(),
          ],
        ),
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              backgroundColor: colorScheme.primary,
              onPressed: () => _showCreateMenu(context),
              child: Icon(Icons.add, color: Colors.white, size: rs.r(22)),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            rs.rw(16),
            0,
            rs.rw(16),
            rs.rh(12),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(rs.r(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: rs.r(20),
                  offset: Offset(0, rs.rh(8)),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(rs.r(24)),
              child: NavigationBarTheme(
                data: NavigationBarThemeData(
                  height: rs.rh(64),
                  backgroundColor: colorScheme.surface,
                  indicatorColor: colorScheme.primary.withValues(alpha: 0.14),
                  indicatorShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(rs.r(16)),
                  ),
                  labelTextStyle: WidgetStateProperty.resolveWith(
                    (states) => TextStyle(
                      fontSize: rs.sp(12),
                      fontWeight: states.contains(WidgetState.selected)
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: states.contains(WidgetState.selected)
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                  iconTheme: WidgetStateProperty.resolveWith(
                    (states) => IconThemeData(
                      size: rs.r(24),
                      color: states.contains(WidgetState.selected)
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                child: NavigationBar(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (index) => setState(() {
                    _selectedIndex = index;
                    _lastSelectedIndex = index;
                  }),
                  labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home_rounded),
                      label: 'Home',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.search_outlined),
                      selectedIcon: Icon(Icons.search_rounded),
                      label: 'Search',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.auto_awesome_outlined),
                      selectedIcon: Icon(Icons.auto_awesome_rounded),
                      label: 'Astrology',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.settings_outlined),
                      selectedIcon: Icon(Icons.settings_rounded),
                      label: 'Settings',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showCreateVillageDialog(VillageProvider villageProvider) {
    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            children: <Widget>[
              PopUpBox(
                hintText: "Enter Village Name",
                labelText: "Create New Village",
                btnText: "CREATE",
                bthFunction: (text) async {
                  final name = text.trim();
                  if (name.isEmpty) {
                    return;
                  }
                  villageProvider.editControllerName.text = name;
                  final id = Uuid().v1();
                  final success = await villageProvider.uploadVillage(id: id);
                  if (!mounted) return;
                  final messenger = ScaffoldMessenger.of(context);
                  messenger.hideCurrentSnackBar();
                  if (success) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text('$name village created'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    villageProvider.clear();
                  } else {
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Failed to create village'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                context: context,
              )
            ],
          );
        });
  }

  void _showCreateMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.rs.r(20)),
        ),
      ),
      builder: (context) {
        final rs = context.rs;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: rs.rh(8)),
              Container(
                width: rs.r(42),
                height: rs.r(4),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(rs.r(10)),
                ),
              ),
              SizedBox(height: rs.rh(6)),
              Text(
                'Create',
                style: TextStyle(
                  fontSize: rs.sp(13.5),
                  fontWeight: FontWeight.w700,
                  fontFamily: 'TamilArima',
                  color: Colors.black87,
                ),
              ),
              ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: rs.rw(16), vertical: 2),
                leading: Icon(Icons.location_city_rounded, size: rs.r(18)),
                title: Text(
                  'Create village',
                  style: TextStyle(
                    fontSize: rs.sp(13.5),
                    fontFamily: 'TamilArima',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showCreateVillageDialog(context.read<VillageProvider>());
                },
              ),
              ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: rs.rw(16), vertical: 2),
                leading: Icon(Icons.tv_rounded, size: rs.r(18)),
                title: Text(
                  'Create dish types',
                  style: TextStyle(
                    fontSize: rs.sp(13.5),
                    fontFamily: 'TamilArima',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DishTypesPage()),
                  );
                },
              ),
              ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: rs.rw(16), vertical: 2),
                leading: Icon(Icons.person_add_alt_1_rounded, size: rs.r(18)),
                title: Text(
                  'Create user',
                  style: TextStyle(
                    fontSize: rs.sp(13.5),
                    fontFamily: 'TamilArima',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => CreateNewUser()),
                  );
                },
              ),
              SizedBox(height: rs.rh(8)),
            ],
          ),
        );
      },
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<VillageProvider>().refreshCounts();
      }
    });
  }

  void _onRefresh() async {
    await context.read<VillageProvider>().refreshCounts();
    await Future.delayed(Duration(milliseconds: 1000));
    _refreshController.refreshCompleted(resetFooterState: true);
  }

  void _onLoading() async {
    setState(() {});
    await Future.delayed(Duration(milliseconds: 1000));
    _refreshController.loadComplete();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;
    return SmartRefresher(
      controller: _refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      enablePullDown: true,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: rs.rw(16),
                vertical: rs.rh(20),
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primaryContainer,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(rs.r(28.0)),
                  bottomLeft: Radius.circular(rs.r(28.0)),
                ),
              ),
              child: Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(rs.r(16)),
                    onTap: () => showRaviInfoDialog(context),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(rs.r(16)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 4.0,
                          left: 3.0,
                          right: 3.0,
                        ),
                        child: Image.asset(
                          'assets/images/ravi-diary.png',
                          height: rs.r(80),
                          width: rs.r(80),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: rs.rw(16)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MRS Diary',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: rs.sp(28),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Track customers and payments',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: rs.sp(15),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: rs.rw(8)),
                  ValueListenableBuilder<int>(
                    valueListenable: FcmService.badgeCount,
                    builder: (context, badgeCount, _) {
                      return _NotificationButton(
                        count: badgeCount,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TodayPaymentNotifications(),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.only(top: rs.rh(12)),
            sliver: SliverToBoxAdapter(
              child: HomeCard(context: context),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({
    required this.count,
    required this.onTap,
  });

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(rs.r(14)),
          onTap: onTap,
          child: Container(
            height: rs.r(44),
            width: rs.r(44),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(rs.r(14)),
              border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.2),
              ),
            ),
            child: Icon(
              Icons.notifications_active_rounded,
              color: Colors.white,
              size: rs.r(24),
            ),
          ),
        ),
        if (count > 0)
          Positioned(
            top: rs.rh(-4),
            right: rs.rw(-4),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: rs.rw(6),
                vertical: rs.rh(2),
              ),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(rs.r(12)),
                border: Border.all(color: Colors.white, width: rs.r(1.5)),
              ),
              constraints: BoxConstraints(
                minWidth: rs.r(18),
                minHeight: rs.r(18),
              ),
              child: Text(
                count > 99 ? '99+' : '$count',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: rs.sp(10),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
