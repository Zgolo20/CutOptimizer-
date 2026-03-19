# ✦ CutOptimizer Pro — Flutter/Dart

A cross-platform 2D panel cut optimization app built with Flutter.
Runs on **Android, iOS, Web, Windows, macOS, Linux** from a single codebase.

---

## 📁 Project Structure

```
cut_optimizer/
├── lib/
│   ├── main.dart                  # App entry point
│   ├── models/
│   │   └── models.dart            # Panel, StockSheet, Placement, Settings
│   ├── engine/
│   │   └── optimizer.dart         # Guillotine bin-packing algorithm
│   ├── state/
│   │   └── app_state.dart         # ChangeNotifier state management
│   ├── screens/
│   │   └── home_screen.dart       # Responsive main screen
│   ├── widgets/
│   │   ├── input_panel.dart       # Collapsible panel/stock tables
│   │   ├── preview_panel.dart     # Toolbar + canvas + sheet tabs
│   │   ├── cut_painter.dart       # CustomPainter for cut layout
│   │   ├── settings_sheet.dart    # Settings bottom sheet
│   │   └── menu_drawer.dart       # Menu bottom sheet
│   └── utils/
│       └── units.dart             # Unit formatting helpers
├── android/
│   └── app/src/main/
│       └── AndroidManifest.xml
└── pubspec.yaml
```

---

## 🚀 Getting Started

### Prerequisites
```bash
flutter --version   # Requires Flutter 3.10+ / Dart 3.0+
```

### Install & Run

```bash
# 1. Get dependencies
flutter pub get

# 2. Run on your device/emulator
flutter run                        # auto-detect connected device
flutter run -d chrome              # Web
flutter run -d windows             # Windows desktop
flutter run -d linux               # Linux desktop
flutter run -d macos               # macOS desktop
flutter run -d android             # Android
flutter run -d ios                 # iOS (requires macOS + Xcode)
```

---

## 📦 Building for Distribution

### Android APK
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle (Play Store)
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS (requires macOS)
```bash
flutter build ios --release
# Then open ios/Runner.xcworkspace in Xcode to archive
```

### Web
```bash
flutter build web --release
# Output: build/web/ — deploy to any static host
```

### Windows
```bash
flutter build windows --release
# Output: build/windows/runner/Release/
```

### Linux
```bash
flutter build linux --release
# Output: build/linux/x64/release/bundle/
```

### macOS
```bash
flutter build macos --release
# Output: build/macos/Build/Products/Release/
```

---

## ✅ Features

| Feature | Status |
|---------|--------|
| Panel input table (collapsible) | ✅ |
| Stock sheet input table (collapsible) | ✅ |
| Guillotine bin-packing algorithm | ✅ |
| Least Waste optimization | ✅ |
| Least Cuts optimization | ✅ |
| Blade kerf (thickness) | ✅ |
| Edge banding calculation | ✅ |
| Color / B&W toggle | ✅ |
| Dimension labels on cuts | ✅ |
| Zoom in/out/fit (InteractiveViewer) | ✅ |
| Pinch-to-zoom on mobile | ✅ |
| Rotate view | ✅ |
| Font size adjust | ✅ |
| Sheet tabs (multi-sheet) | ✅ |
| Efficiency / waste / sheets stats | ✅ |
| Settings (unit, algo, orientation, kerf, edge, maxSheets) | ✅ |
| Language selector (UI only, i18n ready) | ✅ |
| Save / Load project (JSON) | ✅ |
| Desktop responsive layout | ✅ |
| Mobile responsive layout | ✅ |
| Export PNG | 🔧 Add `screenshot` package |
| Export PDF | 🔧 Add `pdf` + `printing` packages |
| Sign in / Auth | 🔧 Add `firebase_auth` |

---

## 📦 Key Dependencies

| Package | Purpose |
|---------|---------|
| `provider` | State management |
| `file_picker` | Load project JSON files |
| `path_provider` | Save project to documents dir |
| `shared_preferences` | Persist settings across sessions |
| `uuid` | Unique IDs for panels/stocks |
| `pdf` + `printing` | PDF export |
| `screenshot` | PNG export |
| `share_plus` | Native share sheet |

---

## 🔧 Adding PDF Export

```dart
// In menu_drawer.dart, replace the toast with:
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

Future<void> _exportPDF(BuildContext context) async {
  final pdf = pw.Document();
  // Add pages for each sheet result
  pdf.addPage(pw.Page(
    build: (ctx) => pw.Center(child: pw.Text('Cut Plan')),
  ));
  await Printing.layoutPdf(onLayout: (_) async => pdf.save());
}
```

---

## 🔧 Adding PNG Export

```dart
// Wrap your canvas in a RepaintBoundary with a GlobalKey
// then use:
import 'package:screenshot/screenshot.dart';

final _screenshotCtrl = ScreenshotController();
// Wrap canvas: Screenshot(controller: _screenshotCtrl, child: canvas)
// Export:
final bytes = await _screenshotCtrl.capture();
// Save or share using share_plus
```

---

## 🌍 Adding Full i18n

```bash
flutter pub add flutter_localizations
flutter pub add intl
flutter gen-l10n
```

Add ARB files in `lib/l10n/app_en.arb`, `app_es.arb`, etc.

---

## 📱 Platform Notes

- **Android**: File picker needs `READ_EXTERNAL_STORAGE` (already in manifest)
- **iOS**: Add `NSDocumentsFolderUsageDescription` to `ios/Runner/Info.plist`
- **Web**: File picker works via browser dialog; path_provider uses IndexedDB
- **Windows/Linux/macOS**: Full file system access, no extra config needed
