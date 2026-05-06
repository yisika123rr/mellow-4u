const Trip = require('../models/Trip');

// Lấy danh sách chuyến đi
exports.getAllTrips = async (req, res) => {
    try {
        const trips = await Trip.find().sort({ createdAt: -1 });
        res.status(200).json(trips);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};

// Tạo mới chuyến đi
exports.createTrip = async (req, res) => {
    try {
        const newTrip = new Trip(req.body);
        const savedTrip = await newTrip.save();
        res.status(201).json(savedTrip);
    } catch (err) {
        res.status(400).json({ message: "Lỗi tạo chuyến đi: " + err.message });
    }
};

// Lấy chi tiết theo ID
exports.getTripById = async (req, res) => {
    try {
        const trip = await Trip.findById(req.params.id);
        if (!trip) return res.status(404).json({ message: "Không tìm thấy chuyến đi" });
        res.status(200).json(trip);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};

// Đánh dấu hoàn tất
exports.markFinished = async (req, res) => {
    try {
        const updatedTrip = await Trip.findByIdAndUpdate(
            req.params.id,
            { status: 'finished' },
            { new: true }
        );
        res.status(200).json(updatedTrip);
    } catch (err) {
        res.status(400).json({ message: err.message });
    }
};
// Hàm xóa sạch bảng trips
exports.deleteAllTrips = async (req, res) => {
    try {
        // Lệnh này sẽ xóa toàn bộ document trong collection trips
        await Trip.deleteMany({});
        res.status(200).json({ 
            success: true, 
            message: "Đã xóa toàn bộ chuyến đi thành công!" 
        });
    } catch (error) {
        res.status(500).json({ 
            success: false, 
            message: "Lỗi khi xóa dữ liệu", 
            error: error.message 
        });
    }
};

// Hàm xóa một chuyến đi theo ID
exports.deleteTrip = async (req, res) => {
    try {
        const { id } = req.params; // Lấy ID từ URL
        const deletedTrip = await Trip.findByIdAndDelete(id); // Lệnh xóa của Mongoose

        if (!deletedTrip) {
            return res.status(404).json({ success: false, message: "Không tìm thấy trip để xóa" });
        }

        res.status(200).json({ success: true, message: "Đã xóa trip thành công!" });
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
};