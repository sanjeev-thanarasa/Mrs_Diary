import 'package:flutter/material.dart';
import 'package:mrs_dth_diary_v1/scr/models/dropDownModel.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/styles.dart';
import 'customText.dart';

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
                        horizontal: 12.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: accent.withValues(alpha: 0.35),
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 10,
                          color: Colors.black.withValues(alpha: 0.04),
                          offset: const Offset(0, 6),
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: 36,
                          height: 36,
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
                                    height: 20,
                                    width: 20,
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
                                color: Colors.black87,
                                fontSize: 15.5,
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
                          size: 28,
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
                  padding: const EdgeInsets.only(bottom: 10),
                  decoration: new BoxDecoration(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20)),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          blurRadius: 4,
                          color: Colors.black26,
                          offset: Offset(0, 4))
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
    return Padding(
      padding: const EdgeInsets.only(left: 26.0, top: 5, bottom: 5),
      child: GestureDetector(
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.only(top: 20),
                decoration: BoxDecoration(
                  border: Border(
                      top: BorderSide(color: Colors.grey.shade200, width: 1)),
                ),
                child: Text(item.name,
                    style: TextStyle(
                        color: Color(0xFF307DF1),
                        fontWeight: FontWeight.w400,
                        fontSize: 14),
                    maxLines: 3,
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis),
              ),
            ),
          ],
        ),
        onTap: () {
          isShow = false;
          expandController.reverse();
          widget.onOptionSelected(item.name);
        },
      ),
    );
  }
}
