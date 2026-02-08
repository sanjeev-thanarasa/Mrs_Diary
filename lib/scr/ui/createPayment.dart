import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mrs_dth_diary_v1/scr/helpers/paymentService.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/CTextField.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/RoundedLoadingButton.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/SimpleCalc.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/datePicker.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/styles.dart';

class CreatePayment extends StatefulWidget {
  final String userId;

  const CreatePayment({
    super.key,
    required this.userId,
  });

  @override
  _CreatePaymentState createState() => _CreatePaymentState();
}

class _CreatePaymentState extends State<CreatePayment> {
  final PaymentServices _paymentServices = PaymentServices();

  @override
  void dispose() {
    _paymentServices.clearRecords();
    _paymentServices.btnController.reset();
    super.dispose();
  }

  @override
  void initState() {
    _paymentServices.createRecordDate.text =
        DateFormat('MM/dd/yyyy hh:mm a').format(DateTime.now());
    _paymentServices.createDate = DateTime.now();
    super.initState();
  }

  void _onRefresh() {
    _paymentServices.clearRecords();
    _paymentServices.btnController.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text(
          "Create Payment",
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
          child: _buildContentUI(context),
        ),
      ),
    );
  }

  bool noteVisible = false;

  Widget _buildContentUI(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeaderCard(),
        const SizedBox(height: 12),
        _sectionCard(
          title: "Payment details",
          child: Column(
            children: [
              _fieldLabel("Record date"),
              CustomTextField(
                controller: _paymentServices.createRecordDate,
                hintText: "Select date",
                icon: Icons.date_range,
                keyboardType: TextInputType.text,
                readOnly: true,
                iconButton: true,
                animatedIconButtonStratIcon: Icons.date_range,
                animatedIconButtonEndIcon: Icons.date_range_outlined,
                animatedIconButtonOnTap: () {
                  showCupertinoModalPopup(
                      context: context,
                      builder: (_) => DatePicker(
                            onDateTimeChanged: (val) {
                              setState(() {
                                _paymentServices.createDate = val;
                                _paymentServices.createRecordDate.text =
                                    DateFormat('MM/dd/yyyy hh:mm a')
                                        .format(val);
                              });
                            },
                          ));
                },
              ),
              const SizedBox(height: 10),
              _fieldLabel("Package name"),
              CustomTextField(
                controller: _paymentServices.packageName,
                hintText: "Recharge Package Name",
                icon: Icons.live_tv_rounded,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 10),
              _fieldLabel("Recharge amount"),
              CustomTextField(
                controller: _paymentServices.rechargeAmount,
                hintText: "Recharge செய்த தொகை",
                icon: Icons.mobile_friendly_sharp,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              _fieldLabel("Paid amount"),
              CustomTextField(
                controller: _paymentServices.giveAmount,
                hintText: "தந்த பணம்",
                icon: Icons.monetization_on,
                keyboardType: TextInputType.number,
                animatedIconButtonStratIcon: Icons.done,
                animatedIconButtonEndIcon: Icons.done_all_rounded,
                iconButton: true,
                animatedIconButtonOnTap: _calculateBalance,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _sectionCard(
          title: "Status",
          child: Column(
            children: [
              if (_paymentServices.pending)
                _statusTile(
                  title: "தருமதி பணம்",
                  value: _paymentServices.pendingAmount.text,
                  color: Colors.orange.shade700,
                ),
              if (_paymentServices.balance)
                _statusTile(
                  title: "கொடுமதி பணம்",
                  value: _paymentServices.balanceAmount.text,
                  color: Colors.green.shade700,
                ),
              if (_paymentServices.pending) ...[
                const SizedBox(height: 10),
                _fieldLabel("Pending date"),
                CustomTextField(
                  readOnly: true,
                  controller: _paymentServices.pendingDateController,
                  hintText: "தருமதி திகதி",
                  icon: Icons.update,
                  keyboardType: TextInputType.text,
                  iconButton: true,
                  animatedIconButtonStratIcon: Icons.date_range,
                  animatedIconButtonOnTap: () {
                    showCupertinoModalPopup(
                        context: context,
                        builder: (_) => DatePicker(
                              onDateTimeChanged: (val) {
                                setState(() {
                                  _paymentServices.pendingDate = val;
                                  _paymentServices.pendingDateController.text =
                                      DateFormat('MM/dd/yyyy hh:mm a')
                                          .format(val);
                                });
                              },
                            ));
                  },
                ),
              ],
              const SizedBox(height: 10),
              _fieldLabel("Expired date"),
              CustomTextField(
                controller: _paymentServices.expiredDateController,
                hintText: "முடியும் திகதி",
                icon: Icons.date_range,
                keyboardType: TextInputType.text,
                readOnly: true,
                iconButton: true,
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
                                    DateFormat('MM/dd/yyyy hh:mm a')
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
              _fieldLabel("Note"),
              CustomTextField(
                controller: _paymentServices.userNote,
                hintText: "குறிப்பு",
                icon: Icons.note_add,
                keyboardType: TextInputType.text,
                iconButton: true,
                animatedIconButtonStratIcon: Icons.add_circle_outline_rounded,
                animatedIconButtonEndIcon:
                    Icons.indeterminate_check_box_outlined,
                animatedIconButtonOnTap: () =>
                    setState(() => noteVisible = !noteVisible),
              ),
              if (noteVisible) ...[
                const SizedBox(height: 10),
                _fieldLabel("Note 2"),
                CustomTextField(
                  controller: _paymentServices.userNote2,
                  hintText: "குறிப்பு 2 ",
                  icon: Icons.note_add_outlined,
                  keyboardType: TextInputType.text,
                ),
              ]
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildSaveButton(context),
      ],
    );
  }

  void _calculateBalance() {
    final rechargeText = _paymentServices.rechargeAmount.text.trim();
    final giveText = _paymentServices.giveAmount.text.trim();
    if (rechargeText.isEmpty || giveText.isEmpty) {
      return;
    }
    final recharge = int.tryParse(rechargeText) ?? 0;
    final give = int.tryParse(giveText) ?? 0;

    if (recharge > give) {
      setState(() {
        _paymentServices.pending = true;
        _paymentServices.balance = false;
        _paymentServices.balanceAmount.clear();
        _paymentServices.pendingAmount.text = (recharge - give).toString();
      });
    } else if (recharge < give) {
      setState(() {
        _paymentServices.pending = false;
        _paymentServices.balance = true;
        _paymentServices.pendingAmount.clear();
        _paymentServices.balanceAmount.text = (give - recharge).toString();
      });
    } else {
      setState(() {
        _paymentServices.pending = false;
        _paymentServices.pendingAmount.clear();
        _paymentServices.balanceAmount.clear();
      });
    }
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: kPrimaryColor.withValues(alpha: 0.12),
            child: const Icon(Icons.payments_rounded, color: kPrimaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "New payment",
                  style: TextStyle(
                    fontFamily: 'TamilArima',
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Create payment record",
                  style: TextStyle(
                    fontFamily: 'TamilArima2',
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _onRefresh,
            icon: const Icon(Icons.refresh_rounded),
          )
        ],
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'TamilArima',
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'TamilArima2',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.black54,
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
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'TamilArima2',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Text(
            value.isEmpty ? "0" : value,
            style: TextStyle(
              fontFamily: 'TamilArima',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: RoundedLoading(
          btnController: _paymentServices.btnController,
          paddingLeft: 10.0,
          paddingRight: 10.0,
          paddingTop: 8.0,
          buttonHeight: 44,
          btnColor: kBlueLight,
          elevation: 2.0,
          label: "Save payment",
          textStyle: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w700,
            fontFamily: 'TamilArima',
            color: Colors.white,
          ),
          buttonPressed: () {
            _paymentServices.createPaymentRecord(userId: widget.userId);
          },
        ),
      ),
    );
  }
}
