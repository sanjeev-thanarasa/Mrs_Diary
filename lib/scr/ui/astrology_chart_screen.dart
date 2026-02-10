import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mrs_dth_diary_v1/scr/ui/astrology_form_screen.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/responsive.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/styles.dart';

class AstrologyChartScreen extends StatefulWidget {
  const AstrologyChartScreen({super.key, required this.profile});

  final AstrologyProfile profile;

  @override
  State<AstrologyChartScreen> createState() => _AstrologyChartScreenState();
}

class _AstrologyChartScreenState extends State<AstrologyChartScreen> {
  late final List<_ChartBoxData> _kattamBoxes;
  Map<String, String> _planetDegrees = {};

  static const Map<String, String> _kattamShortNames = {
    'லக்னம்': 'லக்',
    'சூரியன்': 'சூரி',
    'சந்திரன்': 'சந்',
    'செவ்வாய்': 'செவ்',
    'புதன்': 'புத',
    'குரு': 'குரு',
    'சுக்கிரன்': 'சுக்',
    'சனி': 'சனி',
    'ராகு': 'ராகு',
    'கேது': 'கேது',
    'மாந்தி (குளிகன்)': 'மாந்',
    'யமகண்டம்': 'யம',
    'அர்த்தப்ரஹரன்': 'அர்ப்',
    'தூர்முகம்': 'தூர்',
    'காலன்': 'கால',
    'ம்ருத்யு': 'ம்ரு',
    'யுரேனஸ்': 'யுரே',
    'நெப்டியூன்': 'நெப்',
    'புளூட்டோ': 'ப்ளூ',
  };

  static const Map<String, Color> _kattamColors = {
    'லக்': Color(0xFFE6B800),
    'சூரி': Color(0xFFFF8C00),
    'சந்': Color(0xFF455A64),
    'செவ்': Color(0xFFFF0000),
    'புத': Color(0xFF008000),
    'குரு': Color(0xFFFFC107),
    'சுக்': Color(0xFFC2185B),
    'சனி': Color(0xFF2F4F4F),
    'ராகு': Color(0xFF4B0082),
    'கேது': Color(0xFF8B4513),
    'மாந்': Color(0xFF1C1C1C),
    'யம': Color(0xFF00008B),
    'அர்ப்': Color(0xFF5D4037),
    'தூர்': Color(0xFF555555),
    'கால': Color(0xFF000000),
    'ம்ரு': Color(0xFF8B0000),
    'யுரே': Color(0xFF00CED1),
    'நெப்': Color(0xFF0000FF),
    'ப்ளூ': Color(0xFF6A0DAD),
  };

  static const List<Map<String, String>> _planetFields = [
    {'key': 'lagnam', 'label': 'லக்னம்'},
    {'key': 'sun', 'label': 'சூரியன்'},
    {'key': 'moon', 'label': 'சந்திரன்'},
    {'key': 'mars', 'label': 'செவ்வாய்'},
    {'key': 'mercury', 'label': 'புதன்'},
    {'key': 'jupiter', 'label': 'குரு'},
    {'key': 'venus', 'label': 'சுக்கிரன்'},
    {'key': 'saturn', 'label': 'சனி'},
    {'key': 'rahu', 'label': 'ராகு'},
    {'key': 'ketu', 'label': 'கேது'},
  ];

  static const List<int> _kattamOrder = [
    12,
    1,
    2,
    3,
    11,
    4,
    10,
    5,
    9,
    8,
    7,
    6,
  ];

  @override
  void initState() {
    super.initState();
    _kattamBoxes = _normalizeBoxes(widget.profile.kattamBoxes);
    _loadPlanetDegrees();
  }

  Future<void> _loadPlanetDegrees() async {
    final doc = await FirebaseFirestore.instance
        .collection('AstrologyProfiles')
        .doc(widget.profile.id)
        .get();
    if (!doc.exists) return;
    final data = doc.data();
    if (data == null || !data.containsKey('planetDegrees')) return;
    final raw = data['planetDegrees'];
    if (raw is! Map) return;
    setState(() {
      _planetDegrees = raw.map(
        (key, value) => MapEntry(key.toString(), (value ?? '').toString()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: white,
        elevation: 0,
        foregroundColor: kIndigoDark,
        title: Text(
          'ஜாதகக் காரரின் முழு விவரங்கள்',
          style: TextStyle(
            fontSize: rs.sp(16),
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(rs.r(16)),
          children: [
            _buildHeader(),
            SizedBox(height: rs.rh(16)),
            _buildJathagaKattaSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final rs = context.rs;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(rs.r(14)),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderRow('பெயர்', widget.profile.name),
          _buildHeaderRow('பிறந்த இடம்', widget.profile.address),
          _buildHeaderRow('பிறந்த நாள்', widget.profile.birthDay),
          _buildHeaderRow('ராசி', widget.profile.rasi),
          _buildHeaderRow('நட்சத்திரம்', widget.profile.natchathiram),
          _buildHeaderRow('பாதம்', widget.profile.paatham),
          _buildHeaderRow('பிறந்த திகதி', _formatDate(widget.profile.dob)),
          _buildHeaderRow(
            'பிறந்த நேரம்',
            _formatTime(widget.profile.birthTime),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderRow(String label, String value) {
    final rs = context.rs;
    final display = value.trim().isEmpty ? '-' : value;
    return Padding(
      padding: EdgeInsets.only(bottom: rs.rh(6)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: rs.rw(110),
            child: Text(
              '$label :',
              style: TextStyle(
                fontFamily: 'TamilArima',
                fontSize: rs.sp(13),
                fontWeight: FontWeight.w700,
                color: kIndigoDark,
              ),
            ),
          ),
          Expanded(
            child: Text(
              display,
              style: TextStyle(
                fontFamily: 'TamilArima',
                fontSize: rs.sp(14),
                color: kIndigoLight.withValues(alpha: 0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterPlanetSummary() {
    final rs = context.rs;
    final shortLabels = <String, String>{
      'sun': 'சூரி',
      'moon': 'சந்',
      'mars': 'செவ்',
      'mercury': 'புத',
      'jupiter': 'குரு',
      'venus': 'சுக்',
      'saturn': 'சனி',
      'rahu': 'ராகு',
      'ketu': 'கேது',
      'lagnam': 'லக்',
    };

    final values = <String, String?>{
      'lagnam': _planetDegrees['lagnam'],
      'jupiter': _planetDegrees['jupiter'],
      'sun': _planetDegrees['sun'],
      'venus': _planetDegrees['venus'],
      'moon': _planetDegrees['moon'],
      'saturn': _planetDegrees['saturn'],
      'mars': _planetDegrees['mars'],
      'rahu': _planetDegrees['rahu'],
      'mercury': _planetDegrees['mercury'],
      'ketu': _planetDegrees['ketu'],
    };

    final allEmpty =
        values.values.every((value) => value == null || value.trim().isEmpty);
    if (allEmpty) {
      return Center(
        child: Text(
          'தகவல் இல்லை',
          style: TextStyle(
            fontFamily: 'TamilArima',
            fontSize: rs.sp(11.5),
            fontWeight: FontWeight.w600,
            color: kIndigoLight.withValues(alpha: 0.8),
          ),
        ),
      );
    }

    String formatEntry(String key) {
      final label = shortLabels[key] ?? key;
      final value = values[key];
      final display = value == null || value.trim().isEmpty ? '--' : value;
      return '$label-$display';
    }

    final rows = [
      ['lagnam', 'jupiter'],
      ['sun', 'venus'],
      ['moon', 'saturn'],
      ['mars', 'rahu'],
      ['mercury', 'ketu'],
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: SizedBox(
            height: constraints.maxHeight,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: rows
                    .map(
                      (pair) => Padding(
                        padding: EdgeInsets.only(bottom: rs.rh(2)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                formatEntry(pair[0]),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'TamilArima',
                                  fontSize: rs.sp(10.5),
                                  color: kIndigoLight.withValues(alpha: 0.9),
                                ),
                              ),
                            ),
                            Text(
                              '  ||  ',
                              style: TextStyle(
                                fontFamily: 'TamilArima',
                                fontSize: rs.sp(10.5),
                                color: kIndigoLight.withValues(alpha: 0.9),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                formatEntry(pair[1]),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'TamilArima',
                                  fontSize: rs.sp(10.5),
                                  color: kIndigoLight.withValues(alpha: 0.9),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildJathagaKattaSection() {
    final rs = context.rs;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(rs.r(14)),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'ராசி கட்டம்',
                  style: TextStyle(
                    fontFamily: 'TamilArima',
                    fontSize: rs.sp(16),
                    fontWeight: FontWeight.w700,
                    color: kIndigoDark,
                  ),
                ),
              ),
              IconButton(
                onPressed: _openPlanetDegreesSheet,
                icon: Icon(
                  Icons.edit_rounded,
                  color: kPrimaryColor,
                  size: rs.r(20),
                ),
                tooltip: 'Edit',
              ),
            ],
          ),
          SizedBox(height: rs.rh(12)),
          AspectRatio(
            aspectRatio: 1,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final spacing = rs.r(6);
                final cellSize = (constraints.maxWidth - spacing * 3) / 4;
                final centerSize = cellSize * 2 + spacing;
                final centerOffset = cellSize + spacing;
                final boxes = <Widget>[];

                var ringIndex = 0;
                for (var row = 0; row < 4; row++) {
                  for (var col = 0; col < 4; col++) {
                    final isCenter =
                        row >= 1 && row <= 2 && col >= 1 && col <= 2;
                    if (isCenter) continue;
                    final boxIndex = ringIndex;
                    ringIndex += 1;
                    boxes.add(
                      Positioned(
                        left: col * (cellSize + spacing),
                        top: row * (cellSize + spacing),
                        child: SizedBox(
                          width: cellSize,
                          height: cellSize,
                          child: _ChartBox(
                            data: _kattamBoxes[boxIndex],
                            onEdit: (_) {},
                            onTap: () => _openKattamSelectionSheet(boxIndex),
                            disablePositionTaps: true,
                            hideEmptyPlus: true,
                            valueColor: _kattamColorForValue,
                          ),
                        ),
                      ),
                    );
                  }
                }

                boxes.add(
                  Positioned(
                    left: centerOffset,
                    top: centerOffset,
                    child: Container(
                      width: centerSize,
                      height: centerSize,
                      padding: EdgeInsets.all(rs.r(8)),
                      decoration: BoxDecoration(
                        color: white,
                        borderRadius: BorderRadius.circular(rs.r(8)),
                        border: Border.all(color: kPrimaryLightColor),
                      ),
                      child: _buildCenterPlanetSummary(),
                    ),
                  ),
                );

                return Stack(children: boxes);
              },
            ),
          ),
        ],
      ),
    );
  }

  Color? _kattamColorForValue(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return _kattamColors[trimmed];
  }

  String _formatDate(DateTime value) {
    return '${value.day.toString().padLeft(2, '0')}/'
        '${value.month.toString().padLeft(2, '0')}/'
        '${value.year}';
  }

  String _formatTime(TimeOfDay value) {
    return MaterialLocalizations.of(context).formatTimeOfDay(value);
  }

  Future<void> _openPlanetDegreesSheet() async {
    final controllers = <String, TextEditingController>{};
    for (final field in _planetFields) {
      final key = field['key']!;
      controllers[key] = TextEditingController(
        text: _planetDegrees[key] ?? '',
      );
    }

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final rs = context.rs;
        final viewInsets = MediaQuery.viewInsetsOf(context);
        return Padding(
          padding: EdgeInsets.only(bottom: viewInsets.bottom),
          child: Container(
            decoration: BoxDecoration(
              color: white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(rs.r(20)),
              ),
            ),
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  rs.rw(16),
                  rs.rh(16),
                  rs.rw(16),
                  rs.rh(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'கிரக பாகைகள்',
                      style: TextStyle(
                        fontFamily: 'TamilArima',
                        fontSize: rs.sp(16),
                        fontWeight: FontWeight.w700,
                        color: kIndigoDark,
                      ),
                    ),
                    SizedBox(height: rs.rh(12)),
                    ..._planetFields.map((field) {
                      return _buildDegreeField(
                        label: field['label']!,
                        controller: controllers[field['key']!]!,
                      );
                    }),
                    SizedBox(height: rs.rh(12)),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    if (saved != true) {
      for (final controller in controllers.values) {
        controller.dispose();
      }
      return;
    }

    final updated = <String, String>{};
    for (final field in _planetFields) {
      final key = field['key']!;
      updated[key] = controllers[key]!.text.trim();
    }
    for (final controller in controllers.values) {
      controller.dispose();
    }

    await FirebaseFirestore.instance
        .collection('AstrologyProfiles')
        .doc(widget.profile.id)
        .update({
      'planetDegrees': updated,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    if (!mounted) return;
    setState(() {
      _planetDegrees = updated;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved')),
    );
  }

  Widget _buildDegreeField({
    required String label,
    required TextEditingController controller,
  }) {
    final rs = context.rs;
    return Padding(
      padding: EdgeInsets.only(bottom: rs.rh(10)),
      child: Row(
        children: [
          SizedBox(
            width: rs.rw(90),
            child: Text(
              '$label :',
              style: TextStyle(
                fontFamily: 'TamilArima',
                fontSize: rs.sp(13),
                fontWeight: FontWeight.w600,
                color: kIndigoDark,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textAlign: TextAlign.center,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                _ColonTimeFormatter(),
              ],
              decoration: InputDecoration(
                hintText: '10:11',
                hintStyle: TextStyle(
                  fontFamily: 'TamilArima',
                  fontSize: rs.sp(12),
                  color: kIndigoLight.withValues(alpha: 0.45),
                ),
                filled: true,
                fillColor: kPrimaryLightColor.withValues(alpha: 0.18),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: rs.rw(12),
                  vertical: rs.rh(10),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(rs.r(10)),
                  borderSide: BorderSide(color: kPrimaryLightColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(rs.r(10)),
                  borderSide: BorderSide(color: kPrimaryLightColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(rs.r(10)),
                  borderSide: const BorderSide(color: kPrimaryColor),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _kattamNumberForBox(int boxIndex) {
    if (boxIndex < 0 || boxIndex >= _kattamOrder.length) {
      return boxIndex + 1;
    }
    return _kattamOrder[boxIndex];
  }

  Future<void> _openKattamSelectionSheet(int boxIndex) async {
    final rs = context.rs;
    final shortMap = _kattamShortNames;
    final reverseMap = _kattamShortNames.map(
      (key, value) => MapEntry(value, key),
    );
    final selectedOrder = <String>[];
    final existingBox = _kattamBoxes[boxIndex];
    final existingValues = [
      existingBox.topLeft,
      existingBox.topRight,
      existingBox.center,
      existingBox.bottomLeft,
      existingBox.bottomRight,
    ];
    for (final value in existingValues) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) continue;
      for (final code in trimmed.split(RegExp(r'\s+'))) {
        final full = reverseMap[code.trim()];
        if (full != null) {
          selectedOrder.add(full);
        }
      }
    }

    final initialSet = selectedOrder.toSet();
    selectedOrder
      ..clear()
      ..addAll(initialSet);

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final viewInsets = MediaQuery.viewInsetsOf(context);
        return Padding(
          padding: EdgeInsets.only(bottom: viewInsets.bottom),
          child: Container(
            decoration: BoxDecoration(
              color: white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(rs.r(20)),
              ),
            ),
            child: SafeArea(
              top: false,
              child: StatefulBuilder(
                builder: (context, setSheetState) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      rs.rw(16),
                      rs.rh(16),
                      rs.rw(16),
                      rs.rh(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: rs.rw(12),
                            vertical: rs.rh(8),
                          ),
                          decoration: BoxDecoration(
                            color: kPrimaryColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(rs.r(12)),
                          ),
                          child: Text(
                            'கட்டம் ${_kattamNumberForBox(boxIndex)}',
                            style: TextStyle(
                              fontFamily: 'TamilArima',
                              fontSize: rs.sp(18),
                              fontWeight: FontWeight.w800,
                              color: kIndigoDark,
                            ),
                          ),
                        ),
                        SizedBox(height: rs.rh(12)),
                        _buildChipSection(
                          title: 'லக்னம்',
                          items: const ['லக்னம்'],
                          selected: selectedOrder.toSet(),
                          onToggle: (value) {
                            setSheetState(() {
                              _toggleSelection(value, selectedOrder);
                            });
                          },
                        ),
                        SizedBox(height: rs.rh(12)),
                        _buildChipSection(
                          title: 'நவகிரகங்கள்',
                          items: const [
                            'சூரியன்',
                            'சந்திரன்',
                            'செவ்வாய்',
                            'புதன்',
                            'குரு',
                            'சுக்கிரன்',
                            'சனி',
                            'ராகு',
                            'கேது',
                          ],
                          selected: selectedOrder.toSet(),
                          onToggle: (value) {
                            setSheetState(() {
                              _toggleSelection(value, selectedOrder);
                            });
                          },
                        ),
                        SizedBox(height: rs.rh(12)),
                        _buildChipSection(
                          title: 'உபகிரகங்கள் / கூட பார்க்கப்படும் புள்ளிகள்',
                          items: const [
                            'மாந்தி (குளிகன்)',
                            'யமகண்டம்',
                            'அர்த்தப்ரஹரன்',
                            'தூர்முகம்',
                            'காலன்',
                            'ம்ருத்யு',
                          ],
                          selected: selectedOrder.toSet(),
                          onToggle: (value) {
                            setSheetState(() {
                              _toggleSelection(value, selectedOrder);
                            });
                          },
                        ),
                        SizedBox(height: rs.rh(12)),
                        _buildChipSection(
                          title: 'வெளிக்கிரகங்கள்',
                          items: const ['யுரேனஸ்', 'நெப்டியூன்', 'புளூட்டோ'],
                          selected: selectedOrder.toSet(),
                          onToggle: (value) {
                            setSheetState(() {
                              _toggleSelection(value, selectedOrder);
                            });
                          },
                        ),
                        SizedBox(height: rs.rh(12)),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Save'),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );

    if (saved != true) return;

    final selectedCodes = selectedOrder
        .map((value) => shortMap[value] ?? value)
        .toList(growable: false);

    final center = selectedCodes.isNotEmpty ? selectedCodes[0] : '';
    final tl = selectedCodes.length > 1 ? selectedCodes[1] : '';
    final br = selectedCodes.length > 2 ? selectedCodes[2] : '';
    final tr = selectedCodes.length > 3 ? selectedCodes[3] : '';
    final bl = selectedCodes.length > 4 ? selectedCodes[4] : '';
    setState(() {
      _kattamBoxes[boxIndex] = _kattamBoxes[boxIndex]
          .copyWith(_ChartPosition.topLeft, tl)
          .copyWith(_ChartPosition.topRight, tr)
          .copyWith(_ChartPosition.center, center)
          .copyWith(_ChartPosition.bottomLeft, bl)
          .copyWith(_ChartPosition.bottomRight, br);
    });
    await _saveKattam();
  }

  void _toggleSelection(String value, List<String> selectedOrder) {
    if (selectedOrder.contains(value)) {
      selectedOrder.remove(value);
      return;
    }
    if (selectedOrder.length >= 5) {
      _showMaxSelectionToast();
      return;
    }
    selectedOrder.add(value);
  }

  void _showMaxSelectionToast() {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      const SnackBar(content: Text('Maximum 5')),
    );
  }

  Widget _buildChipSection({
    required String title,
    required List<String> items,
    required Set<String> selected,
    required ValueChanged<String> onToggle,
  }) {
    final rs = context.rs;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'TamilArima',
            fontSize: rs.sp(14),
            fontWeight: FontWeight.w700,
            color: kIndigoDark,
          ),
        ),
        SizedBox(height: rs.rh(8)),
        Wrap(
          spacing: rs.rw(8),
          runSpacing: rs.rh(8),
          children: items
              .map(
                (item) => FilterChip(
                  label: Text(item, style: TextStyle(fontSize: rs.sp(12.5))),
                  selected: selected.contains(item),
                  onSelected: (_) => onToggle(item),
                  selectedColor: kPrimaryColor.withValues(alpha: 0.18),
                  checkmarkColor: kPrimaryColor,
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  List<_ChartBoxData> _normalizeBoxes(List<Map<String, String>> boxes) {
    final mapped = boxes.map(_ChartBoxData.fromMap).toList();
    if (mapped.length >= 12) {
      return mapped.take(12).toList();
    }
    final filled = List<_ChartBoxData>.from(mapped);
    while (filled.length < 12) {
      filled.add(_ChartBoxData.empty());
    }
    return filled;
  }

  Future<void> _saveKattam() async {
    final collection =
        FirebaseFirestore.instance.collection('AstrologyProfiles');
    await collection.doc(widget.profile.id).update({
      'kattamBoxes': _kattamBoxes.map((box) => box.toMap()).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}

class _ColonTimeFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      return newValue.copyWith(text: '');
    }
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i == 2) {
        buffer.write(':');
      }
      buffer.write(digits[i]);
    }
    final text = buffer.toString();
    final selectionIndex = text.length;
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}

enum _ChartPosition {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
  center,
}

class _ChartBoxData {
  final String topLeft;
  final String topRight;
  final String bottomLeft;
  final String bottomRight;
  final String center;

  const _ChartBoxData({
    required this.topLeft,
    required this.topRight,
    required this.bottomLeft,
    required this.bottomRight,
    required this.center,
  });

  factory _ChartBoxData.empty() {
    return const _ChartBoxData(
      topLeft: '',
      topRight: '',
      bottomLeft: '',
      bottomRight: '',
      center: '',
    );
  }

  factory _ChartBoxData.fromMap(Map<String, String> map) {
    return _ChartBoxData(
      topLeft: map['topLeft'] ?? '',
      topRight: map['topRight'] ?? '',
      bottomLeft: map['bottomLeft'] ?? '',
      bottomRight: map['bottomRight'] ?? '',
      center: map['center'] ?? '',
    );
  }

  Map<String, String> toMap() {
    return {
      'topLeft': topLeft,
      'topRight': topRight,
      'bottomLeft': bottomLeft,
      'bottomRight': bottomRight,
      'center': center,
    };
  }

  _ChartBoxData copyWith(_ChartPosition position, String value) {
    switch (position) {
      case _ChartPosition.topLeft:
        return _ChartBoxData(
          topLeft: value,
          topRight: topRight,
          bottomLeft: bottomLeft,
          bottomRight: bottomRight,
          center: center,
        );
      case _ChartPosition.topRight:
        return _ChartBoxData(
          topLeft: topLeft,
          topRight: value,
          bottomLeft: bottomLeft,
          bottomRight: bottomRight,
          center: center,
        );
      case _ChartPosition.bottomLeft:
        return _ChartBoxData(
          topLeft: topLeft,
          topRight: topRight,
          bottomLeft: value,
          bottomRight: bottomRight,
          center: center,
        );
      case _ChartPosition.bottomRight:
        return _ChartBoxData(
          topLeft: topLeft,
          topRight: topRight,
          bottomLeft: bottomLeft,
          bottomRight: value,
          center: center,
        );
      case _ChartPosition.center:
        return _ChartBoxData(
          topLeft: topLeft,
          topRight: topRight,
          bottomLeft: bottomLeft,
          bottomRight: bottomRight,
          center: value,
        );
    }
  }

  String valueFor(_ChartPosition position) {
    switch (position) {
      case _ChartPosition.topLeft:
        return topLeft;
      case _ChartPosition.topRight:
        return topRight;
      case _ChartPosition.bottomLeft:
        return bottomLeft;
      case _ChartPosition.bottomRight:
        return bottomRight;
      case _ChartPosition.center:
        return center;
    }
  }
}

class _ChartBox extends StatelessWidget {
  const _ChartBox({
    required this.data,
    required this.onEdit,
    this.onTap,
    this.disablePositionTaps = false,
    this.hideEmptyPlus = false,
    this.valueColor,
  });

  final _ChartBoxData data;
  final ValueChanged<_ChartPosition> onEdit;
  final VoidCallback? onTap;
  final bool disablePositionTaps;
  final bool hideEmptyPlus;
  final Color? Function(String value)? valueColor;

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;
    final baseColor = kPrimaryLightColor.withValues(alpha: 0.18);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(rs.r(8)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              baseColor,
              white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: kPrimaryLightColor, width: 1.1),
          borderRadius: BorderRadius.circular(rs.r(8)),
          boxShadow: [
            BoxShadow(
              color: kPrimaryColor.withValues(alpha: 0.08),
              blurRadius: rs.r(6),
              offset: Offset(0, rs.rh(2)),
            ),
          ],
        ),
        child: Stack(
          children: [
            _PositionedValue(
              alignment: Alignment.topLeft,
              value: data.topLeft,
              onTap: () => onEdit(_ChartPosition.topLeft),
              enabled: !disablePositionTaps,
              hideEmptyPlus: hideEmptyPlus,
              valueColor: valueColor,
            ),
            _PositionedValue(
              alignment: Alignment.topRight,
              value: data.topRight,
              onTap: () => onEdit(_ChartPosition.topRight),
              enabled: !disablePositionTaps,
              hideEmptyPlus: hideEmptyPlus,
              valueColor: valueColor,
            ),
            _PositionedValue(
              alignment: Alignment.bottomLeft,
              value: data.bottomLeft,
              onTap: () => onEdit(_ChartPosition.bottomLeft),
              enabled: !disablePositionTaps,
              hideEmptyPlus: hideEmptyPlus,
              valueColor: valueColor,
            ),
            _PositionedValue(
              alignment: Alignment.bottomRight,
              value: data.bottomRight,
              onTap: () => onEdit(_ChartPosition.bottomRight),
              enabled: !disablePositionTaps,
              hideEmptyPlus: hideEmptyPlus,
              valueColor: valueColor,
            ),
            _PositionedValue(
              alignment: Alignment.center,
              value: data.center,
              onTap: () => onEdit(_ChartPosition.center),
              enabled: !disablePositionTaps,
              hideEmptyPlus: hideEmptyPlus,
              isCenter: true,
              valueColor: valueColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _PositionedValue extends StatelessWidget {
  const _PositionedValue({
    required this.alignment,
    required this.value,
    required this.onTap,
    this.isCenter = false,
    this.enabled = true,
    this.hideEmptyPlus = false,
    this.valueColor,
  });

  final Alignment alignment;
  final String value;
  final VoidCallback onTap;
  final bool isCenter;
  final bool enabled;
  final bool hideEmptyPlus;
  final Color? Function(String value)? valueColor;

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;
    final displayText =
        value.isEmpty && hideEmptyPlus ? '' : (value.isEmpty ? '+' : value);
    final tokens = displayText
        .split(RegExp(r'\s+'))
        .where((token) => token.isNotEmpty)
        .toList();
    final fallbackColor = value.isEmpty ? kIndigoLight : kIndigoDark;
    final baseFontSize =
        isCenter ? (tokens.length > 1 ? rs.sp(11) : rs.sp(13.5)) : rs.sp(12);
    final textStyle = TextStyle(
      fontSize: baseFontSize,
      fontWeight: FontWeight.w600,
      color: fallbackColor,
    );
    return Align(
      alignment: alignment,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(rs.r(6)),
        child: Padding(
          padding: EdgeInsets.all(isCenter ? rs.r(6) : rs.r(4)),
          child: isCenter && tokens.length > 1
              ? Wrap(
                  alignment: WrapAlignment.center,
                  spacing: rs.rw(4),
                  runSpacing: rs.rh(2),
                  children: tokens
                      .map(
                        (token) => Text(
                          token,
                          style: textStyle.copyWith(
                            color: valueColor?.call(token) ?? fallbackColor,
                          ),
                        ),
                      )
                      .toList(),
                )
              : Text(
                  displayText,
                  style: textStyle.copyWith(
                    color: valueColor?.call(value) ?? fallbackColor,
                  ),
                ),
        ),
      ),
    );
  }
}
