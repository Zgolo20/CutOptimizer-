import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../state/app_state.dart';

void showMenuDrawer(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (ctx) => ChangeNotifierProvider.value(
        value: context.read<AppState>(), child: const _MenuSheet()),
  );
}

class _MenuSheet extends StatelessWidget {
  const _MenuSheet();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Center(child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                    color: const Color(0xFFDEDEDE),
                    borderRadius: BorderRadius.circular(2)),
              )),
              if (user == null) ...[
                _MenuItem(icon: Icons.person_outline, label: 'Sign Up',
                    onTap: () => _showAuth(context, isSignUp: true)),
                _MenuItem(icon: Icons.login, label: 'Sign In',
                    onTap: () => _showAuth(context, isSignUp: false)),
              ] else ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(children: [
                    const Icon(Icons.person, size: 20, color: Color(0xFF555555)),
                    const SizedBox(width: 14),
                    Expanded(child: Text(user.email ?? '',
                        style: const TextStyle(fontFamily: 'monospace',
                            fontSize: 13, color: Color(0xFF333333)))),
                  ]),
                ),
                _MenuItem(icon: Icons.logout, label: 'Sign Out',
                    onTap: () async {
                      Navigator.pop(context);
                      await FirebaseAuth.instance.signOut();
                    }),
              ],
              const _MenuDivider(),
              _MenuItem(icon: Icons.insert_drive_file_outlined,
                  label: 'New Project', onTap: () => _newProject(context)),
              _MenuItem(icon: Icons.save_outlined, label: 'Save Project',
                  onTap: () => _saveProject(context)),
              _MenuItem(icon: Icons.folder_open_outlined, label: 'Load Project',
                  onTap: () => _toast(context, 'Load project coming soon')),
              const _MenuDivider(),
              _MenuItem(icon: Icons.picture_as_pdf_outlined, label: 'Export to PDF',
                  onTap: () => _toast(context, 'PDF export coming soon')),
              _MenuItem(icon: Icons.image_outlined, label: 'Export Image',
                  onTap: () => _toast(context, 'Image export coming soon')),
              const _MenuDivider(),
              _MenuItem(icon: Icons.mail_outline, label: 'Contact / Support',
                  onTap: () => _toast(context, 'support@cutoptimizer.app')),
            ]),
          ),
        );
      },
    );
  }

  void _showAuth(BuildContext context, {required bool isSignUp}) {
    Navigator.pop(context);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (context.mounted) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
          builder: (_) => _AuthSheet(isSignUp: isSignUp),
        );
      }
    });
  }

  void _newProject(BuildContext context) {
    Navigator.pop(context);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('New Project',
                style: TextStyle(
                    fontFamily: 'monospace', fontWeight: FontWeight.w700)),
            content: const Text('Unsaved changes will be lost.',
                style: TextStyle(fontFamily: 'monospace')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel',
                    style: TextStyle(
                        color: Color(0xFF888888), fontFamily: 'monospace')),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.read<AppState>().newProject();
                },
                child: const Text('Start New',
                    style: TextStyle(
                        color: Color(0xFF111111),
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        );
      }
    });
  }

  void _saveProject(BuildContext context) {
    Navigator.pop(context);
    final state = context.read<AppState>();
    final json = jsonEncode(state.toProjectJson());
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Project data ready (${json.length} bytes)',
          style: const TextStyle(fontFamily: 'monospace')),
      backgroundColor: const Color(0xFF111111),
      behavior: SnackBarBehavior.floating,
    ));
  }

  void _toast(BuildContext context, String msg) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: 'monospace')),
      backgroundColor: const Color(0xFF111111),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    ));
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
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text.trim();
    if (email.isEmpty || pass.isEmpty) {
      setState(() => _error = 'Please enter email and password');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      if (widget.isSignUp) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email, password: pass);
      } else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email, password: pass);
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
      setState(() { _error = e.message ?? 'Authentication failed'; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 40),
      child: Column(mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Center(child: Container(
          width: 40, height: 4,
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
              color: const Color(0xFFDEDEDE),
              borderRadius: BorderRadius.circular(2)),
        )),
        Text(widget.isSignUp ? 'Create Account' : 'Sign In',
            style: const TextStyle(
                fontFamily: 'monospace', fontSize: 17,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 20),
        TextField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          autofocus: true,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
          decoration: _inputDecor('Email'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _passCtrl,
          obscureText: true,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
          onSubmitted: (_) => _submit(),
          decoration: _inputDecor('Password'),
        ),
        if (_error != null) ...[
          const SizedBox(height: 10),
          Text(_error!, style: const TextStyle(
              color: Color(0xFFE03535),
              fontFamily: 'monospace', fontSize: 12)),
        ],
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _loading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF111111),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
          child: _loading
            ? const SizedBox(height: 18, width: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text(widget.isSignUp ? 'Create Account' : 'Sign In',
                style: const TextStyle(
                    fontFamily: 'monospace', fontWeight: FontWeight.w700)),
        ),
      ]),
    );
  }

  InputDecoration _inputDecor(String label) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(fontFamily: 'monospace', color: Color(0xFF888888)),
    filled: true, fillColor: const Color(0xFFF0F0F0),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFDEDEDE))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFDEDEDE))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF111111), width: 1.5)),
  );
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuItem({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          alignment: Alignment.centerLeft,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Row(children: [
          Icon(icon, size: 20, color: const Color(0xFF555555)),
          const SizedBox(width: 14),
          Text(label, style: const TextStyle(
              fontFamily: 'monospace', fontSize: 13,
              color: Color(0xFF333333))),
        ]),
      ),
    );
  }
}

class _MenuDivider extends StatelessWidget {
  const _MenuDivider();
  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, color: Color(0xFFEEEEEE));
}
