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
  bool _forceDesktopFullWidth = false;

  void _showRoleSwitcherSheet(BuildContext context, StateService state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0F172A), // Dark slate premium theme
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const UniWashLogo.badge(size: 30),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Switch UniWash Portal',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Select your testing persona or platform view',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.white12, height: 1),
              const SizedBox(height: 12),
              ...UserRole.values.map((role) {
                final isSelected = role == state.currentUser.role;
                final isMobile = role == UserRole.customer || role == UserRole.driver;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () {
                      state.switchRole(role);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Switched to ${role.title}'),
                          duration: const Duration(milliseconds: 1200),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.25)
                            : Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? AppColors.primaryLight : Colors.white12,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.white.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getRoleIcon(role),
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      role.title,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isMobile
                                            ? Colors.teal.withValues(alpha: 0.2)
                                            : Colors.blue.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        isMobile ? '📱 Mobile App' : '💻 Web Dashboard',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: isMobile ? Colors.tealAccent : Colors.lightBlueAccent,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _getRoleDescription(role),
                                  style: const TextStyle(
                                    color: Colors.white60,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle,
                              color: AppColors.primaryLight,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<StateService>();
    final role = state.currentUser.role;
    final isMobileRole = role == UserRole.customer || role == UserRole.driver;
    final screenWidth = MediaQuery.of(context).size.width;

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

    Widget mainContent;

    // Mobile-first responsive logic:
    // 1. If screenWidth < 768 (phones, tablets, narrow windows): 100% full screen fluid fit!
    // 2. If screenWidth >= 768 on desktop for mobile roles:
    //    We center the mobile view cleanly without artificial height clipping!
    if (isMobileRole && screenWidth >= 768 && !_forceDesktopFullWidth) {
      mainContent = Container(
        color: const Color(0xFF0F172A), // Dark slate sleek background for desktop preview
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 440),
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: const Color(0xFF334155), width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 36,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: currentPortal,
          ),
        ),
      );
    } else {
      // 100% Full-screen mobile layout (fluid, responsive, fits every phone perfectly)
      mainContent = currentPortal;
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: mainContent),

          // Sleek Floating Portal Switcher Badge
          // Designed to never block the main app tabs while remaining 100% accessible anywhere
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 12,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showRoleSwitcherSheet(context, state),
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.90),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const UniWashLogo.badge(size: 16),
                      const SizedBox(width: 6),
                      Text(
                        role.shortName,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.unfold_more,
                        size: 14,
                        color: Colors.tealAccent,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Optional Desktop Full-Width Toggle when on widescreen
          if (isMobileRole && screenWidth >= 768)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 12,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() => _forceDesktopFullWidth = !_forceDesktopFullWidth);
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _forceDesktopFullWidth ? Icons.smartphone : Icons.fullscreen,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _forceDesktopFullWidth ? 'Mobile Frame' : 'Full Width',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
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

  static String _getRoleDescription(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return 'Garment catalog, shopping basket, QR tracking & fabric care';
      case UserRole.driver:
        return 'GPS navigation, pickup & delivery dispatch missions';
      case UserRole.laundryWorker:
        return 'Branch operations, item count verification & thermal receipts';
      case UserRole.regionalAdmin:
        return 'Fleet onboarding, laundry contracts & complaints handling';
      case UserRole.superAdmin:
        return 'Global catalog editing, financial audit & multi-country control';
    }
  }
}
