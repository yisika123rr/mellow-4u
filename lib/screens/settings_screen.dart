import 'package:flutter/material.dart';
import 'edit_profile_screen.dart';
import '../services/api_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;

  // Các biến trạng thái để hiển thị
  String fullName = "LOADING...";
  String avatarUrl = 'https://images.pexels.com/photos/414612/pexels-photo-414612.jpeg'; // Ảnh mặc định
  String userRole = "Traveler";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Hàm lấy thông tin User từ server
  Future<void> _fetchUserData() async {
    try {
      // Lấy danh sách user đã được xử lý mảng từ ApiService
      final List<dynamic> users = await ApiService.getUsersList();

      if (users.isNotEmpty) {
        setState(() {
          final Map<String, dynamic> latestUser = users.first;

          // Xử lý và làm sạch dữ liệu tên
          String fName = (latestUser['firstName'] ?? '').toString().trim();
          String lName = (latestUser['lastName'] ?? '').toString().trim();

          // Cập nhật Avatar động từ Database
          if (latestUser['avatarUrl'] != null && latestUser['avatarUrl'].toString().isNotEmpty) {
            avatarUrl = latestUser['avatarUrl'];
          }

          String combined = "$fName $lName".trim();
          fullName = combined.isNotEmpty ? combined : "TRAVELER";
          isLoading = false;
        });
      } else {
        setState(() {
          fullName = "GUEST USER";
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Lỗi load dữ liệu Settings: $e");
      setState(() {
        fullName = "TRAVELER";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Settings',
            style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          // Hiển thị thông tin động
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF00BFA5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                // Ảnh đại diện
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(avatarUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hiển thị tên user
                      Text(
                        fullName.toUpperCase(),
                        style: const TextStyle(
                            color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(userRole, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                    ],
                  ),
                ),
                // Nút chuyển sang màn hình chỉnh sửa
                GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                        context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
                    // Refresh lại toàn bộ dữ liệu khi quay lại
                    _fetchUserData();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
                    ),
                    child: const Text('EDIT PROFILE',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSettingItem(icon: Icons.notifications_outlined, title: 'Notifications', hasSwitch: true),
          _buildSettingItem(icon: Icons.language, title: 'Languages', hasArrow: true),
          _buildSettingItem(icon: Icons.payment, title: 'Payment', hasArrow: true),
          _buildSettingItem(icon: Icons.shield_outlined, title: 'Privacy & Policies', hasArrow: true),
          const Spacer(),
          TextButton(
            onPressed: () {
              // ko viết hàm tại đây vì ko có màn hình đăng nhập đăng ký
            },
            child: const Text('Sign out', style: TextStyle(color: Colors.grey, fontSize: 16)),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // Widget
  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    bool hasSwitch = false,
    bool hasArrow = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Icon(icon, color: Colors.black87, size: 24),
          const SizedBox(width: 16),
          Expanded(
              child: Text(title, style: const TextStyle(color: Colors.black87, fontSize: 16))),
          if (hasSwitch)
            Switch(
              value: notificationsEnabled,
              onChanged: (value) => setState(() => notificationsEnabled = value),
              activeThumbColor: const Color(0xFF00BFA5),
            ),
          if (hasArrow) const Icon(Icons.chevron_right, color: Colors.grey, size: 24),
        ],
      ),
    );
  }
}