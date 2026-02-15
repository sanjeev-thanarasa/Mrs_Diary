import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mrs_dth_diary_v1/scr/helpers/paymentService.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/RoundedLoadingButton.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/SimpleCalc.dart';
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
  DateTime? _initialPendingDate;

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
    _initialPendingDate = _paymentServices.pendingDate;
    _paymentServices.pendingDateController.text =
        _paymentServices.pendingDate != null
            ? DateFormat('dd-MM-yyyy').format(_paymentServices.pendingDate!)
            : '';
    _paymentServices.balanceAmount.text = widget.snapshot['BALANCE_AMOUNT'];
    _paymentServices.userNote.text = widget.snapshot['USER_NOTE'];
    _paymentServices.userNote2.text = widget.snapshot['USER_NOTE2'];
    _showNotes = _paymentServices.userNote.text.trim().isNotEmpty;
  }

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
          "Add new payment record",
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

  bool _showNotes = false;

  Widget _buildContentUI(BuildContext context, bool equal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeaderCard(equal),
        const SizedBox(height: 12),
        _sectionCard(
          title: "புதிதாக தந்த பணம்",
          child: Column(
            children: [
              if (!equal)
                _inputField(
                  controller: _paymentServices.newGiveAmount,
                  labelText: "New paid amount",
                  hintText: widget.snapshot['BALANCE_AMOUNT'] != ''
                      ? "நீங்கள் கொடுத்த பணம்"
                      : "புதிதாக தந்த பணம்",
                  icon: Icons.monetization_on,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => _recalculateFromAdditional(),
                ),
              if (_paymentServices.pending &&
                  _paymentServices.newGiveAmount.text.trim().isNotEmpty) ...[
                const SizedBox(height: 10),
                _inputField(
                  readOnly: true,
                  controller: _paymentServices.pendingDateController,
                  labelText: "நிலுவை திகதி",
                  hintText: "நிலுவை திகதி",
                  icon: Icons.update,
                  keyboardType: TextInputType.text,
                  onTap: () {
                    _pickDate(
                      initialDate: _paymentServices.pendingDate,
                      onSelected: (val) {
                        _paymentServices.pendingDate = val;
                        _paymentServices.pendingDateController.text =
                            DateFormat('dd-MM-yyyy').format(val);
                      },
                    );
                  },
                ),
              ],
              if (_paymentServices.pending) ...[
                const SizedBox(height: 10),
                _statusTile(
                  title: "புதிய நிலுவை தொகை",
                  value: _paymentServices.pendingAmount.text,
                  color: Colors.blueGrey,
                ),
              ],
              if (_paymentServices.balance) ...[
                const SizedBox(height: 10),
                _statusTile(
                  title: "புதிய கொடுமதி தொகை",
                  value: _paymentServices.balanceAmount.text,
                  color: Colors.blueGrey,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        _sectionCard(
          title: "Note",
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Add note",
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
                    activeThumbColor: kPrimaryColor,
                    onChanged: (val) => setState(() => _showNotes = val),
                  ),
                ],
              ),
              if (_showNotes) ...[
                const SizedBox(height: 10),
                _inputField(
                  controller: _paymentServices.userNote,
                  labelText: "Note",
                  hintText: "குறிப்பு",
                  icon: Icons.note_add,
                  keyboardType: TextInputType.text,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildSaveButton(context),
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
                color: kIndigoDark,
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
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                _infoChip(
                  label: 'ரீசார்ஜ் தொகை',
                  value: widget.snapshot['AMOUNT'],
                  color: Colors.green.shade700,
                ),
                const SizedBox(width: 8),
                _infoChip(
                  label: 'செலுத்தியது',
                  value: widget.snapshot['PAID_AMOUNT'],
                  color: Colors.orange.shade700,
                ),
                if (!equal) ...[
                  const SizedBox(width: 8),
                  _infoChip(
                    label: widget.snapshot['BALANCE_AMOUNT'] != ''
                        ? 'கொடுமதி'
                        : 'நிலுவை',
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
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

  Widget _inputField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    ValueChanged<String>? onChanged,
    VoidCallback? onTap,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      onChanged: onChanged,
      onTap: onTap,
      keyboardType: keyboardType,
      style: const TextStyle(
        fontFamily: 'TamilArima',
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        labelText: labelText,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        hintText: hintText,
        hintStyle: const TextStyle(
          fontFamily: 'TamilArima2',
          color: Colors.black45,
        ),
        prefixIcon: Icon(icon, color: Colors.blueGrey.shade600),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: kPrimaryColor, width: 1.2),
          borderRadius: BorderRadius.circular(12),
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
          btnColor: kPrimaryColor,
          elevation: 2.0,
          label: "Save payment",
          textStyle: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w700,
            fontFamily: 'TamilArima',
            color: Colors.white,
          ),
          buttonPressed: () async {
            if (_paymentServices.newGiveAmount.text.trim().isNotEmpty) {
              _recalculateFromAdditional();
            }
            _paymentServices.createDate = DateTime.now();
            await _paymentServices.updatePaymentRecord(
              snapshot: widget.snapshot,
            );
            if (!mounted) return;
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  Future<void> _pickDate({
    required ValueChanged<DateTime> onSelected,
    DateTime? initialDate,
  }) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked == null) return;
    setState(() => onSelected(picked));
  }

  void _recalculateFromAdditional() {
    final additional = _paymentServices.newGiveAmount.text.trim().isNotEmpty
        ? int.tryParse(_paymentServices.newGiveAmount.text.trim()) ?? 0
        : 0;
    final totalPaid = paidAmount + additional;

    if (recharge > totalPaid) {
      setState(() {
        _paymentServices.pending = true;
        _paymentServices.balance = false;
        _paymentServices.balanceAmount.clear();
        _paymentServices.pendingAmount.text = (recharge - totalPaid).toString();
        if (_paymentServices.pendingDate == null &&
            _initialPendingDate != null) {
          _paymentServices.pendingDate = _initialPendingDate;
          _paymentServices.pendingDateController.text =
              DateFormat('dd-MM-yyyy').format(_initialPendingDate!);
        }
      });
    } else if (recharge < totalPaid) {
      setState(() {
        _paymentServices.pending = false;
        _paymentServices.balance = true;
        _paymentServices.pendingAmount.clear();
        _paymentServices.pendingDate = null;
        _paymentServices.pendingDateController.clear();
        _paymentServices.balanceAmount.text = (totalPaid - recharge).toString();
      });
    } else {
      setState(() {
        _paymentServices.pending = false;
        _paymentServices.balance = false;
        _paymentServices.pendingAmount.clear();
        _paymentServices.balanceAmount.clear();
        _paymentServices.pendingDate = null;
        _paymentServices.pendingDateController.clear();
      });
    }
  }
}
