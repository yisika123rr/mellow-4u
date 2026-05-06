const mongoose = require('mongoose');

const tripSchema = new mongoose.Schema({
  // Địa điểm du lịch (ví dụ: "Danang, Vietnam")
  location: { 
    type: String, 
    required: true 
  },
  // Ngày thực hiện chuyến đi
  date: { 
    type: String, 
    required: true 
  },
  // Thời gian bắt đầu và kết thúc
  timeFrom: { type: String },
  timeTo: { type: String },
  // Số lượng khách tham gia
  travelers: { 
    type: Number, 
    default: 1 
  },
  // Chi phí dịch vụ
  fee: { 
    type: Number, 
    required: true 
  },
  // Danh sách các điểm tham quan cụ thể
  attractions: [{ 
    type: String 
  }],
  // Tên hướng dẫn viên phụ trách
  guideName: { 
    type: String, 
    default: "Emmy" 
  },
  // Trạng thái: Chờ xử lý hoặc Đã hoàn thành
  status: { 
    type: String, 
    enum: ['pending', 'finished'], 
    default: 'pending' 
  }
}, { 
  // Tự động tạo trường createdAt và updatedAt
  timestamps: true 
});

module.exports = mongoose.model('Trip', tripSchema);