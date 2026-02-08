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
    final expiredAt = data['EXPIRED_AT'];
    final userNote = _field(data['USER_NOTE']);
    final userNote2 = _field(data['USER_NOTE2']);

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
            color: const Color(0xffF5FAFF),
            border: Border.all(
              color: kPrimaryLightColor.withValues(alpha: 0.6),
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
                      pendingAmount: pendingAmount,
                      balanceAmount: balanceAmount,
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
                            Image.asset("assets/images/dish.png",
                                height: rs.r(26), width: rs.r(26)),
                            SizedBox(width: rs.rw(6)),
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
                                  Icon(Icons.payments_rounded,
                                      color: kBlueLight, size: rs.r(18)),
                                  SizedBox(width: rs.rw(6)),
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
                          IconButton(
                            icon: Icon(
                              tileVisible
                                  ? Icons.expand_less_rounded
                                  : Icons.expand_more_rounded,
                              color: mainBlue,
                            ),
                            onPressed: () {
                              setState(() {
                                tileVisible = !tileVisible;
                              });
                            },
                          )
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
                                  GestureDetector(
                                    onTap: () => changeScreen(
                                      context,
                                      EditPayment(
                                        snapshot: widget.snapshot,
                                        userId: widget.snapshot.id,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit_rounded,
                                            size: rs.r(16), color: kBlueColor),
                                        SizedBox(width: rs.rw(4)),
                                        CText(
                                          msg: "Edit",
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
                                label: 'Paid amount',
                                value:
                                    'Rs.${paidAmount.isEmpty ? "0" : paidAmount}',
                                color: const Color(0xff2E7D32),
                              ),
                              if (pendingAmount.isNotEmpty)
                                _DetailRow(
                                  icon: Icons.schedule_rounded,
                                  label: 'Pending amount',
                                  value: 'Rs.$pendingAmount',
                                  color: const Color(0xffAF0069),
                                ),
                              if (pendingDate != null)
                                _DetailRow(
                                  icon: Icons.event_rounded,
                                  label: 'Pending date',
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
                                  label: 'Expired date',
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
}

class _StatusBadge extends StatelessWidget {
  final String pendingAmount;
  final String balanceAmount;

  const _StatusBadge({
    required this.pendingAmount,
    required this.balanceAmount,
  });

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;
    final hasPending = pendingAmount.isNotEmpty;
    final hasBalance = balanceAmount.isNotEmpty;
    final icon = hasPending
        ? Icons.error_rounded
        : hasBalance
            ? Icons.info_rounded
            : Icons.check_circle_rounded;
    final color = hasPending
        ? Colors.redAccent
        : hasBalance
            ? Colors.orange
            : Colors.green;

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
