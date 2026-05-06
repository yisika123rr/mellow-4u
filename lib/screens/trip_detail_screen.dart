import 'package:flutter/material.dart';
import 'next_trip_screen.dart';
import '../services/api_service.dart';

class TripDetailPage extends StatefulWidget {
  final String? tripId;
  const TripDetailPage({super.key, this.tripId});

  @override
  State<TripDetailPage> createState() => _TripDetailPageState();
}

class _TripDetailPageState extends State<TripDetailPage> {
  late Future<Map<String, dynamic>?> _tripFuture;

  @override
  void initState() {
    super.initState();
    // Dữ liệu chi tiết được truyền từ create trip để tránh mất thời gian lấy dữ liệu từ api
    _tripFuture = widget.tripId != null
        ? ApiService.getTripById(widget.tripId!)
        : Future.value(null);
  }

  // Nếu quay lại tạo trip mới thì xóa để tiết kiệm dữ liệu database
  void _handleBackAndDelete() async {
    if (widget.tripId != null) {
      await ApiService.deleteTrip(widget.tripId!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đã hủy chuyến đi vừa tạo"), backgroundColor: Colors.orange),
        );
      }
    }
    if (mounted) {
      Navigator.pop(context); // Quay lại create
    }
  }

  void _handleFinish() async {
    if (widget.tripId == null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const NextTripPage()));
      return;
    }

    // Đánh dấu hoàn thành chuyến đi trên server
    bool success = await ApiService.finishTrip(widget.tripId!);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Hoàn thành!"), backgroundColor: Colors.teal));
      // Chuyển sang màn hình Next Trip
      Navigator.push(context, MaterialPageRoute(builder: (_) => const NextTripPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>?>(
          future: _tripFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.teal));
            }

            final data = snapshot.data;
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 16),
                  Expanded(child: SingleChildScrollView(child: _buildCard(context, data))),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) => Row(
    children: [
      // Thực hiện xóa ID và quay lại create
      IconButton(icon: const Icon(Icons.close), onPressed: _handleBackAndDelete),
      const Spacer(),
      const Text('Trip Detail', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const Spacer(),
      const SizedBox(width: 48),
    ],
  );

  Widget _buildCard(BuildContext context, Map<String, dynamic>? data) => Container(
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildImageSection(data?['location'] ?? 'Danang, Vietnam'),
        _buildDetailSection(data),
      ],
    ),
  );

  Widget _buildImageSection(String loc) => Stack(
    children: [
      ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Image.network('https://images.pexels.com/photos/1127119/pexels-photo-1127119.jpeg',
            height: 160, width: double.infinity, fit: BoxFit.cover),
      ),
      Positioned(
        bottom: 16, left: 16,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          color: Colors.black54,
          child: Row(children: [
            const Icon(Icons.location_on, color: Colors.white, size: 16),
            const SizedBox(width: 4),
            Text(loc, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ]),
        ),
      ),
    ],
  );

  Widget _buildDetailSection(Map<String, dynamic>? data) => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _info('Date', data?['date'] ?? 'N/A'),
        _info('Time', '${data?['timeFrom'] ?? '--'} - ${data?['timeTo'] ?? '--'}'),
        _info('Guide', data?['guideName'] ?? 'Emmy', highlight: true),
        _info('Travelers', '${data?['travelers'] ?? 0}'),
        const SizedBox(height: 12),
        const Text('Attractions', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8, runSpacing: 4,
          children: (data?['attractions'] as List?)?.map((e) => _chip(e.toString())).toList() ?? [],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Fee', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('\$${data?['fee'] ?? 0}', style: const TextStyle(fontSize: 22, color: Colors.teal, fontWeight: FontWeight.bold)),
          ],
        ),
        const Divider(height: 32),
        SizedBox(
          width: double.infinity, height: 48,
          child: OutlinedButton.icon(
            onPressed: _handleFinish,
            icon: const Icon(Icons.check, color: Colors.teal),
            label: const Text('Mark Finished', style: TextStyle(color: Colors.black87)),
            style: OutlinedButton.styleFrom(shape: const StadiumBorder()),
          ),
        ),
      ],
    ),
  );

  Widget _chip(String label) => Chip(
    avatar: const Icon(Icons.location_on, color: Colors.teal, size: 14),
    label: Text(label, style: const TextStyle(fontSize: 13)),
    backgroundColor: Colors.white,
    shape: StadiumBorder(side: BorderSide(color: Colors.teal.withOpacity(0.2))),
  );

  Widget _info(String t, String v, {bool highlight = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(t, style: const TextStyle(color: Colors.black54)),
        Text(v, style: TextStyle(color: highlight ? Colors.teal : Colors.black87, fontWeight: highlight ? FontWeight.bold : FontWeight.w500)),
      ],
    ),
  );
}