import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mrs_dth_diary_v1/scr/helpers/owner_service.dart';
import 'package:mrs_dth_diary_v1/scr/ui/astrology_chart_screen.dart';
import 'package:mrs_dth_diary_v1/scr/ui/astrology_form_screen.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/responsive.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/styles.dart';

class AstrologyScreen extends StatefulWidget {
  const AstrologyScreen({super.key});

  @override
  State<AstrologyScreen> createState() => _AstrologyScreenState();
}

class _AstrologyScreenState extends State<AstrologyScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
          'Astrology',
          style: TextStyle(
            fontSize: rs.sp(22),
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateForm,
        backgroundColor: kPrimaryColor,
        child: Icon(Icons.add, color: Colors.white, size: rs.r(24)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(child: _buildProfilesList()),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilesList() {
    final ownerId = currentOwnerId();
    if (ownerId == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('AstrologyProfiles')
          .where('ownerId', isEqualTo: ownerId)
          .orderBy('updatedAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        final filtered = _filterProfiles(docs);
        if (filtered.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.separated(
          padding: EdgeInsets.fromLTRB(
            context.rs.rw(16),
            0,
            context.rs.rw(16),
            context.rs.rh(16),
          ),
          itemCount: filtered.length,
          separatorBuilder: (_, __) => SizedBox(height: context.rs.rh(10)),
          itemBuilder: (context, index) {
            return _buildProfileTile(filtered[index]);
          },
        );
      },
    );
  }

  List<AstrologyProfile> _filterProfiles(
    List<QueryDocumentSnapshot> docs,
  ) {
    final profiles = docs.map(AstrologyProfile.fromDoc).toList();
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) {
      return profiles;
    }
    return profiles
        .where(
          (profile) =>
              profile.name.toLowerCase().contains(query) ||
              profile.address.toLowerCase().contains(query),
        )
        .toList();
  }

  Widget _buildSearchBar() {
    final rs = context.rs;
    return Padding(
      padding: EdgeInsets.fromLTRB(rs.rw(16), rs.rh(12), rs.rw(16), rs.rh(12)),
      child: Container(
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(rs.r(14)),
          border: Border.all(color: kPrimaryLightColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: kPrimaryColor.withValues(alpha: 0.08),
              blurRadius: rs.r(8),
              offset: Offset(0, rs.rh(2)),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          style: TextStyle(
            color: kIndigoDark,
            fontSize: rs.sp(15),
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: 'Search profiles...',
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: rs.sp(14.5),
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: kPrimaryColor,
              size: rs.r(20),
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: rs.rw(16),
              vertical: rs.rh(14),
            ),
            isDense: true,
          ),
          onChanged: (value) => setState(() => _query = value),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final rs = context.rs;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: rs.rw(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: rs.r(72),
              height: rs.r(72),
              decoration: BoxDecoration(
                color: kPrimaryColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                color: kPrimaryColor,
                size: rs.r(36),
              ),
            ),
            SizedBox(height: rs.rh(16)),
            Text(
              'No profiles yet',
              style: TextStyle(
                fontSize: rs.sp(20),
                fontWeight: FontWeight.w700,
                color: kIndigoDark,
              ),
            ),
            SizedBox(height: rs.rh(8)),
            Text(
              'Create your first astrology profile using the + button.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: rs.sp(15.5),
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTile(AstrologyProfile profile) {
    final rs = context.rs;
    final date = DateFormat('dd MMM yyyy').format(profile.dob);
    final time = _formatTime(profile.birthTime);
    return Dismissible(
      key: ValueKey(profile.id),
      background: _buildSwipeAction(
        color: Colors.blue.shade50,
        icon: Icons.edit_rounded,
        label: 'Edit',
        alignment: Alignment.centerLeft,
      ),
      secondaryBackground: _buildSwipeAction(
        color: Colors.red.shade50,
        icon: Icons.delete_rounded,
        label: 'Delete',
        alignment: Alignment.centerRight,
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          await _openEditForm(profile);
          return false;
        }
        if (direction == DismissDirection.endToStart) {
          final confirmed = await _confirmDelete(profile);
          if (!confirmed) return false;
          await _deleteProfile(profile);
          return true;
        }
        return false;
      },
      child: Card(
        child: ListTile(
          leading: CircleAvatar(
            radius: rs.r(20),
            backgroundColor: kPrimaryLightColor,
            child: Icon(
              Icons.person_outline,
              color: kPrimaryColor,
              size: rs.r(20),
            ),
          ),
          title: Text(
            profile.name,
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: rs.sp(16)),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: rs.rh(4)),
              Text(profile.address, style: TextStyle(fontSize: rs.sp(13.5))),
              SizedBox(height: rs.rh(2)),
              Text(
                'Birth: $date · $time',
                style: TextStyle(fontSize: rs.sp(13.5)),
              ),
            ],
          ),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AstrologyChartScreen(profile: profile),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSwipeAction({
    required Color color,
    required IconData icon,
    required String label,
    required Alignment alignment,
  }) {
    final rs = context.rs;
    final isLeft = alignment == Alignment.centerLeft;
    return Container(
      alignment: alignment,
      padding: EdgeInsets.symmetric(horizontal: rs.rw(20)),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(rs.r(12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLeft) Icon(icon, color: kPrimaryColor),
          if (isLeft) SizedBox(width: rs.rw(6)),
          Text(
            label,
            style: TextStyle(
              color: kIndigoDark,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (!isLeft) SizedBox(width: rs.rw(6)),
          if (!isLeft) Icon(icon, color: Colors.redAccent),
        ],
      ),
    );
  }

  Future<void> _openEditForm(AstrologyProfile profile) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => AstrologyFormScreen(profile: profile)),
    );
    if (!mounted || saved != true) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved')),
    );
  }

  Future<bool> _confirmDelete(AstrologyProfile profile) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete profile?'),
        content: Text('Remove ${profile.name} profile?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _deleteProfile(AstrologyProfile profile) async {
    await FirebaseFirestore.instance
        .collection('AstrologyProfiles')
        .doc(profile.id)
        .delete();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Deleted')),
    );
  }

  String _formatTime(TimeOfDay time) {
    return MaterialLocalizations.of(context).formatTimeOfDay(time);
  }

  Future<void> _openCreateForm() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AstrologyFormScreen()),
    );
    if (!mounted || created != true) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved')),
    );
  }
}
