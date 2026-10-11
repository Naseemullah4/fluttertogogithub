import 'package:flutter_test/flutter_test.dart';
import 'package:uniwash_laundry/models/admin_team.dart';
import 'package:uniwash_laundry/models/audit_log.dart';
import 'package:uniwash_laundry/models/country_branch.dart';
import 'package:uniwash_laundry/models/order.dart';
import 'package:uniwash_laundry/services/state_service.dart';

void main() {
  group('Super Admin & Regional Admin System Tests', () {
    late StateService state;

    setUp(() {
      state = StateService();
    });

    test('Initializes with default countries, branches, admins, and team members', () {
      expect(state.countries.isNotEmpty, isTrue);
      expect(state.admins.isNotEmpty, isTrue);
      expect(state.teamMembers.isNotEmpty, isTrue);

      // Verify Qatar and UAE exist
      final qatar = state.countries.firstWhere((c) => c.code == 'QAT');
      expect(qatar.name, 'Qatar');
      expect(qatar.branches.isNotEmpty, isTrue);

      // Verify Super Admin exists
      final superAdmin = state.admins.firstWhere((a) => a.isSuperAdmin);
      expect(superAdmin.email, 'faisal.director@uniwash.qa');
      expect(superAdmin.hasPermission(AppPermission.ordersCorrectStatus), isTrue);
      expect(superAdmin.hasPermission(AppPermission.adminsCreate), isTrue);
      expect(superAdmin.hasPermission(AppPermission.auditLogsView), isTrue);
    });

    test('Country and Branch CRUD and toggle status', () {
      final initialCount = state.countries.length;
      final newCountry = CountryModel(
        code: 'BH',
        name: 'Bahrain',
        nameAr: 'مملكة البحرين',
        flag: '🇧🇭',
        currencyCode: 'BHD',
        currencySymbol: 'BD',
        currencySymbolAr: 'د.ب',
        exchangeRateToQar: 9.68,
        hqAddress: 'Diplomatic Area, Manama',
        primaryContactPhone: '+973 1700 0001',
        primaryContactEmail: 'ops.bahrain@uniwash.bh',
        createdAt: DateTime.now(),
        branches: [
          BranchModel(
            id: 'branch-bh-01',
            code: 'MNA-01',
            name: 'Manama Central Hub',
            nameAr: 'فرع المنامة المركزي',
            countryCode: 'BH',
            city: 'Manama',
            address: 'Government Ave, Manama',
            phone: '+973 1700 0001',
            email: 'manama@uniwash.bh',
            managerName: 'Zainab Al-Majed',
            createdAt: DateTime.now(),
          ),
        ],
      );

      state.addCountry(newCountry);
      expect(state.countries.length, initialCount + 1);

      // Toggle country operational status
      state.toggleCountryStatus('BH');
      final fetched = state.countries.firstWhere((c) => c.code == 'BH');
      expect(fetched.isActive, isFalse);

      // Toggle branch operational status
      state.toggleBranchStatus('branch-bh-01');
      final branch = state.countries.firstWhere((c) => c.code == 'BH').branches.first;
      expect(branch.isActive, isFalse);
    });

    test('Admin user management with RBAC permission controls', () {
      final admin = AdminUserModel(
        id: 'adm-test-doha',
        fullName: 'Doha Branch Operations Supervisor',
        email: 'doha.ops@uniwash.qa',
        phone: '+974 5500 9999',
        countryCode: 'QAT',
        assignedBranchIds: ['branch-qat-01'],
        permissions: {
          AppPermission.ordersView,
          AppPermission.ordersCorrectStatus,
          AppPermission.driversView,
        },
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      state.addAdmin(admin);
      final found = state.admins.firstWhere((a) => a.id == 'adm-test-doha');
      expect(found.hasPermission(AppPermission.ordersCorrectStatus), isTrue);
      expect(found.hasPermission(AppPermission.adminsCreate), isFalse);

      // Toggle active status
      state.toggleAdminStatus('adm-test-doha');
      expect(state.admins.firstWhere((a) => a.id == 'adm-test-doha').isActive, isFalse);
    });

    test('Controlled order corrections write immutable audit logs', () {
      final initialLogsCount = state.auditLogs.length;

      // 1. Correct order status
      final order = state.orders.first;
      final originalStatus = order.status;
      const targetStatus = OrderStatus.inLaundry;

      final statusSuccess = state.correctOrderStatus(
        order.id,
        targetStatus,
        reason: 'Laundry wash drum restarted, processing commenced manually.',
      );

      expect(statusSuccess, isTrue);
      final updatedOrder = state.orders.firstWhere((o) => o.id == order.id);
      expect(updatedOrder.status, targetStatus);
      expect(state.auditLogs.length, initialLogsCount + 1);

      final latestLog = state.auditLogs.first;
      expect(latestLog.actionType, AuditActionType.orderStatusCorrected);
      expect(latestLog.previousValue, originalStatus.name);
      expect(latestLog.newValue, targetStatus.name);

      // 2. Override QR state
      final qrSuccess = state.overrideOrderQrState(
        order.id,
        isScanned: true,
        reason: 'Driver camera hardware failure at client villa door.',
      );

      expect(qrSuccess, isTrue);
      expect(state.auditLogs.first.actionType, AuditActionType.qrStateCorrected);
      expect(state.auditLogs.first.reason.contains('failure'), isTrue);

      // 3. Reassign Driver
      final driverSuccess = state.reassignOrderDriver(
        order.id,
        state.drivers.first.id,
        reason: 'Driver route optimized due to highway construction delay.',
      );

      expect(driverSuccess, isTrue);
      expect(state.auditLogs.first.actionType, AuditActionType.orderDriverReassigned);

      // 4. Reopen order
      final reopenSuccess = state.reopenOrder(
        order.id,
        reason: 'Client requested steam re-pressing for silk garments.',
      );

      expect(reopenSuccess, isTrue);
      expect(state.auditLogs.first.actionType, AuditActionType.orderReopened);
      expect(state.orders.firstWhere((o) => o.id == order.id).status, OrderStatus.inLaundry);
    });

    test('Order Problem exception tracking and resolution', () {
      expect(state.orderProblems.isNotEmpty, isTrue);
      final problem = state.orderProblems.firstWhere((p) => !p.isResolved);

      expect(problem.isResolved, isFalse);

      state.resolveOrderProblem(
        problem.id,
        action: 'Manual QR verification cleared and moved forward in queue',
        notes: 'Doorbell camera footage confirmed driver in-person pickup',
      );

      final resolved = state.orderProblems.firstWhere((p) => p.id == problem.id);
      expect(resolved.isResolved, isTrue);
      expect(resolved.resolvedBy, isNotNull);
      expect(resolved.resolutionNotes, 'Doorbell camera footage confirmed driver in-person pickup');
      expect(state.auditLogs.first.actionType, AuditActionType.problemResolved);
    });
  });
}
