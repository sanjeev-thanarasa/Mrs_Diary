import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mrs_dth_diary_v1/scr/helpers/operations.dart';
import 'package:mrs_dth_diary_v1/scr/ui/DashBoard/editMyAccountsPayment.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/animatedSizeTransition.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/showAlertDialog.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/screen_navigation.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/styles.dart';
import 'customText.dart';

class DashBoardPaymentContainerListTile extends StatefulWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> snapshot;

  const DashBoardPaymentContainerListTile({
    super.key,
    required this.snapshot,
  });

  @override
  _DashBoardPaymentContainerListTileState createState() =>
      _DashBoardPaymentContainerListTileState();
}

class _DashBoardPaymentContainerListTileState
    extends State<DashBoardPaymentContainerListTile> {
  Widget? image;
  bool tileVisible = false;
  final NumberFormat _currencyFormatter = NumberFormat.decimalPattern();

  @override
  Widget build(BuildContext context) {
    final place = widget.snapshot['RECHARGE_PLACE'] == ''
        ? "No Place Name"
        : widget.snapshot['RECHARGE_PLACE'].toString();
    final createdAt = DateFormat('dd MMM yyyy, hh:mm a').format(
      (widget.snapshot['CREATE_AT'] as Timestamp).toDate(),
    );
    final rechargeAmount = _formatAmount(widget.snapshot['RECHARGE_AMOUNT']);
    final paidAmount = _formatAmount(widget.snapshot['PAID_AMOUNT']);
    final pendingAmount = _formatAmount(widget.snapshot['PENDING_AMOUNT']);
    final balanceAmount = _formatAmount(widget.snapshot['BALANCE_AMOUNT']);
    final showPaid = _hasAmount(widget.snapshot['PAID_AMOUNT']);
    final showPending = _hasAmount(widget.snapshot['PENDING_AMOUNT']);
    final showBalance = _hasAmount(widget.snapshot['BALANCE_AMOUNT']);

    return GestureDetector(
      onLongPress: () => showAlertDialog(
          context: context,
          title: "",
          content: "Do you want to delete this post ?",
          yesOnPressed: () {
            deleteProduct(
                id: widget.snapshot.id,
                collectionName: "DashboardPaymentRecords");
            Navigator.of(context).pop();
          }),
      onTap: () {
        setState(() {
          tileVisible = !tileVisible;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Container(
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 12, 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: kPrimaryLightColor,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: statusCheck(
                        widget.snapshot['PENDING_AMOUNT']?.toString(),
                        widget.snapshot['BALANCE_AMOUNT']?.toString(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: [
                              Image.asset("assets/images/dish.png",
                                  height: 22, width: 22),
                              const SizedBox(width: 6),
                              Expanded(
                                child: CText(
                                  msg: place,
                                  size: 17,
                                  color: kIndigoDark,
                                  weight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          CText(
                            msg: createdAt,
                            size: 13,
                            color: kIndigoLight,
                            weight: FontWeight.w600,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              if (showPaid)
                                _buildChip(
                                  label: 'Paid',
                                  value: paidAmount,
                                  color: const Color(0xff2E7D32),
                                ),
                              if (showPending)
                                _buildChip(
                                  label: 'Pending',
                                  value: pendingAmount,
                                  color: const Color(0xffAD1457),
                                ),
                              if (showBalance)
                                _buildChip(
                                  label: 'Balance',
                                  value: balanceAmount,
                                  color: const Color(0xff0D47A1),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        CText(
                          msg: 'Total',
                          size: 12,
                          color: kIndigoLight,
                          weight: FontWeight.w600,
                        ),
                        const SizedBox(height: 4),
                        CText(
                          msg: rechargeAmount,
                          size: 16,
                          color: kIndigoDark,
                          weight: FontWeight.w700,
                        ),
                        const SizedBox(height: 8),
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
                  ],
                ),
              ),
              Visibility(
                visible: tileVisible,
                child: AnimatedSizeTransition(
                  duration: 800,
                  child: Container(
                    width: 500,
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0)),
                      elevation: 0.0,
                      color: const Color(0xffF7F9FF),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CText(
                                  msg: "Payment Details",
                                  color: kIndigoDark,
                                  size: 16,
                                  weight: FontWeight.w700,
                                ),
                                GestureDetector(
                                  onTap: () => changeScreen(
                                      context,
                                      EditMyAccountsPayment(
                                        snapshot: widget.snapshot,
                                        dbId: widget.snapshot.id,
                                      )),
                                  child: const Icon(Icons.edit, size: 18),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Divider(height: 1),
                            const SizedBox(height: 10),
                            _buildDetailRow(
                              label: 'கொடுத்த பணம்',
                              value: paidAmount,
                              color: const Color(0xff2E7D32),
                            ),
                            if (showPending)
                              _buildDetailRow(
                                label: 'கொடுமதி பணம்',
                                value: pendingAmount,
                                color: const Color(0xffAD1457),
                              ),
                            if (showBalance)
                              _buildDetailRow(
                                label: 'தருமதி பணம்',
                                value: balanceAmount,
                                color: const Color(0xff0D47A1),
                              ),
                            if (widget.snapshot['PAID_DATE'] != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: CRText(
                                  msg1: "இறுதியாக பணம் கொடுத்த திகதி : ",
                                  msg2:
                                      "${DateFormat('dd-MM-yyyy hh:mm a').format((widget.snapshot['PAID_DATE'] as Timestamp).toDate())}",
                                  size1: 13,
                                  weight1: FontWeight.w600,
                                  color1: kIndigoDark,
                                ),
                              ),
                            if (widget.snapshot['USER_NOTE'] != '')
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: CText(
                                  msg:
                                      "User Note:  ${widget.snapshot['USER_NOTE']}",
                                  size: 13,
                                  weight: FontWeight.w600,
                                  color: kIndigoLight,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
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

  Widget statusCheck(String? pending, String? balance) {
    if (pending != null && pending.isNotEmpty) {
      return Image.asset("assets/images/wrong.png", height: 30, width: 30);
    }
    if (balance != null && balance.isNotEmpty) {
      return Image.asset(
        "assets/images/correct.png",
        height: 30,
        width: 30,
        color: Colors.blue,
      );
    }
    return Image.asset("assets/images/correct.png", height: 30, width: 30);
  }

  bool _hasAmount(dynamic value) {
    if (value == null) return false;
    final text = value.toString().trim();
    if (text.isEmpty) return false;
    return _parseAmount(value) > 0;
  }

  String _formatAmount(dynamic value) {
    final amount = _parseAmount(value);
    if (amount == 0) {
      return 'Rs.0';
    }
    return 'Rs.${_currencyFormatter.format(amount.round())}';
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

  Widget _buildChip({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          CText(
            msg: '$label $value',
            color: color,
            size: 11,
            weight: FontWeight.w700,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CText(
            msg: label,
            size: 14,
            weight: FontWeight.w600,
            color: kIndigoDark,
          ),
          CText(
            msg: value,
            size: 14,
            weight: FontWeight.w700,
            color: color,
          ),
        ],
      ),
    );
  }
}
