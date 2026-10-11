import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/state_service.dart';
import '../../theme/app_colors.dart';

class DriverCompletionScreen extends StatelessWidget {
  final int completedOrdersCount;
  final double earnedBonusQar;

  const DriverCompletionScreen({
    super.key,
    required this.completedOrdersCount,
    required this.earnedBonusQar,
  });

  static Future<void> show(
    BuildContext context, {
    required int completedOrdersCount,
    required double earnedBonusQar,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DriverCompletionScreen(
          completedOrdersCount: completedOrdersCount,
          earnedBonusQar: earnedBonusQar,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<StateService>();
    final driver = state.currentDriver;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Big Smile Avatar with celebratory pulsing glow
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Colors.amber.shade300,
                        Colors.orange.shade500,
                        Colors.deepOrange.shade600,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withValues(alpha: 0.4),
                        blurRadius: 32,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      '😊',
                      style: TextStyle(fontSize: 62),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Celebratory Tag
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade400.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.amber.shade400,
                      width: 1.2,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('🎉', style: TextStyle(fontSize: 16)),
                      SizedBox(width: 8),
                      Text(
                        'BIG SMILE!',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: Colors.amber,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Main Congratulations Heading
                const Text(
                  'Congratulations!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'You have completed your orders.',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF94A3B8),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 28),

                // Bonus Reward Announcement Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF1E293B),
                        const Color(0xFF14532D).withValues(alpha: 0.6),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: const Color(0xFF22C55E).withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.stars, color: Colors.amber, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'BONUS REWARD EARNED',
                            style: TextStyle(
                              color: Color(0xFF86EFAC),
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '+${earnedBonusQar.toStringAsFixed(earnedBonusQar % 1 == 0 ? 0 : 2)} QAR',
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'You have earned your bonus for the completed orders.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFBBF7D0),
                        ),
                      ),
                      const Divider(
                        color: Colors.white12,
                        height: 24,
                      ),
                      // Bonus calculation breakdown
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Completed Missions:',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                          Text(
                            '$completedOrdersCount Orders Today',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Courier Bonus Rate:',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                          Text(
                            '${driver.bonusRatePerOrder.toStringAsFixed(2)} QAR / order',
                            style: const TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Driver Tier Status:',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                          Text(
                            driver.tierBadgeTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Lifetime Completed Trips:',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                          Text(
                            '${driver.completedTrips} Trips',
                            style: const TextStyle(
                              color: Colors.greenAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Back to Dashboard Button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.dashboard_rounded, size: 20),
                    label: const Text(
                      'Back to Driver Console',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
