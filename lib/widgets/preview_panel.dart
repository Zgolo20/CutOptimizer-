import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../models/models.dart';
import 'cut_painter.dart';

class PreviewPanel extends StatefulWidget {
  const PreviewPanel({super.key});

  @override
  State<PreviewPanel> createState() => _PreviewPanelState();
}

class _PreviewPanelState extends State<PreviewPanel> {
  final TransformationController _transformController = TransformationController();

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  void _zoomIn() {
    final Matrix4 m = _transformController.value.clone();
    m.scale(1.25);
    _transformController.value = m;
  }

  void _zoomOut() {
    final Matrix4 m = _transformController.value.clone();
    m.scale(0.8);
    _transformController.value = m;
  }

  void _zoomFit() {
    _transformController.value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return Column(children: [
          _Toolbar(onZoomIn: _zoomIn, onZoomOut: _zoomOut, onZoomFit: _zoomFit),
          if (state.result != null && state.result!.usedSheets.length > 1)
            _SheetTabs(state: state),
          Expanded(
            child: state.result == null
              ? const _EmptyState()
              : _CanvasView(state: state, transformController: _transformController),
          ),
        ]);
      },
    );
  }
}

class _Toolbar extends StatelessWidget {
  final VoidCallback onZoomIn, onZoomOut, onZoomFit;
  const _Toolbar({required this.onZoomIn, required this.onZoomOut, required this.onZoomFit});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFDEDEDE))),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(children: [
          _ToolBtn(icon: Icons.zoom_in, tip: 'Zoom In', onTap: onZoomIn),
          _ToolBtn(icon: Icons.zoom_out, tip: 'Zoom Out', onTap: onZoomOut),
          _ToolBtn(icon: Icons.fit_screen, tip: 'Fit', onTap: onZoomFit),
          const _Sep(),
          Consumer<AppState>(builder: (_, st, __) =>
            _ToolBtn(icon: Icons.rotate_right, tip: 'Rotate', active: st.rotateView, onTap: st.toggleRotate)),
          const _Sep(),
          Consumer<AppState>(builder: (_, st, __) =>
            _ToolBtn(icon: Icons.text_increase, tip: 'Larger text', onTap: st.increaseFontSize)),
          Consumer<AppState>(builder: (_, st, __) =>
            _ToolBtn(icon: Icons.text_decrease, tip: 'Smaller text', onTap: st.decreaseFontSize)),
          const _Sep(),
          Consumer<AppState>(builder: (_, st, __) =>
            _ToolBtn(icon: Icons.palette_outlined, tip: 'Toggle Color', active: st.showColors, onTap: st.toggleColors)),
          Consumer<AppState>(builder: (_, st, __) =>
            _ToolBtn(icon: Icons.square_foot, tip: 'Measurements', active: st.showMeasurements, onTap: st.toggleMeasurements)),
          const _Sep(),
          _ToolBtn(icon: Icons.image_outlined, tip: 'Export PNG',
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Export PNG coming soon'), backgroundColor: Color(0xFF111111), behavior: SnackBarBehavior.floating))),
          _ToolBtn(icon: Icons.picture_as_pdf_outlined, tip: 'Export PDF',
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Export PDF coming soon'), backgroundColor: Color(0xFF111111), behavior: SnackBarBehavior.floating))),
        ]),
      ),
    );
  }
}

class _ToolBtn extends StatelessWidget {
  final IconData icon;
  final String tip;
  final VoidCallback onTap;
  final bool active;
  const _ToolBtn({required this.icon, required this.tip, required this.onTap, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(5),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 4),
            decoration: BoxDecoration(
              color: active ? const Color(0xFFE8E8E8) : Colors.transparent,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Icon(icon, size: 20, color: active ? const Color(0xFF111111) : const Color(0xFF888888)),
          ),
        ),
      ),
    );
  }
}

class _Sep extends StatelessWidget {
  const _Sep();
  @override
  Widget build(BuildContext context) => Container(
    width: 1, height: 24, margin: const EdgeInsets.symmetric(horizontal: 4),
    color: const Color(0xFFDEDEDE),
  );
}

class _SheetTabs extends StatelessWidget {
  final AppState state;
  const _SheetTabs({required this.state});

  @override
  Widget build(BuildContext context) {
    final sheets = state.result!.usedSheets;
    return Container(
      height: 36,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFDEDEDE))),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 12, top: 6),
        child: Row(children: List.generate(sheets.length, (i) {
          final active = i == state.currentSheetIndex;
          return GestureDetector(
            onTap: () => state.selectSheet(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(right: 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: active ? const Color(0xFFF5F5F5) : const Color(0xFFF0F0F0),
                border: Border(
                  top: BorderSide(color: active ? const Color(0xFFDEDEDE) : Colors.transparent),
                  left: BorderSide(color: active ? const Color(0xFFDEDEDE) : Colors.transparent),
                  right: BorderSide(color: active ? const Color(0xFFDEDEDE) : Colors.transparent),
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
              ),
              child: Text('Sheet ${i + 1}', style: TextStyle(
                fontFamily: 'monospace', fontSize: 12,
                color: active ? const Color(0xFF111111) : const Color(0xFFAAAAAA),
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              )),
            ),
          );
        })),
      ),
    );
  }
}

class _CanvasView extends StatelessWidget {
  final AppState state;
  final TransformationController transformController;
  const _CanvasView({required this.state, required this.transformController});

  @override
  Widget build(BuildContext context) {
    final sheet = state.currentSheet;
    if (sheet == null) return const _EmptyState();

    final double canvasW = sheet.sheetWidth + 120;
    final double canvasH = sheet.sheetLength + 120;

    return Container(
      color: const Color(0xFFF0F0F0),
      child: InteractiveViewer(
        transformationController: transformController,
        minScale: 0.05,
        maxScale: 10.0,
        boundaryMargin: const EdgeInsets.all(200),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: CustomPaint(
              size: Size(canvasW, canvasH),
              painter: CutSheetPainter(
                sheet: sheet,
                showColors: state.showColors,
                showMeasurements: state.showMeasurements,
                rotated: state.rotateView,
                fontSize: state.fontSize,
                unit: state.settings.unit,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F5F5),
      child: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.crop_free_rounded, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('Ready to Optimize', style: TextStyle(
            fontFamily: 'monospace', fontSize: 18,
            fontWeight: FontWeight.w700, color: Color(0xFF888888),
          )),
          const SizedBox(height: 8),
          const Text('Add panels & stock sheets,\nthen tap Optimize Cuts.',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'monospace', fontSize: 13,
              color: Color(0xFFAAAAAA), height: 1.6)),
        ]),
      ),
    );
  }
}
