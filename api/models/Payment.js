const mongoose = require('mongoose');

const paymentSchema = new mongoose.Schema({
  // Liên kết người dùng và chuyến đi
  userId: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'User', 
    required: true 
  },
  tripId: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'Trip', 
    required: true 
  },
  // Thông tin thẻ thanh toán
  cardHolderName: { 
    type: String, 
    required: true 
  },
  cardNumber: { 
    type: String, 
    required: true 
  },
  expiryDate: { 
    type: String, 
    required: true 
  },
  // Số tiền và trạng thái
  amount: { 
    type: Number, 
    required: true 
  },
  status: { 
    type: String, 
    enum: ['pending', 'completed', 'failed'], 
    default: 'completed' 
  }
}, { 
  // Thời gian giao dịch
  timestamps: true 
});

module.exports = mongoose.model('Payment', paymentSchema);