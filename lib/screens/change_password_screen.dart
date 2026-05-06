import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _retypePasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureRetype = true;
  bool _isSaving = false;
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    _getUserId();
  }

  // Lấy ID của user mới nhất để thực hiện đổi mật khẩu
  Future<void> _getUserId() async {
    try {
      final List<dynamic> users = await ApiService.getUsersList();
      if (users.isNotEmpty) {
        setState(() {
          // Ưu tiên lấy '_id' từ MongoDB[cite: 9]
          currentUserId = users.first['_id']?.toString() ?? users.first['id']?.toString();
        });
      }
    } catch (e) {
      debugPrint("Lỗi lấy ID: $e");
    }
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _retypePasswordController.dispose();
    super.dispose();
  }

  void _onSave() async {
    // 1. Kiểm tra các trường trống
    if (_currentPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty ||
        _retypePasswordController.text.isEmpty) {
      _showSnackBar('Vui lòng nhập đầy đủ các trường', Colors.red);
      return;
    }

    // 2. Kiểm tra mật khẩu mới khớp nhau
    if (_newPasswordController.text != _retypePasswordController.text) {
      _showSnackBar('Mật khẩu mới không khớp', Colors.red);
      return;
    }

    if (currentUserId == null) {
      _showSnackBar('Không tìm thấy ID người dùng. Thử lại sau!', Colors.red);
      return;
    }

    setState(() => _isSaving = true);

    try {
      // 3. Gọi API đổi mật khẩu
      bool success = await ApiService.changePassword(
        currentUserId!,
        _currentPasswordController.text,
        _newPasswordController.text,
      );

      setState(() => _isSaving = false);

      if (mounted) {
        if (success) {
          _showSnackBar('Đổi mật khẩu thành công!', const Color(0xFF00BFA5));
          Navigator.pop(context); // Quay về màn hình trước
        } else {
          _showSnackBar('Mật khẩu hiện tại không đúng hoặc lỗi Server', Colors.red);
        }
      }
    } catch (e) {
      setState(() => _isSaving = false);
      debugPrint("Lỗi ChangePass: $e");
      _showSnackBar('Lỗi kết nối Server!', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Change Password',
            style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500)),
        centerTitle: true,
        actions: [
          _isSaving
              ? const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF00BFA5))),
            ),
          )
              : TextButton(
            onPressed: _onSave,
            child: const Text('SAVE',
                style: TextStyle(
                    color: Color(0xFF00BFA5), fontSize: 14, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildPasswordField(
              label: 'Current Password',
              controller: _currentPasswordController,
              obscure: _obscureCurrent,
              onToggle: () => setState(() => _obscureCurrent = !_obscureCurrent),
            ),
            const SizedBox(height: 32),
            _buildPasswordField(
              label: 'New Password',
              controller: _newPasswordController,
              obscure: _obscureNew,
              onToggle: () => setState(() => _obscureNew = !_obscureNew),
            ),
            const SizedBox(height: 32),
            _buildPasswordField(
              label: 'Retype New Password',
              controller: _retypePasswordController,
              obscure: _obscureRetype,
              onToggle: () => setState(() => _obscureRetype = !_obscureRetype),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            border: const UnderlineInputBorder(),
            enabledBorder:
            const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
            focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF00BFA5))),
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            suffixIcon: IconButton(
              icon: Icon(obscure ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey, size: 20),
              onPressed: onToggle,
            ),
          ),
        ),
      ],
    );
  }
}