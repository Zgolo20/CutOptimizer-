import '../models/models.dart';

String formatArea(double areaMm2, MeasureUnit unit) {
  switch (unit) {
    case MeasureUnit.mm: return '${areaMm2.round()} mm²';
    case MeasureUnit.cm: return '${(areaMm2 / 100).toStringAsFixed(1)} cm²';
    case MeasureUnit.m: return '${(areaMm2 / 1e6).toStringAsFixed(4)} m²';
    case MeasureUnit.inches: return '${(areaMm2 / 645.16).toStringAsFixed(2)} in²';
  }
}

String formatLength(double mm, MeasureUnit unit) {
  switch (unit) {
    case MeasureUnit.mm: return '${mm.toStringAsFixed(mm % 1 == 0 ? 0 : 1)} mm';
    case MeasureUnit.cm: return '${(mm / 10).toStringAsFixed(1)} cm';
    case MeasureUnit.m: return '${(mm / 1000).toStringAsFixed(3)} m';
    case MeasureUnit.inches: return '${(mm / 25.4).toStringAsFixed(2)}"';
  }
}

String formatDimensions(double l, double w, MeasureUnit unit) {
  String fmt(double v) {
    switch (unit) {
      case MeasureUnit.mm: return v.toStringAsFixed(v % 1 == 0 ? 0 : 1);
      case MeasureUnit.cm: return (v / 10).toStringAsFixed(1);
      case MeasureUnit.m: return (v / 1000).toStringAsFixed(3);
      case MeasureUnit.inches: return (v / 25.4).toStringAsFixed(2);
    }
  }
  return '${fmt(l)} × ${fmt(w)} ${unit == MeasureUnit.inches ? '"' : unit.name}';
}
