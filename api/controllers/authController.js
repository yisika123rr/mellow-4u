const User = require('../models/User');

exports.changePassword = async (req, res) => {
    const { userId, currentPassword, newPassword } = req.body;

    try {
        const user = await User.findById(userId);
        if (!user) return res.status(404).json({ message: "Người dùng không tồn tại" });

        // Kiểm tra mật khẩu (Nên dùng bcrypt để bảo mật hơn)
        if (user.password !== currentPassword) {
            return res.status(400).json({ message: "Mật khẩu hiện tại không đúng" });
        }

        user.password = newPassword;
        await user.save();

        res.status(200).json({ message: "Đổi mật khẩu thành công!" });
    } catch (err) {
        res.status(500).json({ message: err.message });
    }
};