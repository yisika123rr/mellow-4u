import 'package:flutter/material.dart';
import 'trip_detail_screen.dart';
import '../services/api_service.dart';

class AttractionItem {
  final String name;
  final String imagePath;
  bool isSelected;

  AttractionItem({
    required this.name,
    required this.imagePath,
    this.isSelected = false,
  });
}

class CreateNewTripScreen extends StatefulWidget {
  const CreateNewTripScreen({super.key});

  @override
  State<CreateNewTripScreen> createState() => _CreateNewTripScreenState();
}

class _CreateNewTripScreenState extends State<CreateNewTripScreen> {
  int numberOfTravelers = 1;
  bool _isLoading = false;

  // Lấy dữ liệu từ các ô nhập liệu
  final TextEditingController _locationController =
  TextEditingController(text: 'Danang, Vietnam');
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _fromTimeController = TextEditingController();
  final TextEditingController _toTimeController = TextEditingController();
  final TextEditingController _feeController = TextEditingController();
  final TextEditingController _languageController =
  TextEditingController(text: 'Korean, English');

  final List<AttractionItem> attractions = [
    AttractionItem(name: 'Dragon Bridge', imagePath: 'assets/images/dragon.jpg', isSelected: true),
    AttractionItem(name: 'Cham Museum', imagePath: 'assets/images/chua.jpg', isSelected: false),
    AttractionItem(name: 'My Khe Beach', imagePath: 'assets/images/my-khe.jpg', isSelected: true),
  ];

  static const Color primaryTeal = Color(0xFF00C4A0);
  static const Color textGrey = Color(0xFF9E9E9E);
  static const Color textDark = Color(0xFF212121);
  static const Color borderColor = Color(0xFFE0E0E0);

  @override
  void dispose() {
    _locationController.dispose();
    _dateController.dispose();
    _fromTimeController.dispose();
    _toTimeController.dispose();
    _feeController.dispose();
    _languageController.dispose();
    super.dispose();
  }

  // Xử lý logic gửi dữ liệu lên Server
  void _onDone() async {
    if (_locationController.text.isEmpty || _feeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập địa điểm và phí!")),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Chuẩn bị dữ liệu
    final tripData = {
      "location": _locationController.text,
      "date": _dateController.text,
      "timeFrom": _fromTimeController.text,
      "timeTo": _toTimeController.text,
      "travelers": numberOfTravelers,
      "fee": double.tryParse(_feeController.text) ?? 0,
      "guideLanguage": _languageController.text,
      "attractions": attractions
          .where((a) => a.isSelected)
          .map((a) => a.name)
          .toList(),
    };

    final result = await ApiService.createTrip(tripData);

    setState(() => _isLoading = false);

    if (result != null && result.containsKey('_id')) {
      if (!mounted) return;
      // Truyền ID thực tế sang màn hình Detail để lấy dữ liệu
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TripDetailPage(tripId: result['_id'].toString()),
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lỗi kết nối tới Server ThinkBook!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildLocationField(),
                    const SizedBox(height: 20),
                    _buildDateField(),
                    const SizedBox(height: 20),
                    _buildTimeField(),
                    const SizedBox(height: 20),
                    _buildTravelersField(),
                    const SizedBox(height: 20),
                    _buildFeeField(),
                    const SizedBox(height: 20),
                    _buildLanguageField(),
                    const SizedBox(height: 20),
                    _buildAttractionsSection(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _buildDoneButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Center(
        child: Text(
          'Create New Trip',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: textDark),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textDark)),
    );
  }

  Widget _buildLocationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Where you want to explore'),
        Container(
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: borderColor))),
          child: Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 18, color: primaryTeal),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _locationController,
                  style: const TextStyle(fontSize: 14, color: textDark),
                  decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Date'),
        Container(
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: borderColor))),
          child: Row(
            children: [
              const Icon(Icons.calendar_month_outlined, size: 18, color: textGrey),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _dateController,
                  style: const TextStyle(fontSize: 14, color: textDark),
                  decoration: const InputDecoration(hintText: 'dd/mm/yy', border: InputBorder.none),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeField() {
    Widget timeInput(TextEditingController ctrl, String hint) {
      return Expanded(
        child: Container(
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: borderColor))),
          child: Row(
            children: [
              const Icon(Icons.access_time, size: 18, color: textGrey),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: ctrl,
                  decoration: InputDecoration(hintText: hint, border: InputBorder.none),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Time'),
        Row(children: [timeInput(_fromTimeController, 'From(less than 3 date to prepare)'), const SizedBox(width: 16), timeInput(_toTimeController, 'To')]),
      ],
    );
  }

  Widget _buildTravelersField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Number of travelers'),
        Row(
          children: [
            GestureDetector(
              onTap: () { if (numberOfTravelers > 1) setState(() => numberOfTravelers--); },
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: numberOfTravelers > 1 ? primaryTeal : Colors.grey[300], borderRadius: BorderRadius.circular(6)),
                child: const Icon(Icons.arrow_drop_down, color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 50, height: 36, alignment: Alignment.center,
              decoration: BoxDecoration(border: Border.all(color: borderColor), borderRadius: BorderRadius.circular(6)),
              child: Text('$numberOfTravelers', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => setState(() => numberOfTravelers++),
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: primaryTeal, borderRadius: BorderRadius.circular(6)),
                child: const Icon(Icons.arrow_drop_up, color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Fee'),
        Container(
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: borderColor))),
          child: Row(
            children: [
              const Icon(Icons.attach_money, size: 18, color: textGrey),
              Expanded(
                child: TextField(
                  controller: _feeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(border: InputBorder.none),
                ),
              ),
              const Text('(\$/hour)', style: TextStyle(color: textGrey)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel("Guide's Language"),
        Container(
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: borderColor))),
          child: Row(
            children: [
              const Icon(Icons.language, size: 18, color: textGrey),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _languageController,
                  style: const TextStyle(fontSize: 14, color: textDark),
                  decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAttractionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Attractions'),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.55,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10
          ),
          itemCount: attractions.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) return _buildAddNewCard();
            return _buildAttractionCard(attractions[index - 1]);
          },
        ),
      ],
    );
  }

  Widget _buildAddNewCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add, color: primaryTeal, size: 28),
          Text('Add New', style: TextStyle(color: primaryTeal, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildAttractionCard(AttractionItem item) {
    return GestureDetector(
      onTap: () => setState(() => item.isSelected = !item.isSelected),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(item.imagePath, fit: BoxFit.cover),
            if (item.isSelected)
              Positioned(
                top: 8, right: 8,
                child: Container(
                  width: 24, height: 24,
                  decoration: const BoxDecoration(color: primaryTeal, shape: BoxShape.circle),
                  child: const Icon(Icons.check, color: Colors.white, size: 16),
                ),
              ),
            Positioned(
              bottom: 8, left: 8,
              child: Text(item.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoneButton() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity, height: 52,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _onDone,
          style: ElevatedButton.styleFrom(
              backgroundColor: primaryTeal,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))
          ),
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text('DONE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}