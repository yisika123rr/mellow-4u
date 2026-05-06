const express = require('express');
const router = express.Router();
const tripController = require('../controllers/tripController');

// Del tất cả
router.delete('/delete-all', tripController.deleteAllTrips);

// Del 1 chuyến đi
router.delete('/:id', tripController.deleteTrip);

// Lấy tất cả chuyến đi
router.get('/', tripController.getAllTrips);

// Tạo chuyến đi mới 
router.post('/', tripController.createTrip);

// Lấy chi tiết 1 chuyến đi 
router.get('/:id', tripController.getTripById);

// Đánh dấu hoàn thành 
router.patch('/:id/finish', tripController.markFinished);

module.exports = router;