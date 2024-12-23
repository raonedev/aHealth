import 'package:flutter/material.dart';

class RulerSlider extends StatefulWidget {
  final double minValue;
  final double maxValue;
  final double initialValue;
  final ValueChanged<double> onValueChanged;

  const RulerSlider({
    super.key,
    required this.minValue,
    required this.maxValue,
    required this.initialValue,
    required this.onValueChanged,
  });

  @override
  _RulerSliderState createState() => _RulerSliderState();
}

class _RulerSliderState extends State<RulerSlider> {
  late ScrollController _scrollController;
  final double _tickSpacing = 10.0; // Space between ticks
  late double _screenWidth;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get screen width in didChangeDependencies
    _screenWidth = MediaQuery.of(context).size.width-20;
    // Set the initial scroll offset
    _scrollController = ScrollController(
      initialScrollOffset: _valueToScrollOffset(widget.initialValue),
    );
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant RulerSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      _scrollController.jumpTo(_valueToScrollOffset(widget.initialValue));
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    double offset = _scrollController.offset;
    double newValue = _scrollOffsetToValue(offset);

    widget.onValueChanged(newValue);
  }

  double _valueToScrollOffset(double value) {
    // Offset based on value, adjusted for centering
    return (value - widget.minValue) * _tickSpacing - (_screenWidth / 2 - _tickSpacing / 2);
  }

  double _scrollOffsetToValue(double offset) {
    // Convert offset to value, adjusted for centering
    double centeredOffset = offset + (_screenWidth / 2 - _tickSpacing / 2 );
    return (centeredOffset / _tickSpacing).clamp(widget.minValue, widget.maxValue) + widget.minValue;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Scrollable ruler
        Stack(
          alignment: Alignment.center,
          children: [
            // Scrollable ruler ticks
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: _scrollController,
              child: CustomPaint(
                size: Size((widget.maxValue - widget.minValue) * _tickSpacing, 200),
                painter: RulerPainter(
                  minValue: widget.minValue,
                  maxValue: widget.maxValue,
                ),
              ),
            ),
            // Thumb indicator
            Positioned(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top indicator
                  CustomPaint(
                    size: const Size(24, 24),
                    painter: TopIndicatorPainter(),
                  ),
                  const SizedBox(height: 10),
                  // Main indicator
                  CustomPaint(
                    size: const Size(24, 75), // Same dimensions as the SVG
                    painter: IndicatorPainter(),
                  ),
                  const SizedBox(height: 10),
                  // Bottom indicator
                  CustomPaint(
                    size: const Size(14, 16),
                    painter: BottomIndicatorPainter(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}



class RulerPainter extends CustomPainter {
  final double minValue;
  final double maxValue;
  final double tickSpacing;
  final Color majorTickColor;
  final double majorTickWidth;
  final int numberOfminorBetweenMajor;
  final TextStyle textStyle;
  final Color minorTickColor;
  final double minorTickWidth;

  RulerPainter({
    required this.minValue,
    required this.maxValue,
    this.tickSpacing = 10,
    this.majorTickColor = Colors.black,
    this.majorTickWidth = 2,
    this.numberOfminorBetweenMajor = 10,
    this.textStyle = const TextStyle(
        color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
    this.minorTickColor = Colors.grey,
    this.minorTickWidth = 1.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double centerY = size.height / 2; // Calculate vertical center

    for (double i = minValue; i <= maxValue; i++) {
      double x = (i - minValue) * tickSpacing;

      // Major tick (every 10th value)
      if (i % numberOfminorBetweenMajor == 0) {
        canvas.drawLine(
          Offset(x, centerY - 15),
          Offset(x, centerY + 15),
          Paint()
            ..color = majorTickColor
            ..strokeWidth = majorTickWidth,
        );
        TextPainter(
          text: TextSpan(
            text: i.toStringAsFixed(0),
            style: textStyle,
          ),
          textDirection: TextDirection.ltr,
        )
          ..layout()
          ..paint(canvas, Offset(x - 10, centerY + 25));
      } else {
        // Minor tick
        canvas.drawLine(
          Offset(x, centerY - 7.5),
          Offset(x, centerY + 7.5),
          Paint()
            ..color = minorTickColor
            ..strokeWidth = minorTickWidth,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class IndicatorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double originalWidth = 24.0;
    const double originalHeight = 99.0;

    // Calculate scale factors for width and height
    final double scaleX = size.width / originalWidth;
    final double scaleY = size.height / originalHeight;

    // Apply scaling transformation
    canvas.scale(scaleX, scaleY);

    final paint = Paint()
      ..color = Colors.transparent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.butt
      ..strokeJoin = StrokeJoin.miter
      ..isAntiAlias = true;

    // Left path
    final leftPath = Path()
      ..moveTo(0, 96.5)
      ..lineTo(4, 96.5)
      ..cubicTo(8.41828, 96.5, 12, 92.9183, 12, 88.5)
      ..lineTo(12, 10.5)
      ..cubicTo(12, 6.08172, 8.41828, 2.5, 4, 2.5)
      ..lineTo(0, 2.5);

    paint.color = Color(0xFF0F67FE);
    canvas.drawPath(leftPath, paint);

    // Right path
    final rightPath = Path()
      ..moveTo(24, 96.5)
      ..lineTo(20, 96.5)
      ..cubicTo(15.5817, 96.5, 12, 92.9183, 12, 88.5)
      ..lineTo(12, 10.5)
      ..cubicTo(12, 6.08172, 15.5817, 2.5, 20, 2.5)
      ..lineTo(24, 2.5);

    canvas.drawPath(rightPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

//top

class TopIndicatorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double originalWidth = 24.0;
    const double originalHeight = 24.0;

    // Scale canvas to fit the new size
    final double scaleX = size.width / originalWidth;
    final double scaleY = size.height / originalHeight;
    canvas.scale(scaleX, scaleY);

    final paint = Paint()
      ..color = const Color(0xFF0F67FE)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(5.9319, 7.7276)
      ..cubicTo(
        5.45854,
        5.83416,
        6.89062,
        4,
        8.84233,
        4,
      )
      ..lineTo(15.1577, 4)
      ..cubicTo(
        17.1094,
        4,
        18.5415,
        5.83417,
        18.0681,
        7.72761,
      )
      ..lineTo(15.5681, 17.7276)
      ..cubicTo(
        15.2342,
        19.0631,
        14.0343,
        20,
        12.6577,
        20,
      )
      ..lineTo(11.3423, 20)
      ..cubicTo(
        9.96573,
        20,
        8.76578,
        19.0631,
        8.4319,
        17.7276,
      )
      ..lineTo(5.9319, 7.7276)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// bottom

class BottomIndicatorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double originalWidth = 14.0;
    final double originalHeight = 16.0;

    // Scale canvas to fit the new size
    final double scaleX = size.width / originalWidth;
    final double scaleY = size.height / originalHeight;
    canvas.scale(scaleX, scaleY);

    final paint = Paint()
      ..color = Color(0xFF0F67FE)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0.931901, 12.2724)
      ..cubicTo(
        0.458541,
        14.1658,
        1.89062,
        16,
        3.84233,
        16,
      )
      ..lineTo(10.1577, 16)
      ..cubicTo(
        12.1094,
        16,
        13.5415,
        14.1658,
        13.0681,
        12.2724,
      )
      ..lineTo(10.5681, 2.27239)
      ..cubicTo(
        10.2342,
        0.936891,
        9.03427,
        0,
        7.65767,
        0,
      )
      ..lineTo(6.34233, 0)
      ..cubicTo(
        4.96573,
        0,
        3.76578,
        0.936893,
        3.4319,
        2.27239,
      )
      ..lineTo(0.931901, 12.2724)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
