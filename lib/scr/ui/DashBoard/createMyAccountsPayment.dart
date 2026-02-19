import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mrs_dth_diary_v1/scr/helpers/dashBoardService.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/CTextField.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/RoundedLoadingButton.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/SimpleCalc.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/customText.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/styles.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/responsive.dart';

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
    final rs = context.rs;
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: white,
        elevation: 0,
        foregroundColor: kIndigoDark,
        title: Text(
          "New Topup",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: rs.sp(18),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: rs.rw(8)),
            child: IconButton(
              icon: Icon(
                Icons.calculate_rounded,
                size: rs.r(30),
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
        padding: EdgeInsets.fromLTRB(
          rs.rw(16),
          rs.rh(12),
          rs.rw(16),
          rs.rh(24),
        ),
        children: [
          _buildHeaderCard(context),
          SizedBox(height: rs.rh(16)),
          _buildContentUI(context),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    final rs = context.rs;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(rs.r(16)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(rs.r(18)),
        gradient: LinearGradient(
          colors: [kPrimaryColor, kPrimaryColor.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: kPrimaryColor.withValues(alpha: 0.25),
            blurRadius: rs.r(16),
            offset: Offset(0, rs.rh(8)),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(rs.r(12)),
            decoration: BoxDecoration(
              color: white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(rs.r(14)),
            ),
            child: Icon(Icons.add_card, color: white, size: rs.r(28)),
          ),
          SizedBox(width: rs.rw(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Create New Record",
                  style: TextStyle(
                    fontSize: rs.sp(18),
                    fontWeight: FontWeight.w700,
                    color: white,
                  ),
                ),
                SizedBox(height: rs.rh(6)),
                Text(
                  _dashBoardService.createAtController.text,
                  style: TextStyle(color: white, fontSize: rs.sp(13)),
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: white,
              side: BorderSide(color: white.withValues(alpha: 0.6)),
              padding: EdgeInsets.symmetric(
                horizontal: rs.rw(12),
                vertical: rs.rh(8),
              ),
            ),
            onPressed: _onRefresh,
            icon: Icon(Icons.refresh, size: rs.r(16)),
            label: Text(
              "Reset",
              style: TextStyle(fontSize: rs.sp(12.5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentUI(BuildContext context) {
    final rs = context.rs;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(rs.r(16)),
      ),
      child: Padding(
        padding: EdgeInsets.all(rs.r(16)),
        child: Column(
          children: [
            SizedBox(height: rs.rh(5)),
            Divider(thickness: rs.r(1)),
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
                size1: rs.sp(16),
                msg1: "தருமதி பணம் ",
                msg2: ":  ${_dashBoardService.pendingAmount.text} ",
                color1: Colors.grey,
              ),
            ),
            Visibility(
              visible: _dashBoardService.balance,
              child: CRText(
                color1: Colors.grey,
                size1: rs.sp(16),
                msg1: "கொடுமதி பணம் ",
                msg2: ":  ${_dashBoardService.balanceAmount.text}",
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    "குறிப்பு",
                    style: TextStyle(
                      fontFamily: 'TamilArima2',
                      fontSize: rs.sp(13),
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                ),
                Switch(
                  value: _showNotes,
                  activeThumbColor: kPrimaryColor,
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
            SizedBox(height: rs.rh(10)),
            RoundedLoading(
              btnController: _dashBoardService.btnController,
              paddingLeft: rs.rw(10),
              paddingRight: rs.rw(10),
              paddingTop: rs.rh(8),
              buttonHeight: rs.r(40),
              btnColor: Colors.blue,
              buttonPressed: () {
                _dashBoardService.createRecord(dbID: widget.dbId).then((_) {
                  if (mounted) {
                    Navigator.pop(context);
                  }
                });
              },
            ),
            SizedBox(height: rs.rh(20)),
          ],
        ),
      ),
    );
  }
}
