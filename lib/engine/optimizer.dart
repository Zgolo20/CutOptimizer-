import 'dart:math';
import 'package:flutter/material.dart';
import '../models/models.dart';

const List<Color> kPanelColors = [
  Color(0xFFE8534A), Color(0xFF4A90E8), Color(0xFF4CAF50),
  Color(0xFFF5A623), Color(0xFF9B59B6), Color(0xFF1ABC9C),
  Color(0xFFE91E63), Color(0xFF3F51B5), Color(0xFFFF9800),
  Color(0xFF00BCD4), Color(0xFF8BC34A), Color(0xFFFF5722),
  Color(0xFF607D8B), Color(0xFF795548), Color(0xFF673AB7),
  Color(0xFF009688), Color(0xFFC0392B), Color(0xFF2980B9),
  Color(0xFF27AE60), Color(0xFFD35400),
];

class _WorkPanel {
  final double origL, origW, l, w;
  final Color color;
  final String label;
  _WorkPanel({required this.origL, required this.origW, required this.l, required this.w, required this.color, required this.label});
}

class _WorkSheet {
  final double L, W;
  List<FreeRect> freeRects = [];
  List<Placement> placements = [];
  _WorkSheet({required this.L, required this.W});
}

class _FitResult {
  final FreeRect rect;
  final bool rotated;
  _FitResult({required this.rect, required this.rotated});
}

class Optimizer {
  static OptimizeResult optimize({required List<Panel> panels, required List<StockSheet> stocks, required AppSettings settings}) {
    final kerf = settings.kerfThickness;
    final edgeBand = settings.edgeBanding;

    final List<_WorkPanel> workPanels = [];
    int colorIdx = 0;
    for (final p in panels) {
      if (p.length <= 0 || p.width <= 0) continue;
      for (int i = 0; i < p.quantity; i++) {
        workPanels.add(_WorkPanel(origL: p.length, origW: p.width, l: p.length + edgeBand * 2, w: p.width + edgeBand * 2, color: kPanelColors[colorIdx % kPanelColors.length], label: p.label));
        colorIdx++;
      }
    }

    if (workPanels.isEmpty) return const OptimizeResult(sheets: [], unplacedCount: 0);

    if (settings.algo == OptimizeAlgo.leastWaste) {
      workPanels.sort((a, b) => (b.l * b.w).compareTo(a.l * a.w));
    } else {
      workPanels.sort((a, b) => max(b.l, b.w).compareTo(max(a.l, a.w)));
    }

    final List<_WorkSheet> workSheets = [];
    for (final s in stocks) {
      if (s.length <= 0 || s.width <= 0) continue;
      for (int i = 0; i < min(s.quantity, settings.maxSheets); i++) {
        workSheets.add(_WorkSheet(L: s.length, W: s.width));
      }
    }

    if (workSheets.isEmpty) return OptimizeResult(sheets: const [], unplacedCount: workPanels.length);

    final limited = workSheets.take(settings.maxSheets).toList();
    final remaining = List<_WorkPanel>.from(workPanels);

    for (final sheet in limited) {
      if (remaining.isEmpty) break;
      sheet.freeRects = [FreeRect(0, 0, sheet.W, sheet.L)];
      bool placed = true;
      while (placed && remaining.isNotEmpty) {
        placed = false;
        for (int pi = 0; pi < remaining.length; pi++) {
          final panel = remaining[pi];
          final fit = _findBestFit(sheet.freeRects, panel.l, panel.w, kerf, settings.algo, settings.orientation);
          if (fit != null) {
            final pw = fit.rotated ? panel.l : panel.w;
            final ph = fit.rotated ? panel.w : panel.l;
            sheet.placements.add(Placement(x: fit.rect.x, y: fit.rect.y, w: pw, h: ph, origL: panel.origL, origW: panel.origW, rotated: fit.rotated, color: panel.color, label: panel.label));
            _splitRect(sheet.freeRects, fit.rect, pw + kerf, ph + kerf);
            remaining.removeAt(pi);
            placed = true;
            break;
          }
        }
      }
    }

    final results = limited.map((s) => SheetResult(sheetLength: s.L, sheetWidth: s.W, placements: List.unmodifiable(s.placements))).toList();
    return OptimizeResult(sheets: results, unplacedCount: remaining.length);
  }

  static _FitResult? _findBestFit(List<FreeRect> freeRects, double pl, double pw, double kerf, OptimizeAlgo algo, CutOrientation orient) {
    _FitResult? best;
    double bestScore = double.infinity;
    for (final rect in freeRects) {
      final canNormal = pw <= rect.w && pl <= rect.h;
      final canRotated = pl <= rect.w && pw <= rect.h;
      if (canNormal) {
        final score = algo == OptimizeAlgo.leastWaste ? rect.w * rect.h - pw * pl : (rect.w - pw) + (rect.h - pl);
        if (score < bestScore) { bestScore = score; best = _FitResult(rect: rect, rotated: false); }
      }
      if (canRotated && pl != pw) {
        final score = algo == OptimizeAlgo.leastWaste ? rect.w * rect.h - pl * pw : (rect.w - pl) + (rect.h - pw);
        if (score < bestScore) { bestScore = score; best = _FitResult(rect: rect, rotated: true); }
      }
    }
    return best;
  }

  static void _splitRect(List<FreeRect> freeRects, FreeRect used, double pw, double ph) {
    final newRects = <FreeRect>[];
    for (final rect in freeRects) {
      if (!(used.x < rect.x + rect.w && used.x + pw > rect.x && used.y < rect.y + rect.h && used.y + ph > rect.y)) {
        newRects.add(rect); continue;
      }
      final rightW = rect.w - pw - (used.x - rect.x);
      if (used.x + pw < rect.x + rect.w && rightW > 0) newRects.add(FreeRect(used.x + pw, rect.y, rightW, rect.h));
      final botH = rect.h - ph - (used.y - rect.y);
      if (used.y + ph < rect.y + rect.h && botH > 0) newRects.add(FreeRect(rect.x, used.y + ph, rect.w, botH));
    }
    freeRects..clear()..addAll(newRects.where((r) => r.w > 0 && r.h > 0));
  }
}
