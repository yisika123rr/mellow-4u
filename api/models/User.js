const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  firstName: { type: String, required: true },
  lastName: { type: String, required: true },
  
  // Mật khẩu người dùng
  password: { type: String, required: true },
  
  // Ảnh đại diện
  avatarUrl: { type: String },
  
  // Album ảnh cá nhân
  photos: [{ type: String }],
  
  // Trạng thái thông báo
  notificationsEnabled: { type: Boolean, default: true }
}, { 
  // Thời gian tạo/cập nhật
  timestamps: true 
});

module.exports = mongoose.model('User', userSchema);