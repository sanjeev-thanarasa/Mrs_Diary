import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mrs_dth_diary_v1/scr/helpers/auth_service.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/responsive.dart';

class GoogleLoginScreen extends StatefulWidget {
  const GoogleLoginScreen({super.key});

  @override
  State<GoogleLoginScreen> createState() => _GoogleLoginScreenState();
}

class _GoogleLoginScreenState extends State<GoogleLoginScreen> {
  bool _loading = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() => _loading = true);
    try {
      await AuthService().signInWithGoogle();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Google sign-in failed. Try again.')),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primary.withValues(alpha: 0.92),
              colorScheme.primaryContainer.withValues(alpha: 0.95),
              colorScheme.surface,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: -rs.rh(40),
                right: -rs.rw(40),
                child: _GlowOrb(size: rs.r(140)),
              ),
              Positioned(
                bottom: -rs.rh(60),
                left: -rs.rw(30),
                child: _GlowOrb(size: rs.r(180)),
              ),
              Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: rs.rw(24),
                    vertical: rs.rh(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(rs.r(14)),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(rs.r(20)),
                          // boxShadow: [
                          //   BoxShadow(
                          //     color: Colors.black.withValues(alpha: 0.2),
                          //     blurRadius: rs.r(30),
                          //     offset: Offset(0, rs.rh(8)),
                          //   ),
                          // ],
                        ),
                        child: Image.asset(
                          'assets/images/mrslogo.png',
                          height: rs.r(120),
                          width: rs.r(120),
                        ),
                      ),
                      SizedBox(height: rs.rh(18)),
                      Text(
                        'MRS Diary',
                        style: TextStyle(
                          fontSize: rs.sp(28),
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onPrimary,
                          letterSpacing: 0.4,
                          fontFamily: 'TamilArima',
                        ),
                      ),
                      // SizedBox(height: rs.rh(2)),
                      Text(
                        'Your smart payment diary',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: rs.sp(16),
                          color: colorScheme.onPrimary,
                          fontFamily: 'TamilArima2',
                        ),
                      ),
                      SizedBox(height: rs.rh(28)),
                      Container(
                        padding: EdgeInsets.all(rs.r(18)),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(rs.r(22)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: rs.r(18),
                              offset: Offset(0, rs.rh(10)),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            SvgPicture.asset(
                              'assets/icons/personal-finance.svg',
                              height: rs.r(120),
                            ),
                            SizedBox(height: rs.rh(18)),
                            Text(
                              'Welcome back',
                              style: TextStyle(
                                fontSize: rs.sp(18),
                                fontWeight: FontWeight.w700,
                                color: colorScheme.primary,
                              ),
                            ),
                            SizedBox(height: rs.rh(6)),
                            Text(
                              'Login or register with Google',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: rs.sp(12.5),
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            SizedBox(height: rs.rh(16)),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorScheme.primary,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    vertical: rs.rh(12),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      rs.r(14),
                                    ),
                                  ),
                                ),
                                onPressed:
                                    _loading ? null : _handleGoogleSignIn,
                                icon: _loading
                                    ? SizedBox(
                                        height: rs.r(18),
                                        width: rs.r(18),
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.g_mobiledata_rounded),
                                label: Text(
                                  _loading
                                      ? 'Signing in...'
                                      : 'Continue with Google',
                                  style: TextStyle(
                                    fontSize: rs.sp(14.5),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final double size;

  const _GlowOrb({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.4),
            Colors.white.withValues(alpha: 0.05),
          ],
        ),
      ),
    );
  }
}
