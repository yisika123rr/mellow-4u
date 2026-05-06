import 'package:flutter/material.dart';
import 'add_photos_screen.dart';

class MyPhotosScreen extends StatefulWidget {
  const MyPhotosScreen({super.key});

  @override
  State<MyPhotosScreen> createState() => _MyPhotosScreenState();
}

class _MyPhotosScreenState extends State<MyPhotosScreen> {
  final List<String> _samplePhotos = [
    'https://images.pexels.com/photos/1127119/pexels-photo-1127119.jpeg',
    'https://images.pexels.com/photos/414612/pexels-photo-414612.jpeg',
    'https://images.pexels.com/photos/346885/pexels-photo-346885.jpeg',
    'https://images.pexels.com/photos/165505/pexels-photo-165505.jpeg',
    'https://images.pexels.com/photos/147411/italy-mountains-dawn-daybreak-147411.jpeg',
    'https://images.pexels.com/photos/709552/pexels-photo-709552.jpeg',
  ];

  String? _selectedUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Choose Avatar',
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              if (_selectedUrl != null) {
                // trả về dữ liệu chọn ảnh nào cho màn hình edit
                Navigator.pop(context, _selectedUrl);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vui lòng chọn một tấm ảnh')),
                );
              }
            },
            child: const Text(
              'DONE',
              style: TextStyle(color: Color(0xFF00BFA5), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Row 1
            SizedBox(
              height: 110,
              child: Row(
                children: [
                  Expanded(
                    child: _buildAddButton(),
                  ),
                  Expanded(child: _photoTile(_samplePhotos[0])),
                  Expanded(child: _photoTile(_samplePhotos[1])),
                ],
              ),
            ),
            // Row 2
            SizedBox(
              height: 160,
              child: Row(
                children: [
                  Expanded(child: _photoTile(_samplePhotos[2])),
                ],
              ),
            ),
            // Row 3
            SizedBox(
              height: 110,
              child: Row(
                children: [
                  Expanded(child: _photoTile(_samplePhotos[3])),
                  Expanded(child: _photoTile(_samplePhotos[4])),
                  Expanded(child: _photoTile(_samplePhotos[5])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Nút Add Photos
  Widget _buildAddButton() {
    return GestureDetector(
      onTap: () async {
        final List<String>? newPhotos = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddPhotosScreen()),
        );
        if (newPhotos != null && newPhotos.isNotEmpty) {
          setState(() {
            _samplePhotos.insertAll(0, newPhotos);
          });
        }
      },
      child: Container(
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF00BFA5), width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: Color(0xFF00BFA5), size: 28),
            SizedBox(height: 4),
            Text('Add Photos',
                style: TextStyle(
                    color: Color(0xFF00BFA5),
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }


  Widget _photoTile(String url) {
    final isSelected = _selectedUrl == url;
    return GestureDetector(
      onTap: () => setState(() => _selectedUrl = url),
      child: Container(
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
          border: isSelected
              ? Border.all(color: const Color(0xFF00BFA5), width: 3)
              : null,
        ),
        child: isSelected
            ? const Center(
          child: Icon(Icons.check_circle, color: Color(0xFF00BFA5), size: 30),
        )
            : null,
      ),
    );
  }
}