import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class PaymentPreviewScreen extends StatefulWidget {
  final Map<String, String> cardData;

  const PaymentPreviewScreen({super.key, required this.cardData});

  @override
  State<PaymentPreviewScreen> createState() => _PaymentPreviewScreenState();
}

class _PaymentPreviewScreenState extends State<PaymentPreviewScreen> {
  static const _teal = Color(0xFF2EC4A5);
  bool _isProcessing = false;

  late Future<Map<String, dynamic>?> _latestTripFuture;

  @override
  void initState() {
    super.initState();
    _latestTripFuture = _getLatestTrip();
  }

  // Lấy chuyến đi mới nhất để hiển thị
  Future<Map<String, dynamic>?> _getLatestTrip() async {
    try {
      final List<dynamic> trips = await ApiService.getAllTrips();
      if (trips.isNotEmpty) {
        return trips.first as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint("Lỗi lấy trip mới nhất: $e");
    }
    return null;
  }

  // Chỉ giữ lại 4 số cuối
  String _maskCardNumber(String? cardNumber) {
    if (cardNumber == null || cardNumber.isEmpty) return 'N/A';
    String cleanNumber = cardNumber.replaceAll(' ', '');
    if (cleanNumber.length < 4) return cleanNumber;
    String lastFour = cleanNumber.substring(cleanNumber.length - 4);
    return '**** **** **** $lastFour';
  }

  // Hàm xử lý ngày tháng
  String _formatDatePlusThree(String? dateStr) {
    if (dateStr == null || dateStr == 'N/A') return 'N/A';
    try {
      DateTime originalDate = DateFormat('d/M/yyyy').parse(dateStr);
      DateTime newDate = originalDate.add(const Duration(days: 3));
      return DateFormat('d/M/yyyy').format(newDate);
    } catch (e) {
      return dateStr;
    }
  }

  // Gửi dữ liệu thanh toán lên Server
  void _handleConfirmAndPay(Map<String, dynamic>? tripData) async {
    if (tripData == null) return;

    setState(() => _isProcessing = true);

    try {
      final List<dynamic> users = await ApiService.getUsersList();
      if (users.isEmpty) return;

      final firstUser = users.first;
      final String userId = (firstUser['_id'] ?? firstUser['id'] ?? '').toString();
      final double totalAmount = double.tryParse(tripData['fee']?.toString() ?? '0') ?? 0.0;

      final paymentBody = {
        'userId': userId,
        'tripId': tripData['_id'] ?? tripData['id'] ?? '',
        'cardHolderName': widget.cardData['cardHolderName'] ?? '',
        'cardNumber': widget.cardData['cardNumber'] ?? '',
        'expiryDate': widget.cardData['expiryDate'] ?? '',
        'amount': totalAmount,
      };

      bool success = await ApiService.processPayment(paymentBody);

      setState(() => _isProcessing = false);

      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment successful!'), backgroundColor: _teal)
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment failed!'), backgroundColor: Colors.red)
      );
    }
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
            onPressed: () => Navigator.pop(context)
        ),
        title: const Text('Payment', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _latestTripFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: _teal));
          }

          final data = snapshot.data;
          final String destination = data?['location'] ?? 'Danang, Vietnam';
          final String date = _formatDatePlusThree(data?['date']);
          final String time = '${data?['timeFrom'] ?? '--'} - ${data?['timeTo'] ?? '--'}';
          final String guide = data?['guideName'] ?? 'Emmy';
          final String travelers = '${data?['travelers'] ?? 0}';
          final String totalFee = '\$${data?['fee'] ?? 0}';

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text('Order Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 24),

                  // Hiển thị thông tin thẻ đã nhập từ màn hình trước[cite: 1, 2]
                  _buildRow("Card Holder's Name", widget.cardData['cardHolderName'] ?? 'N/A'),
                  _buildRow("Card Number", _maskCardNumber(widget.cardData['cardNumber'])),

                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),

                  _buildRow('Destination', destination),
                  _buildRow('Date', date),
                  _buildRow('Time', time),
                  _buildRow('Guide', guide, highlight: true),
                  _buildRow('Travelers', travelers),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(totalFee, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _teal)),
                  ]),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : () => _handleConfirmAndPay(data),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _teal,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: _isProcessing
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('CONFIRM & PAY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRow(String l, String v, {bool highlight = false}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(l, style: const TextStyle(color: Colors.black54, fontSize: 14)),
        Text(v, style: TextStyle(
            fontSize: 14,
            color: highlight ? _teal : Colors.black87,
            fontWeight: highlight ? FontWeight.bold : FontWeight.w500
        )),
      ]));
}