import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../engine/optimizer.dart';

const _uuid = Uuid();

class AppState extends ChangeNotifier {
  List<Panel> panels = [
    Panel(id: _uuid.v4(), length: 600, width: 400, quantity: 2),
    Panel(id: _uuid.v4(), length: 900, width: 200, quantity: 3),
    Panel(id: _uuid.v4(), length: 300, width: 300, quantity: 4),
  ];

  List<StockSheet> stocks = [
    StockSheet(id: _uuid.v4(), length: 2440, width: 1220, quantity: 2),
  ];

  AppSettings settings = const AppSettings();
  OptimizeResult? result;
  int currentSheetIndex = 0;
  double zoomScale = 1.0;
  bool showColors = true;
  bool showMeasurements = true;
  bool rotateView = false;
  double fontSize = 13.0;
  bool panelsExpanded = true;
  bool stockExpanded = true;
  bool isOptimizing = false;

  void addPanel() { panels = [...panels, Panel(id: _uuid.v4())]; notifyListeners(); }

  void updatePanel(String id, {double? length, double? width, int? quantity, String? label}) {
    panels = panels.map((p) { if (p.id != id) return p; return p.copyWith(length: length, width: width, quantity: quantity, label: label); }).toList();
    notifyListeners();
  }

  void removePanel(String id) { panels = panels.where((p) => p.id != id).toList(); notifyListeners(); }

  void addStock() { stocks = [...stocks, StockSheet(id: _uuid.v4())]; notifyListeners(); }

  void updateStock(String id, {double? length, double? width, int? quantity}) {
    stocks = stocks.map((s) { if (s.id != id) return s; return s.copyWith(length: length, width: width, quantity: quantity); }).toList();
    notifyListeners();
  }

  void removeStock(String id) { stocks = stocks.where((s) => s.id != id).toList(); notifyListeners(); }

  void updateSettings(AppSettings s) { settings = s; notifyListeners(); _saveSettings(); }

  Future<void> optimize() async {
    isOptimizing = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 50));
    result = Optimizer.optimize(panels: panels, stocks: stocks, settings: settings);
    currentSheetIndex = 0;
    isOptimizing = false;
    notifyListeners();
  }

  void setZoom(double scale) { zoomScale = scale.clamp(0.1, 8.0); notifyListeners(); }
  void zoomIn() => setZoom(zoomScale * 1.25);
  void zoomOut() => setZoom(zoomScale * 0.8);
  void zoomFit() => setZoom(1.0);
  void toggleColors() { showColors = !showColors; notifyListeners(); }
  void toggleMeasurements() { showMeasurements = !showMeasurements; notifyListeners(); }
  void toggleRotate() { rotateView = !rotateView; notifyListeners(); }
  void increaseFontSize() { fontSize = (fontSize + 2).clamp(8, 28); notifyListeners(); }
  void decreaseFontSize() { fontSize = (fontSize - 2).clamp(8, 28); notifyListeners(); }
  void selectSheet(int index) { currentSheetIndex = index; notifyListeners(); }
  void togglePanels() { panelsExpanded = !panelsExpanded; notifyListeners(); }
  void toggleStock() { stockExpanded = !stockExpanded; notifyListeners(); }

  Map<String, dynamic> toProjectJson() => {
    'panels': panels.map((p) => p.toJson()).toList(),
    'stocks': stocks.map((s) => s.toJson()).toList(),
    'settings': settings.toJson(),
  };

  void loadFromProjectJson(Map<String, dynamic> json) {
    panels = (json['panels'] as List).map((j) => Panel.fromJson(j as Map<String, dynamic>)).toList();
    stocks = (json['stocks'] as List).map((j) => StockSheet.fromJson(j as Map<String, dynamic>)).toList();
    if (json['settings'] != null) settings = AppSettings.fromJson(json['settings'] as Map<String, dynamic>);
    result = null;
    notifyListeners();
  }

  void newProject() {
    panels = [Panel(id: _uuid.v4())];
    stocks = [StockSheet(id: _uuid.v4())];
    result = null;
    currentSheetIndex = 0;
    notifyListeners();
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('settings', jsonEncode(settings.toJson()));
  }

  Future<void> loadSavedSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('settings');
      if (raw != null) { settings = AppSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>); notifyListeners(); }
    } catch (_) {}
  }

  SheetResult? get currentSheet {
    final used = result?.usedSheets;
    if (used == null || used.isEmpty) return null;
    if (currentSheetIndex >= used.length) return used.last;
    return used[currentSheetIndex];
  }
}
