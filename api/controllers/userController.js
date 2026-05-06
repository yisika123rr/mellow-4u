const User = require('../models/User');

// 1. Cập nhật thông tin Profile (Đã thêm xử lý avatarUrl)
exports.updateProfile = async (req, res) => {
    try {
        const userId = req.params.id;
        
        // Bóc tách dữ liệu từ body gửi lên, bao gồm cả ảnh đại diện[cite: 6]
        const updateData = {
            firstName: req.body.firstName ? req.body.firstName.trim() : "",
            lastName: req.body.lastName ? req.body.lastName.trim() : "",
            avatarUrl: req.body.avatarUrl || "" // Lưu URL ảnh mới chọn[cite: 6]
        };

        const updatedUser = await User.findByIdAndUpdate(
            userId,
            updateData,
            { new: true, runValidators: true } 
        );

        if (!updatedUser) {
            return res.status(404).json({ message: "Không tìm thấy người dùng này" });
        }
        res.status(200).json(updatedUser);
    } catch (err) {
        res.status(400).json({ message: err.message });
    }
};

// 2. Lấy danh sách Profile (Sắp xếp mới nhất lên đầu cho Flutter)[cite: 6]
exports.getProfile = async (req, res) => {
    try {
        const userId = req.query.userId || (req.body ? req.body.userId : null);

        if (!userId) {
            // Lấy toàn bộ danh sách để App dễ dàng bốc user đầu tiên[cite: 6]
            const allUsers = await User.find().sort({ createdAt: -1 });
            return res.status(200).json({
                message: "Success",
                users: allUsers 
            });
        }

        const user = await User.findById(userId);
        if (!user) return res.status(404).json({ message: "Không tìm thấy user" });
        res.status(200).json(user);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};

// 3. Thêm ảnh vào bộ sưu tập cá nhân[cite: 6]
exports.addPhotos = async (req, res) => {
    try {
        const userId = req.body.userId || req.params.id;
        const user = await User.findById(userId);
        if (!user) return res.status(404).json({ message: "User không tồn tại" });

        if (req.body.photos && Array.isArray(req.body.photos)) {
            user.photos.push(...req.body.photos);
            await user.save();
        }
        res.status(200).json(user.photos);
    } catch (err) {
        res.status(400).json({ message: err.message });
    }
};

// 4. Lấy danh sách album ảnh[cite: 6]
exports.getPhotos = async (req, res) => {
    try {
        const userId = req.params.id || req.query.userId;
        const user = await User.findById(userId);
        if (!user) return res.status(404).json({ message: "User không tồn tại" });
        res.status(200).json(user.photos);
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};

// 5. Tạo User mới (Gán giá trị mặc định tránh lỗi null)[cite: 6]
exports.createUser = async (req, res) => {
    try {
        const newUser = new User({
            firstName: req.body.firstName || "New",
            lastName: req.body.lastName || "User",
            avatarUrl: req.body.avatarUrl || "", 
            password: req.body.password || '123456'
        });
        await newUser.save();
        res.status(201).json(newUser);
    } catch (err) {
        res.status(400).json({ message: err.message });
    }
};
// 6. đổi mật khẩu
exports.changePassword = async (req, res) => {
    try {
        const userId = req.params.id;
        const { oldPassword, newPassword } = req.body;

        const user = await User.findById(userId);
        if (!user) {
            return res.status(404).json({ message: "Không tìm thấy người dùng" });
        }

        // Kiểm tra mật khẩu cũ (So sánh trực tiếp vì bạn đang lưu text thuần)
        if (user.password !== oldPassword) {
            return res.status(400).json({ message: "Mật khẩu hiện tại không chính xác" });
        }

        // Cập nhật mật khẩu mới
        user.password = newPassword;
        await user.save();

        res.status(200).json({ message: "Đổi mật khẩu thành công" });
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};