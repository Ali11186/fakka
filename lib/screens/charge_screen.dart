import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/card_model.dart';
import '../services/vodafone_service.dart';

class ChargeScreen extends StatefulWidget {
  final FakkaCard card;
  const ChargeScreen({super.key, required this.card});
  @override
  State<ChargeScreen> createState() => _ChargeScreenState();
}

class _ChargeScreenState extends State<ChargeScreen> {
  final _receiverCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();
  final _service = VodafoneService();
  bool _loading = false;
  String _status = '';
  bool _success = false;

  Future<void> _charge() async {
    final receiver = _receiverCtrl.text.trim();
    final pin = _pinCtrl.text.trim();
    if (!receiver.startsWith('01') || receiver.length != 11) {
      setState(() { _status = '❌ رقم الهاتف غير صحيح'; _success = false; });
      return;
    }
    if (pin.isEmpty) {
      setState(() { _status = '❌ ادخل الرقم السري'; _success = false; });
      return;
    }
    setState(() { _loading = true; _status = '🔄 جاري تسجيل الدخول...'; });
    try {
      final seamless = await _service.getSeamlessToken();
      final token = seamless['seamlessToken'];
      final msisdn = seamless['msisdn']?.toString() ?? '';
      if (token == null) { setState(() { _status = '❌ فشل تسجيل الدخول'; _loading = false; _success = false; }); return; }
      setState(() { _status = '🔄 جاري الحصول على رمز الوصول...'; });
      final access = await _service.getAccessToken(token);
      if (access == null) { setState(() { _status = '❌ فشل رمز الوصول'; _loading = false; _success = false; }); return; }
      setState(() { _status = '🔄 جاري الشحن...'; });
      final result = await _service.chargeCard(
        productId: widget.card.productId, receiver: receiver,
        pin: pin, senderMsisdn: msisdn, accessToken: access,
      );
      if (result['state'] == 'Completed' || result['complete'] == true) {
        setState(() { _status = '✅ تم الشحن بنجاح!'; _success = true; });
      } else {
        setState(() { _status = '❌ فشل: ${result['message'] ?? result}'; _success = false; });
      }
    } catch (e) {
      setState(() { _status = '❌ خطأ: $e'; _success = false; });
    } finally {
      setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text(widget.card.name, style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF1E1E3F), Color(0xFF2D2D5E)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF4A4A8A)),
              ),
              child: Column(children: [
                Text(widget.card.name, style: GoogleFonts.cairo(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(widget.card.units, style: GoogleFonts.cairo(color: const Color(0xFF9090FF), fontSize: 14)),
                Text('صافي: ${widget.card.netCharge} جنيه', style: GoogleFonts.cairo(color: const Color(0xFF00E676), fontSize: 16, fontWeight: FontWeight.bold)),
                Text('المدة: ${widget.card.duration}', style: GoogleFonts.cairo(color: Colors.white54, fontSize: 12)),
              ]),
            ).animate().fadeIn().slideY(begin: -0.2),
            const SizedBox(height: 24),
            TextField(
              controller: _receiverCtrl,
              keyboardType: TextInputType.phone,
              style: GoogleFonts.cairo(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'رقم الهاتف', labelStyle: GoogleFonts.cairo(color: Colors.white54),
                hintText: '01xxxxxxxxx', hintStyle: GoogleFonts.cairo(color: Colors.white30),
                prefixIcon: const Icon(Icons.phone, color: Color(0xFF9090FF)),
                filled: true, fillColor: const Color(0xFF1E1E3F),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 16),
            TextField(
              controller: _pinCtrl, obscureText: true,
              keyboardType: TextInputType.number,
              style: GoogleFonts.cairo(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'الرقم السري للمحفظة', labelStyle: GoogleFonts.cairo(color: Colors.white54),
                prefixIcon: const Icon(Icons.lock, color: Color(0xFF9090FF)),
                filled: true, fillColor: const Color(0xFF1E1E3F),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ).animate().fadeIn(delay: 150.ms),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: _loading ? null : _charge,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A4AFF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    : Text('شحن الآن 🚀', style: GoogleFonts.cairo(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ).animate().fadeIn(delay: 200.ms),
            if (_status.isNotEmpty) ...[
              const SizedBox(height: 20),
              Container(
                width: double.infinity, padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _success ? const Color(0xFF0D2F1A) : const Color(0xFF2F0D0D),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _success ? const Color(0xFF00E676) : const Color(0xFFFF5252)),
                ),
                child: Text(_status,
                    style: GoogleFonts.cairo(color: _success ? const Color(0xFF00E676) : const Color(0xFFFF5252), fontSize: 14, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center),
              ).animate().fadeIn().scale(),
            ],
          ]),
        ),
      ),
    );
  }
}
