import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../models/models.dart';

void showSettingsSheet(BuildContext context) {
  showModalBottomSheet(
    context: context, isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (_) => ChangeNotifierProvider.value(value: context.read<AppState>(), child: const _SettingsSheet()),
  );
}

class _SettingsSheet extends StatelessWidget {
  const _SettingsSheet();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false, initialChildSize: 0.75, minChildSize: 0.4, maxChildSize: 0.95,
      builder: (_, controller) {
        return Consumer<AppState>(builder: (context, state, _) {
          final s = state.settings;
          return ListView(controller: controller, padding: const EdgeInsets.fromLTRB(20, 12, 20, 40), children: [
            Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: const Color(0xFFDEDEDE), borderRadius: BorderRadius.circular(2)))),
            const Text('Settings', style: TextStyle(fontFamily: 'monospace', fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 24),
            _SectionLabel('Language'),
            _OptionGroup(options: const ['English', 'Español', 'Français', 'Deutsch', 'العربية', '中文'], selected: s.language, onSelect: (v) => state.updateSettings(s.copyWith(language: v))),
            const SizedBox(height: 20),
            _SectionLabel('Units'),
            _OptionGroup(options: const ['mm', 'cm', 'm', '"'], selected: s.unitLabel, onSelect: (v) {
              final unit = {'mm': MeasureUnit.mm, 'cm': MeasureUnit.cm, 'm': MeasureUnit.m, '"': MeasureUnit.inches}[v]!;
              state.updateSettings(s.copyWith(unit: unit));
            }),
            const SizedBox(height: 20),
            _SectionLabel('Optimization'),
            _OptionGroup(options: const ['Least Waste', 'Least Cuts'], selected: s.algo == OptimizeAlgo.leastWaste ? 'Least Waste' : 'Least Cuts', onSelect: (v) => state.updateSettings(s.copyWith(algo: v == 'Least Waste' ? OptimizeAlgo.leastWaste : OptimizeAlgo.leastCuts))),
            const SizedBox(height: 20),
            _SectionLabel('Cut Orientation'),
            _OptionGroup(
              options: const ['Optimal', 'Width Cuts', 'Length Cuts'],
              selected: {CutOrientation.optimal: 'Optimal', CutOrientation.widthFirst: 'Width Cuts', CutOrientation.lengthFirst: 'Length Cuts'}[s.orientation]!,
              onSelect: (v) => state.updateSettings(s.copyWith(orientation: {'Optimal': CutOrientation.optimal, 'Width Cuts': CutOrientation.widthFirst, 'Length Cuts': CutOrientation.lengthFirst}[v])),
            ),
            const SizedBox(height: 20),
            _SectionLabel('Blade Thickness (kerf)'),
            _NumberInput(value: s.kerfThickness, hint: 'e.g. 3', suffix: s.unitLabel, onChanged: (v) { final d = double.tryParse(v); if (d != null) state.updateSettings(s.copyWith(kerfThickness: d)); }),
            const SizedBox(height: 20),
            _SectionLabel('Edge Banding Thickness'),
            _NumberInput(value: s.edgeBanding, hint: 'e.g. 0.5', suffix: s.unitLabel, onChanged: (v) { final d = double.tryParse(v); if (d != null) state.updateSettings(s.copyWith(edgeBanding: d)); }),
            const SizedBox(height: 20),
            _SectionLabel('Available Sheets Limit'),
            _NumberInput(value: s.maxSheets.toDouble(), hint: 'Max sheets', suffix: '', onChanged: (v) { final i = int.tryParse(v); if (i != null && i > 0) state.updateSettings(s.copyWith(maxSheets: i)); }),
          ]);
        });
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(text.toUpperCase(), style: const TextStyle(fontFamily: 'monospace', fontSize: 10, letterSpacing: 1.2, color: Color(0xFFAAAAAA), fontWeight: FontWeight.w500)));
  }
}

class _OptionGroup extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelect;
  const _OptionGroup({required this.options, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 6, runSpacing: 6, children: options.map((opt) {
      final active = opt == selected;
      return GestureDetector(
        onTap: () => onSelect(opt),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(color: active ? const Color(0xFFE8E8E8) : Colors.white, border: Border.all(color: active ? const Color(0xFF111111) : const Color(0xFFDEDEDE)), borderRadius: BorderRadius.circular(5)),
          child: Text(opt, style: TextStyle(fontFamily: 'monospace', fontSize: 12, color: active ? const Color(0xFF111111) : const Color(0xFF888888), fontWeight: active ? FontWeight.w600 : FontWeight.w400)),
        ),
      );
    }).toList());
  }
}

class _NumberInput extends StatefulWidget {
  final double value;
  final String hint, suffix;
  final ValueChanged<String> onChanged;
  const _NumberInput({required this.value, required this.hint, required this.suffix, required this.onChanged});
  @override
  State<_NumberInput> createState() => _NumberInputState();
}

class _NumberInputState extends State<_NumberInput> {
  late final TextEditingController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value % 1 == 0 ? widget.value.toInt().toString() : widget.value.toStringAsFixed(1));
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _ctrl, onChanged: widget.onChanged,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
      style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
      decoration: InputDecoration(
        hintText: widget.hint, suffixText: widget.suffix,
        suffixStyle: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: Color(0xFFAAAAAA)),
        isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        filled: true, fillColor: const Color(0xFFF0F0F0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: const BorderSide(color: Color(0xFFDEDEDE))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: const BorderSide(color: Color(0xFFDEDEDE))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(5), borderSide: const BorderSide(color: Color(0xFF111111), width: 1.5)),
      ),
    );
  }
}
