import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:convert';

enum DrawingTool {
  pen,
  pencil,
  brush,
  airbrush,
  watercolor,
  marker,
  calligraphy,
  eraser,
  line,
  rectangle,
  circle,
  arrow,
  text,
  fill,
  colorPicker,
}

class ProcreateDrawingPad extends StatefulWidget {
  final String? initialDrawingData;
  final Function(String?) onDrawingChanged;

  const ProcreateDrawingPad({
    super.key,
    this.initialDrawingData,
    required this.onDrawingChanged,
  });

  @override
  State<ProcreateDrawingPad> createState() => _ProcreateDrawingPadState();
}

class _ProcreateDrawingPadState extends State<ProcreateDrawingPad> {
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  final TransformationController _transformationController =
      TransformationController();

  // Layers
  List<DrawingLayer> _layers = [];
  int _currentLayerIndex = 0;

  // History
  List<List<DrawingLayer>> _history = [];
  int _historyIndex = -1;

  // Current tool settings
  DrawingTool _selectedTool = DrawingTool.pen;
  Color _selectedColor = Colors.black;
  double _strokeWidth = 3.0;
  double _opacity = 1.0;

  // Current drawing
  DrawingObject? _currentDrawing;
  Offset? _startPoint;

  // Text tool
  bool _isAddingText = false;
  TextEditingController _textController = TextEditingController();
  Offset? _textPosition;

  // UI state
  bool _showLayers = false;
  bool _showBrushSettings = false;

  @override
  void initState() {
    super.initState();
    // Initialize with one layer
    _layers.add(DrawingLayer(
        name: 'Layer 1', objects: [], opacity: 1.0, visible: true));

    if (widget.initialDrawingData != null &&
        widget.initialDrawingData!.isNotEmpty) {
      _loadDrawing(widget.initialDrawingData!);
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  void _loadDrawing(String data) {
    try {
      final jsonData = jsonDecode(data);
      if (jsonData is List) {
        // Old format compatibility
        setState(() {
          _layers = [
            DrawingLayer(
              name: 'Layer 1',
              objects:
                  (jsonData).map((obj) => DrawingObject.fromJson(obj)).toList(),
              opacity: 1.0,
              visible: true,
            )
          ];
        });
      } else if (jsonData is Map) {
        // New format with layers
        setState(() {
          _layers = (jsonData['layers'] as List)
              .map((layer) => DrawingLayer.fromJson(layer))
              .toList();
          _currentLayerIndex = jsonData['currentLayer'] ?? 0;
        });
      }
    } catch (e) {
      print('Error loading drawing: $e');
    }
  }

  Future<String?> _saveDrawing() async {
    if (_layers.every((layer) => layer.objects.isEmpty)) return null;

    try {
      final jsonData = {
        'layers': _layers.map((layer) => layer.toJson()).toList(),
        'currentLayer': _currentLayerIndex,
      };
      return jsonEncode(jsonData);
    } catch (e) {
      print('Error saving drawing: $e');
      return null;
    }
  }

  void _addToHistory() {
    if (_historyIndex < _history.length - 1) {
      _history = _history.sublist(0, _historyIndex + 1);
    }

    _history.add(_layers.map((layer) => layer.copy()).toList());
    _historyIndex++;

    if (_history.length > 50) {
      _history.removeAt(0);
      _historyIndex--;
    }
  }

  void _undo() {
    if (_historyIndex > 0) {
      setState(() {
        _historyIndex--;
        _layers = _history[_historyIndex].map((layer) => layer.copy()).toList();
      });
      _notifyDrawingChanged();
    } else if (_historyIndex == 0 && _history.isNotEmpty) {
      setState(() {
        _historyIndex = -1;
        _layers.forEach((layer) => layer.objects.clear());
      });
      _notifyDrawingChanged();
    }
  }

  void _redo() {
    if (_historyIndex < _history.length - 1) {
      setState(() {
        _historyIndex++;
        _layers = _history[_historyIndex].map((layer) => layer.copy()).toList();
      });
      _notifyDrawingChanged();
    }
  }

  void _clearCanvas() {
    setState(() {
      _addToHistory();
      _layers[_currentLayerIndex].objects.clear();
    });
    _notifyDrawingChanged();
  }

  void _notifyDrawingChanged() async {
    final data = await _saveDrawing();
    widget.onDrawingChanged(data);
  }

  void _onPanStart(DragStartDetails details) {
    if (_isAddingText ||
        _selectedTool == DrawingTool.fill ||
        _selectedTool == DrawingTool.colorPicker) return;

    final localPosition =
        _transformationController.toScene(details.localPosition);
    _startPoint = localPosition;

    if (_selectedTool == DrawingTool.pen ||
        _selectedTool == DrawingTool.pencil ||
        _selectedTool == DrawingTool.brush ||
        _selectedTool == DrawingTool.airbrush ||
        _selectedTool == DrawingTool.watercolor ||
        _selectedTool == DrawingTool.marker ||
        _selectedTool == DrawingTool.calligraphy ||
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
          opacity: _opacity,
          points: [localPosition],
        );
      });
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isAddingText || _startPoint == null) return;

    final localPosition =
        _transformationController.toScene(details.localPosition);

    setState(() {
      if (_selectedTool == DrawingTool.pen ||
          _selectedTool == DrawingTool.pencil ||
          _selectedTool == DrawingTool.brush ||
          _selectedTool == DrawingTool.airbrush ||
          _selectedTool == DrawingTool.watercolor ||
          _selectedTool == DrawingTool.marker ||
          _selectedTool == DrawingTool.calligraphy ||
          _selectedTool == DrawingTool.eraser) {
        _currentDrawing?.points.add(localPosition);
      } else if (_selectedTool == DrawingTool.line ||
          _selectedTool == DrawingTool.arrow ||
          _selectedTool == DrawingTool.rectangle ||
          _selectedTool == DrawingTool.circle) {
        _currentDrawing = DrawingObject(
          tool: _selectedTool,
          color: _selectedColor,
          strokeWidth: _strokeWidth,
          opacity: _opacity,
          startPoint: _startPoint,
          endPoint: localPosition,
        );
      }
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_isAddingText || _currentDrawing == null) return;

    setState(() {
      _addToHistory();
      _layers[_currentLayerIndex].objects.add(_currentDrawing!);
      _currentDrawing = null;
      _startPoint = null;
    });
    _notifyDrawingChanged();
  }

  void _onTap(TapDownDetails details) {
    final localPosition =
        _transformationController.toScene(details.localPosition);

    if (_selectedTool == DrawingTool.text) {
      setState(() {
        _textPosition = localPosition;
        _isAddingText = true;
        _textController.clear();
      });
      _showTextInputDialog();
    } else if (_selectedTool == DrawingTool.fill) {
      _performFill(localPosition);
    } else if (_selectedTool == DrawingTool.colorPicker) {
      _pickColorFromCanvas(localPosition);
    }
  }

  void _performFill(Offset position) {
    // Simple fill - adds a filled rectangle
    // For a real flood fill, you'd need pixel-level canvas access
    setState(() {
      _addToHistory();
      _layers[_currentLayerIndex].objects.add(DrawingObject(
            tool: DrawingTool.fill,
            color: _selectedColor,
            strokeWidth: 1.0,
            opacity: _opacity,
            startPoint: Offset(0, 0),
            endPoint: Offset(300, 300), // Canvas size
          ));
    });
    _notifyDrawingChanged();
  }

  void _pickColorFromCanvas(Offset position) {
    // Find the topmost non-transparent object at this position
    for (int i = _layers.length - 1; i >= 0; i--) {
      if (!_layers[i].visible) continue;

      for (var obj in _layers[i].objects.reversed) {
        if (_isPointInObject(position, obj)) {
          setState(() {
            _selectedColor = obj.color;
            _selectedTool = DrawingTool.pen; // Switch back to pen
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Color picked!'), duration: Duration(seconds: 1)),
          );
          return;
        }
      }
    }
  }

  bool _isPointInObject(Offset point, DrawingObject obj) {
    if (obj.points.isNotEmpty) {
      return obj.points.any((p) => (p - point).distance < obj.strokeWidth);
    }
    return false;
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
                  _layers[_currentLayerIndex].objects.add(DrawingObject(
                        tool: DrawingTool.text,
                        color: _selectedColor,
                        strokeWidth: _strokeWidth,
                        opacity: _opacity,
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

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick Color'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Color wheel would go here - using simple palette for now
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Colors.black,
                  Colors.white,
                  Colors.red,
                  Colors.pink,
                  Colors.purple,
                  Colors.deepPurple,
                  Colors.indigo,
                  Colors.blue,
                  Colors.lightBlue,
                  Colors.cyan,
                  Colors.teal,
                  Colors.green,
                  Colors.lightGreen,
                  Colors.lime,
                  Colors.yellow,
                  Colors.amber,
                  Colors.orange,
                  Colors.deepOrange,
                  Colors.brown,
                  Colors.grey,
                ]
                    .map((color) => GestureDetector(
                          onTap: () {
                            setState(() => _selectedColor = color);
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey, width: 2),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTopToolbar(),
        const SizedBox(height: 8),
        _buildCanvas(),
        const SizedBox(height: 8),
        _buildBottomToolbar(),
        if (_showLayers) _buildLayersPanel(),
        if (_showBrushSettings) _buildBrushPanel(),
      ],
    );
  }

  Widget _buildTopToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFE2A9), width: 1.5),
      ),
      child: Row(
        children: [
          Text('Layers',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
          IconButton(
            icon: Icon(Icons.layers, size: 20),
            onPressed: () => setState(() => _showLayers = !_showLayers),
            padding: EdgeInsets.all(4),
            constraints: BoxConstraints(),
          ),
          const SizedBox(width: 8),
          _buildActionButton(Icons.undo, 'Undo', _undo, _historyIndex >= 0),
          _buildActionButton(
              Icons.redo, 'Redo', _redo, _historyIndex < _history.length - 1),
          _buildActionButton(Icons.clear_all, 'Clear Layer', _clearCanvas,
              _layers[_currentLayerIndex].objects.isNotEmpty),
          Spacer(),
          Text('Brush',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
          IconButton(
            icon: Icon(Icons.tune, size: 20),
            onPressed: () =>
                setState(() => _showBrushSettings = !_showBrushSettings),
            padding: EdgeInsets.all(4),
            constraints: BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildCanvas() {
    return Listener(
      onPointerDown: (_) {},
      onPointerMove: (_) {},
      child: Stack(
        children: [
          Container(
            height: 350,
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
              child: InteractiveViewer(
                transformationController: _transformationController,
                boundaryMargin: EdgeInsets.all(double.infinity),
                minScale: 0.5,
                maxScale: 4.0,
                child: RepaintBoundary(
                  key: _repaintBoundaryKey,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanStart: _onPanStart,
                    onPanUpdate: _onPanUpdate,
                    onPanEnd: _onPanEnd,
                    onTapDown: _onTap,
                    child: CustomPaint(
                      painter: ProcreatePainter(
                        layers: _layers,
                        currentDrawing: _currentDrawing,
                        currentLayerIndex: _currentLayerIndex,
                      ),
                      size: Size.infinite,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Tool indicator
          if (_selectedTool == DrawingTool.eraser)
            Positioned(
              top: 8,
              right: 8,
              child: _buildToolIndicator(
                  Icons.cleaning_services, 'Eraser Mode', Colors.pink),
            ),
          if (_selectedTool == DrawingTool.fill)
            Positioned(
              top: 8,
              right: 8,
              child: _buildToolIndicator(
                  Icons.format_color_fill, 'Fill Mode', Colors.blue),
            ),
          if (_selectedTool == DrawingTool.colorPicker)
            Positioned(
              top: 8,
              right: 8,
              child: _buildToolIndicator(
                  Icons.colorize, 'Pick Color', Colors.purple),
            ),
        ],
      ),
    );
  }

  Widget _buildToolIndicator(IconData icon, String label, Color color) {
    final lightColor = color.withValues(alpha: 0.2);
    final darkColor = Color.lerp(color, Colors.black, 0.3)!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: lightColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: darkColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: darkColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomToolbar() {
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
                    DrawingTool.airbrush, Icons.blur_on, 'Airbrush'),
                _buildToolButton(
                    DrawingTool.watercolor, Icons.water_drop, 'Watercolor'),
                _buildToolButton(DrawingTool.marker, Icons.highlight, 'Marker'),
                _buildToolButton(DrawingTool.calligraphy, Icons.font_download,
                    'Calligraphy'),
                const SizedBox(width: 8),
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
                const SizedBox(width: 8),
                _buildToolButton(DrawingTool.text, Icons.text_fields, 'Text'),
                _buildToolButton(
                    DrawingTool.fill, Icons.format_color_fill, 'Fill'),
                _buildToolButton(
                    DrawingTool.colorPicker, Icons.colorize, 'Color Picker'),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Color and settings row
          Row(
            children: [
              // Current color indicator
              GestureDetector(
                onTap: _showColorPicker,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _selectedColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Quick color picker
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
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
                      Colors.white,
                    ].map((color) => _buildQuickColorButton(color)).toList(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBrushPanel() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFE2A9), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Brush Settings',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              Spacer(),
              IconButton(
                icon: Icon(Icons.close, size: 20),
                onPressed: () => setState(() => _showBrushSettings = false),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('Size: ${_strokeWidth.toInt()}', style: TextStyle(fontSize: 12)),
          Slider(
            value: _strokeWidth,
            min: 1,
            max: 20,
            divisions: 19,
            onChanged: (value) => setState(() => _strokeWidth = value),
          ),
          Text('Opacity: ${(_opacity * 100).toInt()}%',
              style: TextStyle(fontSize: 12)),
          Slider(
            value: _opacity,
            min: 0.1,
            max: 1.0,
            divisions: 9,
            onChanged: (value) => setState(() => _opacity = value),
          ),
        ],
      ),
    );
  }

  Widget _buildLayersPanel() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFE2A9), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Layers',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              Spacer(),
              IconButton(
                icon: Icon(Icons.add, size: 20),
                onPressed: _addLayer,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
                tooltip: 'Add Layer',
              ),
              IconButton(
                icon: Icon(Icons.close, size: 20),
                onPressed: () => setState(() => _showLayers = false),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...List.generate(_layers.length, (index) {
            final layerIndex =
                _layers.length - 1 - index; // Reverse order for display
            return _buildLayerItem(_layers[layerIndex], layerIndex);
          }),
        ],
      ),
    );
  }

  Widget _buildLayerItem(DrawingLayer layer, int index) {
    final isSelected = index == _currentLayerIndex;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isSelected
            ? Color(0xFFFFD54F).withValues(alpha: 0.3)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? Color(0xFFFFA000) : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              layer.visible ? Icons.visibility : Icons.visibility_off,
              size: 18,
            ),
            onPressed: () => setState(() => layer.visible = !layer.visible),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _currentLayerIndex = index),
              child: Text(
                layer.name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ),
          Text('${(layer.opacity * 100).toInt()}%',
              style: TextStyle(fontSize: 11)),
          const SizedBox(width: 8),
          if (_layers.length > 1)
            IconButton(
              icon: Icon(Icons.delete, size: 18, color: Colors.red),
              onPressed: () => _deleteLayer(index),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
            ),
        ],
      ),
    );
  }

  void _addLayer() {
    setState(() {
      _layers.add(DrawingLayer(
        name: 'Layer ${_layers.length + 1}',
        objects: [],
        opacity: 1.0,
        visible: true,
      ));
      _currentLayerIndex = _layers.length - 1;
    });
  }

  void _deleteLayer(int index) {
    if (_layers.length > 1) {
      setState(() {
        _layers.removeAt(index);
        if (_currentLayerIndex >= _layers.length) {
          _currentLayerIndex = _layers.length - 1;
        }
      });
      _notifyDrawingChanged();
    }
  }

  Widget _buildToolButton(DrawingTool tool, IconData icon, String tooltip) {
    final isSelected = _selectedTool == tool;
    final isEraser = tool == DrawingTool.eraser;
    final isFill = tool == DrawingTool.fill;
    final isPicker = tool == DrawingTool.colorPicker;

    Color selectedColor = const Color(0xFFFFD54F);
    Color borderColor = const Color(0xFFFFA000);

    if (isEraser) {
      selectedColor = Colors.pink.shade100;
      borderColor = Colors.pink.shade300;
    } else if (isFill) {
      selectedColor = Colors.blue.shade100;
      borderColor = Colors.blue.shade300;
    } else if (isPicker) {
      selectedColor = Colors.purple.shade100;
      borderColor = Colors.purple.shade300;
    }

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
              color: isSelected ? selectedColor : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? borderColor : const Color(0xFFFFE2A9),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Icon(icon, size: 20, color: Colors.black87),
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
            padding: const EdgeInsets.all(4),
            child: Icon(icon,
                size: 18, color: enabled ? Colors.black87 : Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickColorButton(Color color) {
    final isSelected = _selectedColor == color;
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: InkWell(
        onTap: () => setState(() => _selectedColor = color),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? Colors.black : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
        ),
      ),
    );
  }
}

// Drawing Layer
class DrawingLayer {
  String name;
  List<DrawingObject> objects;
  double opacity;
  bool visible;

  DrawingLayer({
    required this.name,
    required this.objects,
    required this.opacity,
    required this.visible,
  });

  DrawingLayer copy() {
    return DrawingLayer(
      name: name,
      objects: objects.map((obj) => obj.copy()).toList(),
      opacity: opacity,
      visible: visible,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'objects': objects.map((obj) => obj.toJson()).toList(),
      'opacity': opacity,
      'visible': visible,
    };
  }

  factory DrawingLayer.fromJson(Map<String, dynamic> json) {
    return DrawingLayer(
      name: json['name'] as String,
      objects: (json['objects'] as List)
          .map((obj) => DrawingObject.fromJson(obj))
          .toList(),
      opacity: (json['opacity'] as num).toDouble(),
      visible: json['visible'] as bool,
    );
  }
}

// Drawing object data model
class DrawingObject {
  final DrawingTool tool;
  final Color color;
  final double strokeWidth;
  final double opacity;
  final List<Offset> points;
  final Offset? startPoint;
  final Offset? endPoint;
  final String? text;

  DrawingObject({
    required this.tool,
    required this.color,
    required this.strokeWidth,
    this.opacity = 1.0,
    this.points = const [],
    this.startPoint,
    this.endPoint,
    this.text,
  });

  DrawingObject copy() {
    return DrawingObject(
      tool: tool,
      color: color,
      strokeWidth: strokeWidth,
      opacity: opacity,
      points: List.from(points),
      startPoint: startPoint,
      endPoint: endPoint,
      text: text,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tool': tool.index,
      'color': color.value,
      'strokeWidth': strokeWidth,
      'opacity': opacity,
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
      opacity:
          json['opacity'] != null ? (json['opacity'] as num).toDouble() : 1.0,
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

// Custom painter with layers support
class ProcreatePainter extends CustomPainter {
  final List<DrawingLayer> layers;
  final DrawingObject? currentDrawing;
  final int currentLayerIndex;

  ProcreatePainter({
    required this.layers,
    this.currentDrawing,
    required this.currentLayerIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw all layers
    for (int i = 0; i < layers.length; i++) {
      if (!layers[i].visible) continue;

      final layer = layers[i];
      canvas.saveLayer(
          null, Paint()..color = Colors.white.withOpacity(layer.opacity));

      for (var obj in layer.objects) {
        _drawObject(canvas, obj);
      }

      canvas.restore();

      // Draw current drawing on current layer
      if (i == currentLayerIndex && currentDrawing != null) {
        _drawObject(canvas, currentDrawing!);
      }
    }
  }

  void _drawObject(Canvas canvas, DrawingObject obj) {
    final paint = Paint()
      ..color = obj.color.withOpacity(obj.opacity)
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

      case DrawingTool.airbrush:
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = obj.strokeWidth * 2;
        paint.maskFilter =
            MaskFilter.blur(BlurStyle.normal, obj.strokeWidth * 0.5);
        _drawPath(canvas, obj.points, paint);
        break;

      case DrawingTool.watercolor:
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = obj.strokeWidth * 2;
        paint.color = obj.color.withOpacity(obj.opacity * 0.3);
        paint.maskFilter =
            MaskFilter.blur(BlurStyle.normal, obj.strokeWidth * 0.8);
        _drawPath(canvas, obj.points, paint);
        break;

      case DrawingTool.marker:
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = obj.strokeWidth * 3;
        paint.strokeCap = StrokeCap.square;
        paint.color = obj.color.withOpacity(obj.opacity * 0.6);
        _drawPath(canvas, obj.points, paint);
        break;

      case DrawingTool.calligraphy:
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = obj.strokeWidth * 2;
        paint.strokeCap = StrokeCap.square;
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

      case DrawingTool.fill:
        if (obj.startPoint != null && obj.endPoint != null) {
          paint.style = PaintingStyle.fill;
          canvas.drawRect(
            Rect.fromPoints(obj.startPoint!, obj.endPoint!),
            paint,
          );
        }
        break;

      case DrawingTool.text:
        if (obj.startPoint != null && obj.text != null) {
          final textPainter = TextPainter(
            text: TextSpan(
              text: obj.text,
              style: TextStyle(
                color: obj.color.withOpacity(obj.opacity),
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

      case DrawingTool.colorPicker:
        // Color picker doesn't draw anything
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
  bool shouldRepaint(ProcreatePainter oldDelegate) {
    return oldDelegate.layers != layers ||
        oldDelegate.currentDrawing != currentDrawing ||
        oldDelegate.currentLayerIndex != currentLayerIndex;
  }
}

// Extension to convert viewport coordinates to scene coordinates
// Used in pan event handlers for proper coordinate transformation with zoom/pan
extension _TransformationControllerExtension on TransformationController {
  // Transform viewport point to scene coordinates considering current transformation
  Offset toScene(Offset viewportPoint) {
    final inverted = Matrix4.inverted(value);
    return MatrixUtils.transformPoint(inverted, viewportPoint);
  }
}
