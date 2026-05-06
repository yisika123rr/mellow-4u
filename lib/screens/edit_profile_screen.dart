import 'package:flutter/material.dart';
import 'change_password_screen.dart';
import 'my_photos_screen.dart';
import '../services/api_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  String? currentUserId;
  String avatarUrl = 'https://images.pexels.com/photos/1127119/pexels-photo-1127119.jpeg';

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _passwordController = TextEditingController(text: 'Đã vô hiệu hóa việc thay đổi password tại đây');
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fetchLatestUser();
  }

  Future<void> _fetchLatestUser() async {
    try {
      final List<dynamic> users = await ApiService.getUsersList();
      if (users.isNotEmpty) {
        setState(() {
          final latestUser = users.first;
          currentUserId = latestUser['id']?.toString() ?? latestUser['_id']?.toString();
          _firstNameController.text = latestUser['firstName'] ?? '';
          _lastNameController.text = latestUser['lastName'] ?? '';

          if (latestUser['avatarUrl'] != null && latestUser['avatarUrl'].toString().isNotEmpty) {
            avatarUrl = latestUser['avatarUrl'];
          }
        });
      }
    } catch (e) {
      debugPrint("Lỗi đồng bộ ID người dùng: $e");
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSave() async {
    if (_firstNameController.text.isEmpty || _lastNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ họ và tên')),
      );
      return;
    }

    setState(() => _isSaving = true);

    // Loại bỏ password để tránh ghi đè màn hình change password
    final userData = {
      'firstName': _firstNameController.text,
      'lastName': _lastNameController.text,
      'avatarUrl': avatarUrl,
    };

    bool success = false;
    if (currentUserId != null) {
      // Cập nhật Profile
      success = await ApiService.updateProfile(currentUserId!, userData);
    } else {
      // Nếu là tạo mới hoàn toàn thì password mặc định 123456
      userData['password'] = '123456';
      final response = await ApiService.createUser(userData);
      success = response != null;
    }

    setState(() => _isSaving = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã cập nhật thông tin thành công!'), backgroundColor: Color(0xFF00BFA5)),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lỗi kết nối Server!'), backgroundColor: Colors.red),
        );
      }
    }
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
        title: Text(
          currentUserId == null ? 'Create Profile' : 'Edit Profile',
          style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
        actions: [
          _isSaving
              ? const Padding(
            padding: EdgeInsets.all(16),
            child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF00BFA5))),
          )
              : TextButton(
            onPressed: _onSave,
            child: const Text('SAVE', style: TextStyle(color: Color(0xFF00BFA5), fontSize: 14, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildAvatar(),
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(child: _buildField('First Name', _firstNameController)),
                const SizedBox(width: 16),
                Expanded(child: _buildField('Last Name', _lastNameController)),
              ],
            ),
            const SizedBox(height: 32),
            // Password Field block để ko cho nhập
            _buildField('Password', _passwordController, readOnly: true),
            const SizedBox(height: 16),
            if (currentUserId != null)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen())),
                  child: const Text('Change Password', style: TextStyle(color: Color(0xFF00BFA5))),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() => Stack(
    children: [
      CircleAvatar(
        radius: 60,
        backgroundImage: NetworkImage(avatarUrl),
      ),
      Positioned(
        bottom: 0,
        right: 0,
        child: GestureDetector(
          onTap: () async {
            final String? pickedUrl = await Navigator.push(
                context, MaterialPageRoute(builder: (_) => const MyPhotosScreen())
            );
            if (pickedUrl != null) {
              setState(() => avatarUrl = pickedUrl);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(color: Color(0xFF00BFA5), shape: BoxShape.circle),
            child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
          ),
        ),
      ),
    ],
  );

  // Thêm thuộc tính readOnly để block ô password
  Widget _buildField(String label, TextEditingController ctrl, {bool readOnly = false}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: Colors.black54, fontSize: 14)),
      TextField(
        controller: ctrl,
        readOnly: readOnly,
        style: TextStyle(color: readOnly ? Colors.grey : Colors.black),
        decoration: const InputDecoration(
          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF00BFA5))),
        ),
      ),
    ],
  );
}