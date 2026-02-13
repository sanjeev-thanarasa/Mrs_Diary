import 'package:flutter/material.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/responsive.dart';

Future<void> showRaviInfoDialog(BuildContext context) {
  final rs = context.rs;
  final theme = Theme.of(context);
  final cs = theme.colorScheme;
  final tt = theme.textTheme;

  TextStyle baseText() => tt.bodyMedium!.copyWith(
        fontSize: rs.sp(12.8),
        height: 1.5,
        color: cs.onSurface.withOpacity(0.88),
      );

  TextStyle boldText() => baseText().copyWith(
        fontWeight: FontWeight.w800,
        color: cs.onSurface,
      );

  Widget chip(String text, {IconData? icon}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: rs.r(10), vertical: rs.r(7)),
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(0.10),
        borderRadius: BorderRadius.circular(rs.r(999)),
        border: Border.all(color: cs.primary.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: rs.r(16), color: cs.primary),
            SizedBox(width: rs.r(6)),
          ],
          Text(
            text,
            style: tt.labelLarge?.copyWith(
              fontSize: rs.sp(12),
              fontWeight: FontWeight.w700,
              color: cs.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget bullet({
    required String title,
    required String desc,
    required IconData icon,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: rs.rh(10)),
      padding: EdgeInsets.all(rs.r(12)),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.55),
        borderRadius: BorderRadius.circular(rs.r(14)),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: rs.r(34),
            height: rs.r(34),
            decoration: BoxDecoration(
              color: cs.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(rs.r(12)),
              border: Border.all(color: cs.primary.withOpacity(0.25)),
            ),
            child: Icon(icon, size: rs.r(18), color: cs.primary),
          ),
          SizedBox(width: rs.r(10)),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: baseText(),
                children: [
                  TextSpan(
                      text: "$title\n",
                      style: boldText().copyWith(fontSize: rs.sp(13.2))),
                  TextSpan(text: desc),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget card({required String title, required Widget child, IconData? icon}) {
    return Container(
      padding: EdgeInsets.all(rs.r(14)),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.55),
        borderRadius: BorderRadius.circular(rs.r(16)),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: rs.r(18), color: cs.primary),
                SizedBox(width: rs.r(8)),
              ],
              Text(
                title,
                style: tt.titleMedium?.copyWith(
                  fontSize: rs.sp(13.8),
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: rs.rh(10)),
          child,
        ],
      ),
    );
  }

  return showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        insetPadding:
            EdgeInsets.symmetric(horizontal: rs.rw(16), vertical: rs.rh(20)),
        contentPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(rs.r(20))),
        content: ConstrainedBox(
          constraints:
              BoxConstraints(maxWidth: rs.rw(520), maxHeight: rs.rh(600)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(rs.r(20)),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Gradient Header
                  Container(
                    padding: EdgeInsets.fromLTRB(
                        rs.r(16), rs.r(20), rs.r(16), rs.r(18)),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          cs.primary.withOpacity(0.22),
                          cs.secondary.withOpacity(0.18),
                          cs.tertiary.withOpacity(0.12),
                        ],
                      ),
                      border: Border(
                        bottom: BorderSide(
                            color: cs.outlineVariant.withOpacity(0.35)),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(rs.r(14)),
                          child: Image.asset(
                            'assets/images/ravi-diary.png',
                            width: rs.rw(150),
                            height: rs.rh(150),
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(height: rs.rh(12)),
                        Text(
                          'Ravi\'s Personal Diary',
                          textAlign: TextAlign.center,
                          style: tt.titleLarge?.copyWith(
                            fontSize: rs.sp(22),
                            fontWeight: FontWeight.w900,
                            color: cs.onSurface,
                          ),
                        ),
                        SizedBox(height: rs.rh(6)),
                        Text(
                          'தனிப்பட்ட டையரி & கணக்கு மேலாண்மை',
                          textAlign: TextAlign.center,
                          style: tt.bodyMedium?.copyWith(
                            fontSize: rs.sp(13),
                            color: cs.onSurface.withOpacity(0.75),
                            height: 1.35,
                          ),
                        ),
                        SizedBox(height: rs.rh(12)),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: rs.r(6),
                          runSpacing: rs.r(6),
                          children: [
                            chip('Fully Personalized',
                                icon: Icons.tune_rounded),
                            chip('Secure Storage', icon: Icons.lock_rounded),
                            chip('Quick Search', icon: Icons.search_rounded),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.all(rs.r(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // About Card (Rich Text with highlights)
                        card(
                          title: 'செயலி பற்றி',
                          icon: Icons.info_outline_rounded,
                          child: RichText(
                            text: TextSpan(
                              style: baseText(),
                              children: [
                                const TextSpan(text: 'இந்த செயலி '),
                                TextSpan(
                                    text: 'திரு. ரவிச்சந்திரன்',
                                    style: boldText()),
                                const TextSpan(
                                    text:
                                        ' அவர்களின் தனிப்பட்ட பயன்பாட்டிற்காக, '),
                                TextSpan(
                                    text: 'அவருடைய மச்சான்',
                                    style:
                                        boldText().copyWith(color: cs.primary)),
                                const TextSpan(text: ' '),
                                TextSpan(
                                    text: 'திரு. சஞ்சீவ் தனராசா',
                                    style: boldText()
                                        .copyWith(color: cs.primary)
                                        .copyWith(
                                          fontSize: rs.sp(13.2),
                                        )),
                                const TextSpan(
                                    text: ' அவர்களால் உருவாக்கப்பட்டது.\n\n'),
                                TextSpan(
                                  text: 'இது முழுமையாக ',
                                ),
                                TextSpan(
                                  text:
                                      'தனிப்பயனாக்கப்பட்ட (Fully Personalized)',
                                  style:
                                      boldText().copyWith(color: cs.secondary),
                                ),
                                const TextSpan(
                                    text:
                                        ' தனிநபர் டையரி மற்றும் கணக்கு மேலாண்மை செயலியாகும்.'),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: rs.rh(14)),

                        // Features
                        Text(
                          'இந்த செயலியில் என்ன செய்யலாம்?',
                          style: tt.titleMedium?.copyWith(
                            fontSize: rs.sp(13.8),
                            fontWeight: FontWeight.w800,
                            color: cs.onSurface,
                          ),
                        ),
                        SizedBox(height: rs.rh(10)),

                        bullet(
                          title: 'Dish TV ரீசார்ஜ் கட்டண பதிவுகள்',
                          desc:
                              'வாடிக்கையாளர்களின் ரீசார்ஜ் கட்டணங்களை தேதி/தொகையுடன் பதிவு செய்து வைத்துக்கொள்ளலாம்.',
                          icon: Icons.tv_rounded,
                        ),
                        bullet(
                          title: 'பரிவர்த்தனை & ரீசார்ஜ் விவரங்கள்',
                          desc:
                              'ரீசார்ஜ் விபரம், நிலுவை, பெற்ற தொகை போன்ற தகவல்களை ஒழுங்காக பராமரிக்கலாம்.',
                          icon: Icons.receipt_long_rounded,
                        ),
                        bullet(
                          title: 'ஜோதிட வாடிக்கையாளர் விவரங்கள்',
                          desc:
                              'ஜாதகம்/கேஸ் விவரங்கள், குறிப்புகள், தொடர்பு தகவல்கள் போன்றவற்றை சேமிக்கலாம்.',
                          icon: Icons.auto_awesome_rounded,
                        ),
                        bullet(
                          title: 'தினசரி கணக்கு குறிப்புகள்',
                          desc:
                              'வரவு-செலவு மற்றும் தினசரி குறிப்புகளை எளிதாக பதிவு செய்யலாம்.',
                          icon: Icons.event_note_rounded,
                        ),

                        SizedBox(height: rs.rh(14)),

                        // Closing Card
                        card(
                          title: 'சிறப்பு அம்சங்கள்',
                          icon: Icons.star_outline_rounded,
                          child: RichText(
                            text: TextSpan(
                              style: baseText(),
                              children: [
                                TextSpan(
                                  text: 'User-Friendly Interface',
                                  style: boldText().copyWith(color: cs.primary),
                                ),
                                const TextSpan(text: ' • '),
                                TextSpan(
                                  text: 'Secure Data Storage',
                                  style:
                                      boldText().copyWith(color: cs.secondary),
                                ),
                                const TextSpan(text: ' • '),
                                TextSpan(
                                  text: 'Quick Access',
                                  style:
                                      boldText().copyWith(color: cs.tertiary),
                                ),
                                const TextSpan(
                                  text:
                                      '\n\nஇந்த செயலி முழுக்க முழுக்க அவரின் தேவைக்கு ஏற்ற மாதிரி வடிவமைக்கப்பட்ட தனிப்பட்ட தொழில்முறை செயலியாகும்.',
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: rs.rh(14)),

                        // Action
                        SizedBox(
                          height: rs.rh(44),
                          child: FilledButton.icon(
                            onPressed: () => Navigator.pop(dialogContext),
                            icon: const Icon(Icons.close_rounded),
                            label: Text(
                              'Close',
                              style: TextStyle(
                                  fontSize: rs.sp(13.2),
                                  fontWeight: FontWeight.w800),
                            ),
                            style: FilledButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(rs.r(14)),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: rs.rh(8)),

                        // Footer
                        Text(
                          'Developed by Sanjeev Thanarasa • Personal Use Only',
                          textAlign: TextAlign.center,
                          style: tt.labelMedium?.copyWith(
                            fontSize: rs.sp(11.8),
                            color: cs.onSurface.withOpacity(0.55),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
