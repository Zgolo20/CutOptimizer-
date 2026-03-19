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
    const margin = 32.0;
    double sheetW = sheet.sheetWidth;
    double sheetH = sheet.sheetLength;
    if (rotated) { final t = sheetW; sheetW = sheetH; sheetH = t; }

    final availW = size.width - margin * 2;
    final availH = size.height - margin * 2;
    final s = min(availW / sheetW, availH / sheetH);
    final offX = margin + (availW - sheetW * s) / 2;
    final offY = margin + (availH - sheetH * s) / 2;

    final sheetRect = Rect.fromLTWH(offX, offY, sheetW * s, sheetH * s);
    canvas.drawRect(sheetRect, Paint()..color = Colors.white);
    _drawHatch(canvas, sheetRect);
    canvas.drawRect(sheetRect, Paint()..color = const Color(0xFFCCCCCC)..style = PaintingStyle.stroke..strokeWidth = 1.5);

    _drawText(canvas, _dimLabel(sheet.sheetLength, sheet.sheetWidth), Offset(offX, offY - 18), fontSize: 11, color: const Color(0xFF888888));

    for (final p in sheet.placements) {
      double px = p.x, py = p.y, pw = p.w, ph = p.h;
      if (rotated) { final tmp = px; px = py; py = tmp; final tw = pw; pw = ph; ph = tw; }

      final rx = offX + px * s;
      final ry = offY + py * s;
      final rw = pw * s;
      final rh = ph * s;

      final fillColor = showColors ? p.color.withOpacity(0.82) : const Color(0xFFDDDDDD);
      final textColor = showColors ? Colors.black : const Color(0xFF333333);

      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(rx, ry, rw, rh), const Radius.circular(2)), Paint()..color = fillColor);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(rx, ry, rw, rh), const Radius.circular(2)), Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 1.5);

      if (showMeasurements && rw > 30 && rh > 16) {
        final lbl = _dimLabel(p.origL, p.origW) + (p.rotated ? ' ↻' : '');
        final fs = min(fontSize, min(rw / max(lbl.length, 1) * 1.5, rh * 0.42));
        if (fs > 6) _drawText(canvas, lbl, Offset(rx + rw / 2, ry + rh / 2), fontSize: fs, color: textColor, centered: true);
      }
    }
  }

  void _drawHatch(Canvas canvas, Rect rect) {
    final paint = Paint()..color = const Color(0xFFDDDDDD)..strokeWidth = 0.8;
    const spacing = 8.0;
    canvas.save();
    canvas.clipRect(rect);
    final diag = rect.width + rect.height;
    for (double i = -diag; i < diag; i += spacing) {
      canvas.drawLine(Offset(rect.left + i, rect.top), Offset(rect.left + i + rect.height, rect.top + rect.height), paint);
    }
    canvas.restore();
  }

  String _dimLabel(double l, double w) {
    String fmt(double v) {
      switch (unit) {
        case MeasureUnit.mm: return v.toStringAsFixed(v % 1 == 0 ? 0 : 1);
        case MeasureUnit.cm: return (v / 10).toStringAsFixed(1);
        case MeasureUnit.m: return (v / 1000).toStringAsFixed(2);
        case MeasureUnit.inches: return (v / 25.4).toStringAsFixed(1);
      }
    }
    return '${fmt(l)}×${fmt(w)}';
  }

  void _drawText(Canvas canvas, String text, Offset position, {double fontSize = 13, Color color = Colors.black, bool centered = false}) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: TextStyle(fontFamily: 'monospace', fontSize: fontSize, color: color, fontWeight: FontWeight.w500, height: 1.2)),
      textDirection: TextDirection.ltr,
    )..layout();
    final offset = centered ? Offset(position.dx - painter.width / 2, position.dy - painter.height / 2) : position;
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(CutSheetPainter old) => old.sheet != sheet || old.showColors != showColors || old.showMeasurements != showMeasurements || old.rotated != rotated || old.fontSize != fontSize || old.unit != unit;
}
