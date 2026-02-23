import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mrs_dth_diary_v1/scr/ui/astrology_form_screen.dart';
import 'package:mrs_dth_diary_v1/scr/helpers/owner_service.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/responsive.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/styles.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:async';

class AstrologyChartScreen extends StatefulWidget {
  const AstrologyChartScreen({super.key, required this.profile});

  final AstrologyProfile profile;

  @override
  State<AstrologyChartScreen> createState() => _AstrologyChartScreenState();
}

class _AstrologyChartScreenState extends State<AstrologyChartScreen> {
  late final List<_ChartBoxData> _kattamBoxes;
  Map<String, String> _planetDegrees = {};
  final List<_GocharamParvaEntry> _gocharamParvaEntries = [];
  int _nextGocharamParvaNumber = 1;

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
    'மாந்தி': 'மாந்',
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
    _loadProfileExtras();
  }

  Future<void> _loadProfileExtras() async {
    final doc = await FirebaseFirestore.instance
        .collection('AstrologyProfiles')
        .doc(widget.profile.id)
        .get();
    if (!doc.exists) return;
    final data = doc.data();
    if (data == null) return;

    Map<String, String> planetDegrees = {};
    final rawDegrees = data['planetDegrees'];
    if (rawDegrees is Map) {
      planetDegrees = rawDegrees.map(
        (key, value) => MapEntry(key.toString(), (value ?? '').toString()),
      );
    }

    final rawEntries = data['gocharamParvaEntries'];
    final mapped = <_GocharamParvaEntry>[];
    if (rawEntries is List) {
      mapped.addAll(
        rawEntries.whereType<Map>().map(
              (map) => _GocharamParvaEntry.fromMap(map,
                  profileId: widget.profile.id),
            ),
      );
    }

    var maxNumber = 0;
    var fallbackNumber = 1;
    for (var i = 0; i < mapped.length; i++) {
      final entry = mapped[i];
      if (entry.number <= 0) {
        mapped[i] = entry.copyWith(number: fallbackNumber);
        fallbackNumber += 1;
      }
      if (mapped[i].number > maxNumber) {
        maxNumber = mapped[i].number;
      }
    }

    if (!mounted) return;
    setState(() {
      _planetDegrees = planetDegrees;
      _gocharamParvaEntries
        ..clear()
        ..addAll(mapped);
      _nextGocharamParvaNumber = maxNumber + 1;
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
            SizedBox(height: rs.rh(16)),
            _buildGocharamParvaSection(),
            SizedBox(height: rs.rh(150)),
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
          _buildHeaderRow('பாலினம்', widget.profile.gender),
          _buildHeaderRow('பிறந்த நாள்', widget.profile.birthDay),
          _buildHeaderRow('ராசி', widget.profile.rasi),
          _buildHeaderRow('நட்சத்திரம்', widget.profile.natchathiram),
          _buildHeaderRow('பாதம்', widget.profile.paatham),
          _buildHeaderRow('திதி', widget.profile.thithi),
          _buildHeaderRow('கரணம்', widget.profile.karanam),
          _buildHeaderRow('யோகம்', widget.profile.yogam),
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

  Widget _buildCenterPlanetSummary({
    double fontScale = 1.0,
    bool singleLine = false,
  }) {
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
            fontSize: rs.sp(11.5) * fontScale,
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
                                  fontSize: rs.sp(9.5) * fontScale,
                                  color: kIndigoLight.withValues(alpha: 0.9),
                                ),
                                maxLines: singleLine ? 1 : null,
                                overflow: singleLine
                                    ? TextOverflow.ellipsis
                                    : TextOverflow.visible,
                              ),
                            ),
                            Text(
                              '  ||  ',
                              style: TextStyle(
                                fontFamily: 'TamilArima',
                                fontSize: rs.sp(9.5) * fontScale,
                                color: kIndigoLight.withValues(alpha: 0.9),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                formatEntry(pair[1]),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'TamilArima',
                                  fontSize: rs.sp(9.5) * fontScale,
                                  color: kIndigoLight.withValues(alpha: 0.9),
                                ),
                                maxLines: singleLine ? 1 : null,
                                overflow: singleLine
                                    ? TextOverflow.ellipsis
                                    : TextOverflow.visible,
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
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: rs.rw(10),
              vertical: rs.rh(6),
            ),
            decoration: BoxDecoration(
              color: kPrimaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(rs.r(12)),
              border: Border.all(
                color: kPrimaryColor.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
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
                Container(
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _openPlanetDegreesSheet,
                    icon: Icon(
                      Icons.edit_rounded,
                      color: kPrimaryColor,
                      size: rs.r(20),
                    ),
                    tooltip: 'Edit',
                  ),
                ),
              ],
            ),
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
                      child: Transform.scale(
                        scale: 0.95,
                        alignment: Alignment.center,
                        child: _buildCenterPlanetSummary(),
                      ),
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

  Widget _buildGocharamParvaSection() {
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
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: rs.rw(10),
              vertical: rs.rh(6),
            ),
            decoration: BoxDecoration(
              color: kPrimaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(rs.r(12)),
              border: Border.all(
                color: kPrimaryColor.withValues(alpha: 0.01),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'கோச்சார பார்வைகள்',
                    style: TextStyle(
                      fontFamily: 'TamilArima',
                      fontSize: rs.sp(16),
                      fontWeight: FontWeight.w700,
                      color: kIndigoDark,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _openGocharamParvaSheet,
                    icon: Icon(
                      Icons.add_circle_outline,
                      color: kPrimaryColor,
                      size: rs.r(22),
                    ),
                    tooltip: 'Add',
                  ),
                ),
              ],
            ),
          ),
          if (_gocharamParvaEntries.isEmpty)
            Padding(
              padding: EdgeInsets.only(top: rs.rh(8)),
              child: Text(
                'பார்வை விவரங்கள் சேர்க்கப்படவில்லை',
                style: TextStyle(
                  fontFamily: 'TamilArima',
                  fontSize: rs.sp(12.5),
                  color: kIndigoLight.withValues(alpha: 0.75),
                ),
              ),
            )
          else
            ..._gocharamParvaEntries
                .map((entry) => _buildGocharamParvaTile(entry)),
          SizedBox(
            height: rs.rh(8),
          )
        ],
      ),
    );
  }

  Widget _buildGocharamParvaTile(_GocharamParvaEntry entry) {
    final rs = context.rs;
    final numberLabel = entry.number.toString().padLeft(2, '0');

    return Padding(
      padding: EdgeInsets.only(top: rs.rh(8)),
      child: Dismissible(
        key: ValueKey('gocharam-parva-${entry.id}'),
        direction: DismissDirection.horizontal,
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            await _openGocharamParvaSheet(editId: entry.id);
            return false;
          }
          return _confirmGocharamParvaDelete();
        },
        onDismissed: (direction) {
          setState(() {
            _gocharamParvaEntries.removeWhere((item) => item.id == entry.id);
          });
          _saveGocharamParvaEntries();
        },
        background: Container(
          decoration: BoxDecoration(
            color: kPrimaryColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(rs.r(12)),
          ),
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(left: rs.rw(16)),
          child: Row(
            children: [
              Icon(Icons.edit, color: kPrimaryColor, size: rs.r(18)),
              SizedBox(width: rs.rw(6)),
              Text(
                'Edit',
                style: TextStyle(
                  fontFamily: 'TamilArima',
                  fontSize: rs.sp(12.5),
                  fontWeight: FontWeight.w600,
                  color: kPrimaryColor,
                ),
              ),
            ],
          ),
        ),
        secondaryBackground: Container(
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(rs.r(12)),
          ),
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(right: rs.rw(16)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Delete',
                style: TextStyle(
                  fontFamily: 'TamilArima',
                  fontSize: rs.sp(12.5),
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
              SizedBox(width: rs.rw(6)),
              Icon(Icons.delete_outline, color: Colors.red, size: rs.r(18)),
            ],
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: rs.rw(14),
                vertical: rs.rh(12),
              ),
              decoration: BoxDecoration(
                color: white,
                borderRadius: BorderRadius.circular(rs.r(14)),
                border: Border.all(color: kPrimaryLightColor),
                boxShadow: [
                  BoxShadow(
                    color: kPrimaryColor.withValues(alpha: 0.08),
                    blurRadius: rs.r(8),
                    offset: Offset(0, rs.rh(3)),
                  ),
                ],
              ),
              child: InkWell(
                onTap: () => _openGocharamParvaDetails(entry),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: rs.r(16),
                      backgroundColor: kPrimaryColor.withValues(alpha: 0.18),
                      child: Text(
                        numberLabel,
                        style: TextStyle(
                          fontFamily: 'TamilArima',
                          fontSize: rs.sp(12.5),
                          fontWeight: FontWeight.w800,
                          color: kIndigoDark,
                        ),
                      ),
                    ),
                    SizedBox(width: rs.rw(12)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'கோச்சார விவரம்',
                                style: TextStyle(
                                  fontFamily: 'TamilArima',
                                  fontSize: rs.sp(13.5),
                                  fontWeight: FontWeight.w800,
                                  color: kIndigoDark,
                                ),
                              ),
                              SizedBox(width: rs.rw(6)),
                              Icon(
                                Icons.auto_awesome,
                                size: rs.r(16),
                                color: kPrimaryColor,
                              ),
                              const Spacer(),
                              IconButton(
                                onPressed: () => _openGocharamParvaDetails(
                                  entry,
                                ),
                                icon: Icon(
                                  Icons.info_outline_rounded,
                                  size: rs.r(22),
                                  color: kIndigoLight.withValues(alpha: 0.9),
                                ),
                                tooltip: 'View details',
                              ),
                            ],
                          ),
                          SizedBox(height: rs.rh(6)),
                          Row(
                            children: [
                              Icon(
                                Icons.event,
                                size: rs.r(16),
                                color: kPrimaryColor,
                              ),
                              SizedBox(width: rs.rw(6)),
                              Text(
                                _formatDate(entry.date),
                                style: TextStyle(
                                  fontFamily: 'TamilArima',
                                  fontSize: rs.sp(12.5),
                                  fontWeight: FontWeight.w600,
                                  color: kIndigoDark,
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                Icons.access_time,
                                size: rs.r(16),
                                color: kPrimaryColor,
                              ),
                              SizedBox(width: rs.rw(6)),
                              Text(
                                _formatTime(entry.time),
                                style: TextStyle(
                                  fontFamily: 'TamilArima',
                                  fontSize: rs.sp(12.5),
                                  fontWeight: FontWeight.w600,
                                  color: kIndigoDark,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openGocharamParvaDetails(_GocharamParvaEntry entry) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _GocharamParvaDetailsScreen(
          entry: entry,
          kattamBoxes: _kattamBoxes,
          planetDegrees: _planetDegrees,
          onEditBox: (boxIndex, boxData, onLocalUpdate) async {
            await _openGocharamParvaBoxSheet(
              boxIndex: boxIndex,
              boxData: boxData,
              entryId: entry.id,
              onUpdate: (index, data) {
                setState(() {
                  final entryIndex = _gocharamParvaEntries
                      .indexWhere((item) => item.id == entry.id);
                  if (entryIndex < 0) return;
                  final current = _gocharamParvaEntries[entryIndex];
                  final updatedBoxes =
                      List<_ChartBoxData>.from(current.gocharamBoxes);
                  updatedBoxes[index] = data;
                  _gocharamParvaEntries[entryIndex] = current.copyWith(
                    gocharamBoxes: updatedBoxes,
                  );
                });
                onLocalUpdate(data);
              },
            );
          },
        ),
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
    try {
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
        return;
      }

      // Read values before any async operations
      final updated = <String, String>{};
      for (final field in _planetFields) {
        final key = field['key']!;
        updated[key] = controllers[key]!.text.trim();
      }

      // Perform async operation with the values
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
    } finally {
      // Always dispose controllers at the end
      for (final controller in controllers.values) {
        controller.dispose();
      }
    }
  }

  Future<void> _openGocharamParvaSheet({String? editId}) async {
    final existing = editId == null
        ? null
        : _gocharamParvaEntries
            .where((entry) => entry.id == editId)
            .cast<_GocharamParvaEntry?>()
            .firstWhere((entry) => entry != null, orElse: () => null);
    DateTime? selectedDate = existing?.date;
    TimeOfDay? selectedTime = existing?.time;

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
              child: StatefulBuilder(
                builder: (context, setSheetState) {
                  Future<void> pickDate() async {
                    final now = DateTime.now();
                    final initial = selectedDate ?? now;
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: initial,
                      firstDate: DateTime(now.year - 5),
                      lastDate: DateTime(now.year + 5),
                    );
                    if (picked == null) return;
                    setSheetState(() {
                      selectedDate = picked;
                    });
                  }

                  Future<void> pickTime() async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: selectedTime ??
                          TimeOfDay.fromDateTime(DateTime.now()),
                    );
                    if (picked == null) return;
                    setSheetState(() {
                      selectedTime = picked;
                    });
                  }

                  final canSave = selectedDate != null && selectedTime != null;

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
                        Text(
                          'கோச்சாரம்',
                          style: TextStyle(
                            fontFamily: 'TamilArima',
                            fontSize: rs.sp(16),
                            fontWeight: FontWeight.w700,
                            color: kIndigoDark,
                          ),
                        ),
                        SizedBox(height: rs.rh(12)),
                        _buildPickField(
                          label: 'பார்க்க வந்த தேதி',
                          value: selectedDate == null
                              ? 'தேர்வு செய்யவும்'
                              : _formatDate(selectedDate!),
                          onTap: pickDate,
                        ),
                        SizedBox(height: rs.rh(10)),
                        _buildPickField(
                          label: 'பார்க்க வந்த நேரம்',
                          value: selectedTime == null
                              ? 'தேர்வு செய்யவும்'
                              : _formatTime(selectedTime!),
                          onTap: pickTime,
                        ),
                        SizedBox(height: rs.rh(16)),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: canSave
                                ? () => Navigator.pop(context, true)
                                : null,
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

    if (saved != true || selectedDate == null || selectedTime == null) return;

    setState(() {
      if (existing != null) {
        final updated = existing.copyWith(
          date: selectedDate!,
          time: selectedTime!,
        );
        final index = _gocharamParvaEntries
            .indexWhere((entry) => entry.id == existing.id);
        if (index >= 0) {
          _gocharamParvaEntries[index] = updated;
        }
      } else {
        // Create empty gocharam boxes (12 boxes)
        final emptyGocharamBoxes = List.generate(
          12,
          (_) => _ChartBoxData.empty(),
        );
        _gocharamParvaEntries.add(
          _GocharamParvaEntry(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            number: _nextGocharamParvaNumber,
            date: selectedDate!,
            time: selectedTime!,
            gocharamBoxes: emptyGocharamBoxes,
            profileId: widget.profile.id,
          ),
        );
        _nextGocharamParvaNumber += 1;
      }
    });
    await _saveGocharamParvaEntries();
  }

  Future<bool> _confirmGocharamParvaDelete() async {
    final rs = context.rs;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'நீக்க வேண்டுமா?',
            style: TextStyle(
              fontFamily: 'TamilArima',
              fontSize: rs.sp(14),
              fontWeight: FontWeight.w700,
              color: kIndigoDark,
            ),
          ),
          content: Text(
            'இந்த பதிவை நீக்க விரும்புகிறீர்களா?',
            style: TextStyle(
              fontFamily: 'TamilArima',
              fontSize: rs.sp(12.5),
              color: kIndigoDark,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('No'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  Future<void> _saveGocharamParvaEntries() async {
    final collection =
        FirebaseFirestore.instance.collection('AstrologyProfiles');
    await collection.doc(widget.profile.id).update({
      'gocharamParvaEntries':
          _gocharamParvaEntries.map((entry) => entry.toMap()).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _openGocharamParvaBoxSheet({
    required int boxIndex,
    required _ChartBoxData boxData,
    required String entryId,
    required Function(int, _ChartBoxData) onUpdate,
  }) async {
    final rs = context.rs;
    final shortMap = _kattamShortNames;
    final reverseMap = _kattamShortNames.map(
      (key, value) => MapEntry(value, key),
    );
    final selectedOrder = <String>[];
    final existingValues = [
      boxData.topLeft,
      boxData.topRight,
      boxData.center,
      boxData.bottomLeft,
      boxData.bottomRight,
    ];

    // Parse existing short codes back to full names
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

    final coNumber = _kattamNumberForBox(boxIndex);
    final orderedPositions = _gocharamOrderForCo(coNumber);

    final values = List<String>.filled(5, '', growable: false);
    for (var i = 0; i < values.length && i < selectedCodes.length; i++) {
      values[i] = selectedCodes[i];
    }

    final valueMap = <_ChartPosition, String>{
      for (var i = 0; i < orderedPositions.length; i++)
        orderedPositions[i]: values[i],
    };

    final updatedBox = _ChartBoxData(
      topLeft: valueMap[_ChartPosition.topLeft] ?? '',
      topRight: valueMap[_ChartPosition.topRight] ?? '',
      center: valueMap[_ChartPosition.center] ?? '',
      bottomLeft: valueMap[_ChartPosition.bottomLeft] ?? '',
      bottomRight: valueMap[_ChartPosition.bottomRight] ?? '',
    );

    onUpdate(boxIndex, updatedBox);
    await _saveGocharamParvaEntries();
  }

  Widget _buildPickField({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    final rs = context.rs;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(rs.r(10)),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: rs.rw(12),
          vertical: rs.rh(12),
        ),
        decoration: BoxDecoration(
          color: kPrimaryLightColor.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(rs.r(10)),
          border: Border.all(color: kPrimaryLightColor),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'TamilArima',
                  fontSize: rs.sp(12.5),
                  fontWeight: FontWeight.w600,
                  color: kIndigoDark,
                ),
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'TamilArima',
                fontSize: rs.sp(12.5),
                fontWeight: FontWeight.w700,
                color: kIndigoDark,
              ),
            ),
            SizedBox(width: rs.rw(6)),
            Icon(
              Icons.calendar_today,
              size: rs.r(16),
              color: kPrimaryColor,
            ),
          ],
        ),
      ),
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

  List<_ChartPosition> _gocharamOrderForCo(int coNumber) {
    switch (coNumber) {
      case 12:
        return const [
          _ChartPosition.center,
          _ChartPosition.topLeft,
          _ChartPosition.topRight,
          _ChartPosition.bottomLeft,
          _ChartPosition.bottomRight,
        ];
      case 1:
      case 2:
      case 3:
        return const [
          _ChartPosition.center,
          _ChartPosition.topLeft,
          _ChartPosition.topRight,
          _ChartPosition.bottomRight,
          _ChartPosition.bottomLeft,
        ];
      case 4:
      case 5:
        return const [
          _ChartPosition.center,
          _ChartPosition.topRight,
          _ChartPosition.bottomRight,
          _ChartPosition.bottomLeft,
          _ChartPosition.topLeft,
        ];
      case 6:
        return const [
          _ChartPosition.center,
          _ChartPosition.bottomRight,
          _ChartPosition.topRight,
          _ChartPosition.bottomLeft,
          _ChartPosition.topLeft,
        ];
      case 7:
      case 8:
      case 9:
        return const [
          _ChartPosition.center,
          _ChartPosition.bottomLeft,
          _ChartPosition.bottomRight,
          _ChartPosition.topLeft,
          _ChartPosition.topRight,
        ];
      case 10:
      case 11:
        return const [
          _ChartPosition.center,
          _ChartPosition.topLeft,
          _ChartPosition.bottomLeft,
          _ChartPosition.bottomRight,
          _ChartPosition.topRight,
        ];
      default:
        return const [
          _ChartPosition.center,
          _ChartPosition.topLeft,
          _ChartPosition.topRight,
          _ChartPosition.bottomLeft,
          _ChartPosition.bottomRight,
        ];
    }
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

class _GocharamParvaDetailsScreen extends StatefulWidget {
  const _GocharamParvaDetailsScreen({
    required this.entry,
    required this.kattamBoxes,
    required this.planetDegrees,
    required this.onEditBox,
  });

  final _GocharamParvaEntry entry;
  final List<_ChartBoxData> kattamBoxes;
  final Map<String, String> planetDegrees;
  final Future<void> Function(
    int boxIndex,
    _ChartBoxData boxData,
    ValueChanged<_ChartBoxData> onLocalUpdate,
  ) onEditBox;

  @override
  State<_GocharamParvaDetailsScreen> createState() =>
      _GocharamParvaDetailsScreenState();
}

class _GocharamParvaDetailsScreenState
    extends State<_GocharamParvaDetailsScreen> {
  late List<_ChartBoxData> _gocharamBoxes;
  bool _isVoiceMode = false;
  bool _showAddNoteSection = false;
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayer _savedNotePlayer = AudioPlayer(); // For playing saved notes
  bool _isRecording = false;
  bool _isPlaying = false;
  String? _recordedFilePath;
  String? _savedVoiceNoteUrl;
  final TextEditingController _textController = TextEditingController();
  int _recordingSeconds = 0;
  Timer? _recordingTimer;
  Duration _playbackDuration = Duration.zero;
  Duration _playbackPosition = Duration.zero;
  List<_SavedNote> _savedNotes = [];
  int? _editingNoteIndex;
  int? _playingNoteIndex; // Track which saved note is playing
  Duration _savedNoteDuration = Duration.zero;
  Duration _savedNotePosition = Duration.zero;
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _gocharamBoxes = List<_ChartBoxData>.from(widget.entry.gocharamBoxes);
    _loadNotes();

    // Setup listeners for saved note player
    _savedNotePlayer.onDurationChanged.listen((duration) {
      setState(() {
        _savedNoteDuration = duration;
      });
    });

    _savedNotePlayer.onPositionChanged.listen((position) {
      setState(() {
        _savedNotePosition = position;
      });
    });

    _savedNotePlayer.onPlayerComplete.listen((_) {
      setState(() {
        _playingNoteIndex = null;
        _savedNotePosition = Duration.zero;
        _savedNoteDuration = Duration.zero;
      });
    });
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    _savedNotePlayer.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _loadNotes() async {
    try {
      // Load notes from Firestore
      final collection =
          FirebaseFirestore.instance.collection('AstrologyProfiles');
      final profileDoc = await collection.doc(widget.entry.profileId).get();

      if (profileDoc.exists) {
        final data = profileDoc.data()!;
        final gocharamEntries = (data['gocharamParvaEntries'] as List?)
                ?.map((e) => Map<String, dynamic>.from(e as Map))
                .toList() ??
            [];

        final entryIndex = gocharamEntries.indexWhere(
          (e) => e['number'] == widget.entry.number,
        );

        if (entryIndex >= 0) {
          final entry = gocharamEntries[entryIndex];

          // Load new format (notes array)
          if (entry.containsKey('notes') && entry['notes'] is List) {
            final notesList = entry['notes'] as List;
            _savedNotes = notesList
                .map((n) =>
                    _SavedNote.fromMap(Map<String, dynamic>.from(n as Map)))
                .toList();
          } else {
            // Legacy format - single textNote/voiceNoteUrl
            if (entry.containsKey('textNote') ||
                entry.containsKey('voiceNoteUrl')) {
              _savedNotes.add(_SavedNote(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                textNote: entry['textNote']?.toString(),
                voiceNoteUrl: entry['voiceNoteUrl']?.toString(),
                createdAt: DateTime.now(),
              ));
            }
          }
        }
      }

      setState(() {});
    } catch (e) {
      print('Error loading notes: $e');
    }
  }

  Future<void> _startRecording() async {
    try {
      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        Fluttertoast.showToast(
          msg: 'Microphone permission required',
          backgroundColor: Colors.red,
          textColor: white,
        );
        return;
      }

      final directory = await getApplicationDocumentsDirectory();
      final filePath =
          '${directory.path}/voice_note_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _audioRecorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: filePath,
      );

      setState(() {
        _isRecording = true;
        _recordedFilePath = null; // Clear old recording
        _recordingSeconds = 0;
      });

      // Start timer
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _recordingSeconds++;
        });
      });

      Fluttertoast.showToast(
        msg: 'Recording started',
        backgroundColor: Colors.red,
        textColor: white,
        toastLength: Toast.LENGTH_SHORT,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error starting recording: $e',
        backgroundColor: Colors.red,
        textColor: white,
      );
    }
  }

  Future<void> _stopRecording() async {
    try {
      if (!_isRecording) return;

      _recordingTimer?.cancel();
      final path = await _audioRecorder.stop();

      setState(() {
        _isRecording = false;
        if (path != null) {
          _recordedFilePath = path;
        }
      });

      if (path != null) {
        Fluttertoast.showToast(
          msg: 'Recording stopped - ${_recordingSeconds}s',
          backgroundColor: kPrimaryColor,
          textColor: white,
          toastLength: Toast.LENGTH_SHORT,
        );
      }
    } catch (e) {
      _recordingTimer?.cancel();
      setState(() {
        _isRecording = false;
      });
      Fluttertoast.showToast(
        msg: 'Error stopping recording: $e',
        backgroundColor: Colors.red,
        textColor: white,
      );
    }
  }

  Future<void> _playRecording() async {
    try {
      if (_recordedFilePath != null && File(_recordedFilePath!).existsSync()) {
        await _audioPlayer.play(DeviceFileSource(_recordedFilePath!));
        setState(() {
          _isPlaying = true;
        });

        _audioPlayer.onPlayerComplete.listen((_) {
          if (mounted) {
            setState(() {
              _isPlaying = false;
              _playbackPosition = Duration.zero;
            });
          }
        });

        _audioPlayer.onDurationChanged.listen((duration) {
          if (mounted) {
            setState(() {
              _playbackDuration = duration;
            });
          }
        });

        _audioPlayer.onPositionChanged.listen((position) {
          if (mounted) {
            setState(() {
              _playbackPosition = position;
            });
          }
        });
      } else if (_savedVoiceNoteUrl != null) {
        await _audioPlayer.play(UrlSource(_savedVoiceNoteUrl!));
        setState(() {
          _isPlaying = true;
        });

        _audioPlayer.onPlayerComplete.listen((_) {
          if (mounted) {
            setState(() {
              _isPlaying = false;
              _playbackPosition = Duration.zero;
            });
          }
        });
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error playing recording',
        backgroundColor: Colors.red,
        textColor: white,
      );
    }
  }

  Future<void> _stopPlaying() async {
    await _audioPlayer.stop();
    setState(() {
      _isPlaying = false;
      _playbackPosition = Duration.zero;
    });
  }

  Future<void> _deleteRecording() async {
    if (_isPlaying) {
      await _audioPlayer.stop();
    }
    if (_recordedFilePath != null && File(_recordedFilePath!).existsSync()) {
      await File(_recordedFilePath!).delete();
    }
    setState(() {
      _recordedFilePath = null;
      _savedVoiceNoteUrl = null;
      _isPlaying = false;
      _playbackPosition = Duration.zero;
      _playbackDuration = Duration.zero;
      _recordingSeconds = 0;
    });

    Fluttertoast.showToast(
      msg: 'Recording deleted',
      backgroundColor: Colors.orange,
      textColor: white,
    );
  }

  Future<void> _saveNotes() async {
    if (_isUploading) return; // Prevent multiple saves

    try {
      final textNote = _textController.text.trim();
      final voiceFilePath = _recordedFilePath;

      if (textNote.isEmpty && voiceFilePath == null) {
        Fluttertoast.showToast(
          msg: 'Please add a note first',
          backgroundColor: Colors.orange,
          textColor: white,
        );
        return;
      }

      setState(() {
        _isUploading = true;
        _uploadProgress = 0.0;
      });

      String? uploadedVoiceUrl;

      // Upload voice file to Firebase Storage if exists
      if (voiceFilePath != null && File(voiceFilePath).existsSync()) {
        try {
          final file = File(voiceFilePath);
          final ownerId = requireOwnerId();
          final fileName =
              'users/$ownerId/voice_notes/${widget.entry.profileId}/${DateTime.now().millisecondsSinceEpoch}.m4a';
          final storageRef = FirebaseStorage.instance.ref().child(fileName);
          final uploadTask = storageRef.putFile(file);

          // Listen to upload progress
          uploadTask.snapshotEvents.listen((taskSnapshot) {
            final progress =
                taskSnapshot.bytesTransferred / taskSnapshot.totalBytes;
            if (mounted) {
              setState(() {
                _uploadProgress = progress;
              });
            }
          });

          // Wait for upload to complete
          final snapshot = await uploadTask;
          uploadedVoiceUrl = await snapshot.ref.getDownloadURL();
        } catch (e) {
          setState(() {
            _isUploading = false;
            _uploadProgress = 0.0;
          });
          Fluttertoast.showToast(
            msg: 'Error uploading voice note: $e',
            backgroundColor: Colors.red,
            textColor: white,
          );
          return;
        }
      }

      final newNote = _SavedNote(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        textNote: textNote.isNotEmpty ? textNote : null,
        voiceNoteUrl: uploadedVoiceUrl ?? _savedVoiceNoteUrl,
        createdAt: DateTime.now(),
      );

      if (_editingNoteIndex != null) {
        // Update existing note
        _savedNotes[_editingNoteIndex!] = newNote;
        _editingNoteIndex = null;
      } else {
        // Add new note
        _savedNotes.add(newNote);
      }

      // Save to Firestore
      final collection =
          FirebaseFirestore.instance.collection('AstrologyProfiles');
      final profileDoc = await collection.doc(widget.entry.profileId).get();

      if (!profileDoc.exists) {
        setState(() {
          _isUploading = false;
          _uploadProgress = 0.0;
        });
        Fluttertoast.showToast(
          msg: 'Error: Profile not found',
          backgroundColor: Colors.red,
          textColor: white,
        );
        return;
      }

      final data = profileDoc.data()!;
      final gocharamEntries = (data['gocharamParvaEntries'] as List?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [];

      final entryIndex = gocharamEntries.indexWhere(
        (e) => e['number'] == widget.entry.number,
      );

      if (entryIndex >= 0) {
        gocharamEntries[entryIndex]['notes'] =
            _savedNotes.map((n) => n.toMap()).toList();

        await collection.doc(widget.entry.profileId).update({
          'gocharamParvaEntries': gocharamEntries,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        setState(() {
          _showAddNoteSection = false;
          _textController.clear();
          _recordedFilePath = null;
          _savedVoiceNoteUrl = null;
          _isVoiceMode = false;
          _recordingSeconds = 0;
          _isUploading = false;
          _uploadProgress = 0.0;
        });

        Fluttertoast.showToast(
          msg: 'Uploaded successfully',
          backgroundColor: kPrimaryColor,
          textColor: white,
          toastLength: Toast.LENGTH_SHORT,
        );
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
      });
      Fluttertoast.showToast(
        msg: 'Error saving notes: $e',
        backgroundColor: Colors.red,
        textColor: white,
      );
    }
  }

  String _formatDate(DateTime value) {
    return '${value.day.toString().padLeft(2, '0')}/'
        '${value.month.toString().padLeft(2, '0')}/'
        '${value.year}';
  }

  String _formatTime(TimeOfDay value) {
    return MaterialLocalizations.of(context).formatTimeOfDay(value);
  }

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;
    return PopScope(
      canPop: !_isUploading,
      onPopInvoked: (didPop) {
        if (!didPop && _isUploading) {
          Fluttertoast.showToast(
            msg: 'Please wait, uploading voice note...',
            backgroundColor: Colors.orange,
            textColor: white,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'கோச்சார முழு விவரங்கள்',
            style: TextStyle(
              fontFamily: 'TamilArima',
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
              _buildDetailCard(rs),
              SizedBox(height: rs.rh(16)),
              Text(
                'கோச்சார சார்ட்',
                style: TextStyle(
                  fontFamily: 'TamilArima',
                  fontSize: rs.sp(15.5),
                  fontWeight: FontWeight.w700,
                  color: kIndigoDark,
                ),
              ),
              SizedBox(height: rs.rh(10)),
              _GocharamChartView(
                innerData: widget.kattamBoxes,
                outerData: _gocharamBoxes,
                planetDegrees: widget.planetDegrees,
                onEditBox: (boxIndex, boxData) async {
                  await widget.onEditBox(
                    boxIndex,
                    boxData,
                    (updatedBox) {
                      setState(() {
                        _gocharamBoxes[boxIndex] = updatedBox;
                      });
                    },
                  );
                },
              ),
              SizedBox(height: rs.rh(20)),
              _buildNotesSection(rs),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotesSection(ResponsiveScale rs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'குறிப்புகள்',
              style: TextStyle(
                fontFamily: 'TamilArima',
                fontSize: rs.sp(15.5),
                fontWeight: FontWeight.w700,
                color: kIndigoDark,
              ),
            ),
            const Spacer(),
            Switch(
              value: _showAddNoteSection,
              onChanged: (value) {
                setState(() {
                  _showAddNoteSection = value;
                  if (!value) {
                    _textController.clear();
                    _recordedFilePath = null;
                    _savedVoiceNoteUrl = null;
                    _isVoiceMode = false;
                    _editingNoteIndex = null;
                  }
                });
              },
              activeColor: kPrimaryColor,
            ),
          ],
        ),
        SizedBox(height: rs.rh(12)),

        // Add note section (only shown when toggle is ON)
        if (_showAddNoteSection) ...[
          _buildNoteTypeToggle(rs),
          SizedBox(height: rs.rh(16)),
          if (_isVoiceMode)
            _buildVoiceNoteSection(rs)
          else
            _buildTextNoteSection(rs),
          SizedBox(height: rs.rh(20)),
          _buildSaveButton(rs),
          SizedBox(height: rs.rh(20)),
        ],

        // Saved notes list
        if (_savedNotes.isNotEmpty) ...[
          Text(
            'Your Notes',
            style: TextStyle(
              fontFamily: 'TamilArima',
              fontSize: rs.sp(18),
              fontWeight: FontWeight.w600,
              color: kIndigoDark.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: rs.rh(12)),
          ..._savedNotes.asMap().entries.map((entry) {
            final index = entry.key;
            final note = entry.value;
            return _buildSavedNoteTile(rs, note, index);
          }).toList(),
        ],

        // No notes saved message
        if (_savedNotes.isEmpty) ...[
          Center(
            child: Text(
              'No notes saved yet',
              style: TextStyle(
                fontFamily: 'TamilArima',
                fontSize: rs.sp(18),
                fontWeight: FontWeight.w600,
                color: kIndigoDark.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],

        SizedBox(height: rs.rh(150)),
      ],
    );
  }

  Widget _buildNoteTypeToggle(ResponsiveScale rs) {
    return Container(
      decoration: BoxDecoration(
        color: kPrimaryLightColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(rs.r(12)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isVoiceMode = false;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: rs.rh(12)),
                decoration: BoxDecoration(
                  color: !_isVoiceMode ? kPrimaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(rs.r(12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.text_fields,
                      size: rs.r(20),
                      color: !_isVoiceMode ? white : kIndigoDark,
                    ),
                    SizedBox(width: rs.rw(8)),
                    Text(
                      'Text Note',
                      style: TextStyle(
                        fontFamily: 'TamilArima',
                        fontSize: rs.sp(13),
                        fontWeight: FontWeight.w600,
                        color: !_isVoiceMode ? white : kIndigoDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isVoiceMode = true;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: rs.rh(12)),
                decoration: BoxDecoration(
                  color: _isVoiceMode ? kPrimaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(rs.r(12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.mic,
                      size: rs.r(20),
                      color: _isVoiceMode ? white : kIndigoDark,
                    ),
                    SizedBox(width: rs.rw(8)),
                    Text(
                      'Voice Note',
                      style: TextStyle(
                        fontFamily: 'TamilArima',
                        fontSize: rs.sp(13),
                        fontWeight: FontWeight.w600,
                        color: _isVoiceMode ? white : kIndigoDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceNoteSection(ResponsiveScale rs) {
    return Container(
      padding: EdgeInsets.all(rs.r(16)),
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
        children: [
          // Recording controls
          if (!_isRecording &&
              _recordedFilePath == null &&
              _savedVoiceNoteUrl == null)
            Center(
              child: ElevatedButton.icon(
                onPressed: _startRecording,
                icon: Icon(Icons.mic, size: rs.r(24)),
                label: Text(
                  'Start Recording',
                  style: TextStyle(
                    fontSize: rs.sp(14),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: white,
                  padding: EdgeInsets.symmetric(
                    horizontal: rs.rw(24),
                    vertical: rs.rh(14),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(rs.r(12)),
                  ),
                ),
              ),
            ),

          // Recording in progress
          if (_isRecording)
            Column(
              children: [
                Container(
                  padding: EdgeInsets.all(rs.r(20)),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.mic,
                    color: Colors.red,
                    size: rs.r(40),
                  ),
                ),
                SizedBox(height: rs.rh(12)),
                Text(
                  'Recording...',
                  style: TextStyle(
                    fontSize: rs.sp(14),
                    fontWeight: FontWeight.w700,
                    color: Colors.red,
                  ),
                ),
                SizedBox(height: rs.rh(8)),
                Text(
                  _formatDuration(_recordingSeconds),
                  style: TextStyle(
                    fontSize: rs.sp(20),
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                    fontFamily: 'monospace',
                  ),
                ),
                SizedBox(height: rs.rh(16)),
                ElevatedButton.icon(
                  onPressed: _stopRecording,
                  icon: Icon(Icons.stop, size: rs.r(24)),
                  label: Text(
                    'Stop Recording',
                    style: TextStyle(
                      fontSize: rs.sp(14),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: white,
                    padding: EdgeInsets.symmetric(
                      horizontal: rs.rw(24),
                      vertical: rs.rh(14),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(rs.r(12)),
                    ),
                  ),
                ),
              ],
            ),

          // Recorded audio playback
          if (!_isRecording &&
              (_recordedFilePath != null || _savedVoiceNoteUrl != null))
            Column(
              children: [
                Container(
                  padding: EdgeInsets.all(rs.r(12)),
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(rs.r(12)),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: _isPlaying ? _stopPlaying : _playRecording,
                        icon: Icon(
                          _isPlaying
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_filled,
                          color: kPrimaryColor,
                          size: rs.r(48),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isPlaying ? 'Playing...' : 'Voice Note',
                              style: TextStyle(
                                fontSize: rs.sp(13),
                                fontWeight: FontWeight.w600,
                                color: kIndigoDark,
                              ),
                            ),
                            SizedBox(height: rs.rh(4)),
                            Text(
                              _isPlaying
                                  ? '${_formatPlaybackDuration(_playbackPosition)} / ${_formatPlaybackDuration(_playbackDuration)}'
                                  : _formatPlaybackDuration(_playbackDuration),
                              style: TextStyle(
                                fontSize: rs.sp(11),
                                color: kIndigoDark.withValues(alpha: 0.6),
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _deleteRecording,
                        icon: Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: rs.r(24),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isPlaying)
                  Padding(
                    padding: EdgeInsets.only(top: rs.rh(8)),
                    child: LinearProgressIndicator(
                      value: _playbackDuration.inMilliseconds > 0
                          ? _playbackPosition.inMilliseconds /
                              _playbackDuration.inMilliseconds
                          : 0,
                      backgroundColor: kPrimaryLightColor,
                      color: kPrimaryColor,
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _formatPlaybackDuration(Duration duration) {
    final mins = duration.inMinutes;
    final secs = duration.inSeconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Widget _buildSavedNoteTile(ResponsiveScale rs, _SavedNote note, int index) {
    return Padding(
      padding: EdgeInsets.only(bottom: rs.rh(12)),
      child: Slidable(
        key: ValueKey(note.id),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (context) => _editNote(index),
              backgroundColor: kPrimaryColor,
              foregroundColor: white,
              icon: Icons.edit,
              label: 'Edit',
            ),
            SlidableAction(
              onPressed: (context) => _deleteNote(index),
              backgroundColor: Colors.red,
              foregroundColor: white,
              icon: Icons.delete,
              label: 'Delete',
            ),
          ],
        ),
        child: Container(
          padding: EdgeInsets.all(rs.r(14)),
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(rs.r(12)),
            border: Border.all(color: kPrimaryLightColor, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: kPrimaryColor.withValues(alpha: 0.05),
                blurRadius: rs.r(8),
                offset: Offset(0, rs.rh(3)),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    note.voiceNoteUrl != null ? Icons.mic : Icons.text_fields,
                    color: kPrimaryColor,
                    size: rs.r(20),
                  ),
                  SizedBox(width: rs.rw(8)),
                  Expanded(
                    child: Text(
                      _formatDateTime(note.createdAt),
                      style: TextStyle(
                        fontSize: rs.sp(11),
                        color: kIndigoDark.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ],
              ),
              if (note.textNote != null && note.textNote!.isNotEmpty) ...[
                SizedBox(height: rs.rh(8)),
                Text(
                  note.textNote!,
                  style: TextStyle(
                    fontSize: rs.sp(14),
                    color: kIndigoDark,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (note.voiceNoteUrl != null) ...[
                SizedBox(height: rs.rh(8)),
                Container(
                  padding: EdgeInsets.all(rs.r(12)),
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(rs.r(8)),
                    border: Border.all(
                      color: kPrimaryColor.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Progress bar
                      if (_playingNoteIndex == index &&
                          _savedNoteDuration.inSeconds > 0)
                        Column(
                          children: [
                            SliderTheme(
                              data: SliderThemeData(
                                activeTrackColor: kPrimaryColor,
                                inactiveTrackColor:
                                    kPrimaryColor.withValues(alpha: 0.2),
                                thumbColor: kPrimaryColor,
                                overlayColor:
                                    kPrimaryColor.withValues(alpha: 0.2),
                                trackHeight: 3.0,
                                thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 6.0),
                              ),
                              child: Slider(
                                value: _savedNotePosition.inSeconds
                                    .toDouble()
                                    .clamp(
                                      0.0,
                                      _savedNoteDuration.inSeconds.toDouble(),
                                    ),
                                max: _savedNoteDuration.inSeconds.toDouble() > 0
                                    ? _savedNoteDuration.inSeconds.toDouble()
                                    : 1.0,
                                onChanged: (value) async {
                                  final position =
                                      Duration(seconds: value.toInt());
                                  setState(() {
                                    _savedNotePosition = position;
                                  });
                                  await _savedNotePlayer.seek(position);
                                },
                              ),
                            ),
                            Padding(
                              padding:
                                  EdgeInsets.symmetric(horizontal: rs.rw(12)),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatDuration(
                                        _savedNotePosition.inSeconds),
                                    style: TextStyle(
                                      fontSize: rs.sp(11),
                                      color: kIndigoDark.withValues(alpha: 0.7),
                                    ),
                                  ),
                                  Text(
                                    _formatDuration(
                                        _savedNoteDuration.inSeconds),
                                    style: TextStyle(
                                      fontSize: rs.sp(11),
                                      color: kIndigoDark.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: rs.rh(8)),
                          ],
                        ),
                      // Control buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_playingNoteIndex == index) ...[
                            // Pause/Resume button
                            IconButton(
                              onPressed: () async {
                                final state = _savedNotePlayer.state;
                                if (state == PlayerState.playing) {
                                  await _pauseSavedNote();
                                } else if (state == PlayerState.paused) {
                                  await _resumeSavedNote();
                                }
                                setState(() {});
                              },
                              icon: Icon(
                                _savedNotePlayer.state == PlayerState.playing
                                    ? Icons.pause_circle_filled
                                    : Icons.play_circle_filled,
                                color: kPrimaryColor,
                                size: rs.r(40),
                              ),
                            ),
                            SizedBox(width: rs.rw(12)),
                            // Stop button
                            IconButton(
                              onPressed: _stopSavedNote,
                              icon: Icon(
                                Icons.stop_circle,
                                color: Colors.red,
                                size: rs.r(40),
                              ),
                            ),
                          ] else ...[
                            // Play button
                            InkWell(
                              onTap: () => _playNoteAudio(index),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: rs.rw(16),
                                  vertical: rs.rh(8),
                                ),
                                decoration: BoxDecoration(
                                  color: kPrimaryColor,
                                  borderRadius: BorderRadius.circular(rs.r(20)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.play_arrow,
                                      color: white,
                                      size: rs.r(20),
                                    ),
                                    SizedBox(width: rs.rw(6)),
                                    Text(
                                      'Play Voice Note',
                                      style: TextStyle(
                                        fontSize: rs.sp(13),
                                        color: white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inDays == 0) {
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return 'Today at $hour:$minute';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  Future<void> _playNoteAudio(int noteIndex) async {
    try {
      final audioPath = _savedNotes[noteIndex].voiceNoteUrl;
      if (audioPath == null) return;

      // If same note is playing, do nothing (use pause/resume buttons instead)
      if (_playingNoteIndex == noteIndex) {
        return;
      }

      // Stop any currently playing note
      if (_playingNoteIndex != null) {
        await _savedNotePlayer.stop();
      }

      // Reset position and duration
      setState(() {
        _playingNoteIndex = noteIndex;
        _savedNotePosition = Duration.zero;
        _savedNoteDuration = Duration.zero;
      });

      if (File(audioPath).existsSync()) {
        await _savedNotePlayer.play(DeviceFileSource(audioPath));
      } else {
        await _savedNotePlayer.play(UrlSource(audioPath));
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error playing audio',
        backgroundColor: Colors.red,
        textColor: white,
      );
      setState(() {
        _playingNoteIndex = null;
      });
    }
  }

  Future<void> _pauseSavedNote() async {
    await _savedNotePlayer.pause();
  }

  Future<void> _resumeSavedNote() async {
    await _savedNotePlayer.resume();
  }

  Future<void> _stopSavedNote() async {
    await _savedNotePlayer.stop();
    setState(() {
      _playingNoteIndex = null;
      _savedNotePosition = Duration.zero;
      _savedNoteDuration = Duration.zero;
    });
  }

  void _editNote(int index) {
    final note = _savedNotes[index];
    setState(() {
      _editingNoteIndex = index;
      _showAddNoteSection = true;
      _textController.text = note.textNote ?? '';

      if (note.voiceNoteUrl != null) {
        _isVoiceMode = true;
        _savedVoiceNoteUrl = note.voiceNoteUrl;
        _recordedFilePath = note.voiceNoteUrl;
      } else {
        _isVoiceMode = false;
      }
    });
  }

  Future<void> _deleteNote(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final rs = context.rs;
        return AlertDialog(
          title: Text(
            'Delete Note?',
            style: TextStyle(
              fontFamily: 'TamilArima',
              fontSize: rs.sp(18),
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Are you sure you want to delete this note?',
            style: TextStyle(fontSize: rs.sp(15)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Cancel',
                style: TextStyle(fontSize: rs.sp(15)),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(
                'Delete',
                style: TextStyle(
                  fontSize: rs.sp(15),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        // Delete audio file if exists
        final note = _savedNotes[index];
        if (note.voiceNoteUrl != null &&
            File(note.voiceNoteUrl!).existsSync()) {
          await File(note.voiceNoteUrl!).delete();
        }

        setState(() {
          _savedNotes.removeAt(index);
        });

        // Update Firestore
        final collection =
            FirebaseFirestore.instance.collection('AstrologyProfiles');
        final profileDoc = await collection.doc(widget.entry.profileId).get();

        if (profileDoc.exists) {
          final data = profileDoc.data()!;
          final gocharamEntries = (data['gocharamParvaEntries'] as List?)
                  ?.map((e) => Map<String, dynamic>.from(e as Map))
                  .toList() ??
              [];

          final entryIndex = gocharamEntries.indexWhere(
            (e) => e['number'] == widget.entry.number,
          );

          if (entryIndex >= 0) {
            gocharamEntries[entryIndex]['notes'] =
                _savedNotes.map((n) => n.toMap()).toList();

            await collection.doc(widget.entry.profileId).update({
              'gocharamParvaEntries': gocharamEntries,
              'updatedAt': FieldValue.serverTimestamp(),
            });
          }
        }

        Fluttertoast.showToast(
          msg: 'Note deleted',
          backgroundColor: Colors.orange,
          textColor: white,
        );
      } catch (e) {
        Fluttertoast.showToast(
          msg: 'Error deleting note',
          backgroundColor: Colors.red,
          textColor: white,
        );
      }
    }
  }

  Widget _buildTextNoteSection(ResponsiveScale rs) {
    return Container(
      padding: EdgeInsets.all(rs.r(16)),
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
      child: TextField(
        controller: _textController,
        maxLines: 6,
        decoration: InputDecoration(
          hintText: 'Type your notes here...',
          hintStyle: TextStyle(
            fontSize: rs.sp(13),
            color: kIndigoDark.withValues(alpha: 0.5),
          ),
          border: InputBorder.none,
        ),
        style: TextStyle(
          fontSize: rs.sp(16),
          color: kIndigoDark,
        ),
      ),
    );
  }

  Widget _buildSaveButton(ResponsiveScale rs) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isUploading ? null : _saveNotes,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isUploading ? Colors.grey : kPrimaryColor,
          foregroundColor: white,
          padding: EdgeInsets.symmetric(vertical: rs.rh(14)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(rs.r(12)),
          ),
        ),
        child: _isUploading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: rs.r(16),
                    height: rs.r(16),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(white),
                      value: _uploadProgress,
                    ),
                  ),
                  SizedBox(width: rs.rw(10)),
                  Text(
                    'பதிவேற்றுகிறது... ${(_uploadProgress * 100).toInt()}%',
                    style: TextStyle(
                      fontFamily: 'TamilArima',
                      fontSize: rs.sp(14),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              )
            : Text(
                'சேமி',
                style: TextStyle(
                  fontFamily: 'TamilArima',
                  fontSize: rs.sp(14),
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }

  Widget _buildDetailCard(ResponsiveScale rs) {
    return Container(
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
          Text(
            'கோச்சார நேரம்',
            style: TextStyle(
              fontFamily: 'TamilArima',
              fontSize: rs.sp(14),
              fontWeight: FontWeight.w700,
              color: kIndigoDark,
            ),
          ),
          SizedBox(height: rs.rh(10)),
          Row(
            children: [
              Icon(
                Icons.event,
                size: rs.r(16),
                color: kPrimaryColor,
              ),
              SizedBox(width: rs.rw(6)),
              Text(
                _formatDate(widget.entry.date),
                style: TextStyle(
                  fontFamily: 'TamilArima',
                  fontSize: rs.sp(12.5),
                  fontWeight: FontWeight.w600,
                  color: kIndigoDark,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.access_time,
                size: rs.r(16),
                color: kPrimaryColor,
              ),
              SizedBox(width: rs.rw(6)),
              Text(
                _formatTime(widget.entry.time),
                style: TextStyle(
                  fontFamily: 'TamilArima',
                  fontSize: rs.sp(12.5),
                  fontWeight: FontWeight.w600,
                  color: kIndigoDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GocharamChartView extends StatefulWidget {
  const _GocharamChartView({
    required this.innerData,
    required this.outerData,
    required this.planetDegrees,
    required this.onEditBox,
  });

  final List<_ChartBoxData> innerData;
  final List<_ChartBoxData> outerData;
  final Map<String, String> planetDegrees;
  final Future<void> Function(int, _ChartBoxData) onEditBox;

  @override
  State<_GocharamChartView> createState() => _GocharamChartViewState();
}

class _GocharamChartViewState extends State<_GocharamChartView> {
  bool _showInnerOnTop = true;

  @override
  Widget build(BuildContext context) {
    final rs = context.rs;
    final outerLabels = _AstrologyChartScreenState._kattamOrder
        .map((value) => 'CO-$value')
        .toList(growable: false);

    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final spacingOuter = rs.r(6);
          final outerCellSize = (constraints.maxWidth - spacingOuter * 3) / 4;

          final innerScale = 0.66;
          final innerCellSize = outerCellSize * innerScale;
          final innerSpacing = spacingOuter * innerScale;
          final innerSize = innerCellSize * 4 + innerSpacing * 3;
          final innerOffset = (constraints.maxWidth - innerSize) / 2;

          final centerSize = innerCellSize * 2 + innerSpacing;
          final centerOffset = innerOffset + innerCellSize + innerSpacing;

          List<Widget> buildOuterRing(
            List<String> labels,
            List<_ChartBoxData> data,
            double offset,
            double cellSize,
            double spacing,
          ) {
            final boxes = <Widget>[];
            var ringIndex = 0;
            for (var row = 0; row < 4; row++) {
              for (var col = 0; col < 4; col++) {
                final isCenter = row >= 1 && row <= 2 && col >= 1 && col <= 2;
                if (isCenter) continue;
                final label = labels[ringIndex];
                final boxData = data[ringIndex];
                final boxIndex = ringIndex;
                ringIndex += 1;
                boxes.add(
                  Positioned(
                    left: offset + col * (cellSize + spacing),
                    top: offset + row * (cellSize + spacing),
                    child: _buildGocharamOuterBox(
                      label: label,
                      data: boxData,
                      size: cellSize,
                      onTap: () => widget.onEditBox(boxIndex, boxData),
                    ),
                  ),
                );
              }
            }
            return boxes;
          }

          List<Widget> buildDataRing(
            List<_ChartBoxData> data,
            double offset,
            double cellSize,
            double spacing,
          ) {
            final boxes = <Widget>[];
            var ringIndex = 0;
            for (var row = 0; row < 4; row++) {
              for (var col = 0; col < 4; col++) {
                final isCenter = row >= 1 && row <= 2 && col >= 1 && col <= 2;
                if (isCenter) continue;
                final boxData = data[ringIndex];
                ringIndex += 1;
                boxes.add(
                  Positioned(
                    left: offset + col * (cellSize + spacing),
                    top: offset + row * (cellSize + spacing),
                    child: _buildGocharamDataBox(
                      data: boxData,
                      size: cellSize,
                    ),
                  ),
                );
              }
            }
            return boxes;
          }

          final widgets = <Widget>[];
          if (!_showInnerOnTop) {
            widgets.addAll(
              buildDataRing(
                widget.innerData,
                innerOffset,
                innerCellSize,
                innerSpacing,
              ),
            );
          }
          widgets.addAll(
            buildOuterRing(
              outerLabels,
              widget.outerData,
              0,
              outerCellSize,
              spacingOuter,
            ),
          );
          if (_showInnerOnTop) {
            widgets.addAll(
              buildDataRing(
                widget.innerData,
                innerOffset,
                innerCellSize,
                innerSpacing,
              ),
            );
          }
          widgets.add(
            Positioned(
              left: centerOffset,
              top: centerOffset,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _showInnerOnTop = !_showInnerOnTop;
                  });
                },
                borderRadius: BorderRadius.circular(rs.r(8)),
                child: Container(
                  width: centerSize,
                  height: centerSize,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: white,
                    borderRadius: BorderRadius.circular(rs.r(8)),
                    border: Border.all(color: kPrimaryLightColor),
                  ),
                  child: Transform.scale(
                    scale: 0.8,
                    alignment: Alignment.center,
                    child: _buildCenterPlanetSummary(),
                  ),
                ),
              ),
            ),
          );

          return Stack(children: widgets);
        },
      ),
    );
  }

  Widget _buildGocharamOuterBox({
    required String label,
    required _ChartBoxData data,
    required double size,
    required VoidCallback onTap,
  }) {
    final rs = context.rs;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(rs.r(6)),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(rs.r(6)),
          border: Border.all(color: kPrimaryLightColor),
        ),
        child: Padding(
          padding: EdgeInsets.all(rs.r(3)),
          child: Stack(
            children: [
              _PositionedValue(
                alignment: Alignment.topLeft,
                value: data.topLeft,
                onTap: () {},
                enabled: false,
                hideEmptyPlus: true,
                fontScale: 0.75,
              ),
              _PositionedValue(
                alignment: Alignment.topRight,
                value: data.topRight,
                onTap: () {},
                enabled: false,
                hideEmptyPlus: true,
                fontScale: 0.75,
              ),
              _PositionedValue(
                alignment: Alignment.bottomLeft,
                value: data.bottomLeft,
                onTap: () {},
                enabled: false,
                hideEmptyPlus: true,
                fontScale: 0.75,
              ),
              _PositionedValue(
                alignment: Alignment.bottomRight,
                value: data.bottomRight,
                onTap: () {},
                enabled: false,
                hideEmptyPlus: true,
                fontScale: 0.75,
              ),
              _PositionedValue(
                alignment: Alignment.center,
                value: data.center,
                onTap: () {},
                enabled: false,
                hideEmptyPlus: true,
                isCenter: true,
                fontScale: 0.75,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGocharamDataBox({
    required _ChartBoxData data,
    required double size,
  }) {
    final rs = context.rs;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(rs.r(6)),
        border: Border.all(color: kPrimaryLightColor, width: 1.2),
      ),
      child: Padding(
        padding: EdgeInsets.all(rs.r(2)),
        child: Container(
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(rs.r(5)),
            border: Border.all(color: kPrimaryLightColor, width: 1.0),
          ),
          child: Stack(
            children: [
              _PositionedValue(
                alignment: Alignment.topLeft,
                value: data.topLeft,
                onTap: () {},
                enabled: false,
                hideEmptyPlus: true,
                valueColor: _kattamColorForValue,
                fontScale: 0.7,
              ),
              _PositionedValue(
                alignment: Alignment.topRight,
                value: data.topRight,
                onTap: () {},
                enabled: false,
                hideEmptyPlus: true,
                valueColor: _kattamColorForValue,
                fontScale: 0.7,
              ),
              _PositionedValue(
                alignment: Alignment.bottomLeft,
                value: data.bottomLeft,
                onTap: () {},
                enabled: false,
                hideEmptyPlus: true,
                valueColor: _kattamColorForValue,
                fontScale: 0.7,
              ),
              _PositionedValue(
                alignment: Alignment.bottomRight,
                value: data.bottomRight,
                onTap: () {},
                enabled: false,
                hideEmptyPlus: true,
                valueColor: _kattamColorForValue,
                fontScale: 0.7,
              ),
              _PositionedValue(
                alignment: Alignment.center,
                value: data.center,
                onTap: () {},
                enabled: false,
                hideEmptyPlus: true,
                isCenter: true,
                valueColor: _kattamColorForValue,
                fontScale: 0.7,
              ),
            ],
          ),
        ),
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
      'lagnam': widget.planetDegrees['lagnam'],
      'jupiter': widget.planetDegrees['jupiter'],
      'sun': widget.planetDegrees['sun'],
      'venus': widget.planetDegrees['venus'],
      'moon': widget.planetDegrees['moon'],
      'saturn': widget.planetDegrees['saturn'],
      'mars': widget.planetDegrees['mars'],
      'rahu': widget.planetDegrees['rahu'],
      'mercury': widget.planetDegrees['mercury'],
      'ketu': widget.planetDegrees['ketu'],
    };

    final allEmpty =
        values.values.every((value) => value == null || value.trim().isEmpty);
    if (allEmpty) {
      return Center(
        child: Text(
          'தகவல் இல்லை',
          style: TextStyle(
            fontFamily: 'TamilArima',
            fontSize: rs.sp(12),
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
                                  fontSize: rs.sp(10),
                                  color: kIndigoLight.withValues(alpha: 0.9),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '  ||  ',
                              style: TextStyle(
                                fontFamily: 'TamilArima',
                                fontSize: rs.sp(10),
                                color: kIndigoLight.withValues(alpha: 0.9),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                formatEntry(pair[1]),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'TamilArima',
                                  fontSize: rs.sp(10),
                                  color: kIndigoLight.withValues(alpha: 0.9),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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

  Color? _kattamColorForValue(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return _AstrologyChartScreenState._kattamColors[trimmed];
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
    this.fontScale = 1.0,
  });

  final Alignment alignment;
  final String value;
  final VoidCallback onTap;
  final bool isCenter;
  final bool enabled;
  final bool hideEmptyPlus;
  final Color? Function(String value)? valueColor;
  final double fontScale;

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
        (isCenter ? (tokens.length > 1 ? rs.sp(11) : rs.sp(13.5)) : rs.sp(12)) *
            fontScale;
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

class _GocharamParvaEntry {
  final String id;
  final int number;
  final DateTime date;
  final TimeOfDay time;
  final List<_ChartBoxData> gocharamBoxes;
  final String? textNote;
  final String? voiceNoteUrl;
  final String profileId;

  const _GocharamParvaEntry({
    required this.id,
    required this.number,
    required this.date,
    required this.time,
    required this.gocharamBoxes,
    this.textNote,
    this.voiceNoteUrl,
    required this.profileId,
  });

  factory _GocharamParvaEntry.fromMap(Map<dynamic, dynamic> map,
      {String? profileId}) {
    final rawDate = map['date'];
    final dateValue = rawDate is Timestamp
        ? rawDate.toDate()
        : DateTime.tryParse((rawDate ?? '').toString());
    final rawTime = (map['time'] ?? '').toString();
    final parts = rawTime.split(':');
    final hour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;

    // Parse gocharamBoxes
    List<_ChartBoxData> boxes = [];
    final rawBoxes = map['gocharamBoxes'];
    if (rawBoxes is List) {
      boxes = rawBoxes
          .whereType<Map>()
          .map((box) => _ChartBoxData.fromMap(Map<String, String>.from(
              box.map((k, v) => MapEntry(k.toString(), v.toString())))))
          .toList();
    }
    // Ensure we have exactly 12 boxes
    while (boxes.length < 12) {
      boxes.add(_ChartBoxData.empty());
    }
    if (boxes.length > 12) {
      boxes = boxes.take(12).toList();
    }

    return _GocharamParvaEntry(
      id: (map['id'] ?? DateTime.now().microsecondsSinceEpoch.toString())
          .toString(),
      number: int.tryParse((map['number'] ?? '').toString()) ?? 0,
      date: dateValue ?? DateTime.now(),
      time: TimeOfDay(hour: hour, minute: minute),
      gocharamBoxes: boxes,
      textNote: map['textNote']?.toString(),
      voiceNoteUrl: map['voiceNoteUrl']?.toString(),
      profileId: profileId ?? map['profileId']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'number': number,
      'date': Timestamp.fromDate(date),
      'time':
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
      'gocharamBoxes': gocharamBoxes.map((box) => box.toMap()).toList(),
      if (textNote != null) 'textNote': textNote,
      if (voiceNoteUrl != null) 'voiceNoteUrl': voiceNoteUrl,
      'profileId': profileId,
    };
  }

  _GocharamParvaEntry copyWith({
    int? number,
    DateTime? date,
    TimeOfDay? time,
    List<_ChartBoxData>? gocharamBoxes,
    String? textNote,
    String? voiceNoteUrl,
  }) {
    return _GocharamParvaEntry(
      id: id,
      number: number ?? this.number,
      date: date ?? this.date,
      time: time ?? this.time,
      gocharamBoxes: gocharamBoxes ?? this.gocharamBoxes,
      textNote: textNote ?? this.textNote,
      voiceNoteUrl: voiceNoteUrl ?? this.voiceNoteUrl,
      profileId: profileId,
    );
  }
}

class _SavedNote {
  final String id;
  final String? textNote;
  final String? voiceNoteUrl;
  final DateTime createdAt;

  _SavedNote({
    required this.id,
    this.textNote,
    this.voiceNoteUrl,
    required this.createdAt,
  });

  factory _SavedNote.fromMap(Map<dynamic, dynamic> map) {
    final rawDate = map['createdAt'];
    final dateValue = rawDate is Timestamp
        ? rawDate.toDate()
        : DateTime.tryParse((rawDate ?? '').toString()) ?? DateTime.now();

    return _SavedNote(
      id: map['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      textNote: map['textNote']?.toString(),
      voiceNoteUrl: map['voiceNoteUrl']?.toString(),
      createdAt: dateValue,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      if (textNote != null && textNote!.isNotEmpty) 'textNote': textNote,
      if (voiceNoteUrl != null && voiceNoteUrl!.isNotEmpty)
        'voiceNoteUrl': voiceNoteUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
