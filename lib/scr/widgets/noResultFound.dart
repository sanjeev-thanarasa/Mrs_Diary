import 'package:flutter/material.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/responsive.dart';

class SearchNoData extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final rs = context.rs;
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.center,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: rs.rw(20),
          vertical: rs.rh(20),
        ),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(rs.r(18)),
          border: Border.all(color: colorScheme.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: rs.r(18),
              offset: Offset(0, rs.rh(10)),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              "assets/images/noResults.png",
              height: rs.r(100),
              fit: BoxFit.contain,
            ),
            SizedBox(height: rs.rh(12)),
            // Text(
            //   'No results found',
            //   style: TextStyle(
            //     fontSize: rs.sp(16),
            //     fontWeight: FontWeight.w700,
            //     color: colorScheme.onSurface,
            //     fontFamily: 'TamilArima',
            //   ),
            //   textAlign: TextAlign.center,
            // ),
            SizedBox(height: rs.rh(6)),
            Text(
              'Try a different keyword or adjust your filters.',
              style: TextStyle(
                fontSize: rs.sp(12.5),
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
                fontFamily: 'TamilArima2',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
