const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');

router.post('/profile', userController.createUser);

// Lấy thông tin cá nhân và cài đặt 
router.get('/profile', userController.getProfile);

// Cập nhật Profile 
router.put('/profile', userController.updateProfile);
router.put('/:id', userController.updateProfile);
router.post('/:id/change-password', userController.changePassword);

// Quản lý ảnh 
router.get('/photos', userController.getPhotos);
router.post('/photos', userController.addPhotos);

module.exports = router;