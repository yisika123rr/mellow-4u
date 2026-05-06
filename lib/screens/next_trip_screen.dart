import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'payment_checkout_screen.dart';
import '../services/api_service.dart';

class NextTripPage extends StatefulWidget {
  final String? tripId;
  const NextTripPage({super.key, this.tripId});

  @override
  State<NextTripPage> createState() => _NextTripPageState();
}

class _NextTripPageState extends State<NextTripPage> {
  late Future<Map<String, dynamic>?> _tripFuture;

  @override
  void initState() {
    super.initState();
    _loadTripData();
  }

  void _loadTripData() {
    if (widget.tripId != null) {
      // Nếu có ID, lấy theo ID
      _tripFuture = ApiService.getTripById(widget.tripId!);
    } else {
      // Lấy danh sách và bốc phần tử đầu tiên
      _tripFuture = ApiService.getAllTrips().then((list) {
        if (list.isNotEmpty) {
          return list.first;
        }
        return null;
      });
    }
  }

  // Cộng thêm 3 ngày
  String _formatAndAddDays(dynamic dateValue) {
    if (dateValue == null) return 'N/A';
    String dateStr = dateValue.toString();
    try {
      DateTime parsedDate;
      parsedDate = DateFormat("d/M/yyyy").parse(dateStr);
      // Cộng 3 ngày
      DateTime finalDate = parsedDate.add(const Duration(days: 3));
      return DateFormat("MMM d, yyyy").format(finalDate);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>?>(
          future: _tripFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF00C9A7)));
            }

            final nextTrip = snapshot.data;
            if (nextTrip == null) {
              return const Center(child: Text("Không có dữ liệu mới nhất."));
            }

            return Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildHero(nextTrip['location'] ?? 'Danang, Vietnam'),
                        _buildDetails(nextTrip),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
        const Text('Next Trip', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Icon(Icons.more_horiz),
      ],
    ),
  );

  Widget _buildHero(String loc) => Stack(
    children: [
      Image.network(
        'https://images.pexels.com/photos/1127119/pexels-photo-1127119.jpeg',
        height: 180, width: double.infinity, fit: BoxFit.cover,
      ),
      Positioned(
        bottom: 15, left: 15,
        child: Text(loc, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      const Positioned(
        top: 110, right: 15,
        child: CircleAvatar(
          radius: 30, backgroundColor: Color(0xFF00C9A7),
          child: CircleAvatar(
            radius: 27,
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, color: Colors.white),
          ),
        ),
      ),
    ],
  );

  Widget _buildDetails(Map<String, dynamic> trip) => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      children: [
        _row('Date', _formatAndAddDays(trip['date'])),
        _row('Time', '${trip['timeFrom'] ?? '--'} - ${trip['timeTo'] ?? '--'}'),
        _row('Guide', trip['guideName'] ?? 'Emmy', isTeal: true),
        _row('Travelers', '${trip['travelers'] ?? 0}'),
        const SizedBox(height: 15),
        const Align(alignment: Alignment.centerLeft, child: Text('Attractions', style: TextStyle(color: Colors.black54))),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: (trip['attractions'] as List?)?.map((e) => _chip(e.toString())).toList() ?? [],
        ),
        const Divider(height: 50),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Fee', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('\$${trip['fee'] ?? 0}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF00C9A7))),
          ],
        ),
        const SizedBox(height: 30),
        Row(
          children: [
            Expanded(child: _btn('Chat', Icons.chat_bubble_outline, () {})),
            const SizedBox(width: 15),
            Expanded(child: _btn('Pay', Icons.credit_card, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentScreen()));
            })),
          ],
        )
      ],
    ),
  );

  Widget _row(String l, String v, {bool isTeal = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(l, style: const TextStyle(color: Colors.black54)),
      Text(v, style: TextStyle(fontWeight: FontWeight.bold, color: isTeal ? const Color(0xFF00C9A7) : Colors.black)),
    ]),
  );

  Widget _chip(String l) => Chip(label: Text(l, style: const TextStyle(fontSize: 12)), backgroundColor: Colors.white, side: const BorderSide(color: Color(0xFFEEEEEE)));

  Widget _btn(String l, IconData i, VoidCallback fn) => OutlinedButton.icon(
    onPressed: fn, icon: Icon(i, size: 18), label: Text(l),
    style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF00C9A7), side: const BorderSide(color: Color(0xFF00C9A7)), padding: const EdgeInsets.symmetric(vertical: 12)),
  );
}