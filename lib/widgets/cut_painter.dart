
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/models.dart';

class CutSheetPainter extends CustomPainter {
  final SheetResult sheet;
  final bool showColors, showMeasurements, rotated;
  final double fontSize;
  final MeasureUnit unit;

  CutSheetPainter({required this.sheet, required this.showColors, required this.showMeasurements, required this.rotated, required this.fontSize, required this.unit});

  @override
  void paint(Canvas canvas, Size size) {
    const margin = 40.0;
    double sheetW = sheet.sheetWidth;
    double sheetH = sheet.sheetLength;
    if (rotated) { final t = sheetW; sheetW = sheetH; sheetH = t; }

    final availW = size.width - margin * 2;
    final availH = size.height - margin * 2;
    final s = min(availW / sheetW, availH / sheetH);

    final drawW = sheetW * s;
    final drawH = sheetH * s;
    final offX = margin + (availW - drawW) / 2;
    final offY = margin + (availH - drawH) / 2;

    final sheetRect = Rect.fromLTWH(offX, offY, drawW, drawH);

    canvas.drawRect(sheetRect, Paint()..color = Colors.white);
    _drawHatch(canvas, sheetRect);
    canvas.drawRect(sheetRect, Paint()
      ..color = const Color(0xFFAAAAAA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5);

    _drawText(canvas, '${_fmt(sheet.sheetLength)} × ${_fmt(sheet.sheetWidth)} ${_unitName()}',
      Offset(offX, offY - 20), fontSize: 11, color: const Color(0xFF666666));

    for (int i = 0; i < sheet.placements.length; i++) {
      final p = sheet.placements[i];
      double px = p.x, py = p.y, pw = p.w, ph = p.h;
      if (rotated) {
        final tmp = px; px = py; py = tmp;
        final tw = pw; pw = ph; ph = tw;
      }

      final rx = offX + px * s;
      final ry = offY + py * s;
      final rw = pw * s;
      final rh = ph * s;

      final fillColor = showColors
        ? (i < _colors.length ? _colors[i % _colors.length] : Colors.blue).withOpacity(0.82)
        : const Color(0xFFDDDDDD);
      final textColor = showColors ? Colors.black87 : const Color(0xFF333333);

      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(rx, ry, rw, rh), const Radius.circular(3)),
        Paint()..color = fillColor,
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(rx, ry, rw, rh), const Radius.circular(3)),
        Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 1.5,
      );

      if (showMeasurements && rw > 30 && rh > 16) {
        final lbl = '${_fmt(p.origL)}×${_fmt(p.origW)}${p.rotated ? " ↻" : ""}';
        final fs = min(fontSize, min(rw / max(lbl.length, 1) * 1.5, rh * 0.4)).clamp(7.0, 20.0);
        _drawText(canvas, lbl, Offset(rx + rw / 2, ry + rh / 2),
          fontSize: fs, color: textColor, centered: true);
      }
    }
  }

  static const List<Color> _colors = [
    Color(0xFFE8534A), Color(0xFF4A90E8), Color(0xFF4CAF50),
    Color(0xFFF5A623), Color(0xFF9B59B6), Color(0xFF1ABC9C),
    Color(0xFFE91E63), Color(0xFF3F51B5), Color(0xFFFF9800),
    Color(0xFF00BCD4), Color(0xFF8BC34A), Color(0xFFFF5722),
    Color(0xFF607D8B), Color(0xFF795548), Color(0xFF673AB7),
    Color(0xFF009688), Color(0xFFC0392B), Color(0xFF2980B9),
    Color(0xFF27AE60), Color(0xFFD35400),
  ];

  void _drawHatch(Canvas canvas, Rect rect) {
    final paint = Paint()..color = const Color(0xFFDDDDDD)..strokeWidth = 0.8;
    const spacing = 10.0;
    canvas.save();
    canvas.clipRect(rect);
    final diag = rect.width + rect.height;
    for (double i = -diag; i < diag; i += spacing) {
      canvas.drawLine(
        Offset(rect.left + i, rect.top),
        Offset(rect.left + i + rect.height, rect.top + rect.height),
        paint,
      );
    }
    canvas.restore();
  }

  String _fmt(double v) {
    switch (unit) {
      case MeasureUnit.mm: return v.toStringAsFixed(v % 1 == 0 ? 0 : 1);
      case MeasureUnit.cm: return (v / 10).toStringAsFixed(1);
      case MeasureUnit.m: return (v / 1000).toStringAsFixed(2);
      case MeasureUnit.inches: return (v / 25.4).toStringAsFixed(1);
    }
  }

  String _unitName() {
    switch (unit) {
      case MeasureUnit.mm: return 'mm';
      case MeasureUnit.cm: return 'cm';
      case MeasureUnit.m: return 'm';
      case MeasureUnit.inches: return '"';
    }
  }

  void _drawText(Canvas canvas, String text, Offset position,
      {double fontSize = 13, Color color = Colors.black, bool centered = false}) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: TextStyle(
        fontFamily: 'monospace', fontSize: fontSize,
        color: color, fontWeight: FontWeight.w500, height: 1.2,
      )),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 300);
    final offset = centered
      ? Offset(position.dx - painter.width / 2, position.dy - painter.height / 2)
      : position;
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(CutSheetPainter old) => true;
}
