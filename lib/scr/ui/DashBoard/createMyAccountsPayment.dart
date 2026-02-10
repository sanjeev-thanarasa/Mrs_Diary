import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mrs_dth_diary_v1/scr/helpers/dashBoardService.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/CTextField.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/RoundedLoadingButton.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/SimpleCalc.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/customText.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/styles.dart';

class CreateMyAccountsPayment extends StatefulWidget {
  final String dbId;

  const CreateMyAccountsPayment({super.key, required this.dbId});

  @override
  _CreateMyAccountsPaymentState createState() =>
      _CreateMyAccountsPaymentState();
}

class _CreateMyAccountsPaymentState extends State<CreateMyAccountsPayment> {
  DashBoardService _dashBoardService = DashBoardService();
  bool _showNotes = false;

  @override
  void dispose() {
    _dashBoardService.clearRecords();
    _dashBoardService.btnController.reset();
    super.dispose();
  }

  @override
  void initState() {
    final now = DateTime.now();
    _dashBoardService.createAt = now;
    _dashBoardService.createAtController.text =
        DateFormat('dd-MM-yyyy hh:mm a').format(now);
    super.initState();
  }

  void _onRefresh() {
    _dashBoardService.clearRecords();
    _dashBoardService.btnController.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: white,
        elevation: 0,
        foregroundColor: kIndigoDark,
        title: const Text(
          "New Topup",
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Icon(
                Icons.calculate_rounded,
                size: 30.0,
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
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _buildHeaderCard(context),
          const SizedBox(height: 16),
          _buildContentUI(context),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [kPrimaryColor, kPrimaryColor.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: kPrimaryColor.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.add_card, color: white, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Create New Record",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _dashBoardService.createAtController.text,
                  style: const TextStyle(color: white, fontSize: 13),
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: white,
              side: BorderSide(color: white.withValues(alpha: 0.6)),
            ),
            onPressed: _onRefresh,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text("Reset"),
          ),
        ],
      ),
    );
  }

  Widget _buildContentUI(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 5),
            const Divider(thickness: 1.0),
            CustomTextField(
              controller: _dashBoardService.rechargePlace,
              hintText: "எடுத்த இடம் ???",
              icon: Icons.home,
              keyboardType: TextInputType.text,
            ),
            CustomTextField(
              controller: _dashBoardService.packageAmount,
              hintText: "எடுத்த பணம் ???",
              icon: Icons.attach_money_outlined,
              keyboardType: TextInputType.number,
            ),
            CustomTextField(
              controller: _dashBoardService.paidAmount,
              hintText: "கொடுத்த பணம் ???",
              icon: Icons.money_off_rounded,
              keyboardType: TextInputType.number,
              iconButton: true,
              animatedIconButtonStratIcon: Icons.done,
              animatedIconButtonEndIcon: Icons.done_all_rounded,
              animatedIconButtonOnTap: () {
                int recharge =
                    int.parse(_dashBoardService.packageAmount.text.trim());
                int give = int.parse(_dashBoardService.paidAmount.text.trim());
                if (recharge > give) {
                  setState(() {
                    _dashBoardService.balanceAmount.clear();
                    _dashBoardService.pendingAmount.text =
                        (recharge - give).toString();
                    _dashBoardService.pending = true;
                    _dashBoardService.balance = false;
                  });
                } else if (recharge < give) {
                  setState(() {
                    _dashBoardService.pending = false;
                    _dashBoardService.balance = true;
                    _dashBoardService.pendingAmount.clear();
                    _dashBoardService.balanceAmount.text =
                        (give - recharge).toString();
                  });
                } else if (recharge == give) {
                  setState(() {
                    _dashBoardService.pendingAmount.clear();
                    _dashBoardService.balanceAmount.clear();
                    _dashBoardService.pending = false;
                    _dashBoardService.balance = false;
                  });
                }
              },
            ),
            Visibility(
              visible: _dashBoardService.pending,
              child: CRText(
                color2: Colors.grey,
                size1: 16.0,
                msg1: "நிலுவை (தருமதி) பணம் ",
                msg2: ":  ${_dashBoardService.pendingAmount.text} ",
                color1: Colors.grey,
              ),
            ),
            Visibility(
              visible: _dashBoardService.balance,
              child: CRText(
                color1: Colors.grey,
                size1: 16.0,
                msg1: "கொடுமதி பணம் ",
                msg2: ":  ${_dashBoardService.balanceAmount.text}",
              ),
            ),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    "குறிப்பு",
                    style: TextStyle(
                      fontFamily: 'TamilArima2',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                ),
                Switch(
                  value: _showNotes,
                  activeColor: kPrimaryColor,
                  onChanged: (val) => setState(() => _showNotes = val),
                ),
              ],
            ),
            if (_showNotes)
              CustomTextField(
                controller: _dashBoardService.userNote,
                hintText: "குறிப்பு ",
                icon: Icons.note_add,
                keyboardType: TextInputType.text,
              ),
            const SizedBox(height: 10),
            RoundedLoading(
              btnController: _dashBoardService.btnController,
              paddingLeft: 10.0,
              paddingRight: 10.0,
              paddingTop: 8.0,
              buttonHeight: 40,
              btnColor: Colors.blue,
              buttonPressed: () {
                _dashBoardService.createRecord(dbID: widget.dbId).then((_) {
                  if (mounted) {
                    Navigator.pop(context);
                  }
                });
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
