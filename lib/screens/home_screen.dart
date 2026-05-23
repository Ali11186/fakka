import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/card_model.dart';
import 'charge_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cards = getAllCards();
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text('شحن كروت فودافون',
            style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, childAspectRatio: 1.4,
              crossAxisSpacing: 10, mainAxisSpacing: 10,
            ),
            itemCount: cards.length,
            itemBuilder: (context, i) {
              final card = cards[i];
              return GestureDetector(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => ChargeScreen(card: card))),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E1E3F), Color(0xFF2D2D5E)],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF4A4A8A)),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(card.name, style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                      Text(card.units, style: GoogleFonts.cairo(color: const Color(0xFF9090FF), fontSize: 11)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${card.netCharge} ج', style: GoogleFonts.cairo(color: const Color(0xFF00E676), fontWeight: FontWeight.bold, fontSize: 13)),
                          Text(card.duration, style: GoogleFonts.cairo(color: Colors.white54, fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: Duration(milliseconds: i * 40)),
              );
            },
          ),
        ),
      ),
    );
  }
}
