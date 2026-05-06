const Payment = require('../models/Payment');
const Trip = require('../models/Trip');

// 1. Xử lý thanh toán[cite: 16, 21]
exports.processPayment = async (req, res) => {
    try {
        const { 
            userId, 
            tripId, 
            cardHolderName, 
            cardNumber, 
            expiryDate, 
            amount 
        } = req.body;

        // Lưu bản ghi thanh toán vào MongoDB[cite: 16, 21]
        const newPayment = new Payment({
            userId,
            tripId,
            cardHolderName,
            cardNumber,
            expiryDate,
            amount,
            status: 'completed' // Mặc định là thành công[cite: 17, 20]
        });

        const savedPayment = await newPayment.save();

        // Cập nhật trạng thái chuyến đi thành 'paid'[cite: 16, 21]
        await Trip.findByIdAndUpdate(tripId, { status: 'paid' });

        res.status(201).json({
            message: "Thanh toán thành công!",
            payment: savedPayment
        });

    } catch (err) {
        res.status(400).json({ 
            message: "Lỗi thanh toán: " + err.message 
        });
    }
};

// 2. Lấy lịch sử thanh toán (Toàn bộ hoặc theo User)[cite: 16, 21]
exports.getPaymentHistory = async (req, res) => {
    try {
        const { userId } = req.params;
        
        // Nếu URL có userId thì lọc theo user, không thì để trống {} để lấy tất cả[cite: 21]
        const query = userId ? { userId: userId } : {};

        const payments = await Payment.find(query)
            .populate('userId', 'firstName lastName') // Lấy thêm tên user để biết ai trả tiền[cite: 21]
            .populate('tripId') // Lấy chi tiết chuyến đi[cite: 16, 21]
            .sort({ createdAt: -1 }); // Mới nhất lên đầu

        res.status(200).json(payments);
    } catch (err) {
        res.status(500).json({ 
            message: "Lỗi lấy lịch sử: " + err.message 
        });
    }
};