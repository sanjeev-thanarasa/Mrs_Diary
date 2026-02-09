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
      margin: EdgeInsets.symmetric(horizontal: rs.rw(8), vertical: rs.rh(4)),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(rs.r(16))),
      child: InkWell(
        borderRadius: BorderRadius.circular(rs.r(16)),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(rs.r(14)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: rs.sp(16),
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                            fontFamily: 'TamilArima',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (villageName.isNotEmpty) ...[
                          SizedBox(height: rs.rh(8)),
                          Row(
                            children: [
                              Icon(Icons.location_on_rounded,
                                  color: colorScheme.primary, size: rs.r(16)),
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
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(width: rs.rw(14)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
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
                      SizedBox(height: rs.rh(_hasAmount ? 8 : 0)),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.tv_rounded,
                              color: colorScheme.primary, size: rs.r(16)),
                          SizedBox(width: rs.rw(4)),
                          Text(
                            dishNumber,
                            style: TextStyle(
                              fontSize: rs.sp(12.5),
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                              fontFamily: 'Lobster',
                            ),
                          ),
                        ],
                      ),
                      if (mobileNo.trim().isNotEmpty) ...[
                        SizedBox(height: rs.rh(8)),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.phone_rounded,
                                color: colorScheme.primary, size: rs.r(16)),
                            SizedBox(width: rs.rw(4)),
                            Text(
                              mobileNo,
                              style: TextStyle(
                                fontSize: rs.sp(13.5),
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                                fontFamily: 'Lobster',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
