const express = require('express');
const router = express.Router();
const paymentController = require('../controllers/paymentController');

// 1. Lấy TOÀN BỘ lịch sử thanh toán
// Link: http://192.168.2.178:3000/api/payments/history
router.get('/history', paymentController.getPaymentHistory);

// 2. Lấy lịch sử theo User ID
router.get('/history/:userId', paymentController.getPaymentHistory);

// 3. Xử lý thanh toán mới[cite: 16, 21]
router.post('/checkout', paymentController.processPayment);

module.exports = router;