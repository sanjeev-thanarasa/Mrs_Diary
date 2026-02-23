import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:convert';

enum DrawingTool {
  pen,
  pencil,
  brush,
  eraser,
  line,
  rectangle,
  circle,
  arrow,
  text,
}

class DrawingPad extends StatefulWidget {
  final String? initialDrawingData;
  final Function(String?) onDrawingChanged;

  const DrawingPad({
    super.key,
    this.initialDrawingData,
    required this.onDrawingChanged,
  });

  @override
  State<DrawingPad> createState() => _DrawingPadState();
}

class _DrawingPadState extends State<DrawingPad> {
  final GlobalKey _repaintBoundaryKey = GlobalKey();

  // Drawing state
  List<DrawingObject> _drawingObjects = [];
  List<List<DrawingObject>> _history = [];
  int _historyIndex = -1;

  // Current tool settings
  DrawingTool _selectedTool = DrawingTool.pen;
  Color _selectedColor = Colors.black;
  double _strokeWidth = 3.0;

  // Current drawing
  DrawingObject? _currentDrawing;
  Offset? _startPoint;

  // Text tool
  bool _isAddingText = false;
  TextEditingController _textController = TextEditingController();
  Offset? _textPosition;

  @override
  void initState() {
    super.initState();
    if (widget.initialDrawingData != null &&
        widget.initialDrawingData!.isNotEmpty) {
      _loadDrawing(widget.initialDrawingData!);
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _loadDrawing(String data) {
    try {
      final jsonData = jsonDecode(data) as List;
      setState(() {
        _drawingObjects =
            jsonData.map((obj) => DrawingObject.fromJson(obj)).toList();
      });
    } catch (e) {
      print('Error loading drawing: $e');
    }
  }

  Future<String?> _saveDrawing() async {
    if (_drawingObjects.isEmpty) return null;

    try {
      final jsonData = _drawingObjects.map((obj) => obj.toJson()).toList();
      return jsonEncode(jsonData);
    } catch (e) {
      print('Error saving drawing: $e');
      return null;
    }
  }

  void _addToHistory() {
    // Remove any history after current index
    if (_historyIndex < _history.length - 1) {
      _history = _history.sublist(0, _historyIndex + 1);
    }

    // Add current state to history
    _history.add(List.from(_drawingObjects));
    _historyIndex++;

    // Limit history size
    if (_history.length > 50) {
      _history.removeAt(0);
      _historyIndex--;
    }
  }

  void _undo() {
    if (_historyIndex > 0) {
      setState(() {
        _historyIndex--;
        _drawingObjects = List.from(_history[_historyIndex]);
      });
      _notifyDrawingChanged();
    } else if (_historyIndex == 0 && _history.isNotEmpty) {
      setState(() {
        _historyIndex = -1;
        _drawingObjects.clear();
      });
      _notifyDrawingChanged();
    }
  }

  void _redo() {
    if (_historyIndex < _history.length - 1) {
      setState(() {
        _historyIndex++;
        _drawingObjects = List.from(_history[_historyIndex]);
      });
      _notifyDrawingChanged();
    }
  }

  void _clearCanvas() {
    setState(() {
      _addToHistory();
      _drawingObjects.clear();
    });
    _notifyDrawingChanged();
  }

  void _notifyDrawingChanged() async {
    final data = await _saveDrawing();
    widget.onDrawingChanged(data);
  }

  void _onPanStart(DragStartDetails details) {
    if (_isAddingText) return;

    _startPoint = details.localPosition;

    if (_selectedTool == DrawingTool.pen ||
        _selectedTool == DrawingTool.pencil ||
        _selectedTool == DrawingTool.brush ||
        _selectedTool == DrawingTool.eraser) {
      setState(() {
        _currentDrawing = DrawingObject(
          tool: _selectedTool,
          color: _selectedTool == DrawingTool.eraser
              ? Colors.white
              : _selectedColor,
          strokeWidth: _selectedTool == DrawingTool.eraser
              ? _strokeWidth * 2
              : _strokeWidth,
          points: [details.localPosition],
        );
      });
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isAddingText || _startPoint == null) return;

    setState(() {
      if (_selectedTool == DrawingTool.pen ||
          _selectedTool == DrawingTool.pencil ||
          _selectedTool == DrawingTool.brush ||
          _selectedTool == DrawingTool.eraser) {
        _currentDrawing?.points.add(details.localPosition);
      } else if (_selectedTool == DrawingTool.line ||
          _selectedTool == DrawingTool.arrow ||
          _selectedTool == DrawingTool.rectangle ||
          _selectedTool == DrawingTool.circle) {
        _currentDrawing = DrawingObject(
          tool: _selectedTool,
          color: _selectedColor,
          strokeWidth: _strokeWidth,
          startPoint: _startPoint,
          endPoint: details.localPosition,
        );
      }
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_isAddingText || _currentDrawing == null) return;

    setState(() {
      _addToHistory();
      _drawingObjects.add(_currentDrawing!);
      _currentDrawing = null;
      _startPoint = null;
    });
    _notifyDrawingChanged();
  }

  void _onTapForText(TapDownDetails details) {
    if (_selectedTool != DrawingTool.text) return;

    setState(() {
      _textPosition = details.localPosition;
      _isAddingText = true;
      _textController.clear();
    });

    _showTextInputDialog();
  }

  void _showTextInputDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Text'),
        content: TextField(
          controller: _textController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Type here...'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _isAddingText = false);
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (_textController.text.isNotEmpty && _textPosition != null) {
                setState(() {
                  _addToHistory();
                  _drawingObjects.add(DrawingObject(
                    tool: DrawingTool.text,
                    color: _selectedColor,
                    strokeWidth: _strokeWidth,
                    text: _textController.text,
                    startPoint: _textPosition,
                  ));
                  _isAddingText = false;
                });
                _notifyDrawingChanged();
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tools toolbar
        _buildToolbar(),
        const SizedBox(height: 8),

        // Drawing canvas
        Listener(
          onPointerDown: (_) {},
          onPointerMove: (_) {},
          child: Stack(
            children: [
              Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _selectedTool == DrawingTool.eraser
                        ? Colors.pink.shade300
                        : const Color(0xFFFFE2A9),
                    width: _selectedTool == DrawingTool.eraser ? 2.5 : 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _selectedTool == DrawingTool.eraser
                          ? Colors.pink.withValues(alpha: 0.15)
                          : Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: RepaintBoundary(
                    key: _repaintBoundaryKey,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onPanStart: _onPanStart,
                      onPanUpdate: _onPanUpdate,
                      onPanEnd: _onPanEnd,
                      onTapDown: _onTapForText,
                      child: CustomPaint(
                        painter: DrawingPainter(
                          drawingObjects: _drawingObjects,
                          currentDrawing: _currentDrawing,
                        ),
                        size: Size.infinite,
                      ),
                    ),
                  ),
                ),
              ),
              // Eraser mode indicator
              if (_selectedTool == DrawingTool.eraser)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.pink.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: Colors.pink.shade300, width: 1.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.cleaning_services,
                            size: 14, color: Colors.pink.shade700),
                        const SizedBox(width: 4),
                        Text(
                          'Eraser Mode',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.pink.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFE2A9), width: 1.5),
      ),
      child: Column(
        children: [
          // Drawing tools row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildToolButton(DrawingTool.pen, Icons.edit, 'Pen'),
                _buildToolButton(DrawingTool.pencil, Icons.create, 'Pencil'),
                _buildToolButton(DrawingTool.brush, Icons.brush, 'Brush'),
                _buildToolButton(
                    DrawingTool.eraser, Icons.cleaning_services, 'Eraser'),
                const SizedBox(width: 8),
                _buildToolButton(
                    DrawingTool.line, Icons.horizontal_rule, 'Line'),
                _buildToolButton(
                    DrawingTool.rectangle, Icons.crop_square, 'Rectangle'),
                _buildToolButton(
                    DrawingTool.circle, Icons.circle_outlined, 'Circle'),
                _buildToolButton(
                    DrawingTool.arrow, Icons.arrow_forward, 'Arrow'),
                _buildToolButton(DrawingTool.text, Icons.text_fields, 'Text'),
                const SizedBox(width: 8),
                _buildActionButton(
                    Icons.undo, 'Undo', _undo, _historyIndex >= 0),
                _buildActionButton(Icons.redo, 'Redo', _redo,
                    _historyIndex < _history.length - 1),
                _buildActionButton(Icons.clear_all, 'Clear', _clearCanvas,
                    _drawingObjects.isNotEmpty),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Color and stroke width controls row
          Row(
            children: [
              // Color picker
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      const Text('Color: ',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600)),
                      ...[
                        Colors.black,
                        Colors.red,
                        Colors.blue,
                        Colors.green,
                        Colors.yellow,
                        Colors.orange,
                        Colors.purple,
                        Colors.pink,
                        Colors.brown,
                        Colors.grey,
                        Colors.cyan,
                        Colors.lime,
                      ].map((color) => _buildColorButton(color)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Stroke width selector
              PopupMenuButton<double>(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFFE2A9)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.line_weight, size: 16),
                      const SizedBox(width: 4),
                      Text('${_strokeWidth.toInt()}',
                          style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                onSelected: (value) {
                  setState(() => _strokeWidth = value);
                },
                itemBuilder: (context) => [
                  PopupMenuItem(value: 1.0, child: Text('Thin (1)')),
                  PopupMenuItem(value: 3.0, child: Text('Normal (3)')),
                  PopupMenuItem(value: 5.0, child: Text('Medium (5)')),
                  PopupMenuItem(value: 8.0, child: Text('Thick (8)')),
                  PopupMenuItem(value: 12.0, child: Text('Very Thick (12)')),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton(DrawingTool tool, IconData icon, String tooltip) {
    final isSelected = _selectedTool == tool;
    final isEraser = tool == DrawingTool.eraser;
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: () => setState(() => _selectedTool = tool),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected
                  ? (isEraser ? Colors.pink.shade100 : const Color(0xFFFFD54F))
                  : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? (isEraser
                        ? Colors.pink.shade300
                        : const Color(0xFFFFA000))
                    : const Color(0xFFFFE2A9),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Icon(icon,
                size: 20,
                color: isEraser && isSelected
                    ? Colors.pink.shade700
                    : Colors.black87),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
      IconData icon, String tooltip, VoidCallback onPressed, bool enabled) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: enabled ? Colors.white : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFFE2A9)),
            ),
            child: Icon(icon,
                size: 20, color: enabled ? Colors.black87 : Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildColorButton(Color color) {
    final isSelected = _selectedColor == color;
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: InkWell(
        onTap: () => setState(() => _selectedColor = color),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? Colors.black : Colors.grey.shade300,
              width: isSelected ? 3 : 1,
            ),
          ),
          child: isSelected
              ? const Icon(Icons.check, size: 16, color: Colors.white)
              : null,
        ),
      ),
    );
  }
}

// Drawing object data model
class DrawingObject {
  final DrawingTool tool;
  final Color color;
  final double strokeWidth;
  final List<Offset> points;
  final Offset? startPoint;
  final Offset? endPoint;
  final String? text;

  DrawingObject({
    required this.tool,
    required this.color,
    required this.strokeWidth,
    this.points = const [],
    this.startPoint,
    this.endPoint,
    this.text,
  });

  Map<String, dynamic> toJson() {
    return {
      'tool': tool.index,
      'color': color.value,
      'strokeWidth': strokeWidth,
      'points': points.map((p) => {'x': p.dx, 'y': p.dy}).toList(),
      'startPoint': startPoint != null
          ? {'x': startPoint!.dx, 'y': startPoint!.dy}
          : null,
      'endPoint':
          endPoint != null ? {'x': endPoint!.dx, 'y': endPoint!.dy} : null,
      'text': text,
    };
  }

  factory DrawingObject.fromJson(Map<String, dynamic> json) {
    return DrawingObject(
      tool: DrawingTool.values[json['tool'] as int],
      color: Color(json['color'] as int),
      strokeWidth: (json['strokeWidth'] as num).toDouble(),
      points: (json['points'] as List?)
              ?.map((p) => Offset(
                  (p['x'] as num).toDouble(), (p['y'] as num).toDouble()))
              .toList() ??
          [],
      startPoint: json['startPoint'] != null
          ? Offset((json['startPoint']['x'] as num).toDouble(),
              (json['startPoint']['y'] as num).toDouble())
          : null,
      endPoint: json['endPoint'] != null
          ? Offset((json['endPoint']['x'] as num).toDouble(),
              (json['endPoint']['y'] as num).toDouble())
          : null,
      text: json['text'] as String?,
    );
  }
}

// Custom painter for drawing
class DrawingPainter extends CustomPainter {
  final List<DrawingObject> drawingObjects;
  final DrawingObject? currentDrawing;

  DrawingPainter({
    required this.drawingObjects,
    this.currentDrawing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw all completed objects
    for (var obj in drawingObjects) {
      _drawObject(canvas, obj);
    }

    // Draw current object being drawn
    if (currentDrawing != null) {
      _drawObject(canvas, currentDrawing!);
    }
  }

  void _drawObject(Canvas canvas, DrawingObject obj) {
    final paint = Paint()
      ..color = obj.color
      ..strokeWidth = obj.strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    switch (obj.tool) {
      case DrawingTool.pen:
        paint.style = PaintingStyle.stroke;
        _drawPath(canvas, obj.points, paint);
        break;

      case DrawingTool.pencil:
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = obj.strokeWidth * 0.7;
        _drawPath(canvas, obj.points, paint);
        break;

      case DrawingTool.brush:
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = obj.strokeWidth * 1.5;
        _drawPath(canvas, obj.points, paint);
        break;

      case DrawingTool.eraser:
        paint.style = PaintingStyle.stroke;
        paint.color = Colors.white;
        paint.blendMode = BlendMode.srcOver;
        paint.strokeWidth = obj.strokeWidth * 2;
        _drawPath(canvas, obj.points, paint);
        break;

      case DrawingTool.line:
        if (obj.startPoint != null && obj.endPoint != null) {
          paint.style = PaintingStyle.stroke;
          canvas.drawLine(obj.startPoint!, obj.endPoint!, paint);
        }
        break;

      case DrawingTool.rectangle:
        if (obj.startPoint != null && obj.endPoint != null) {
          paint.style = PaintingStyle.stroke;
          canvas.drawRect(
            Rect.fromPoints(obj.startPoint!, obj.endPoint!),
            paint,
          );
        }
        break;

      case DrawingTool.circle:
        if (obj.startPoint != null && obj.endPoint != null) {
          paint.style = PaintingStyle.stroke;
          final center = obj.startPoint!;
          final radius = (obj.endPoint! - obj.startPoint!).distance;
          canvas.drawCircle(center, radius, paint);
        }
        break;

      case DrawingTool.arrow:
        if (obj.startPoint != null && obj.endPoint != null) {
          paint.style = PaintingStyle.stroke;
          _drawArrow(canvas, obj.startPoint!, obj.endPoint!, paint);
        }
        break;

      case DrawingTool.text:
        if (obj.startPoint != null && obj.text != null) {
          final textPainter = TextPainter(
            text: TextSpan(
              text: obj.text,
              style: TextStyle(
                color: obj.color,
                fontSize: obj.strokeWidth * 4,
                fontWeight: FontWeight.w600,
              ),
            ),
            textDirection: TextDirection.ltr,
          );
          textPainter.layout();
          textPainter.paint(canvas, obj.startPoint!);
        }
        break;
    }
  }

  void _drawPath(Canvas canvas, List<Offset> points, Paint paint) {
    if (points.isEmpty) return;

    if (points.length == 1) {
      canvas.drawCircle(points[0], paint.strokeWidth / 2, paint);
      return;
    }

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(path, paint);
  }

  void _drawArrow(Canvas canvas, Offset start, Offset end, Paint paint) {
    canvas.drawLine(start, end, paint);

    // Draw arrowhead
    final arrowSize = paint.strokeWidth * 3;
    final angle = (end - start).direction;
    final arrowAngle = 0.5;

    final path = Path();
    path.moveTo(end.dx, end.dy);
    path.lineTo(
      end.dx - arrowSize * math.cos(angle - arrowAngle),
      end.dy - arrowSize * math.sin(angle - arrowAngle),
    );
    path.moveTo(end.dx, end.dy);
    path.lineTo(
      end.dx - arrowSize * math.cos(angle + arrowAngle),
      end.dy - arrowSize * math.sin(angle + arrowAngle),
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) {
    return oldDelegate.drawingObjects != drawingObjects ||
        oldDelegate.currentDrawing != currentDrawing;
  }
}

extension OffsetExtension on Offset {
  double get cos => dx / distance;
  double get sin => dy / distance;
}
