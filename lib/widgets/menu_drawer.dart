import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../state/app_state.dart';

void showMenuDrawer(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (_) => ChangeNotifierProvider.value(value: context.read<AppState>(), child: const _MenuSheet()),
  );
}

class _MenuSheet extends StatelessWidget {
  const _MenuSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 16), decoration: BoxDecoration(color: const Color(0xFFDEDEDE), borderRadius: BorderRadius.circular(2)))),
          _MenuItem(icon: Icons.person_outline, label: 'Sign In / Sign Up', onTap: () => _toast(context, 'Authentication coming soon')),
          const _MenuDivider(),
          _MenuItem(icon: Icons.insert_drive_file_outlined, label: 'New Project', onTap: () => _newProject(context)),
          _MenuItem(icon: Icons.save_outlined, label: 'Save Project', onTap: () => _saveProject(context)),
          _MenuItem(icon: Icons.folder_open_outlined, label: 'Load Project', onTap: () => _loadProject(context)),
          const _MenuDivider(),
          _MenuItem(icon: Icons.picture_as_pdf_outlined, label: 'Export to PDF', onTap: () => _toast(context, 'Add pdf + printing packages to enable')),
          _MenuItem(icon: Icons.image_outlined, label: 'Export Image', onTap: () => _toast(context, 'Add screenshot package to enable')),
          const _MenuDivider(),
          _MenuItem(icon: Icons.mail_outline, label: 'Contact / Support', onTap: () => _toast(context, 'support@cutoptimizer.app')),
        ]),
      ),
    );
  }

  void _toast(BuildContext context, String msg) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg, style: const TextStyle(fontFamily: 'monospace')), behavior: SnackBarBehavior.floating, backgroundColor: const Color(0xFF111111), duration: const Duration(seconds: 2)));
  }

  void _newProject(BuildContext context) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('New Project', style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w700)),
        content: const Text('Unsaved changes will be lost.', style: TextStyle(fontFamily: 'monospace')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Color(0xFF888888), fontFamily: 'monospace'))),
          TextButton(onPressed: () { Navigator.pop(context); context.read<AppState>().newProject(); }, child: const Text('Start New', style: TextStyle(color: Color(0xFF111111), fontFamily: 'monospace', fontWeight: FontWeight.w700))),
        ],
      ),
    );
  }

  Future<void> _saveProject(BuildContext context) async {
    Navigator.pop(context);
    try {
      final state = context.read<AppState>();
      final json = jsonEncode(state.toProjectJson());
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/cut_project.json');
      await file.writeAsString(json);
      if (context.mounted) _toast(context, 'Saved to ${file.path}');
    } catch (e) {
      if (context.mounted) _toast(context, 'Save failed: $e');
    }
  }

  Future<void> _loadProject(BuildContext context) async {
    Navigator.pop(context);
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['json']);
      if (result != null && result.files.single.path != null) {
        final content = await File(result.files.single.path!).readAsString();
        final json = jsonDecode(content) as Map<String, dynamic>;
        if (context.mounted) {
          context.read<AppState>().loadFromProjectJson(json);
          if (context.mounted) _toast(context, 'Project loaded!');
        }
      }
    } catch (e) {
      if (context.mounted) _toast(context, 'Load failed: $e');
    }
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuItem({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(children: [
          Icon(icon, size: 20, color: const Color(0xFF555555)),
          const SizedBox(width: 14),
          Text(label, style: const TextStyle(fontFamily: 'monospace', fontSize: 13, color: Color(0xFF333333))),
        ]),
      ),
    );
  }
}

class _MenuDivider extends StatelessWidget {
  const _MenuDivider();
  @override
  Widget build(BuildContext context) => const Divider(height: 1, color: Color(0xFFEEEEEE));
}
