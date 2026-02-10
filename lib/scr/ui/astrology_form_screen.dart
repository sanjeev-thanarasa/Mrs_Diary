import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mrs_dth_diary_v1/scr/helpers/owner_service.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/responsive.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/styles.dart';

class AstrologyProfile {
  final String id;
  final String name;
  final String address;
  final String birthDay;
  final String rasi;
  final String natchathiram;
  final String paatham;
  final DateTime dob;
  final TimeOfDay birthTime;
  final String paathangal;
  final List<Map<String, String>> chartBoxes;
  final List<Map<String, String>> kattamBoxes;

  const AstrologyProfile({
    required this.id,
    required this.name,
    required this.address,
    required this.birthDay,
    required this.rasi,
    required this.natchathiram,
    required this.paatham,
    required this.dob,
    required this.birthTime,
    required this.paathangal,
    required this.chartBoxes,
    required this.kattamBoxes,
  });

  static AstrologyProfile fromDoc(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final dob = (data['dob'] as Timestamp?)?.toDate() ?? DateTime.now();
    final birthTime = _parseTime((data['birthTime'] ?? '').toString());
    final rawBoxes = (data['chartBoxes'] as List?) ?? [];
    final rawKattam = (data['kattamBoxes'] as List?) ?? [];
    final chartBoxes = rawBoxes
        .whereType<Map>()
        .map(
          (box) => {
            'topLeft': (box['topLeft'] ?? '').toString(),
            'topRight': (box['topRight'] ?? '').toString(),
            'bottomLeft': (box['bottomLeft'] ?? '').toString(),
            'bottomRight': (box['bottomRight'] ?? '').toString(),
            'center': (box['center'] ?? '').toString(),
          },
        )
        .toList();
    final kattamBoxes = rawKattam
        .whereType<Map>()
        .map(
          (box) => {
            'topLeft': (box['topLeft'] ?? '').toString(),
            'topRight': (box['topRight'] ?? '').toString(),
            'bottomLeft': (box['bottomLeft'] ?? '').toString(),
            'bottomRight': (box['bottomRight'] ?? '').toString(),
            'center': (box['center'] ?? '').toString(),
          },
        )
        .toList();
    return AstrologyProfile(
      id: doc.id,
      name: (data['name'] ?? '').toString(),
      address: (data['address'] ?? '').toString(),
      birthDay: (data['birthDay'] ?? '').toString(),
      rasi: (data['rasi'] ?? '').toString(),
      natchathiram: (data['natchathiram'] ?? '').toString(),
      paatham: (data['paatham'] ?? '').toString(),
      dob: dob,
      birthTime: birthTime,
      paathangal: (data['paathangal'] ?? '').toString(),
      chartBoxes: _ensureChartBoxes(chartBoxes),
      kattamBoxes: _ensureChartBoxes(kattamBoxes),
    );
  }

  static List<Map<String, String>> defaultChartBoxes() {
    return List.generate(12, (_) => _emptyBox());
  }

  static List<Map<String, String>> defaultKattamBoxes() {
    return List.generate(12, (_) => _emptyBox());
  }

  static List<Map<String, String>> _ensureChartBoxes(
    List<Map<String, String>> boxes,
  ) {
    if (boxes.length >= 12) {
      return boxes.take(12).toList();
    }
    final filled = List<Map<String, String>>.from(boxes);
    while (filled.length < 12) {
      filled.add(_emptyBox());
    }
    return filled;
  }

  static Map<String, String> _emptyBox() {
    return const {
      'topLeft': '',
      'topRight': '',
      'bottomLeft': '',
      'bottomRight': '',
      'center': '',
    };
  }

  static TimeOfDay _parseTime(String value) {
    final parts = value.split(':');
    if (parts.length != 2) {
      return const TimeOfDay(hour: 0, minute: 0);
    }
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    return TimeOfDay(hour: hour, minute: minute);
  }
}

class AstrologyFormScreen extends StatefulWidget {
  final AstrologyProfile? profile;

  const AstrologyFormScreen({super.key, this.profile});

  @override
  State<AstrologyFormScreen> createState() => _AstrologyFormScreenState();
}

class _AstrologyFormScreenState extends State<AstrologyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();

  String? _birthDay;
  String? _selectedRasi;
  String? _selectedNatchathiram;
  String? _selectedPaatham;
  DateTime? _dob;
  TimeOfDay? _birthTime;

  static const List<String> _weekDays = [
    'திங்கள்',
    'செவ்வாய்',
    'புதன்',
    'வியாழன்',
    'வெள்ளி',
    'சனி',
    'ஞாயிறு',
  ];

  static const List<String> _rasiList = [
    'மேஷம்',
    'ரிஷபம்',
    'மிதுனம்',
    'கடகம்',
    'சிம்மம்',
    'கன்னி',
    'துலாம்',
    'விருச்சிகம்',
    'தனுசு',
    'மகரம்',
    'கும்பம்',
    'மீனம்',
  ];

  static const Map<String, List<String>> _natchathiramByRasi = {
    'மேஷம்': ['அசுவினி', 'பரணி', 'கார்த்திகை'],
    'ரிஷபம்': ['கார்த்திகை', 'ரோகிணி', 'மிருகசீரிஷம்'],
    'மிதுனம்': ['மிருகசீரிஷம்', 'திருவாதிரை', 'புனர்பூசம்'],
    'கடகம்': ['புனர்பூசம்', 'பூசம்', 'ஆயில்யம்'],
    'சிம்மம்': ['மகம்', 'பூரம்', 'உத்திரம்'],
    'கன்னி': ['உத்திரம்', 'ஹஸ்தம்', 'சித்திரை'],
    'துலாம்': ['சித்திரை', 'சுவாதி', 'விசாகம்'],
    'விருச்சிகம்': ['விசாகம்', 'அனுஷம்', 'கேட்டை'],
    'தனுசு': ['மூலம்', 'பூராடம்', 'உத்திராடம்'],
    'மகரம்': ['உத்திராடம்', 'திருவோணம்', 'அவிட்டம்'],
    'கும்பம்': ['அவிட்டம்', 'சதயம்', 'பூரட்டாதி'],
    'மீனம்': ['பூரட்டாதி', 'உத்திரட்டாதி', 'ரேவதி'],
  };

  static const List<String> _paathamList = [
    '1ம் பாதம்',
    '2ம் பாதம்',
    '3ம் பாதம்',
    '4ம் பாதம்',
  ];

  bool get _isEditing => widget.profile != null;

  @override
  void initState() {
    super.initState();
    final profile = widget.profile;
    if (profile != null) {
      _nameController.text = profile.name;
      _addressController.text = profile.address;
      _birthDay = profile.birthDay.isEmpty ? null : profile.birthDay;
      _selectedRasi = profile.rasi.isEmpty ? null : profile.rasi;
      _selectedNatchathiram =
          profile.natchathiram.isEmpty ? null : profile.natchathiram;
      _selectedPaatham = profile.paatham.isEmpty ? null : profile.paatham;
      _dob = profile.dob;
      _birthTime = profile.birthTime;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        Navigator.of(context).pop(false);
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: white,
          elevation: 0,
          foregroundColor: kIndigoDark,
          title: Text(
            _isEditing ? 'Edit Astrology Profile' : 'Astrology Profile',
            style: TextStyle(
              fontSize: rs.sp(22),
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.all(rs.r(12)),
              children: [
                _buildSectionCard(
                  title: 'ஜாதகக் காரரின் விவரங்கள்',
                  icon: Icons.person_outline,
                  children: [
                    _buildTextField(
                      controller: _nameController,
                      label: 'பெயர்',
                      hint: 'முழுப் பெயர்',
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Enter a name'
                              : null,
                    ),
                    SizedBox(height: rs.rh(10)),
                    _buildTextField(
                      controller: _addressController,
                      label: 'பிறந்த இடம்',
                      hint: 'பிறந்த இடம்',
                      maxLines: 2,
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Enter an address'
                              : null,
                    ),
                    SizedBox(height: rs.rh(10)),
                    _buildDropdownField(
                      label: 'பிறந்த நாள்',
                      hint: 'நாள் தேர்வு செய்யவும்',
                      value: _birthDay,
                      items: _weekDays,
                      onChanged: (value) => setState(() => _birthDay = value),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Select a day'
                          : null,
                    ),
                    SizedBox(height: rs.rh(10)),
                    _buildDropdownField(
                      label: 'ராசி',
                      hint: 'ராசி தேர்வு செய்யவும்',
                      value: _selectedRasi,
                      items: _rasiList,
                      onChanged: (value) {
                        setState(() {
                          _selectedRasi = value;
                          _selectedNatchathiram = null;
                          _selectedPaatham = null;
                        });
                      },
                      validator: (value) => value == null || value.isEmpty
                          ? 'Select a rasi'
                          : null,
                    ),
                    SizedBox(height: rs.rh(10)),
                    _buildDropdownField(
                      label: 'நட்சத்திரம்',
                      hint: 'நட்சத்திரம் தேர்வு செய்யவும்',
                      value: _selectedNatchathiram,
                      items: _selectedRasi == null
                          ? const []
                          : _natchathiramByRasi[_selectedRasi!] ?? const [],
                      onChanged: _selectedRasi == null
                          ? null
                          : (value) =>
                              setState(() => _selectedNatchathiram = value),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Select a natchathiram'
                          : null,
                    ),
                    SizedBox(height: rs.rh(12)),
                    _buildDropdownField(
                      label: 'பாதம்',
                      hint: 'பாதம் தேர்வு செய்யவும்',
                      value: _selectedPaatham,
                      items: _paathamList,
                      onChanged: (value) =>
                          setState(() => _selectedPaatham = value),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Select a paatham'
                          : null,
                    ),
                  ],
                ),
                SizedBox(height: rs.rh(12)),
                _buildSectionCard(
                  title: 'பிறந்த திகதி மற்றும் நேரம்',
                  icon: Icons.cake_outlined,
                  children: [
                    _buildPickerTile(
                      title: 'பிறந்த திகதி',
                      value: _dob == null
                          ? 'தேதி தேர்வு செய்யவும்'
                          : _formatDate(_dob!),
                      icon: Icons.calendar_today_outlined,
                      onTap: () => _pickDate((date) => _dob = date),
                    ),
                    SizedBox(height: rs.rh(8)),
                    _buildPickerTile(
                      title: 'பிறந்த நேரம்',
                      value: _birthTime == null
                          ? 'நேரம் தேர்வு செய்யவும்'
                          : _formatTime(_birthTime!),
                      icon: Icons.access_time_rounded,
                      onTap: () => _pickTime((time) => _birthTime = time),
                    ),
                  ],
                ),
                SizedBox(height: rs.rh(16)),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _saveProfile,
                    child: Text(
                      'Save',
                      style: TextStyle(fontSize: rs.sp(16)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final rs = context.rs;
    return Container(
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(rs.r(16)),
        border: Border.all(color: kPrimaryLightColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: kPrimaryColor.withValues(alpha: 0.08),
            blurRadius: rs.r(10),
            offset: Offset(0, rs.rh(4)),
          ),
        ],
      ),
      padding: EdgeInsets.all(rs.r(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(rs.r(8)),
                decoration: BoxDecoration(
                  color: kPrimaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(rs.r(10)),
                ),
                child: Icon(icon, color: kPrimaryColor, size: rs.r(20)),
              ),
              SizedBox(width: rs.rw(10)),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: "TamilArima",
                    fontSize: rs.sp(15),
                    fontWeight: FontWeight.w700,
                    color: kIndigoDark,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: rs.rh(10)),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    FormFieldValidator<String>? validator,
    int maxLines = 1,
  }) {
    final rs = context.rs;
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: TextStyle(
        color: kIndigoDark,
        fontSize: rs.sp(14.5),
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: kPrimaryLightColor.withValues(alpha: 0.18),
        labelStyle: TextStyle(
          color: kIndigoDark,
          fontSize: rs.sp(13.5),
          fontFamily: "TamilArima",
        ),
        hintStyle: TextStyle(
          fontFamily: "TamilArima",
          fontSize: rs.sp(12.5),
          color: kIndigoLight.withValues(alpha: 0.45),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(rs.r(12)),
          borderSide: BorderSide(color: kPrimaryLightColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(rs.r(12)),
          borderSide: BorderSide(color: kPrimaryLightColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(rs.r(12)),
          borderSide: const BorderSide(color: kPrimaryColor, width: 1.4),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String hint,
    required List<String> items,
    required String? value,
    required ValueChanged<String?>? onChanged,
    FormFieldValidator<String>? validator,
  }) {
    final rs = context.rs;
    return DropdownButtonFormField<String>(
      value: value,
      style: TextStyle(
        fontFamily: "TamilArima",
        fontSize: rs.sp(13.5),
        fontWeight: FontWeight.w600,
        color: kIndigoDark,
      ),
      items: items
          .map(
            (item) => DropdownMenuItem(
              value: item,
              child: Text(
                item,
                style: TextStyle(
                  fontFamily: "TamilArima",
                  fontSize: rs.sp(13.5),
                  fontWeight: FontWeight.w600,
                  color: kIndigoDark,
                ),
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
      validator: validator,
      isExpanded: true,
      icon: Icon(Icons.keyboard_arrow_down_rounded, color: kIndigoLight),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: kPrimaryLightColor.withValues(alpha: 0.18),
        labelStyle: TextStyle(
          color: kIndigoDark,
          fontSize: rs.sp(15.5),
          fontFamily: "TamilArima",
        ),
        hintStyle: TextStyle(
          fontSize: rs.sp(10.5),
          fontFamily: "TamilArima",
          color: kIndigoLight.withValues(alpha: 0.45),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(rs.r(12)),
          borderSide: BorderSide(color: kPrimaryLightColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(rs.r(12)),
          borderSide: BorderSide(color: kPrimaryLightColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(rs.r(12)),
          borderSide: const BorderSide(color: kPrimaryColor, width: 1.4),
        ),
      ),
    );
  }

  Widget _buildPickerTile({
    required String title,
    required String value,
    required IconData icon,
    required Future<void> Function() onTap,
  }) {
    final rs = context.rs;
    return InkWell(
      onTap: () async {
        await onTap();
        if (!mounted) return;
        setState(() {});
      },
      borderRadius: BorderRadius.circular(rs.r(12)),
      child: Container(
        padding: EdgeInsets.all(rs.r(12)),
        decoration: BoxDecoration(
          color: kPrimaryLightColor.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(rs.r(12)),
          border: Border.all(color: kPrimaryLightColor),
        ),
        child: Row(
          children: [
            Icon(icon, color: kPrimaryColor, size: rs.r(20)),
            SizedBox(width: rs.rw(10)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: rs.sp(12.5),
                      fontWeight: FontWeight.w600,
                      color: kIndigoDark,
                    ),
                  ),
                  SizedBox(height: rs.rh(4)),
                  Text(
                    value,
                    style: TextStyle(
                      fontFamily: "TamilArima",
                      fontSize: rs.sp(14),
                      fontWeight: FontWeight.w600,
                      color:
                          value.contains('தேர்வு') ? kIndigoLight : kIndigoDark,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: kIndigoLight, size: rs.r(20)),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate(ValueChanged<DateTime> onSelected) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(1950),
      lastDate: now.add(const Duration(days: 365 * 10)),
    );
    if (picked == null) return;
    onSelected(picked);
  }

  Future<void> _pickTime(ValueChanged<TimeOfDay> onSelected) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked == null) return;
    onSelected(picked);
  }

  String _formatDate(DateTime value) {
    return '${value.day.toString().padLeft(2, '0')}/'
        '${value.month.toString().padLeft(2, '0')}/'
        '${value.year}';
  }

  String _formatTime(TimeOfDay value) {
    return MaterialLocalizations.of(context).formatTimeOfDay(value);
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_birthDay == null || _birthDay!.isEmpty) {
      _showMessage('Select birth day.');
      return;
    }
    if (_selectedRasi == null || _selectedRasi!.isEmpty) {
      _showMessage('Select rasi.');
      return;
    }
    if (_selectedNatchathiram == null || _selectedNatchathiram!.isEmpty) {
      _showMessage('Select natchathiram.');
      return;
    }
    if (_selectedPaatham == null || _selectedPaatham!.isEmpty) {
      _showMessage('Select paatham.');
      return;
    }
    if (_dob == null || _birthTime == null) {
      _showMessage('Select date of birth and birth time.');
      return;
    }
    final profiles = FirebaseFirestore.instance.collection('AstrologyProfiles');
    if (_isEditing) {
      await profiles.doc(widget.profile!.id).update({
        'name': _nameController.text.trim(),
        'address': _addressController.text.trim(),
        'birthDay': _birthDay,
        'rasi': _selectedRasi,
        'natchathiram': _selectedNatchathiram,
        'paatham': _selectedPaatham,
        'dob': Timestamp.fromDate(_dob!),
        'birthTime': _formatTime24(_birthTime!),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      await profiles.add({
        'ownerId': requireOwnerId(),
        'name': _nameController.text.trim(),
        'address': _addressController.text.trim(),
        'birthDay': _birthDay,
        'rasi': _selectedRasi,
        'natchathiram': _selectedNatchathiram,
        'paatham': _selectedPaatham,
        'paathangal': '',
        'dob': Timestamp.fromDate(_dob!),
        'birthTime': _formatTime24(_birthTime!),
        'chartBoxes': AstrologyProfile.defaultChartBoxes(),
        'kattamBoxes': AstrologyProfile.defaultKattamBoxes(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  String _formatTime24(TimeOfDay value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
