import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mrs_dth_diary_v1/scr/helpers/operations.dart';
import 'package:mrs_dth_diary_v1/scr/ui/editPayment.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/animatedSizeTransition.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/screen_navigation.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/styles.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/responsive.dart';
import 'customText.dart';

class PaymentContainerListTile extends StatefulWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> snapshot;

  const PaymentContainerListTile({
    super.key,
    required this.snapshot,
  });

  @override
  _PaymentContainerListTileState createState() =>
      _PaymentContainerListTileState();
}

class _PaymentContainerListTileState extends State<PaymentContainerListTile>
    with SingleTickerProviderStateMixin {
  Widget? image;
  bool tileVisible = false;

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;
    final data = widget.snapshot.data();
    final packageName = _field(data['PACKAGE_NAME']);
    final createdAt = data['CREATE_AT'];
    final amount = _field(data['AMOUNT']);
    final paidAmount = _field(data['PAID_AMOUNT']);
    final pendingAmount = _field(data['PENDING_AMOUNT']);
    final pendingDate = data['PENDING_DATE'];
    final balanceAmount = _field(data['BALANCE_AMOUNT']);
    final history = (data['PAYMENT_HISTORY'] as List?) ?? [];
    final expiredAt = data['EXPIRED_AT'];
    final userNote = _field(data['USER_NOTE']);
    final userNote2 = _field(data['USER_NOTE2']);
    final status = _resolveStatus(
      amount: amount,
      paidAmount: paidAmount,
      pendingAmount: pendingAmount,
      balanceAmount: balanceAmount,
    );
    final statusStyle = _resolveStatusStyle(
      amount: amount,
      paidAmount: paidAmount,
      pendingAmount: pendingAmount,
      balanceAmount: balanceAmount,
    );
    final amountValue = _parseAmount(amount);
    final paidValue = _parseAmount(paidAmount);
    final pendingValue = _parseAmount(pendingAmount);
    final balanceValue = _parseAmount(balanceAmount);
    final hasBalance = balanceValue > 0;
    final isCompleted = amountValue > 0 &&
        paidValue >= amountValue &&
        pendingValue <= 0 &&
        balanceValue <= 0;

    return GestureDetector(
      onLongPress: () => _showDeleteDialog(context),
      onTap: () {
        setState(() {
          tileVisible = !tileVisible;
        });
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: rs.rw(12),
          vertical: rs.rh(6),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(rs.r(18)),
            color: statusStyle?.backgroundColor ?? const Color(0xffF5FAFF),
            border: Border.all(
              color: (statusStyle?.color ?? kPrimaryLightColor)
                  .withValues(alpha: 0.35),
            ),
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(rs.r(14)),
                    child: _StatusBadge(
                      icon: statusStyle?.icon ?? Icons.info_rounded,
                      color: statusStyle?.color ?? kBlueColor,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: rs.rh(10), left: rs.rw(3)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: [
                            CText(
                              msg:
                                  packageName.isEmpty ? "No Name" : packageName,
                              size: rs.sp(16),
                              color: kIndigoDark,
                              weight: FontWeight.w700,
                            ),
                          ],
                        ),
                        SizedBox(height: rs.rh(4)),
                        CText(
                          msg: _formatDate(createdAt),
                          size: rs.sp(13),
                          color: kIndigoLight,
                          weight: FontWeight.w600,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: rs.rw(8)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(rs.r(8)),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: rs.rw(10),
                                vertical: rs.rh(6),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(rs.r(12)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.06),
                                    blurRadius: rs.r(12),
                                    offset: Offset(0, rs.rh(6)),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CText(
                                    msg: "Rs.${amount.isEmpty ? "0" : amount}",
                                    size: rs.sp(15),
                                    color: Colors.black87,
                                    weight: FontWeight.w800,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (status != null)
                            Padding(
                              padding: EdgeInsets.only(
                                right: rs.rw(8),
                                bottom: rs.rh(6),
                              ),
                              child: _StatusChip(
                                label: status.label,
                                value: status.value,
                                color: status.color,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Visibility(
                  visible: tileVisible,
                  child: AnimatedSizeTransition(
                    duration: 800,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.fromLTRB(
                        rs.rw(12),
                        rs.rh(8),
                        rs.rw(12),
                        rs.rh(12),
                      ),
                      child: Card(
                        elevation: 0,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(rs.r(14)),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(rs.r(14)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  CText(
                                    msg: "Payment details",
                                    color: kIndigoLight,
                                    size: rs.sp(15),
                                    weight: FontWeight.w700,
                                  ),
                                  if (!isCompleted && !hasBalance)
                                    GestureDetector(
                                      onTap: () {
                                        if (balanceAmount.isNotEmpty) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Balance amount exists. Create next payment to adjust.'),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                            ),
                                          );
                                          return;
                                        }
                                        changeScreen(
                                          context,
                                          EditPayment(
                                            snapshot: widget.snapshot,
                                            userId: widget.snapshot.id,
                                          ),
                                        );
                                      },
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit_rounded,
                                              size: rs.r(16),
                                              color: kBlueColor),
                                          SizedBox(width: rs.rw(4)),
                                          CText(
                                            msg: "Add Payment",
                                            size: rs.sp(12),
                                            color: kBlueColor,
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              Divider(height: rs.rh(16)),
                              _DetailRow(
                                icon: Icons.payments_rounded,
                                label: 'செலுத்திய தொகை',
                                value:
                                    'Rs.${paidAmount.isEmpty ? "0" : paidAmount}',
                                color: const Color(0xff2E7D32),
                              ),
                              if (pendingAmount.isNotEmpty)
                                _DetailRow(
                                  icon: Icons.schedule_rounded,
                                  label: 'நிலுவை தொகை',
                                  value: 'Rs.$pendingAmount',
                                  color: const Color(0xffAF0069),
                                ),
                              if (pendingDate != null)
                                _DetailRow(
                                  icon: Icons.event_rounded,
                                  label: 'நிலுவை தேதி',
                                  value: _formatDate(pendingDate),
                                  color: const Color(0xff09015f),
                                ),
                              if (balanceAmount.isNotEmpty)
                                _DetailRow(
                                  icon: Icons.wallet_rounded,
                                  label: 'Balance amount',
                                  value: 'Rs.$balanceAmount',
                                  color: const Color(0xffAF0069),
                                ),
                              if (expiredAt != null)
                                _DetailRow(
                                  icon: Icons.event_busy_rounded,
                                  label: 'காலாவதி தேதி',
                                  value: _formatDate(expiredAt),
                                  color: const Color(0xff09015f),
                                ),
                              if (userNote.isNotEmpty)
                                _DetailRow(
                                  icon: Icons.notes_rounded,
                                  label: 'Note',
                                  value: userNote,
                                  color: const Color(0xffff884b),
                                ),
                              if (userNote2.isNotEmpty)
                                _DetailRow(
                                  icon: Icons.notes_rounded,
                                  label: 'Note 2',
                                  value: userNote2,
                                  color: const Color(0xffff884b),
                                ),
                              if (history.isNotEmpty) ...[
                                Divider(height: rs.rh(20)),
                                Text(
                                  'Payment history',
                                  style: TextStyle(
                                    fontSize: rs.sp(13),
                                    fontWeight: FontWeight.w700,
                                    color: kIndigoLight,
                                  ),
                                ),
                                SizedBox(height: rs.rh(8)),
                                ...history.reversed.map((entry) {
                                  final map = entry is Map<String, dynamic>
                                      ? entry
                                      : <String, dynamic>{};
                                  final paidAt = map['PAID_AT'];
                                  final paidValue =
                                      _field(map['AMOUNT']).isEmpty
                                          ? '0'
                                          : _field(map['AMOUNT']);
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: rs.rh(6)),
                                    child: Row(
                                      children: [
                                        Icon(Icons.payments_rounded,
                                            size: rs.r(14), color: kBlueColor),
                                        SizedBox(width: rs.rw(6)),
                                        Expanded(
                                          child: Text(
                                            _formatDate(paidAt),
                                            style: TextStyle(
                                              fontSize: rs.sp(12),
                                              color: Colors.black54,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          'Rs.$paidValue',
                                          style: TextStyle(
                                            fontSize: rs.sp(12),
                                            fontWeight: FontWeight.w700,
                                            color: kIndigoDark,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget gap({double? h, double? w}) {
    return SizedBox(
      height: h,
      width: w,
    );
  }

  String _field(dynamic value) {
    if (value == null) return '';
    if (value is String) return value.trim();
    return value.toString();
  }

  String _formatDate(dynamic value) {
    if (value == null) return '';
    if (value is Timestamp) {
      return DateFormat('dd-MM-yyyy hh:mm a').format(value.toDate());
    }
    if (value is DateTime) {
      return DateFormat('dd-MM-yyyy hh:mm a').format(value);
    }
    return value.toString();
  }

  Future<void> _showDeleteDialog(BuildContext context) async {
    final rs = context.rs;
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(rs.r(16)),
          ),
          titlePadding: EdgeInsets.fromLTRB(
            rs.rw(16),
            rs.rh(14),
            rs.rw(16),
            rs.rh(6),
          ),
          contentPadding: EdgeInsets.fromLTRB(
            rs.rw(16),
            0,
            rs.rw(16),
            rs.rh(8),
          ),
          actionsPadding: EdgeInsets.fromLTRB(
            rs.rw(12),
            0,
            rs.rw(12),
            rs.rh(12),
          ),
          title: Row(
            children: [
              Container(
                height: rs.r(36),
                width: rs.r(36),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(rs.r(10)),
                ),
                child: Icon(
                  Icons.delete_rounded,
                  color: Colors.redAccent,
                  size: rs.r(20),
                ),
              ),
              SizedBox(width: rs.rw(10)),
              Expanded(
                child: Text(
                  'Delete payment?',
                  style: TextStyle(
                    fontSize: rs.sp(16),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'Do you want to delete this payment record? This action cannot be undone.',
            style: TextStyle(
              fontSize: rs.sp(13),
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(fontSize: rs.sp(13)),
              ),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(rs.r(10)),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: rs.rw(14),
                  vertical: rs.rh(10),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(true),
              icon: Icon(Icons.delete_rounded, size: rs.r(16)),
              label: Text(
                'Delete',
                style: TextStyle(fontSize: rs.sp(13)),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      deleteProduct(id: widget.snapshot.id, collectionName: "PaymentRecords");
    }
  }

  _StatusInfo? _resolveStatus({
    required String amount,
    required String paidAmount,
    required String pendingAmount,
    required String balanceAmount,
  }) {
    final amountValue = _parseAmount(amount);
    final paidValue = _parseAmount(paidAmount);
    final pendingValue = _parseAmount(pendingAmount);
    final balanceValue = _parseAmount(balanceAmount);

    if (balanceValue > 0) {
      return _StatusInfo(
        label: 'கொடுமதி',
        value: balanceValue,
        color: Colors.orange,
      );
    }
    if (pendingValue > 0 || (amountValue > 0 && paidValue < amountValue)) {
      return _StatusInfo(
        label: 'நிலுவை',
        value: pendingValue > 0
            ? pendingValue
            : (amountValue - paidValue).clamp(0, double.infinity),
        color: Colors.redAccent,
      );
    }
    if (amountValue > 0 && paidValue >= amountValue) {
      return _StatusInfo(
        label: 'முடிந்தது',
        value: paidValue,
        color: Colors.green,
      );
    }
    return null;
  }

  _StatusStyle? _resolveStatusStyle({
    required String amount,
    required String paidAmount,
    required String pendingAmount,
    required String balanceAmount,
  }) {
    final amountValue = _parseAmount(amount);
    final paidValue = _parseAmount(paidAmount);
    final pendingValue = _parseAmount(pendingAmount);
    final balanceValue = _parseAmount(balanceAmount);

    if (balanceValue > 0) {
      return _StatusStyle(
        icon: Icons.account_balance_wallet_rounded,
        color: Colors.orange,
        backgroundColor: Colors.orange.withValues(alpha: 0.08),
      );
    }
    if (pendingValue > 0 || (amountValue > 0 && paidValue < amountValue)) {
      return _StatusStyle(
        icon: Icons.schedule_rounded,
        color: Colors.redAccent,
        backgroundColor: Colors.redAccent.withValues(alpha: 0.08),
      );
    }
    if (amountValue > 0 && paidValue >= amountValue) {
      return _StatusStyle(
        icon: Icons.check_circle_rounded,
        color: Colors.green,
        backgroundColor: Colors.green.withValues(alpha: 0.08),
      );
    }
    return null;
  }

  double _parseAmount(String value) {
    if (value.isEmpty) return 0;
    final text = value
        .replaceAll('Rs.', '')
        .replaceAll('Rs', '')
        .replaceAll(',', '')
        .trim();
    return double.tryParse(text) ?? 0;
  }
}

class _StatusInfo {
  final String label;
  final double value;
  final Color color;

  const _StatusInfo({
    required this.label,
    required this.value,
    required this.color,
  });
}

class _StatusStyle {
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  const _StatusStyle({
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });
}

class _StatusChip extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _StatusChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: rs.rw(8),
        vertical: rs.rh(4),
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(rs.r(10)),
      ),
      child: Text(
        '$label Rs.${value.toStringAsFixed(0)}',
        style: TextStyle(
          fontSize: rs.sp(11),
          fontWeight: FontWeight.w700,
          color: color,
          fontFamily: 'TamilArima2',
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _StatusBadge({
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;
    return Container(
      height: rs.r(40),
      width: rs.r(40),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(rs.r(12)),
      ),
      child: Icon(icon, color: color, size: rs.r(22)),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: rs.rh(4)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: rs.r(24),
            width: rs.r(24),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(rs.r(6)),
            ),
            child: Icon(icon, color: color, size: rs.r(14)),
          ),
          SizedBox(width: rs.rw(8)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: rs.sp(12),
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: rs.rh(2)),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: rs.sp(13),
                    color: Colors.black87,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
