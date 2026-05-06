const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
require('dotenv').config();
const tripRoutes = require('./routes/tripRoutes');
const app = express();

// 1. Cấu hình Middleware
app.use(cors()); // Cho phép Flutter gọi API
app.use(express.json()); // Để đọc dữ liệu JSON từ Flutter 

// 2. Kết nối Database 
mongoose.connect(process.env.MONGO_URI)
    .then(() => console.log(" MongoDB Atlas đã sẵn sàng!"))
    .catch(err => console.error("Lỗi kết nối DB:", err));

// 3. Khai báo các Route 
app.use('/api/trips', tripRoutes);

app.use('/api/auth', require('./routes/authRoutes'));       // Cho ChangePasswordScreen
app.use('/api/users', require('./routes/userRoutes'));     // Cho Profile & Photos
app.use('/api/trips', require('./routes/tripRoutes'));     // Cho CreateTrip & Detail
app.use('/api/payments', require('./routes/paymentRoutes')); // Cho Payment Checkout

// 4. Route kiểm tra nhanh
app.get('/', (req, res) => {
    res.send('Mellow API Server is running...');
});

// 5. Khởi chạy Server 
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(` Server đang chạy tại: http://localhost:${PORT}`);
});