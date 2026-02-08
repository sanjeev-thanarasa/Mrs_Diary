import 'package:flutter/material.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/responsive.dart';

class UserDetailsTile extends StatelessWidget {
  final String name;
  final String dishNumber;
  final String mobileNo;
  final String villageName;
  final VoidCallback onTap;
  final String? amountLabel;
  final String? amountValue;

  const UserDetailsTile({
    super.key,
    required this.name,
    required this.dishNumber,
    required this.mobileNo,
    required this.villageName,
    required this.onTap,
    this.amountLabel,
    this.amountValue,
  });

  bool get _hasAmount {
    final value = amountValue?.trim() ?? '';
    return value.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: rs.r(1.5),
      margin: EdgeInsets.symmetric(horizontal: rs.rw(16), vertical: rs.rh(6)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rs.r(16))),
      child: InkWell(
        borderRadius: BorderRadius.circular(rs.r(16)),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(rs.r(14)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.person_rounded,
                      color: colorScheme.primary, size: rs.r(20)),
                  SizedBox(width: rs.rw(8)),
                  Expanded(
                    child: Text(
                      name,
                      style: TextStyle(
                        fontSize: rs.sp(16),
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                        fontFamily: 'TamilArima',
                      ),
                    ),
                  ),
                  if (_hasAmount)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: rs.rw(8),
                        vertical: rs.rh(4),
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(rs.r(10)),
                      ),
                      child: Text(
                        '${amountLabel ?? 'Due'}: Rs.${amountValue!.trim()}',
                        style: TextStyle(
                          fontSize: rs.sp(11.5),
                          fontWeight: FontWeight.w700,
                          color: colorScheme.primary,
                          fontFamily: 'TamilArima2',
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: rs.rh(10)),
              Row(
                children: [
                  Icon(Icons.tv_rounded,
                      color: colorScheme.primary, size: rs.r(18)),
                  SizedBox(width: rs.rw(6)),
                  Expanded(
                    child: Text(
                      dishNumber,
                      style: TextStyle(
                        fontSize: rs.sp(14),
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                        fontFamily: 'Lobster',
                      ),
                    ),
                  ),
                  Icon(Icons.phone_rounded,
                      color: colorScheme.primary, size: rs.r(18)),
                  SizedBox(width: rs.rw(6)),
                  Text(
                    mobileNo,
                    style: TextStyle(
                      fontSize: rs.sp(14),
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                      fontFamily: 'Lobster',
                    ),
                  ),
                ],
              ),
              if (villageName.isNotEmpty) ...[
                SizedBox(height: rs.rh(10)),
                Row(
                  children: [
                    Icon(Icons.location_on_rounded,
                        color: colorScheme.primary, size: rs.r(18)),
                    SizedBox(width: rs.rw(6)),
                    Expanded(
                      child: Text(
                        villageName,
                        style: TextStyle(
                          fontSize: rs.sp(13),
                          color: colorScheme.onSurfaceVariant,
                          fontFamily: 'TamilArima2',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
