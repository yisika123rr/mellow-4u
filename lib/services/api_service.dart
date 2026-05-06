import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart'; // Thêm để dùng debugPrint

class ApiService {
  // IP của máy ThinkBook chạy Backend
  static const String baseUrl = 'http://127.0.0.1:3000/api';

  // --- 1. TRIPS ---

  // Lấy toàn bộ danh sách chuyến đi
  static Future<List<dynamic>> getAllTrips() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/trips'));
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      debugPrint("Lỗi getAllTrips: $e");
    }
    return [];
  }

  // Tạo chuyến đi mới
  static Future<Map<String, dynamic>?> createTrip(Map<String, dynamic> data) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/trips'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      if (res.statusCode == 201) return jsonDecode(res.body);
    } catch (e) {
      debugPrint("Lỗi createTrip: $e");
    }
    return null;
  }

  // Lấy chi tiết một chuyến đi cụ thể
  static Future<Map<String, dynamic>?> getTripById(String id) async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/trips/$id'));
      if (res.statusCode == 200) return jsonDecode(res.body);
    } catch (e) {
      debugPrint("Lỗi getTripById: $e");
    }
    return null;
  }

  // Hoàn thành chuyến đi (Mark Finished)
  static Future<bool> finishTrip(String id) async {
    try {
      final res = await http.patch(Uri.parse('$baseUrl/trips/$id/finish'));
      return res.statusCode == 200;
    } catch (e) {
      debugPrint("Lỗi finishTrip: $e");
      return false;
    }
  }

  // Delete id
  static Future<bool> deleteTrip(String id) async {
    try {
      final res = await http.delete(Uri.parse('$baseUrl/trips/$id'));
      return res.statusCode == 200;
    } catch (e) {
      debugPrint("Lỗi deleteTrip: $e");
      return false;
    }
  }

  // --- 2. USERS ---

  // Hàm xử lý bóc tách mảng phẳng để dùng cho Settings và Edit Profile
  static Future<List<dynamic>> getUsersList() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/users/profile'));
      if (res.statusCode == 200) {
        // Ép kiểu dynamic để gọi được containsKey trên Map
        final dynamic data = jsonDecode(res.body);

        // Kiểm tra nếu là Map chứa key 'users' thì bóc tách mảng[cite: 9]
        if (data is Map<String, dynamic> && data.containsKey('users')) {
          return data['users'] as List<dynamic>;
        } else if (data is List) {
          return data;
        }
      }
    } catch (e) {
      debugPrint("Lỗi getUsersList: $e");
    }
    return [];
  }

  static Future<List<dynamic>> getAllUsers() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/users/profile'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['users'] ?? [];
      }
    } catch (e) {
      debugPrint("Lỗi getAllUsers: $e");
    }
    return [];
  }

  // Tạo User mới
  static Future<Map<String, dynamic>?> createUser(Map<String, dynamic> data) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/users/profile'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      if (res.statusCode == 201) return jsonDecode(res.body);
    } catch (e) {
      debugPrint("Lỗi createUser: $e");
    }
    return null;
  }

  // Cập nhật Profile
  static Future<bool> updateProfile(String id, Map<String, dynamic> data) async {
    try {
      final res = await http.put(
        Uri.parse('$baseUrl/users/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      return res.statusCode == 200;
    } catch (e) {
      debugPrint("Lỗi updateProfile: $e");
      return false;
    }
  }

  // Đổi mật khẩu
  static Future<bool> changePassword(String id, String oldP, String newP) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/users/$id/change-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'oldPassword': oldP, 'newPassword': newP}),
      );
      return res.statusCode == 200;
    } catch (e) {
      debugPrint("Lỗi changePassword: $e");
      return false;
    }
  }

  // --- 3. PHOTOS ---

  static Future<List<String>> getMyPhotos() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/photos'));
      if (res.statusCode == 200) {
        List data = jsonDecode(res.body);
        return data.map((e) => e['url'].toString()).toList();
      }
    } catch (e) {
      debugPrint("Lỗi getMyPhotos: $e");
    }
    return [];
  }

  static Future<bool> saveSelectedPhotos(List<String> urls) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/photos'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'urls': urls}),
      );
      return res.statusCode == 201;
    } catch (e) {
      debugPrint("Lỗi saveSelectedPhotos: $e");
      return false;
    }
  }

  // --- 4. PAYMENTS ---

  static Future<bool> processPayment(Map<String, dynamic> data) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/payments/checkout'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      return res.statusCode == 201;
    } catch (e) {
      debugPrint("Lỗi processPayment: $e");
      return false;
    }
  }
}