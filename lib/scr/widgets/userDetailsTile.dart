import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mrs_dth_diary_v1/scr/helpers/owner_service.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/responsive.dart';

class UserDetailsTile extends StatefulWidget {
  final String name;
  final String dishNumber;
  final String mobileNo;
  final String villageName;
  final VoidCallback onTap;
  final String? amountLabel;
  final Object? amountValue;
  final String? userId;

  const UserDetailsTile({
    super.key,
    required this.name,
    required this.dishNumber,
    required this.mobileNo,
    required this.villageName,
    required this.onTap,
    this.amountLabel,
    this.amountValue,
    this.userId,
  });

  @override
  State<UserDetailsTile> createState() => _UserDetailsTileState();
}

class _UserDetailsTileState extends State<UserDetailsTile> {
  Future<Map<String, Object?>?>? _amountFuture;

  @override
  void initState() {
    super.initState();
    _setPendingFuture();
  }

  @override
  void didUpdateWidget(covariant UserDetailsTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId ||
        oldWidget.amountValue != widget.amountValue) {
      _setPendingFuture();
    }
  }

  void _setPendingFuture() {
    if (_hasAmountValue(widget.amountValue)) {
      _amountFuture = null;
      return;
    }
    final id = widget.userId?.trim();
    if (id == null || id.isEmpty) {
      _amountFuture = null;
      return;
    }
    _amountFuture = _fetchOutstandingAmount(id);
  }

  bool _hasAmountValue(Object? value) {
    if (value == null) return false;
    if (value is num) {
      return value > 0;
    }
    final text = value.toString().trim();
    if (text.isEmpty) return false;
    return text != '0' && text != '0.0';
  }

  String _formatAmountText(Object? value) {
    if (value == null) return '';
    if (value is num) {
      if (value == value.roundToDouble()) {
        return value.toInt().toString();
      }
      return value.toString();
    }
    final text = value.toString().trim();
    return text.endsWith('.0') ? text.substring(0, text.length - 2) : text;
  }

  Future<Map<String, Object?>?> _fetchOutstandingAmount(String userId) async {
    try {
      final ownerId = currentOwnerId();
      if (ownerId == null) return null;
      final snapshot = await FirebaseFirestore.instance
          .collection('PaymentRecords')
          .where('ownerId', isEqualTo: ownerId)
          .where('USER_ID', isEqualTo: userId)
          .limit(20)
          .get();

      Object? bestPending;
      Object? bestBalance;
      DateTime? bestDate;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final pendingValue = data['PENDING_AMOUNT'];
        final balanceValue = data['BALANCE_AMOUNT'];
        final createdAt = data['CREATE_AT'];
        DateTime? created;
        if (createdAt is Timestamp) {
          created = createdAt.toDate();
        } else if (createdAt is DateTime) {
          created = createdAt;
        }

        if (bestDate == null ||
            (created != null && created.isAfter(bestDate))) {
          bestDate = created ?? bestDate;
          bestPending = pendingValue;
          bestBalance = balanceValue;
        } else if (bestPending == null && bestBalance == null) {
          bestPending = pendingValue;
          bestBalance = balanceValue;
        }
      }

      if (_hasAmountValue(bestPending)) {
        return {
          'label': 'நிலுவை',
          'value': bestPending,
        };
      }
      if (_hasAmountValue(bestBalance)) {
        return {
          'label': 'கொடுமதி',
          'value': bestBalance,
        };
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  Widget _buildAmountChip(BuildContext context, String label, String amount) {
    final rs = context.rs;
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: rs.rw(8),
        vertical: rs.rh(4),
      ),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(rs.r(10)),
      ),
      child: Text(
        '$label: Rs.$amount',
        style: TextStyle(
          fontSize: rs.sp(11.5),
          fontWeight: FontWeight.w700,
          color: colorScheme.primary,
          fontFamily: 'TamilArima2',
        ),
      ),
    );
  }

  Widget _buildAmountSection(BuildContext context) {
    final label = widget.amountLabel ?? 'நிலுவை';
    if (_hasAmountValue(widget.amountValue)) {
      final amountText = _formatAmountText(widget.amountValue);
      return _buildAmountChip(context, label, amountText);
    }

    if (_amountFuture == null) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<Map<String, Object?>?>(
      future: _amountFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }
        final data = snapshot.data;
        final value = data?['value'];
        final labelText = data?['label']?.toString().trim();
        if (!_hasAmountValue(value)) {
          return const SizedBox.shrink();
        }
        final amountText = _formatAmountText(value);
        if (amountText.isEmpty) {
          return const SizedBox.shrink();
        }
        return _buildAmountChip(
          context,
          labelText?.isNotEmpty == true ? labelText! : label,
          amountText,
        );
      },
    );
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
        onTap: widget.onTap,
        child: Padding(
          padding: EdgeInsets.all(rs.r(14)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.name,
                      style: TextStyle(
                        fontSize: rs.sp(16),
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                        fontFamily: 'TamilArima',
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: rs.rw(12)),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.tv_rounded,
                          color: colorScheme.primary, size: rs.r(16)),
                      SizedBox(width: rs.rw(4)),
                      Text(
                        widget.dishNumber,
                        style: TextStyle(
                          fontSize: rs.sp(12.5),
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                          fontFamily: 'Lobster',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (widget.villageName.isNotEmpty ||
                  _hasAmountValue(widget.amountValue) ||
                  _amountFuture != null) ...[
                SizedBox(height: rs.rh(8)),
                Row(
                  children: [
                    if (widget.villageName.isNotEmpty)
                      Expanded(
                        child: Row(
                          children: [
                            Icon(Icons.location_on_rounded,
                                color: colorScheme.primary, size: rs.r(16)),
                            SizedBox(width: rs.rw(6)),
                            Expanded(
                              child: Text(
                                widget.villageName,
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
                      )
                    else
                      const Spacer(),
                    _buildAmountSection(context),
                  ],
                ),
              ],
              if (widget.mobileNo.trim().isNotEmpty) ...[
                SizedBox(height: rs.rh(8)),
                Row(
                  children: [
                    Icon(Icons.phone_rounded,
                        color: colorScheme.primary, size: rs.r(16)),
                    SizedBox(width: rs.rw(4)),
                    Text(
                      widget.mobileNo,
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
        ),
      ),
    );
  }
}
