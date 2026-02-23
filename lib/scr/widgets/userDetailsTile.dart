import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mrs_dth_diary_v1/scr/helpers/operations.dart';
import 'package:mrs_dth_diary_v1/scr/helpers/owner_service.dart';
import 'package:mrs_dth_diary_v1/scr/helpers/user_amount_cache.dart';
import 'package:mrs_dth_diary_v1/scr/ui/editUserDetail.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/responsive.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/screen_navigation.dart';

class UserDetailsTile extends StatefulWidget {
  final String name;
  final String dishNumber;
  final String mobileNo;
  final String villageName;
  final VoidCallback onTap;
  final String? amountLabel;
  final Object? amountValue;
  final String userId;
  final String collectionName;
  final bool enableActions;

  const UserDetailsTile({
    super.key,
    required this.name,
    required this.dishNumber,
    required this.mobileNo,
    required this.villageName,
    required this.onTap,
    required this.userId,
    required this.collectionName,
    this.enableActions = false,
    this.amountLabel,
    this.amountValue,
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
    final id = widget.userId.trim();
    if (id.isEmpty) {
      _amountFuture = null;
      return;
    }
    final cached = UserAmountCache.get(id);
    if (cached != null) {
      _amountFuture = cached;
      return;
    }
    final future = _fetchOutstandingAmount(id);
    UserAmountCache.set(id, future);
    _amountFuture = future;
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
          .get();

      double pendingTotal = 0;
      double balanceTotal = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        pendingTotal += _parseAmount(data['PENDING_AMOUNT']);
        balanceTotal += _parseAmount(data['BALANCE_AMOUNT']);
      }

      if (pendingTotal > 0) {
        return {
          'label': 'தருமதி',
          'value': pendingTotal,
        };
      }
      if (balanceTotal > 0) {
        return {
          'label': 'கொடுமதி',
          'value': balanceTotal,
        };
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  double _parseAmount(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    final text = value
        .toString()
        .replaceAll('Rs.', '')
        .replaceAll('Rs', '')
        .replaceAll(',', '')
        .trim();
    return double.tryParse(text) ?? 0;
  }

  Widget _buildAmountChip(BuildContext context, String label, String amount) {
    final rs = context.rs;
    final colorScheme = Theme.of(context).colorScheme;
    final isPending = label.contains('தருமதி');
    final isBalance = label.contains('கொடுமதி');
    final chipColor = isPending
        ? Colors.red.shade50
        : isBalance
            ? Colors.orange.shade50
            : colorScheme.primary.withValues(alpha: 0.12);
    final textColor = isPending
        ? Colors.red.shade700
        : isBalance
            ? Colors.orange.shade800
            : colorScheme.primary;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: rs.rw(8),
        vertical: rs.rh(4),
      ),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(rs.r(10)),
        border: isPending
            ? Border.all(color: Colors.red.shade200)
            : isBalance
                ? Border.all(color: Colors.orange.shade200)
                : null,
      ),
      child: Text(
        '$label: Rs.$amount',
        style: TextStyle(
          fontSize: rs.sp(11.5),
          fontWeight: FontWeight.w700,
          color: textColor,
          fontFamily: 'TamilArima2',
        ),
      ),
    );
  }

  Widget _buildAmountSection(BuildContext context) {
    final label = widget.amountLabel ?? 'தருமதி';
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

  Future<void> _confirmDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Delete user?',
          style: TextStyle(
            fontFamily: 'TamilArima',
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'Deleting this user will also delete all their payment records permanently. This action cannot be undone.\n\nDo you want to continue?',
          style: TextStyle(
            fontFamily: 'TamilArima2',
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      try {
        // Delete all payment records for this user
        final ownerId = requireOwnerId();
        final paymentRecords = await FirebaseFirestore.instance
            .collection('PaymentRecords')
            .where('ownerId', isEqualTo: ownerId)
            .where('USER_ID', isEqualTo: widget.userId)
            .get();

        // Delete all payment records
        for (final doc in paymentRecords.docs) {
          await doc.reference.delete();
        }

        // Delete the user
        await deleteProduct(
          id: widget.userId,
          collectionName: widget.collectionName,
        );

        UserAmountCache.invalidate(widget.userId);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('User and all payment records deleted successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  Future<void> _navigateToEdit(BuildContext context) async {
    changeScreenAnimated(
      context,
      EditUserDetail(
        userId: widget.userId,
        collectionName: widget.collectionName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: rs.r(1.5),
      margin: EdgeInsets.symmetric(horizontal: rs.rw(8), vertical: rs.rh(4)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(rs.r(16)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(rs.r(16)),
        onTap: widget.onTap,
        onLongPress: widget.enableActions ? () => _showActions(context) : null,
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

  Future<void> _showActions(BuildContext context) async {
    final rs = context.rs;
    await showModalBottomSheet<void>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(rs.r(18))),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_rounded, color: Colors.blue),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToEdit(context);
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.delete_rounded, color: Colors.redAccent),
                title: const Text('Delete'),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
