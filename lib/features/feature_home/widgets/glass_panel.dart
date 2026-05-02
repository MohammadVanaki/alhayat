import 'dart:ui';
import 'package:flutter/material.dart';

class GlassPanel extends StatelessWidget {
  const GlassPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          // Blur effect for glass
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            width: 300,
            height: 200,
            decoration: BoxDecoration(
              // Semi transparent color
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),

              // Glass border
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),

              // Soft shadow
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Center(
              child: Text(
                "Glass Panel",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
