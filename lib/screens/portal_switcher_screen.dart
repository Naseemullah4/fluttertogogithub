import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../services/state_service.dart';
import '../theme/app_colors.dart';
import 'customer/customer_main_screen.dart';
import 'driver/driver_main_screen.dart';
import 'laundry/laundry_main_screen.dart';
import 'admin/admin_main_screen.dart';
import 'super_admin/super_admin_main_screen.dart';
import '../widgets/uniwash_logo.dart';

class PortalSwitcherScreen extends StatefulWidget {
  const PortalSwitcherScreen({super.key});

  @override
  State<PortalSwitcherScreen> createState() => _PortalSwitcherScreenState();
}

class _PortalSwitcherScreenState extends State<PortalSwitcherScreen> {
  bool _useMobileFrame360x690 = true;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<StateService>();
    final role = state.currentUser.role;
    final isMobile = role == UserRole.customer || role == UserRole.driver;

    Widget currentPortal;
    switch (role) {
      case UserRole.customer:
        currentPortal = const CustomerMainScreen();
        break;
      case UserRole.driver:
        currentPortal = const DriverMainScreen();
        break;
      case UserRole.laundryWorker:
        currentPortal = const LaundryMainScreen();
        break;
      case UserRole.regionalAdmin:
        currentPortal = const AdminMainScreen();
        break;
      case UserRole.superAdmin:
        currentPortal = const SuperAdminMainScreen();
        break;
    }

    final screenWidth = MediaQuery.of(context).size.width;

    Widget mainContent;

    if (isMobile && _useMobileFrame360x690 && screenWidth > 420) {
      // Centered 360 x 690 Mobile Viewport Frame for Customer & Driver on desktop/browser
      mainContent = LayoutBuilder(
        builder: (context, constraints) {
          // Calculate dynamically available height inside the Scaffold body
          final availableHeight = constraints.maxHeight;
          // Overhead for device header tag (~28px) + vertical margins/padding (~24px)
          const double overhead = 52.0;
          final double maxFrameHeight = math.max(300.0, availableHeight - overhead);
          final double frameHeight = math.min(690.0, maxFrameHeight);

          return Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFF0B132B), // Deep navy aesthetic background
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Device header tag
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const UniWashLogo.badge(size: 16),
                          const SizedBox(width: 8),
                          Text(
                            '${role.shortName} App • 360 × 690 Mobile Viewport',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.tealAccent),
                          ),
                        ],
                      ),
                    ),

                    // The 360 x 690 Container Frame
                    Container(
                      width: 360,
                      height: frameHeight,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: const Color(0xFF1E293B), width: 3.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.45),
                            blurRadius: 30,
                            spreadRadius: 2,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: currentPortal,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    } else {
      // Full screen Web Application (for Super Admin, Admin, Laundry) or native mobile view
      mainContent = currentPortal;
    }

    return Scaffold(
      body: mainContent,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A), // Dark slate premium bottom bar
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const UniWashLogo.badge(size: 32),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                state.currentUser.role.title,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _isWebPortal(role)
                                      ? AppColors.accent.withValues(alpha: 0.3)
                                      : AppColors.primary.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  _isWebPortal(role) ? '💻 BROWSER WEB APP' : '📱 MOBILE (360×690)',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: _isWebPortal(role) ? Colors.lightBlueAccent : Colors.tealAccent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Logged in as: ${state.currentUser.fullName}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white60,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 360 x 690 Viewport Size Toggle for mobile roles
                    if (isMobile && screenWidth > 420)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: InkWell(
                          onTap: () {
                            setState(() => _useMobileFrame360x690 = !_useMobileFrame360x690);
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _useMobileFrame360x690 ? Colors.teal.shade800 : Colors.white12,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _useMobileFrame360x690 ? Colors.tealAccent : Colors.white24,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _useMobileFrame360x690 ? Icons.check_circle : Icons.aspect_ratio,
                                  size: 12,
                                  color: Colors.tealAccent,
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  '360×690 Frame',
                                  style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    PopupMenuButton<UserRole>(
                      tooltip: 'Quick Role Switcher',
                      icon: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.6)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              'Switch Portal',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.unfold_more, size: 14, color: Colors.white),
                          ],
                        ),
                      ),
                      onSelected: (newRole) {
                        state.switchRole(newRole);
                      },
                      itemBuilder: (ctx) => UserRole.values.map((r) {
                        final isCur = r == state.currentUser.role;
                        return PopupMenuItem<UserRole>(
                          value: r,
                          child: Row(
                            children: [
                              Icon(
                                _getRoleIcon(r),
                                size: 18,
                                color: isCur ? AppColors.primary : AppColors.textMuted,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                _isWebPortal(r) ? '${r.shortName} (Web)' : '${r.shortName} (360×690 Mobile)',
                                style: TextStyle(
                                  fontWeight: isCur ? FontWeight.w700 : FontWeight.w500,
                                  color: isCur ? AppColors.primaryDark : AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              // Segmented Nav Tabs for easy one-tap switching
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 6),
                child: Row(
                  children: UserRole.values.map((r) {
                    final isSelected = r == role;
                    final isWeb = _isWebPortal(r);
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: InkWell(
                        onTap: () => state.switchRole(r),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? AppColors.primaryLight : Colors.transparent,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(_getRoleIcon(r), size: 13, color: isSelected ? Colors.white : Colors.white70),
                              const SizedBox(width: 6),
                              Text(
                                isWeb ? '💻 ${r.shortName} (Web)' : '📱 ${r.shortName} (Mobile)',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected ? Colors.white : Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static bool _isWebPortal(UserRole role) {
    return role == UserRole.laundryWorker ||
        role == UserRole.regionalAdmin ||
        role == UserRole.superAdmin;
  }

  static IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return Icons.shopping_bag_outlined;
      case UserRole.driver:
        return Icons.electric_moped_outlined;
      case UserRole.laundryWorker:
        return Icons.local_laundry_service_outlined;
      case UserRole.regionalAdmin:
        return Icons.admin_panel_settings_outlined;
      case UserRole.superAdmin:
        return Icons.public;
    }
  }
}
