import 'package:flutter/material.dart';
import 'package:hisabapp/core/presentation/theme/app_colors.dart'; 

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top spacing
            const SizedBox(height: 40),
            
            // --- Logo Image Section ---
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 185,
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        // Logo 1: Top logo
                        Image.asset(
                          'assets/images/logo2.png',
                          width: 140,
                          height: 140,
                          fit: BoxFit.contain,
                        ),
                        // Logo 2: overlaps logo1 from below
                        Positioned(
                          top: 85,
                          child: ColorFiltered(
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.modulate,
                            ),
                            child: Image.asset(
                              'assets/images/logo1.jpg',
                              width: 110,
                              height: 110,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),

            // --- Title Section ---
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Welcome to HisabApp',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textMain,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // --- Action Button ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 140, vertical: 20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    print('Get Started tapped!');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryYellow, 
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(
                      color: AppColors.textMain,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}