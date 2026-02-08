import 'package:flutter/material.dart';
import 'package:mrs_dth_diary_v1/scr/widgets/subHelpers/styles.dart';

class SimpleCalc extends StatefulWidget {
  const SimpleCalc({super.key});

  @override
  _SimpleCalcState createState() => _SimpleCalcState();
}

class _SimpleCalcState extends State<SimpleCalc> {
  final List<String> content = [
    "AC",
    "C",
    "/",
    "*",
    "7",
    "8",
    "9",
    "-",
    "4",
    "5",
    "6",
    "+",
    "1",
    "2",
    "3",
    "=",
    "0",
    ".",
  ];
  double result = 0;
  final CustomStk obj = CustomStk();

  @override
  Widget build(BuildContext context) {
    final expression = obj.getExpr();
    final resultText = _formatNumber(result);

    return SafeArea(
      child: Material(
        color: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.9,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              children: [
                Container(
                  height: 5,
                  width: 48,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calculate_rounded, color: kPrimaryColor),
                    const SizedBox(width: 8),
                    const Text(
                      "Calculator",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'TamilArima',
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                      tooltip: "Close",
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: kPrimaryColor.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        expression.isEmpty ? " " : expression,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: 'TamilArima',
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        resultText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 32,
                          fontFamily: 'Lobster',
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      const crossAxisCount = 4;
                      final rows = (content.length / crossAxisCount).ceil();
                      const spacing = 10.0;
                      final itemWidth = (constraints.maxWidth -
                              spacing * (crossAxisCount - 1)) /
                          crossAxisCount;
                      final itemHeight =
                          (constraints.maxHeight - spacing * (rows - 1)) / rows;
                      final aspectRatio =
                          itemHeight > 0 ? itemWidth / itemHeight : 1.0;

                      return GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: spacing,
                          crossAxisSpacing: spacing,
                          childAspectRatio: aspectRatio,
                        ),
                        itemCount: content.length,
                        itemBuilder: (context, index) =>
                            _buildKey(content[index]),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatNumber(double value) {
    final text = value.toString();
    if (text.contains('.')) {
      return text.replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
    }
    return text;
  }

  Widget _buildKey(String text) {
    final bool isOperator = ["+", "-", "*", "/"].contains(text);
    final bool isEqual = text == "=";
    final bool isClear = text == "AC" || text == "C";

    Color background;
    Color foreground;
    BorderSide border;
    double elevation = 0;

    if (isEqual) {
      background = kPrimaryColor;
      foreground = Colors.white;
      border = const BorderSide(color: kPrimaryColor);
      elevation = 1;
    } else if (isOperator) {
      background = kBlueColor;
      foreground = Colors.white;
      border = const BorderSide(color: kBlueColor);
      elevation = 1;
    } else if (isClear) {
      background = Colors.red.withValues(alpha: 0.1);
      foreground = Colors.red.shade700;
      border = BorderSide(color: Colors.red.withValues(alpha: 0.3));
    } else {
      background = Colors.white;
      foreground = Colors.black87;
      border = BorderSide(color: Colors.grey.shade300);
    }

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: elevation,
        backgroundColor: background,
        foregroundColor: foreground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: border,
        ),
        padding: EdgeInsets.zero,
      ),
      onPressed: () => _handleInput(text),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          fontFamily: 'TamilArima',
        ),
      ),
    );
  }

  void _handleInput(String text) {
    setState(() {
      if (text == "C") {
        result = obj.pop();
      } else if (text == "AC") {
        obj.clear();
        result = 0.0;
      } else if (text == "=") {
        result = obj.result;
        obj.clear();
        obj.cstStk.add(result.toString());
      } else {
        result = obj.push(text);
      }
    });
  }
}

class CustomStk {
  String num1 = "";
  double result = 0;
  int i = 0;
  List oprs = ["+", "*", "-", "/"];
  List nmbrs = List.generate(11, (n) => (n == 10) ? "." : n.toString());
  List cstStk = [];
  List opnStk = [];
  List oprStk = [];
  List rstStk = [];

  double push(t) {
    if (oprs.contains(t)) {
      (cstStk.isEmpty) ? cstStk.add("0") : 0;
      cstStk.add(t);
      num1 = "";
    } else if (nmbrs.contains(t)) {
      num1 += t;
      if (cstStk.isNotEmpty && !oprs.contains(cstStk.last)) cstStk.removeLast();
      cstStk.add(num1);
    }
    result = recalc();
    return result;
  }

  double recalc() {
    String t = "";
    oprStk.clear();
    opnStk.clear();
    rstStk.clear();
    for (i = 0; i < cstStk.length; i++) {
      t = cstStk[i];
      if (oprs.contains(t)) {
        while (oprStk.isNotEmpty && highP(t, oprStk.last)) {
          opnStk.add(oprStk.last);
          oprStk.removeLast();
        }
        oprStk.add(t);
      } else
        opnStk.add(t);
    }
    while (oprStk.isNotEmpty) {
      opnStk.add(oprStk.last);
      oprStk.removeLast();
    }
    for (i = 0; i < opnStk.length; i++) {
      t = opnStk[i];
      if (oprs.contains(t))
        doOp(t);
      else
        rstStk.add(double.parse(t));
    }
    if (rstStk.isEmpty)
      return 0;
    else
      return rstStk[0];
  }

  bool highP(t, topOfStk) {
    int currentP = getP(t);
    int tosP = getP(topOfStk);

    if (t == topOfStk) return false;
    if (tosP >= currentP)
      return true;
    else
      return false;
  }

  int getP(t) {
    if (t == "*" || t == "/")
      return 2;
    else
      return 1;
  }

  doOp(symbol) {
    double num1, num2;

    if (rstStk.length == 1) return rstStk[0];
    num1 = rstStk.last;
    rstStk.removeLast();
    num2 = rstStk.last;
    rstStk.removeLast();
    if (symbol == "+")
      rstStk.add(num1 + num2);
    else if (symbol == "-")
      rstStk.add(num2 - num1);
    else if (symbol == "*")
      rstStk.add(num1 * num2);
    else
      rstStk.add(num2 / num1);
  }

  pop() {
    num1 = "";
    if (cstStk.isNotEmpty) {
      String tmp = cstStk.last;
      if (tmp.length == 1)
        cstStk.removeLast();
      else {
        tmp = tmp.substring(0, tmp.length - 1);
        cstStk.removeLast();
        cstStk.add(tmp);
      }
    }
    return recalc();
  }

  clear() {
    if (rstStk.isNotEmpty) result = rstStk[0];
    num1 = "";
    cstStk.clear();
    opnStk.clear();
    oprStk.clear();
    rstStk.clear();
    return result;
  }

  getExpr() {
    String temp = "";
    for (i = 0; i < cstStk.length; i++) temp += cstStk[i];
    return temp;
  }
}
