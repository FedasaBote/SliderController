import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'slider_decoration.dart';

///
/// Class to Render the slider Widget
///

class RenderSliderController extends RenderBox {
  RenderSliderController(
      {required double value,
      required double min,
      required double max,
      required ValueChanged<double> onChanged,
      required ValueChanged<double>? onChangeStart,
      required ValueChanged<double>? onChangeEnd,
      required SliderDecoration sliderDecoration,
      required bool isDraggable})
      : _value = value,
        _min = min,
        _max = max,
        _onChanged = onChanged,
        _onChangeStart = onChangeStart,
        _onChangeEnd = onChangeEnd,
        _sliderDecoration = sliderDecoration,
        _isDraggable = isDraggable {
    if (_isDraggable) {
      _drag = HorizontalDragGestureRecognizer()
        ..onStart = (DragStartDetails details) {
          _updateSliderThumbPosition(
            details.localPosition,
            ChangeValueType.changeStart,
          );
        }
        ..onUpdate = (DragUpdateDetails details) {
          _updateSliderThumbPosition(
            details.localPosition,
            ChangeValueType.change,
          );
        }
        ..onEnd = (DragEndDetails details) {
          _onChangeEnd?.call(_value);
        };
    }
  }
  double get value => _value;
  double _value;
  set value(double value) {
    assert(value >= _min && value <= _max, "Value must be between min and max");
    if (value == _value) return;
    _value = value;
    markNeedsPaint();
  }

  ValueChanged<double> _onChanged;
  ValueChanged<double> get onChanged => _onChanged;

  set onChanged(ValueChanged<double> onChanged) {
    if (_onChanged == onChanged) return;
    _onChanged = onChanged;
    markNeedsPaint();
  }

  ValueChanged<double>? _onChangeEnd;
  ValueChanged<double>? get onChangeEnd => _onChangeEnd;

  set onChangeEnd(ValueChanged<double>? onChangeEnd) {
    if (_onChangeEnd == onChangeEnd) return;
    _onChangeEnd = onChangeEnd;
    markNeedsPaint();
  }

  ValueChanged<double>? _onChangeStart;
  ValueChanged<double>? get onChangeStart => _onChangeStart;

  set onChangeStart(ValueChanged<double>? onChangeStart) {
    if (_onChangeStart == onChangeStart) return;
    _onChangeStart = onChangeStart;
    markNeedsPaint();
  }

  double get min => _min;
  double _min;

  set min(double min) {
    if (min == _min) return;
    _min = min;
    markNeedsPaint();
  }

  double get max => _max;
  double _max;

  set max(double max) {
    if (max == _max) return;
    _max = max;
    markNeedsPaint();
  }

  SliderDecoration get sliderDecoration => _sliderDecoration;
  SliderDecoration _sliderDecoration;

  set sliderDecoration(SliderDecoration sliderDecoration) {
    if (sliderDecoration == _sliderDecoration) return;
    _sliderDecoration = sliderDecoration;
    markNeedsPaint();
    markNeedsLayout();
  }

  bool get isDraggable => _isDraggable;
  bool _isDraggable;

  set isDraggable(bool isDrag) {
    if (isDraggable == isDrag) return;
    _isDraggable = isDraggable;
    markNeedsPaint();
    markNeedsLayout();
  }

  final double _strokeWidth = 4.0;

  final double _thumbLeftPadding = 10.0;

  @override
  void performLayout() {
    // Setting up the size for the slider widget
    final desiredWidth = constraints.maxWidth;
    final desiredHeight = _sliderDecoration.height;
    final desiredSize = Size(desiredWidth, desiredHeight);
    size = constraints.constrain(desiredSize);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    canvas.save();
    canvas.translate(offset.dx, offset.dy);

    // Draw the slider track
    final inactiveSliderPainter = Paint()
      ..color = _sliderDecoration.inactiveColor
      ..strokeWidth = _strokeWidth
      ..strokeCap = StrokeCap.round;

    final activeSliderPainter = Paint()
      ..color = _sliderDecoration.activeColor
      ..strokeWidth = _strokeWidth
      ..strokeCap = StrokeCap.round;

    final thumbPainter = Paint()..color = _sliderDecoration.thumbColor;

    canvas.drawRRect(
        RRect.fromRectAndCorners(
            Offset.zero & Size(constraints.maxWidth, _sliderDecoration.height),
            topRight: Radius.circular(_sliderDecoration.borderRadius),
            bottomRight: Radius.circular(_sliderDecoration.borderRadius),
            topLeft: Radius.circular(_sliderDecoration.borderRadius),
            bottomLeft: Radius.circular(_sliderDecoration.borderRadius)),
        inactiveSliderPainter);

    final activeTrackLength = (value - min) / (max - min) * size.width;

    canvas.drawRRect(
        RRect.fromRectAndCorners(
            Offset.zero & Size(activeTrackLength, _sliderDecoration.height),
            topRight: Radius.circular(_sliderDecoration.borderRadius),
            bottomRight: Radius.circular(_sliderDecoration.borderRadius),
            topLeft: Radius.circular(_sliderDecoration.borderRadius),
            bottomLeft: Radius.circular(_sliderDecoration.borderRadius)),
        activeSliderPainter);

    if (_sliderDecoration.isThumbVisible) {
      final thumbDesiredDx = activeTrackLength -
          ((activeTrackLength == 0.0) ? 0.0 : _thumbLeftPadding);
      final thumbDesiredDy =
          (size.height / 2) - (_sliderDecoration.thumbHeight / 2);
      final thumbCenter = Offset(thumbDesiredDx, thumbDesiredDy);

      canvas.drawRRect(
          RRect.fromRectAndCorners(
              thumbCenter &
                  Size(_sliderDecoration.thumbWidth,
                      _sliderDecoration.thumbHeight),
              topRight: Radius.circular(_sliderDecoration.borderRadius),
              bottomRight: Radius.circular(_sliderDecoration.borderRadius),
              topLeft: Radius.circular(_sliderDecoration.borderRadius),
              bottomLeft: Radius.circular(_sliderDecoration.borderRadius)),
          thumbPainter);
    }
    canvas.restore();
  }

  /// Helped to Use the horizontal drag gesture for the slider
  HorizontalDragGestureRecognizer _drag = HorizontalDragGestureRecognizer();

  /// Indicates that our widget handles the gestures
  @override
  bool hitTestSelf(Offset position) => true;

  /// Handles the events
  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    assert(
      debugHandleEvent(event, entry),
      'renderer should handle the events',
    );
    if (event is PointerDownEvent) {
      _drag.addPointer(event);
    }
  }

  /// Used to update the slider thumb position
  void _updateSliderThumbPosition(
    Offset localPosition,
    ChangeValueType changeValueType,
  ) {
    /// Clamp the position between the full width of the render object
    var dx = localPosition.dx.clamp(0.0, size.width);

    /// Make the size between 0 and 1 with only 1 decimal and multiply it.
    var desiredDx = double.parse((dx / size.width).toStringAsFixed(1));
    _value = desiredDx * (_max - _min) + _min;

    switch (changeValueType) {
      case ChangeValueType.changeStart:
        _onChangeStart?.call(_value);
        break;
      case ChangeValueType.change:
        _onChanged(_value);
        break;
      case ChangeValueType.changeEnd:
        _onChangeEnd?.call(_value);
        break;
    }

    /// Calling the paint and layout method to render the slider widget
    markNeedsPaint();
    markNeedsSemanticsUpdate();
  }

  @override
  void detach() {
    /// Disposing the horizontal drag gesture
    _drag.dispose();
    super.detach();
  }
}

enum ChangeValueType { changeStart, change, changeEnd }
