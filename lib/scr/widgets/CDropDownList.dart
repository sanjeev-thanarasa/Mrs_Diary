import 'package:flutter/material.dart';
import 'package:mrs_dth_diary_v1/scr/models/dropDownModel.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/styles.dart';

class SelectDropList extends StatefulWidget {
  final String itemSelected;
  final DropListModel dropListModel;
  final ValueChanged<String> onOptionSelected;
  final String? image;
  final bool onlyIcon;
  final double? iconSize;
  final Color? iconColor;

  const SelectDropList({
    super.key,
    required this.itemSelected,
    required this.dropListModel,
    required this.onOptionSelected,
    this.image,
    this.onlyIcon = false,
    this.iconSize,
    this.iconColor,
  });

  @override
  _SelectDropListState createState() => _SelectDropListState();
}

class _SelectDropListState extends State<SelectDropList>
    with SingleTickerProviderStateMixin {
  late final AnimationController expandController;
  late final Animation<double> animation;
  bool isShow = false;
  @override
  void initState() {
    super.initState();
    expandController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 350));
    animation = CurvedAnimation(
      parent: expandController,
      curve: Curves.fastOutSlowIn,
    );
    _runExpandCheck();
  }

  void _runExpandCheck() {
    if (isShow) {
      expandController.forward();
    } else {
      expandController.reverse();
    }
  }

  @override
  void dispose() {
    expandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.iconColor ?? mainBlue;
    return Container(
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              this.isShow = !this.isShow;
              _runExpandCheck();
              setState(() {});
            },
            child: widget.onlyIcon
                ? IconButton(
                    onPressed: () {
                      this.isShow = !this.isShow;
                      _runExpandCheck();
                      setState(() {});
                    },
                    icon: Icon(
                      Icons.arrow_drop_down_outlined,
                      size: widget.iconSize ?? 30.0,
                      color: accent,
                    ),
                  )
                : Container(
                    margin: const EdgeInsets.symmetric(vertical: 6.0),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 6.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: accent.withValues(alpha: 0.22),
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(14.0),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 12,
                          color: Colors.black.withValues(alpha: 0.05),
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: widget.image == null
                                ? const SizedBox(width: 20, height: 20)
                                : Image(
                                    image: AssetImage(widget.image!),
                                    fit: BoxFit.cover,
                                    height: 18,
                                    width: 18,
                                    color: accent,
                                  ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              this.isShow = !this.isShow;
                              _runExpandCheck();
                              setState(() {});
                            },
                            child: Text(
                              widget.itemSelected,
                              style: const TextStyle(
                                color: Colors.blueGrey,
                                fontSize: 15,
                                fontFamily: 'TamilArima',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        Icon(
                          isShow
                              ? Icons.keyboard_arrow_down_rounded
                              : Icons.keyboard_arrow_right_rounded,
                          color: Colors.black54,
                          size: 26,
                        ),
                      ],
                    ),
                  ),
          ),
          SizeTransition(
              axisAlignment: 1.0,
              sizeFactor: animation,
              child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: Colors.white,
                    border: Border.all(color: Colors.black12),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 10,
                        color: Colors.black.withValues(alpha: 0.06),
                        offset: const Offset(0, 6),
                      )
                    ],
                  ),
                  child: _buildDropListOptions(
                      widget.dropListModel.listOptionItems, context))),
          // AnimatedSizeTransition(
          //     duration: 500,
          //     child: Container(
          //         margin: const EdgeInsets.only(bottom: 10),
          //         padding: const EdgeInsets.only(bottom: 10),
          //         decoration: new BoxDecoration(
          //           borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
          //           color: Colors.white,
          //           boxShadow: [
          //             BoxShadow(
          //                 blurRadius: 4,
          //                 color: Colors.black26,
          //                 offset: Offset(0, 4))
          //           ],
          //         ),
          //         child: _buildDropListOptions(widget.dropListModel.listOptionItems, context)
          //     )
          // ),
//          Divider(color: Colors.grey.shade300, height: 1,)
        ],
      ),
    );
  }

  Column _buildDropListOptions(List<OptionItem> items, BuildContext context) {
    return Column(
      children: items.map((item) => _buildSubMenu(item, context)).toList(),
    );
  }

  Widget _buildSubMenu(OptionItem item, BuildContext context) {
    final accent = widget.iconColor ?? mainBlue;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          isShow = false;
          expandController.reverse();
          widget.onOptionSelected(item.name);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.name,
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
