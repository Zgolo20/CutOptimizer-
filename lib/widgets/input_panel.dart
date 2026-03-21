import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../models/models.dart';

class InputPanel extends StatelessWidget {
  const InputPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return Column(children: [
          _CollapsibleSection(title: 'PANELS TO CUT', expanded: state.panelsExpanded, onToggle: state.togglePanels, child: _PanelTable(state: state)),
          _CollapsibleSection(title: 'STOCK SHEET', expanded: state.stockExpanded, onToggle: state.toggleStock, child: _StockTable(state: state)),
          _OptimizeSection(state: state),
          if (state.result != null) _StatsRow(state: state),
        ]);
      },
    );
  }
}

class _CollapsibleSection extends StatelessWidget {
  final String title;
  final bool expanded;
  final VoidCallback onToggle;
  final Widget child;
  const _CollapsibleSection({required this.title, required this.expanded, required this.onToggle, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      InkWell(
        onTap: onToggle,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(color: Color(0xFFF0F0F0), border: Border(bottom: BorderSide(color: Color(0xFFDEDEDE)))),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(title, style: const TextStyle(fontFamily: 'monospace', fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: Color(0xFF555555))),
            AnimatedRotation(turns: expanded ? 0 : -0.25, duration: const Duration(milliseconds: 200), child: const Icon(Icons.keyboard_arrow_down, size: 18, color: Color(0xFF888888))),
          ]),
        ),
      ),
      AnimatedCrossFade(
        firstChild: Padding(padding: const EdgeInsets.all(12), child: child),
        secondChild: const SizedBox.shrink(),
        crossFadeState: expanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
        duration: const Duration(milliseconds: 200),
      ),
    ]);
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();
  @override
  Widget build(BuildContext context) {
    return Row(children: const [
      Expanded(child: _HeaderCell('LENGTH')), SizedBox(width: 6),
      Expanded(child: _HeaderCell('WIDTH')), SizedBox(width: 6),
      SizedBox(width: 60, child: _HeaderCell('QTY')), SizedBox(width: 32),
    ]);
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;
  const _HeaderCell(this.label);
  @override
  Widget build(BuildContext context) {
    return Text(label, style: const TextStyle(fontFamily: 'monospace', fontSize: 10, letterSpacing: 1, color: Color(0xFFAAAAAA), fontWeight: FontWeight.w500));
  }
}

class _PanelTable extends StatelessWidget {
  final AppState state;
  const _PanelTable({required this.state});
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const _TableHeader(), const SizedBox(height: 4),
      ...state.panels.map((p) => _PanelRow(key: ValueKey(p.id), panel: p, onUpdate: (l, w, q) => state.updatePanel(p.id, length: l, width: w, quantity: q), onDelete: () => state.removePanel(p.id))),
      const SizedBox(height: 8),
      _AddRowButton(label: '+ Add Panel', onTap: state.addPanel),
    ]);
  }
}

class _StockTable extends StatelessWidget {
  final AppState state;
  const _StockTable({required this.state});
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const _TableHeader(), const SizedBox(height: 4),
      ...state.stocks.map((s) => _StockRow(key: ValueKey(s.id), stock: s, onUpdate: (l, w, q) => state.updateStock(s.id, length: l, width: w, quantity: q), onDelete: () => state.removeStock(s.id))),
      const SizedBox(height: 8),
      _AddRowButton(label: '+ Add Stock Sheet', onTap: state.addStock),
    ]);
  }
}

class _PanelRow extends StatefulWidget {
  final Panel panel;
  final Function(double?, double?, int?) onUpdate;
  final VoidCallback onDelete;
  const _PanelRow({super.key, required this.panel, required this.onUpdate, required this.onDelete});
  @override
  State<_PanelRow> createState() => _PanelRowState();
}

class _PanelRowState extends State<_PanelRow> {
  late final TextEditingController _lCtrl, _wCtrl, _qCtrl;
  @override
  void initState() {
    super.initState();
    _lCtrl = TextEditingController(text: widget.panel.length > 0 ? widget.panel.length.toStringAsFixed(widget.panel.length % 1 == 0 ? 0 : 1) : '');
    _wCtrl = TextEditingController(text: widget.panel.width > 0 ? widget.panel.width.toStringAsFixed(widget.panel.width % 1 == 0 ? 0 : 1) : '');
    _qCtrl = TextEditingController(text: widget.panel.quantity.toString());
  }
  @override
  void dispose() { _lCtrl.dispose(); _wCtrl.dispose(); _qCtrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.only(bottom: 4), child: Row(children: [
      Expanded(child: _NumInput(controller: _lCtrl, hint: 'L', onChanged: (v) => widget.onUpdate(double.tryParse(v), null, null))),
      const SizedBox(width: 6),
      Expanded(child: _NumInput(controller: _wCtrl, hint: 'W', onChanged: (v) => widget.onUpdate(null, double.tryParse(v), null))),
      const SizedBox(width: 6),
      SizedBox(width: 60, child: _NumInput(controller: _qCtrl, hint: 'Qty', onChanged: (v) => widget.onUpdate(null, null, int.tryParse(v)))),
      SizedBox(width: 32, child: IconButton(onPressed: widget.onDelete, icon: const Icon(Icons.close, size: 16), color: const Color(0xFFAAAAAA), splashRadius: 16, padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 32, minHeight: 32))),
    ]));
  }
}

class _StockRow extends StatefulWidget {
  final StockSheet stock;
  final Function(double?, double?, int?) onUpdate;
  final VoidCallback onDelete;
  const _StockRow({super.key, required this.stock, required this.onUpdate, required this.onDelete});
  @override
  State<_StockRow> createState() => _StockRowState();
}

class _StockRowState extends State<_StockRow> {
  late final TextEditingController _lCtrl, _wCtrl, _qCtrl;
  @override
  void initState() {
    super.initState();
    _lCtrl = TextEditingController(text: widget.stock.length > 0 ? widget.stock.length.toStringAsFixed(0) : '');
    _wCtrl = TextEditingController(text: widget.stock.width > 0 ? widget.stock.width.toStringAsFixed(0) : '');
    _qCtrl = TextEditingController(text: widget.stock.quantity.toString());
  }
  @override
  void dispose() { _lCtrl.dispose(); _wCtrl.dispose(); _qCtrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.only(bottom: 4), child: Row(children: [
      Expanded(child: _NumInput(controller: _lCtrl, hint: 'L', onChanged: (v) => widget.onUpdate(double.tryParse(v), null, null))),
      const SizedBox(width: 6),
      Expanded(child: _NumInput(controller: _wCtrl, hint: 'W', onChanged: (v) => widget.onUpdate(null, double.tryParse(v), null))),
      const SizedBox(width: 6),
      SizedBox(width: 60, child: _NumInput(controller: _qCtrl, hint: 'Qty', onChanged: (v) => widget.onUpdate(null, null, int.tryParse(v)))),
      SizedBox(width: 32, child: IconButton(onPressed: widget.onDelete, icon: const Icon(Icons.close, size: 16), color: const Color(0xFFAAAAAA), splashRadius: 16, padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 32, minHeight: 32))),
    ]));
  }
}

class _NumInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  const _NumInput({required this.controller, required this.hint, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller, onChanged: onChanged,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
      style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
      decoration: InputDecoration(
        hintText: hint, hintStyle: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 13),
        isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        filled: true, fillColor: const Color(0xFFE8E8E8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: const BorderSide(color: Color(0xFFDEDEDE))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: const BorderSide(color: Color(0xFFDEDEDE))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: const BorderSide(color: Color(0xFF111111), width: 1.5)),
      ),
    );
  }
}

class _AddRowButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _AddRowButton({required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(border: Border.all(color: const Color(0xFFDEDEDE)), borderRadius: BorderRadius.circular(8)),
        child: Text(label, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: Color(0xFFAAAAAA), letterSpacing: 0.5)),
      ),
    );
  }
}

class _OptimizeSection extends StatelessWidget {
  final AppState state;
  const _OptimizeSection({required this.state});
  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.all(16), child: Column(children: [
      Row(children: [
        Expanded(child: _AlgoButton(label: '◈  Least Waste', active: state.settings.algo == OptimizeAlgo.leastWaste, onTap: () => state.updateSettings(state.settings.copyWith(algo: OptimizeAlgo.leastWaste)))),
        const SizedBox(width: 8),
        Expanded(child: _AlgoButton(label: '✂  Least Cuts', active: state.settings.algo == OptimizeAlgo.leastCuts, onTap: () => state.updateSettings(state.settings.copyWith(algo: OptimizeAlgo.leastCuts)))),
      ]),
      const SizedBox(height: 10),
      SizedBox(width: double.infinity, child: ElevatedButton(
        onPressed: state.isOptimizing ? null : state.optimize,
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF111111), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0),

        
        child: state.isOptimizing
          ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.content_cut, size: 18, color: Colors.white),
              SizedBox(width: 8),
              Text('OPTIMIZE CUTS', style: TextStyle(fontFamily: 'monospace', fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 1)),
            )), 
        )),
    ]));
  }
}

class _AlgoButton extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _AlgoButton({required this.label, required this.active, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFE8E8E8) : const Color(0xFFF0F0F0),
          border: Border.all(color: active ? const Color(0xFF444444) : const Color(0xFFDEDEDE)),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: active ? const Color(0xFF111111) : const Color(0xFF888888), fontWeight: active ? FontWeight.w600 : FontWeight.w400)),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final AppState state;
  const _StatsRow({required this.state});
  @override
  Widget build(BuildContext context) {
    final result = state.result!;
    final sheets = result.usedSheets;
    return Container(
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFDEDEDE)))),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        Expanded(child: _StatBox(value: '${result.totalEfficiency.toStringAsFixed(1)}%', label: 'Efficiency')),
        const SizedBox(width: 8),
        Expanded(child: _StatBox(value: '${(result.totalWaste / 1000).toStringAsFixed(0)} cm²', label: 'Waste')),
        const SizedBox(width: 8),
        Expanded(child: _StatBox(value: '${sheets.length}', label: 'Sheets')),
      ]),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value, label;
  const _StatBox({required this.value, required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(color: const Color(0xFFF0F0F0), borderRadius: BorderRadius.circular(8)),
      child: Column(children: [
        Text(value, style: const TextStyle(fontFamily: 'monospace', fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF111111))),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontFamily: 'monospace', fontSize: 10, color: Color(0xFFAAAAAA), letterSpacing: 0.5)),
      ]),
    );
  }
}
