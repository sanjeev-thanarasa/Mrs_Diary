import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mrs_dth_diary_v1/scr/helpers/operations.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/gap.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/responsive.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/styles.dart';
import 'customText.dart';

class CListTile extends StatefulWidget {
  final BuildContext context;
  final String docId;
  final String collectionName;
  final VoidCallback? tileOnTap;
  final String? image;
  final Color? subCircleColor;
  final String title;
  final String subtitle;
  final String? subtitle2;
  final String? subtitle3;
  final IconData subtitleIcon;
  final String? counter;
  final String? pendingAmount;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool enableEdit;

  const CListTile({
    super.key,
    required this.context,
    required this.docId,
    required this.collectionName,
    this.tileOnTap,
    this.image,
    this.subCircleColor,
    required this.title,
    required this.subtitle,
    this.subtitle2,
    this.subtitle3,
    required this.subtitleIcon,
    this.counter,
    this.pendingAmount,
    this.onEdit,
    this.onDelete,
    this.enableEdit = true,
  });

  @override
  _CListTileState createState() => _CListTileState();
}

class _CListTileState extends State<CListTile> {
  @override
  Widget build(BuildContext context) {
    final rs = context.rs;
    final colorScheme = Theme.of(context).colorScheme;
    final actions = <Widget>[];
    if (widget.enableEdit) {
      actions.add(
        SlidableAction(
          onPressed: (_) {
            if (widget.onEdit != null) {
              widget.onEdit!.call();
            } else if (widget.tileOnTap != null) {
              widget.tileOnTap!.call();
            }
          },
          backgroundColor: kPrimaryColor,
          foregroundColor: white,
          icon: Icons.edit_rounded,
          label: "Edit",
          borderRadius: BorderRadius.circular(rs.r(16)),
        ),
      );
    }
    actions.add(
      SlidableAction(
        onPressed: (_) => _handleDelete(context),
        backgroundColor: red,
        foregroundColor: white,
        icon: Icons.delete_rounded,
        label: "Delete",
        borderRadius: BorderRadius.circular(rs.r(16)),
      ),
    );

    return Slidable(
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: actions,
      ),
      child: GestureDetector(
        onTap: widget.tileOnTap,
        child: Container(
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(rs.r(18)),
            border: Border.all(color: colorScheme.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: rs.r(12),
                offset: Offset(0, rs.r(6)),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(rs.r(18)),
              onTap: widget.tileOnTap,
              child: Padding(
                padding: EdgeInsets.all(rs.r(14)),
                child: Row(
                  children: [
                    _buildLeading(rs),
                    SizedBox(width: rs.rw(12)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: CText(
                                  msg: widget.title,
                                  color: kIndigoDark,
                                  size: widget.collectionName == "Villages"
                                      ? 18
                                      : 16,
                                  weight: FontWeight.w700,
                                ),
                              ),
                              if (widget.pendingAmount != null &&
                                  widget.pendingAmount!.isNotEmpty)
                                _buildAmountChip(widget.pendingAmount!),
                            ],
                          ),
                          SizedBox(height: rs.rh(6)),
                          Row(
                            children: [
                              Icon(
                                widget.subtitleIcon,
                                color: kBlueColor,
                                size: rs.r(12),
                              ),
                              SizedBox(width: rs.rw(4)),
                              Expanded(
                                child: CText(
                                  msg: widget.subtitle,
                                  size: 13,
                                  weight: FontWeight.w600,
                                  color: kIndigoLight,
                                ),
                              ),
                              if (widget.subtitle3 != null &&
                                  widget.subtitle3!.isNotEmpty)
                                Row(
                                  children: [
                                    Icon(
                                      Icons.people_alt_rounded,
                                      size: rs.r(13),
                                      color: kPrimaryColor,
                                    ),
                                    Gap(w: rs.rw(3.0)),
                                    CText(
                                      msg: widget.subtitle3 ?? "",
                                      size: 13,
                                      weight: FontWeight.w600,
                                      color: kPrimaryColor,
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: kIndigoLight,
                      size: rs.r(22),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeading(ResponsiveScale rs) {
    if (widget.image != null && widget.image!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(rs.r(16))),
        child: Image.asset(
          widget.image!,
          height: rs.r(56),
          width: rs.r(56),
          fit: BoxFit.cover,
        ),
      );
    }

    if (widget.counter != null && widget.counter!.isNotEmpty) {
      return CircleAvatar(
        radius: rs.r(24),
        backgroundColor: kPrimaryLightColor,
        child: CText(
          msg: widget.counter ?? "",
          color: kIndigoDark,
          size: 14,
          weight: FontWeight.w700,
        ),
      );
    }

    return CircleAvatar(
      radius: rs.r(24),
      backgroundColor: kPrimaryLightColor,
      child: Icon(
        Icons.account_balance_wallet_outlined,
        color: kIndigoDark,
        size: rs.r(20),
      ),
    );
  }

  Widget _buildAmountChip(String amount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: kPrimaryLightColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: CText(
        msg: amount,
        color: kIndigoDark,
        size: 12,
        weight: FontWeight.w700,
      ),
    );
  }

  Future<bool?> showAlertDialog({
    required BuildContext context,
    required String title,
    required String content,
  }) async {
    return showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: CText(msg: title, color: blue),
        content: CText(msg: content, color: red, size: 20.0),
        actions: <Widget>[
          CupertinoDialogAction(
            child: CText(
              msg: "No",
              color: blue,
            ),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          CupertinoDialogAction(
            child: CText(
              msg: "Yes",
              color: red,
            ),
            onPressed: () {
              deleteProduct(
                id: widget.docId,
                collectionName: widget.collectionName,
              );
              Navigator.of(context).pop(true);
            },
          ),
        ],
      ),
    );
  }

  void _handleDelete(BuildContext context) {
    if (widget.onDelete != null) {
      widget.onDelete!.call();
      return;
    }

    showAlertDialog(
      context: context,
      title: "Delete",
      content: "இந்த பதிவை நீக்க விரும்புகிறீர்களா ?",
    );
  }
}
