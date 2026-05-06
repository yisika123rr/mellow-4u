import 'package:flutter/material.dart';
import 'payment_preview_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _nameController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  static const _teal = Color(0xFF2EC4A5);

  @override
  void dispose() {
    _nameController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _onNext() {
    // Kiểm tra dữ liệu đầu vào
    if (_nameController.text.isEmpty || _cardNumberController.text.isEmpty ||
        _expiryController.text.isEmpty || _cvvController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin thẻ')),
      );
      return;
    }

    // Truyền thông tin sang màn hình Preview
    final cardData = {
      'cardHolderName': _nameController.text,
      'cardNumber': _cardNumberController.text,
      'expiryDate': _expiryController.text,
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentPreviewScreen(cardData: cardData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).maybePop(),
                      child: const Icon(Icons.close, color: Colors.black87, size: 24),
                    ),
                  ),
                  const Text('Payment',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
              child: Row(
                children: [
                  const _StepCircle(active: true, label: '1'),
                  Expanded(child: Container(height: 2, color: Colors.grey.shade300)),
                  const _StepCircle(active: false, label: '2'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Payment Method',
                      style: TextStyle(fontSize: 12, color: _teal, fontWeight: FontWeight.w500)),
                  const Text('Preview & Check out',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.credit_card, size: 22, color: Colors.black87),
                        SizedBox(width: 8),
                        Text('Card Information',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black87)),
                      ],
                    ),
                    const SizedBox(height: 28),
                    _buildLabel("Card Holder's Name"),
                    const SizedBox(height: 8),
                    _buildTextField(controller: _nameController, hint: "Card Holder's Name"),
                    const SizedBox(height: 24),
                    _buildLabel('Card Number'),
                    const SizedBox(height: 8),
                    _buildTextField(
                        controller: _cardNumberController,
                        hint: '0000 0000 0000 0000',
                        keyboardType: TextInputType.number,
                        maxLength: 19),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Expiration Date'),
                              const SizedBox(height: 8),
                              _buildTextField(
                                  controller: _expiryController,
                                  hint: 'mm/yy',
                                  keyboardType: TextInputType.datetime,
                                  maxLength: 5),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('CVV'),
                              const SizedBox(height: 8),
                              _buildTextField(
                                  controller: _cvvController,
                                  hint: '000',
                                  keyboardType: TextInputType.number,
                                  maxLength: 3,
                                  obscureText: true),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _onNext,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _teal,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('NEXT',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87));
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    int? maxLength,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      obscureText: obscureText,
      style: const TextStyle(fontSize: 14, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        counterText: '',
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5)),
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: _teal, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
      ),
    );
  }
}

class _StepCircle extends StatelessWidget {
  final bool active;
  final String label;
  const _StepCircle({required this.active, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? const Color(0xFF2EC4A5) : Colors.transparent,
        border: active ? null : Border.all(color: Colors.grey.shade400, width: 1.5),
      ),
      child: Center(
        child: active
            ? const Icon(Icons.check, color: Colors.white, size: 16)
            : Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
      ),
    );
  }
}