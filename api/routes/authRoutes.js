const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');

// Đổi mật khẩu 
router.post('/change-password', authController.changePassword);

module.exports = router;