import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mrs_dth_diary_v1/scr/helpers/paymentService.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/datePicker.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/RoundedLoadingButton.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/SimpleCalc.dart';
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
  bool _showNotes = false;
  bool _useCustomDate = false;

  @override
  void dispose() {
    _paymentServices.clearRecords();
    _paymentServices.btnController.reset();
    super.dispose();
  }

  @override
  void initState() {
    _setDefaultCreateDate();
    super.initState();
  }

  void _setDefaultCreateDate() {
    final now = DateTime.now();
    _paymentServices.createDate = now;
    _paymentServices.createRecordDate.text =
        DateFormat('MM/dd/yyyy hh:mm a').format(now);
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
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(
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

  Widget _buildContentUI(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionCard(
          title: "Payment time",
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Custom date & time",
                      style: TextStyle(
                        fontFamily: 'TamilArima2',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  Switch(
                    value: _useCustomDate,
                    activeThumbColor: kPrimaryColor,
                    onChanged: (val) {
                      setState(() {
                        _useCustomDate = val;
                        if (!val) {
                          _setDefaultCreateDate();
                        }
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _inputField(
                controller: _paymentServices.createRecordDate,
                labelText: "Payment date & time",
                hintText: "Select date & time",
                icon: Icons.event,
                keyboardType: TextInputType.text,
                readOnly: true,
                onTap: _useCustomDate ? _pickDateTime : null,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _sectionCard(
          title: "Payment details",
          child: Column(
            children: [
              _inputField(
                controller: _paymentServices.packageName,
                labelText: "Package name",
                hintText: "பேக்கேஜ் பெயர்",
                icon: Icons.live_tv_rounded,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 10),
              _inputField(
                controller: _paymentServices.rechargeAmount,
                labelText: "Package amount",
                hintText: "பேக்கேஜ் தொகை",
                icon: Icons.mobile_friendly_sharp,
                keyboardType: TextInputType.number,
                onChanged: (_) => _calculateBalance(),
              ),
              const SizedBox(height: 10),
              _inputField(
                controller: _paymentServices.giveAmount,
                labelText: "Paid amount",
                hintText: "கொடுத்த பணம்",
                icon: Icons.monetization_on,
                keyboardType: TextInputType.number,
                onChanged: (_) => _calculateBalance(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _sectionCard(
          title: "நிலை",
          child: Column(
            children: [
              if (_paymentServices.pending)
                _statusTile(
                  title: "தருமதி தொகை",
                  value: _paymentServices.pendingAmount.text,
                  color: Colors.orange.shade700,
                ),
              if (_paymentServices.balance)
                _statusTile(
                  title: "கொடுமதி தொகை",
                  value: _paymentServices.balanceAmount.text,
                  color: Colors.green.shade700,
                ),
              if (_paymentServices.pending) ...[
                const SizedBox(height: 10),
                _inputField(
                  readOnly: true,
                  controller: _paymentServices.pendingDateController,
                  labelText: "தருமதி திகதி",
                  hintText: "தருமதி திகதி",
                  icon: Icons.update,
                  keyboardType: TextInputType.text,
                  onTap: () {
                    _pickDate(
                      onSelected: (val) {
                        _paymentServices.pendingDate = val;
                        _paymentServices.pendingDateController.text =
                            DateFormat('dd-MM-yyyy').format(val);
                      },
                    );
                  },
                ),
              ],
              const SizedBox(height: 10),
              _inputField(
                controller: _paymentServices.expiredDateController,
                labelText: "Package end date",
                hintText: "பேக்கேஜ் முடியும் திகதி",
                icon: Icons.date_range,
                keyboardType: TextInputType.text,
                readOnly: true,
                onTap: () {
                  _pickDate(
                    onSelected: (val) {
                      _paymentServices.expiredDate = val;
                      _paymentServices.expiredDateController.text =
                          DateFormat('dd-MM-yyyy').format(val);
                    },
                  );
                },
              ),
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
      ],
    );
  }

  Future<void> _pickDate({required ValueChanged<DateTime> onSelected}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked == null) return;
    setState(() => onSelected(picked));
  }

  Future<void> _pickDateTime() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return DatePicker(
          onDateTimeChanged: (val) {
            setState(() {
              _paymentServices.createDate = val;
              _paymentServices.createRecordDate.text =
                  DateFormat('MM/dd/yyyy hh:mm a').format(val);
            });
          },
        );
      },
    );
  }

  void _calculateBalance() {
    final rechargeText = _paymentServices.rechargeAmount.text.trim();
    final giveText = _paymentServices.giveAmount.text.trim();
    if (rechargeText.isEmpty || giveText.isEmpty) {
      setState(() {
        _paymentServices.pending = false;
        _paymentServices.balance = false;
        _paymentServices.pendingAmount.clear();
        _paymentServices.balanceAmount.clear();
      });
      return;
    }
    final recharge = _parseAmount(rechargeText);
    final give = _parseAmount(giveText);

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

  int _parseAmount(String value) {
    final cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(cleaned) ?? 0;
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

  Widget _inputField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    VoidCallback? onTap,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      onChanged: onChanged,
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
          btnColor: kPrimaryColor,
          elevation: 2.0,
          label: "Save payment",
          textStyle: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w700,
            fontFamily: 'TamilArima',
            color: Colors.white,
          ),
          buttonPressed: () {
            _savePayment();
          },
        ),
      ),
    );
  }

  Future<void> _savePayment() async {
    if (_useCustomDate) {
      final latestDate =
          await _paymentServices.getLatestCreateAt(userId: widget.userId);
      final selectedDate = _paymentServices.createDate;
      if (latestDate != null && selectedDate != null) {
        if (!selectedDate.isAfter(latestDate)) {
          if (!mounted) return;
          await _showDateError(latestDate);
          _paymentServices.btnController.reset();
          return;
        }
      }
    }
    final success = await _paymentServices.createPaymentRecord(
      userId: widget.userId,
    );
    if (!mounted) return;
    if (success) {
      Navigator.of(context).pop();
    } else {
      _paymentServices.btnController.reset();
    }
  }

  Future<void> _showDateError(DateTime latestDate) async {
    final latestText = DateFormat('MM/dd/yyyy hh:mm a').format(latestDate);
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Invalid date"),
          content: Text(
            "Custom date must be after the last payment record.\n\nLast record: $latestText",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
}
