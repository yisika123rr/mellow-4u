import 'package:flutter/material.dart';

class AddPhotosScreen extends StatefulWidget {
  const AddPhotosScreen({super.key});

  @override
  State<AddPhotosScreen> createState() => _AddPhotosScreenState();
}

class _AddPhotosScreenState extends State<AddPhotosScreen> {
  final List<String> _galleryPhotos = [
    'https://images.pexels.com/photos/1127119/pexels-photo-1127119.jpeg',
    'https://images.pexels.com/photos/674010/pexels-photo-674010.jpeg',
    'https://images.pexels.com/photos/3155666/pexels-photo-3155666.jpeg',
    'https://images.pexels.com/photos/2161467/pexels-photo-2161467.jpeg',
    'https://images.pexels.com/photos/164175/pexels-photo-164175.jpeg',
    'https://images.pexels.com/photos/3408354/pexels-photo-3408354.jpeg',
    'https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg',
    'https://images.pexels.com/photos/338515/pexels-photo-338515.jpeg',
  ];

  final Set<int> _selectedIndices = {};

  void _toggleSelection(int index) {
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else {
        _selectedIndices.add(index);
      }
    });
  }

  void _onDone() {
    if (_selectedIndices.isEmpty) {
      Navigator.pop(context);
      return;
    }
    final selected = _selectedIndices.map((i) => _galleryPhotos[i]).toList();
    Navigator.pop(context, selected);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Add Photos',
            style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _onDone,
            child: Text('DONE',
                style: TextStyle(
                    color: _selectedIndices.isNotEmpty
                        ? const Color(0xFF00BFA5)
                        : Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(3),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 3,
            mainAxisSpacing: 3,
          ),
          itemCount: _galleryPhotos.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) return _buildTakePhotoCell();
            final photoIndex = index - 1;
            return _buildPhotoCell(photoIndex, _selectedIndices.contains(photoIndex));
          },
        ),
      ),
    );
  }

  Widget _buildTakePhotoCell() {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Opening camera...'), duration: Duration(seconds: 1)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF00BFA5), width: 1.5),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt_outlined, color: Color(0xFF00BFA5), size: 32),
            SizedBox(height: 6),
            Text('Take Photo',
                style: TextStyle(
                    color: Color(0xFF00BFA5), fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoCell(int photoIndex, bool isSelected) {
    return GestureDetector(
      onTap: () => _toggleSelection(photoIndex),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.network(
              _galleryPhotos[photoIndex],
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: Colors.grey[200],
                  child: const Center(
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Color(0xFF00BFA5))),
                );
              },
            ),
          ),
          if (isSelected)
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Container(color: Colors.black.withOpacity(0.25)),
            ),
          Positioned(
            top: 6,
            right: 6,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? const Color(0xFF00BFA5) : Colors.transparent,
                border: Border.all(
                    color: isSelected ? const Color(0xFF00BFA5) : Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 1))
                ],
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
