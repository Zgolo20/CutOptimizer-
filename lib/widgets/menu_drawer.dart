import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    final user = FirebaseAuth.instance.currentUser;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 16), decoration: BoxDecoration(color: const Color(0xFFDEDEDE), borderRadius: BorderRadius.circular(2)))),
          user == null
            ? Column(mainAxisSize: MainAxisSize.min, children: [
                _MenuItem(icon: Icons.person_outline, label: 'Sign Up', onTap: () => _showAuthSheet(context, isSignUp: true)),
                _MenuItem(icon: Icons.login, label: 'Sign In', onTap: () => _showAuthSheet(context, isSignUp: false)),
              ])
            : Column(mainAxisSize: MainAxisSize.min, children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(children: [
                    const Icon(Icons.person, size: 20, color: Color(0xFF555555)),
                    const SizedBox(width: 14),
                    Expanded(child: Text(user.email ?? '', style: const TextStyle(fontFamily: 'monospace', fontSize: 13, color: Color(0xFF333333)))),
                  ]),
                ),
                _MenuItem(icon: Icons.logout, label: 'Sign Out', onTap: () => _signOut(context)),
              ]),
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

  void _showAuthSheet(BuildContext context, {required bool isSignUp}) {
    Navigator.pop(context);
    Future.delayed(const Duration(milliseconds: 300), () {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        builder: (_) => _AuthSheet(isSignUp: isSignUp),
      );
    });
  }

  Future<void> _signOut(BuildContext context) async {
    Navigator.pop(context);
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Signed out successfully', style: TextStyle(fontFamily: 'monospace')),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color(0xFF111111),
      ));
    }
  }

  void _toast(BuildContext context, String msg) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: 'monospace')),
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFF111111),
      duration: const Duration(seconds: 2),
    ));
  }

  void _newProject(BuildContext context) {
    Navigator.pop(context);
    Future.delayed(const Duration(milliseconds: 300), () {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('New Project', style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w700)),
          content: const Text('Unsaved changes will be lost.', style: TextStyle(fontFamily: 'monospace')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF888888), fontFamily: 'monospace')),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<AppState>().newProject();
              },
              child: const Text('Start New', style: TextStyle(color: Color(0xFF111111), fontFamily: 'monospace', fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );
    });
  }

  Future<void> _saveProject(BuildContext context) async {
    Navigator.pop(context);
    try {
      final state = context.read<AppState>();
      final json = jsonEncode(state.toProjectJson());
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/cut_project.json');
      await file.writeAsString(json);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Project saved!', style: TextStyle(fontFamily: 'monospace')),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Color(0xFF111111),
        ));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Save failed: $e', style: const TextStyle(fontFamily: 'monospace')),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF111111),
        ));
      }
    }
  }

  Future<void> _loadProject(BuildContext context) async {
    Navigator.pop(context);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (result != null && result.files.single.path != null) {
        final content = await File(result.files.single.path!).readAsString();
        final json = jsonDecode(content) as Map<String, dynamic>;
        if (context.mounted) {
          context.read<AppState>().loadFromProjectJson(json);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Project loaded!', style: TextStyle(fontFamily: 'monospace')),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Color(0xFF111111),
          ));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Load failed: $e', style: const TextStyle(fontFamily: 'monospace')),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF111111),
        ));
      }
    }
  }
}

class _AuthSheet extends StatefulWidget {
  final bool isSignUp;
  const _AuthSheet({required this.isSignUp});

  @override
  State<_AuthSheet> createState() => _AuthSheetState();
}

class _AuthSheetState extends State<_AuthSheet> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() { _emailCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    setState(() { _loading = true; _error = null; });
    try {
      if (widget.isSignUp) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text.trim(),
        );
      } else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text.trim(),
        );
      }
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(widget.isSignUp ? 'Account created!' : 'Welcome back!',
              style: const TextStyle(fontFamily: 'monospace')),
          backgroundColor: const Color(0xFF111111),
          behavior: SnackBarBehavior.floating,
        ));
      }
    } on FirebaseAuthException catch (e) {
      setState(() { _error = e.message; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 40),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: const Color(0xFFDEDEDE), borderRadius: BorderRadius.circular(2)))),
        Text(widget.isSignUp ? 'Create Account' : 'Sign In',
            style: const TextStyle(fontFamily: 'monospace', fontSize: 17, fontWeight: FontWeight.w700)),
        const SizedBox(height: 20),
        TextField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
          decoration: InputDecoration(
            labelText: 'Email',
            labelStyle: const TextStyle(fontFamily: 'monospace', color: Color(0xFF888888)),
            filled: true, fillColor: const Color(0xFFF0F0F0),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFDEDEDE))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFDEDEDE))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF111111), width: 1.5)),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _passCtrl,
          obscureText: true,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
          decoration: InputDecoration(
            labelText: 'Password',
            labelStyle: const TextStyle(fontFamily: 'monospace', color: Color(0xFF888888)),
            filled: true, fillColor: const Color(0xFFF0F0F0),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFDEDEDE))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFDEDEDE))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF111111), width: 1.5)),
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 10),
          Text(_error!, style: const TextStyle(color: Color(0xFFE03535), fontFamily: 'monospace', fontSize: 12)),
        ],
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _loading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF111111),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
          child: _loading
            ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text(widget.isSignUp ? 'Create Account' : 'Sign In',
                style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w700)),
        ),
      ]),
    );
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
