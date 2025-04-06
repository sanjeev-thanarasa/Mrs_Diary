import 'package:flutter/material.dart';
import 'package:mrs_dth_diary_v1/scr/models/dropDownModel.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/styles.dart';
import 'customText.dart';

class SelectDropList extends StatefulWidget {
  final String itemSelected;
  final DropListModel dropListModel;
  final Function(String) onOptionSelected;
  final String image;
  final bool onlyIcon;
  final double iconSize;
  final Color iconColor;

  const SelectDropList({Key key,
    this.itemSelected,
    this.dropListModel,
    this.onOptionSelected,
    this.image,
    this.onlyIcon=false,
    this.iconSize,
    this.iconColor
  }) : super(key: key);


  @override
  _SelectDropListState createState() => _SelectDropListState();
}

class _SelectDropListState extends State<SelectDropList> with SingleTickerProviderStateMixin {



  AnimationController expandController;
  Animation<double> animation;
  bool isShow = false;
  @override
  void initState() {
    super.initState();
    expandController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 350)
    );
    animation = CurvedAnimation(
      parent: expandController,
      curve: Curves.fastOutSlowIn,
    );
    _runExpandCheck();
  }

  void _runExpandCheck() {
    if(isShow) {
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
    return Container(
      child: Column(
        children: <Widget>[
         GestureDetector(
          onTap: (){
            this.isShow = !this.isShow;
            _runExpandCheck();},
            child:  widget.onlyIcon
                ? IconButton(
              onPressed: (){
                this.isShow = !this.isShow;
                _runExpandCheck();
                setState(() {

                });
              },
              icon: Icon(
                  Icons.arrow_drop_down_outlined,
                size: widget.iconSize ?? 30.0,

              ),)
                : Container(
              height: 50.0,
              margin:
              const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
              decoration: new BoxDecoration(
              border: Border.all(color: widget.iconColor ?? mainBlue, width: 1.0,),
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
            BoxShadow(
            blurRadius: 1,
            color: Colors.white,
                      offset: Offset(0, 2))
                ],
              ),
              child: new Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                      padding:
                      EdgeInsets.symmetric(vertical: 0.0, horizontal: 15.0),
                      child: Image(
                        image:AssetImage(
                        widget.image,
                      ),fit: BoxFit.cover,height: 30,width: 25,color: widget.iconColor ?? mainBlue,)
                  ),//////ICON OR IMAGE////////
                  Container(
                    height: 25.0,
                    width: 1.0,
                    color: widget.iconColor ?? mainBlue,
                    margin: const EdgeInsets.only(left: 00.0, right: 10.0),
                  ),///////// | //////////
                  SizedBox(width: 10,),
                  Expanded(
                      child: GestureDetector(
                        onTap: () {
                          this.isShow = !this.isShow;
                          _runExpandCheck();
                          setState(() {

                          });
                        },
                        child: CText(
                            msg:widget.itemSelected,
                            color: Colors.blue,
                            size: 16),
                      )
                  ),
                  Align(
                    alignment: Alignment(1, 0),
                    child: Icon(
                      isShow ? Icons.arrow_drop_down : Icons.arrow_right,
                      color: Colors.black,
                      size: 40,
                    ),
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
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          blurRadius: 4,
                          color: Colors.black26,
                          offset: Offset(0, 4))
                    ],
                  ),
                  child: _buildDropListOptions(widget.dropListModel.listOptionItems, context)
              )
          ),
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
                  border: Border(top: BorderSide(color: Colors.grey[200], width: 1)),
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