import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mrs_dth_diary_v1/scr/helpers/paymentService.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/CTextField.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/RoundedLoadingButton.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/SimpleCalc.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/datePicker.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/styles.dart';

class EditPayment extends StatefulWidget {
  final String userId;
  final QueryDocumentSnapshot<Map<String, dynamic>> snapshot;

  const EditPayment({
    super.key,
    required this.userId,
    required this.snapshot,
  });

  @override
  _EditPaymentState createState() => _EditPaymentState();
}

class _EditPaymentState extends State<EditPayment> {
  final PaymentServices _paymentServices = PaymentServices();

  @override
  void dispose() {
    _paymentServices.clearRecords();
    super.dispose();
  }

  @override
  void initState() {
    _paymentServices.createRecordDate.text =
        widget.snapshot['CREATE_AT'] != null
            ? DateFormat('dd-MM-yyyy hh:mm a')
                .format(widget.snapshot['CREATE_AT'].toDate())
            : "";
    editInitialize();
    super.initState();
  }

  // void _onRefresh() {
  //   _paymentServices.clearRecords();
  //   _paymentServices.btnController.reset();
  // }

  void editInitialize() {
    _paymentServices.createDate = widget.snapshot['CREATE_AT'] != null
        ? widget.snapshot['CREATE_AT'].toDate()
        : null;
    _paymentServices.expiredDate = widget.snapshot['EXPIRED_AT'] != null
        ? widget.snapshot['EXPIRED_AT'].toDate()
        : null;
    _paymentServices.packageName.text = widget.snapshot['PACKAGE_NAME'];
    _paymentServices.rechargeAmount.text = widget.snapshot['AMOUNT'];
    _paymentServices.giveAmount.text = widget.snapshot['PAID_AMOUNT'];
    _paymentServices.pendingAmount.text = widget.snapshot['PENDING_AMOUNT'];
    _paymentServices.pendingDate = widget.snapshot['PENDING_DATE'] != null
        ? widget.snapshot['PENDING_DATE'].toDate()
        : null;
    _paymentServices.balanceAmount.text = widget.snapshot['BALANCE_AMOUNT'];
    _paymentServices.userNote.text = widget.snapshot['USER_NOTE'];
    _paymentServices.userNote2.text = widget.snapshot['USER_NOTE2'];
    if (_paymentServices.pendingDate != null) {
      _paymentServices.pendingDateController.text =
          DateFormat('dd-MM-yyyy hh:mm a')
              .format(_paymentServices.pendingDate!);
    }
    if (_paymentServices.expiredDate != null) {
      _paymentServices.expiredDateController.text =
          DateFormat('dd-MM-yyyy hh:mm a')
              .format(_paymentServices.expiredDate!);
    }
  }

  final TextStyle _style = const TextStyle(
    fontSize: 15.0,
    fontFamily: "TamilArima",
    color: Colors.blueGrey,
  );
  int recharge = 0;
  int paidAmount = 0;

  @override
  Widget build(BuildContext context) {
    recharge = widget.snapshot['AMOUNT'] != ''
        ? int.parse(widget.snapshot['AMOUNT'].trim().toString())
        : 0;
    paidAmount = widget.snapshot['PAID_AMOUNT'] != ''
        ? int.parse(widget.snapshot['PAID_AMOUNT'].trim().toString())
        : 0;
    final equal = recharge == paidAmount;
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text(
          "Edit Payment",
          style: TextStyle(
            fontFamily: 'TamilArima',
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Icon(
                Icons.calculate_rounded,
                size: 26.0,
                color: Colors.black87,
              ),
              onPressed: () {
                showModalBottomSheet<void>(
                    isScrollControlled: true,
                    useSafeArea: true,
                    context: context,
                    builder: (BuildContext context) {
                      return SimpleCalc();
                    });
              },
            ),
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: _buildContentUI(context, equal),
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

  bool noteVisible = false;

  Widget _buildContentUI(BuildContext context, bool equal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeaderCard(equal),
        const SizedBox(height: 12),
        _sectionCard(
          title: "Update payment",
          child: Column(
            children: [
              if (!equal)
                CustomTextField(
                  controller: _paymentServices.newGiveAmount,
                  hintText: widget.snapshot['BALANCE_AMOUNT'] != ''
                      ? "நீங்கள் கொடுத்த பணம்"
                      : "புதிதாக தந்த பணம்",
                  hintTextColor: Colors.blueGrey,
                  icon: Icons.monetization_on,
                  textStyle: _style,
                  keyboardType: TextInputType.number,
                  animatedIconButtonStratIcon: Icons.done,
                  animatedIconButtonEndIcon: Icons.done_all_rounded,
                  iconButton: true,
                  animatedIconButtonOnTap: () {
                    widget.snapshot['BALANCE_AMOUNT'] != ''
                        ? calculateBalance()
                        : calculatePending();
                  },
                ),
              if (_paymentServices.pending) ...[
                const SizedBox(height: 10),
                _statusTile(
                  title: "புதிய தருமதி பணம்",
                  value: _paymentServices.pendingAmount.text,
                  color: Colors.blueGrey,
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  readOnly: true,
                  controller: _paymentServices.pendingDateController,
                  hintText: "தருமதி திகதி",
                  icon: Icons.update,
                  keyboardType: TextInputType.text,
                  animatedIconButtonStratIcon: Icons.date_range,
                  textStyle: _style,
                  hintTextColor: Colors.blueGrey,
                  iconButton: true,
                  animatedIconButtonOnTap: () {
                    showCupertinoModalPopup(
                        context: context,
                        builder: (_) => DatePicker(
                              onDateTimeChanged: (val) {
                                setState(() {
                                  _paymentServices.pendingDate = val;
                                  _paymentServices.pendingDateController.text =
                                      DateFormat('dd-MM-yyyy hh:mm a')
                                          .format(val);
                                });
                              },
                            ));
                  },
                ),
              ],
              if (_paymentServices.balance) ...[
                const SizedBox(height: 10),
                _statusTile(
                  title: "புதிய கொடுமதி பணம்",
                  value: _paymentServices.balanceAmount.text,
                  color: Colors.blueGrey,
                ),
              ],
              const SizedBox(height: 10),
              CustomTextField(
                readOnly: true,
                controller: _paymentServices.expiredDateController,
                hintText: "முடியும் திகதி",
                icon: Icons.date_range,
                keyboardType: TextInputType.text,
                textStyle: _style,
                hintTextColor: Colors.blueGrey,
                animatedIconButtonStratIcon: Icons.date_range,
                animatedIconButtonEndIcon: Icons.date_range_outlined,
                animatedIconButtonOnTap: () {
                  showCupertinoModalPopup(
                      context: context,
                      builder: (_) => DatePicker(
                            onDateTimeChanged: (val) {
                              setState(() {
                                _paymentServices.expiredDate = val;
                                _paymentServices.expiredDateController.text =
                                    DateFormat('dd-MM-yyyy hh:mm a')
                                        .format(val);
                              });
                            },
                          ));
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _sectionCard(
          title: "Notes",
          child: Column(
            children: [
              CustomTextField(
                controller: _paymentServices.userNote,
                hintText: "குறிப்பு",
                icon: Icons.note_add,
                keyboardType: TextInputType.text,
                textStyle: _style,
                hintTextColor: Colors.blueGrey,
                iconButton: true,
                animatedIconButtonStratIcon: Icons.add_circle_outline_rounded,
                animatedIconButtonEndIcon:
                    Icons.indeterminate_check_box_outlined,
                animatedIconButtonOnTap: () =>
                    setState(() => noteVisible = !noteVisible),
              ),
              if (noteVisible)
                CustomTextField(
                  controller: _paymentServices.userNote2,
                  hintText: "குறிப்பு 2",
                  icon: Icons.note_add_outlined,
                  textStyle: _style,
                  keyboardType: TextInputType.text,
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        RoundedLoading(
          btnController: _paymentServices.btnController,
          paddingLeft: 10.0,
          paddingRight: 10.0,
          paddingTop: 8.0,
          buttonHeight: 44,
          btnColor: kBlueColor,
          buttonPressed: () {
            _paymentServices.updatePaymentRecord(snapshot: widget.snapshot);
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildHeaderCard(bool equal) {
    final pendingOrBalance = widget.snapshot['BALANCE_AMOUNT'] != ''
        ? widget.snapshot['BALANCE_AMOUNT']
        : widget.snapshot['PENDING_AMOUNT'];

    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.snapshot['PACKAGE_NAME'] == ''
                  ? 'No Name'
                  : widget.snapshot['PACKAGE_NAME'],
              style: const TextStyle(
                fontSize: 18,
                fontFamily: 'TamilArima',
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.event_rounded, size: 16, color: kBlueColor),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _paymentServices.createRecordDate.text,
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'TamilArima2',
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Change date',
                  onPressed: () {
                    showCupertinoModalPopup(
                        context: context,
                        builder: (_) => DatePicker(
                              onDateTimeChanged: (val) {
                                setState(() {
                                  _paymentServices.createDate = val;
                                  _paymentServices.createRecordDate.text =
                                      DateFormat('dd-MM-yyyy hh:mm a')
                                          .format(val);
                                });
                              },
                            ));
                  },
                  icon: const Icon(Icons.edit_calendar_rounded),
                )
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                _infoChip(
                  label: 'Recharge',
                  value: widget.snapshot['AMOUNT'],
                  color: Colors.green.shade700,
                ),
                const SizedBox(width: 8),
                _infoChip(
                  label: 'Paid',
                  value: widget.snapshot['PAID_AMOUNT'],
                  color: Colors.orange.shade700,
                ),
                if (!equal) ...[
                  const SizedBox(width: 8),
                  _infoChip(
                    label: widget.snapshot['BALANCE_AMOUNT'] != ''
                        ? 'Balance'
                        : 'Pending',
                    value: pendingOrBalance,
                    color: Colors.purple.shade700,
                  ),
                ]
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'TamilArima',
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }

  Widget _statusTile({
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(Icons.payments_rounded, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'TamilArima2',
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
          Text(
            'Rs.$value',
            style: TextStyle(
              fontFamily: 'TamilArima',
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontFamily: 'TamilArima2',
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value == '' ? '0' : value.toString(),
            style: TextStyle(
              fontSize: 13,
              fontFamily: 'TamilArima',
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void calculatePending() {
    int amount = _paymentServices.newGiveAmount.text != ''
        ? int.parse(_paymentServices.newGiveAmount.text.trim())
        : 0;

    int give = paidAmount + amount;

    if (recharge > give) {
      setState(() {
        _paymentServices.pending = true;
        _paymentServices.balance = false;
        _paymentServices.balanceAmount.clear();
        _paymentServices.pendingAmount.text = (recharge - give).toString();
        _paymentServices.newGiveAmount.text = give.toString();
      });
    } else if (recharge < give) {
      setState(() {
        _paymentServices.pending = false;
        _paymentServices.balance = true;
        _paymentServices.pendingAmount.clear();
        _paymentServices.pendingDate = null;
        _paymentServices.balanceAmount.text = (give - recharge).toString();
        _paymentServices.newGiveAmount.text = give.toString();
      });
    } else if (recharge == give) {
      setState(() {
        _paymentServices.pending = false;
        _paymentServices.balance = false;
        _paymentServices.pendingAmount.clear();
        _paymentServices.balanceAmount.clear();
        _paymentServices.pendingDate = null;
        _paymentServices.newGiveAmount.text = give.toString();
      });
    } else {
      setState(() {
        _paymentServices.pending = false;
        _paymentServices.balance = false;
        _paymentServices.pendingDate = null;
        _paymentServices.pendingAmount.clear();
        _paymentServices.balanceAmount.clear();
      });
    }
  }

  void calculateBalance() {
    int balance = widget.snapshot['BALANCE_AMOUNT'] != ''
        ? int.parse(widget.snapshot['BALANCE_AMOUNT'].trim())
        : 0;

    int give = _paymentServices.newGiveAmount.text != ''
        ? int.parse(_paymentServices.newGiveAmount.text.trim())
        : 0;

    if (balance > give) {
      setState(() {
        _paymentServices.pending = false;
        _paymentServices.balance = true;
        _paymentServices.pendingAmount.clear();
        _paymentServices.pendingDate = null;
        _paymentServices.balanceAmount.text = (balance - give).toString();
      });
    } else if (balance < give) {
      setState(() {
        _paymentServices.pending = false;
        _paymentServices.balance = true;
        _paymentServices.balanceAmount.clear();
        _paymentServices.pendingDate = null;
        _paymentServices.pendingAmount.text = (give - balance).toString();
      });
    } else if (balance == give) {
      setState(() {
        _paymentServices.pending = false;
        _paymentServices.balance = false;
        _paymentServices.pendingDate = null;
        _paymentServices.pendingAmount.clear();
        _paymentServices.balanceAmount.clear();
      });
    } else {
      setState(() {});
    }
  }
}
