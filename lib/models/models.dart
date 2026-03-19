import 'dart:ui';
import 'package:flutter/material.dart';

class Panel {
  String id;
  double length;
  double width;
  int quantity;
  String label;

  Panel({required this.id, this.length = 0, this.width = 0, this.quantity = 1, this.label = ''});

  Panel copyWith({double? length, double? width, int? quantity, String? label}) {
    return Panel(id: id, length: length ?? this.length, width: width ?? this.width, quantity: quantity ?? this.quantity, label: label ?? this.label);
  }

  Map<String, dynamic> toJson() => {'id': id, 'length': length, 'width': width, 'quantity': quantity, 'label': label};

  factory Panel.fromJson(Map<String, dynamic> j) => Panel(id: j['id'] ?? '', length: (j['length'] ?? 0).toDouble(), width: (j['width'] ?? 0).toDouble(), quantity: j['quantity'] ?? 1, label: j['label'] ?? '');
}

class StockSheet {
  String id;
  double length;
  double width;
  int quantity;

  StockSheet({required this.id, this.length = 0, this.width = 0, this.quantity = 1});

  StockSheet copyWith({double? length, double? width, int? quantity}) {
    return StockSheet(id: id, length: length ?? this.length, width: width ?? this.width, quantity: quantity ?? this.quantity);
  }

  Map<String, dynamic> toJson() => {'id': id, 'length': length, 'width': width, 'quantity': quantity};

  factory StockSheet.fromJson(Map<String, dynamic> j) => StockSheet(id: j['id'] ?? '', length: (j['length'] ?? 0).toDouble(), width: (j['width'] ?? 0).toDouble(), quantity: j['quantity'] ?? 1);
}

class Placement {
  final double x, y, w, h, origL, origW;
  final bool rotated;
  final Color color;
  final String label;

  const Placement({required this.x, required this.y, required this.w, required this.h, required this.origL, required this.origW, required this.rotated, required this.color, this.label = ''});
}

class FreeRect {
  double x, y, w, h;
  FreeRect(this.x, this.y, this.w, this.h);
}

class SheetResult {
  final double sheetLength, sheetWidth;
  final List<Placement> placements;

  const SheetResult({required this.sheetLength, required this.sheetWidth, required this.placements});

  double get usedArea => placements.fold(0.0, (sum, p) => sum + p.w * p.h);
  double get totalArea => sheetLength * sheetWidth;
  double get efficiency => totalArea > 0 ? (usedArea / totalArea * 100) : 0.0;
  double get wasteArea => totalArea - usedArea;
}

class OptimizeResult {
  final List<SheetResult> sheets;
  final int unplacedCount;

  const OptimizeResult({required this.sheets, this.unplacedCount = 0});

  List<SheetResult> get usedSheets => sheets.where((s) => s.placements.isNotEmpty).toList();

  double get totalEfficiency {
    if (usedSheets.isEmpty) return 0;
    final totalUsed = usedSheets.fold(0.0, (s, r) => s + r.usedArea);
    final totalArea = usedSheets.fold(0.0, (s, r) => s + r.totalArea);
    return totalArea > 0 ? totalUsed / totalArea * 100 : 0;
  }

  double get totalWaste => usedSheets.fold(0.0, (s, r) => s + r.wasteArea);
}

enum OptimizeAlgo { leastWaste, leastCuts }
enum CutOrientation { optimal, widthFirst, lengthFirst }
enum MeasureUnit { mm, cm, m, inches }

class AppSettings {
  final MeasureUnit unit;
  final OptimizeAlgo algo;
  final CutOrientation orientation;
  final double kerfThickness, edgeBanding;
  final int maxSheets;
  final String language;

  const AppSettings({this.unit = MeasureUnit.mm, this.algo = OptimizeAlgo.leastWaste, this.orientation = CutOrientation.optimal, this.kerfThickness = 3.0, this.edgeBanding = 0.0, this.maxSheets = 999, this.language = 'English'});

  AppSettings copyWith({MeasureUnit? unit, OptimizeAlgo? algo, CutOrientation? orientation, double? kerfThickness, double? edgeBanding, int? maxSheets, String? language}) {
    return AppSettings(unit: unit ?? this.unit, algo: algo ?? this.algo, orientation: orientation ?? this.orientation, kerfThickness: kerfThickness ?? this.kerfThickness, edgeBanding: edgeBanding ?? this.edgeBanding, maxSheets: maxSheets ?? this.maxSheets, language: language ?? this.language);
  }

  Map<String, dynamic> toJson() => {'unit': unit.index, 'algo': algo.index, 'orientation': orientation.index, 'kerfThickness': kerfThickness, 'edgeBanding': edgeBanding, 'maxSheets': maxSheets, 'language': language};

  factory AppSettings.fromJson(Map<String, dynamic> j) => AppSettings(unit: MeasureUnit.values[j['unit'] ?? 0], algo: OptimizeAlgo.values[j['algo'] ?? 0], orientation: CutOrientation.values[j['orientation'] ?? 0], kerfThickness: (j['kerfThickness'] ?? 3.0).toDouble(), edgeBanding: (j['edgeBanding'] ?? 0.0).toDouble(), maxSheets: j['maxSheets'] ?? 999, language: j['language'] ?? 'English');

  String get unitLabel {
    switch (unit) {
      case MeasureUnit.mm: return 'mm';
      case MeasureUnit.cm: return 'cm';
      case MeasureUnit.m: return 'm';
      case MeasureUnit.inches: return '"';
    }
  }
}
