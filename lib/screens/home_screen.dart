import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../widgets/input_panel.dart';
import '../widgets/preview_panel.dart';
import '../widgets/settings_sheet.dart';
import '../widgets/menu_drawer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _AppBar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 768) return const _DesktopLayout();
          return const _MobileLayout();
        },
      ),
    );
  }
}

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(52);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: const Color(0xFFDEDEDE)),
      ),
      title: RichText(
        text: const TextSpan(children: [
          TextSpan(text: '✦ Cut', style: TextStyle(fontFamily: 'monospace', fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF111111), letterSpacing: -0.5)),
          TextSpan(text: 'Optimizer', style: TextStyle(fontFamily: 'monospace', fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF444444), letterSpacing: -0.5)),
        ]),
      ),
      actions: [
        IconButton(icon: const Icon(Icons.settings_outlined, color: Color(0xFF888888)), tooltip: 'Settings', onPressed: () => showSettingsSheet(context)),
        IconButton(icon: const Icon(Icons.more_horiz, color: Color(0xFF888888)), tooltip: 'Menu', onPressed: () => showMenuDrawer(context)),
        const SizedBox(width: 4),
      ],
    );
  }
}

class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout();

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SizedBox(
        width: 320,
        child: Container(
          decoration: const BoxDecoration(color: Colors.white, border: Border(right: BorderSide(color: Color(0xFFDEDEDE)))),
          child: const SingleChildScrollView(child: InputPanel()),
        ),
      ),
      const Expanded(child: PreviewPanel()),
    ]);
  }
}

class _MobileLayout extends StatelessWidget {
  const _MobileLayout();

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.55),
        decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Color(0xFFDEDEDE)))),
        child: const SingleChildScrollView(child: InputPanel()),
      ),
      const Expanded(child: PreviewPanel()),
    ]);
  }
}
