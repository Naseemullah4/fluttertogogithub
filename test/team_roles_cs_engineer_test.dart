import 'package:flutter_test/flutter_test.dart';
import 'package:uniwash_laundry/models/admin_team.dart';
import 'package:uniwash_laundry/models/driver.dart';
import 'package:uniwash_laundry/models/order.dart';
import 'package:uniwash_laundry/models/order_item.dart';
import 'package:uniwash_laundry/models/order_problem.dart';
import 'package:uniwash_laundry/models/system_bug.dart';
import 'package:uniwash_laundry/models/user.dart';
import 'package:uniwash_laundry/services/state_service.dart';

void main() {
  group(
    'Admin Team Roles, Customer Service & Engineering Diagnostics Tests',
    () {
      late StateService state;

      setUp(() {
        state = StateService();
      });

      test('Admin adds Company Driver (Corporate Fleet) vs Laundry Driver', () {
        final initialDriversCount = state.drivers.length;
        final initialTeamCount = state.teamMembers.length;

        // 1. Add Company Driver (Corporate Fleet - NOT for laundry)
        final companyDriver = DriverModel(
          id: 'drv-company-001',
          userId: 'DRV-CORP-901',
          systemPassword: 'CorpPass@2026',
          fullName: 'Rashid Al-Kuwari',
          phone: '+974 5555 1111',
          licenseNumber: 'QA-DL-99120',
          qidPassportNumber: '29363409988',
          assignedLaundryId: 'laundry-doha-01',
          assignedLaundryName: 'UniWash Pearl & Marina Branch',
          affiliation: DriverAffiliation.companyFleet,
          documents: DriverDocumentFolder(
            passportDocumentName: 'Passport_Corp.pdf',
            visaDocumentName: 'Visa_Corp.pdf',
            drivingLicenseDocumentName: 'License_Corp.pdf',
            qidDocumentName: 'QID_Corp.pdf',
            signedContractDocumentName: 'Contract_Corp.pdf',
            vehicleRegPlate: 'QA 10293',
            joinedAt: DateTime(2025, 1, 1),
          ),
        );
        state.addDriver(companyDriver);

        expect(state.drivers.length, initialDriversCount + 1);
        final addedCompanyDriver = state.drivers.firstWhere(
          (d) => d.id == 'drv-company-001',
        );
        expect(addedCompanyDriver.affiliation, DriverAffiliation.companyFleet);
        expect(addedCompanyDriver.affiliation.shortBadge, 'Company Fleet');
        expect(
          addedCompanyDriver.affiliation.fullTitle,
          contains('Company Driver'),
        );

        // 2. Add Laundry Driver (Dedicated to Partner Facility)
        final laundryDriver = DriverModel(
          id: 'drv-laundry-002',
          userId: 'DRV-LND-902',
          systemPassword: 'LndPass@2026',
          fullName: 'Tariq Mehmood',
          phone: '+974 6666 2222',
          licenseNumber: 'QA-DL-88219',
          qidPassportNumber: '29463401122',
          assignedLaundryId: state.laundries.first.id,
          assignedLaundryName: state.laundries.first.name,
          affiliation: DriverAffiliation.laundryDedicated,
          documents: DriverDocumentFolder(
            passportDocumentName: 'Passport_Lnd.pdf',
            visaDocumentName: 'Visa_Lnd.pdf',
            drivingLicenseDocumentName: 'License_Lnd.pdf',
            qidDocumentName: 'QID_Lnd.pdf',
            signedContractDocumentName: 'Contract_Lnd.pdf',
            vehicleRegPlate: 'QA 88392',
            joinedAt: DateTime(2025, 1, 1),
          ),
        );
        state.addDriver(laundryDriver);

        final addedLaundryDriver = state.drivers.firstWhere(
          (d) => d.id == 'drv-laundry-002',
        );
        expect(
          addedLaundryDriver.affiliation,
          DriverAffiliation.laundryDedicated,
        );
        expect(addedLaundryDriver.affiliation.shortBadge, 'Laundry Driver');
        expect(
          addedLaundryDriver.affiliation.fullTitle,
          contains('Laundry Driver'),
        );

        // 3. Add Team Members across all roles
        state.addTeamMember(
          TeamMemberModel(
            id: 'tm-eng-001',
            fullName: 'Eng. Sarah Al-Emadi',
            email: 'sarah.engineer@uniwash.com',
            phone: '+974 3333 4444',
            jobTitle: 'Lead Mobile & Backend Engineer',
            category: TeamCategory.engineer,
            countryCode: 'QAT',
            branchId: 'br-doha-main',
            branchName: 'Doha Central Hub',
            joinedAt: DateTime.now(),
          ),
        );

        state.addTeamMember(
          TeamMemberModel(
            id: 'tm-cs-001',
            fullName: 'Fatima Al-Sulaiti',
            email: 'fatima.support@uniwash.com',
            phone: '+974 4444 5555',
            jobTitle: 'Senior Customer Experience Specialist',
            category: TeamCategory.customerService,
            countryCode: 'QAT',
            branchId: 'br-doha-main',
            branchName: 'Doha Central Hub',
            joinedAt: DateTime.now(),
          ),
        );

        state.addTeamMember(
          TeamMemberModel(
            id: 'tm-staff-001',
            fullName: 'Bilal Ahmad',
            email: 'bilal.dispatch@uniwash.com',
            phone: '+974 7777 8888',
            jobTitle: 'Central Dispatch Coordinator',
            category: TeamCategory.officeStaff,
            countryCode: 'QAT',
            branchId: 'br-doha-main',
            branchName: 'Doha Central Hub',
            joinedAt: DateTime.now(),
          ),
        );

        state.addTeamMember(
          TeamMemberModel(
            id: 'tm-other-001',
            fullName: 'Suhail Qadri',
            email: 'suhail.consultant@uniwash.com',
            phone: '+974 8888 9999',
            jobTitle: 'Fleet Maintenance Inspector',
            category: TeamCategory.other,
            countryCode: 'QAT',
            branchId: 'br-doha-main',
            branchName: 'Doha Central Hub',
            joinedAt: DateTime.now(),
          ),
        );

        expect(state.teamMembers.length, initialTeamCount + 4);
        expect(
          state.teamMembers.any((m) => m.category == TeamCategory.engineer),
          isTrue,
        );
        expect(
          state.teamMembers.any(
            (m) => m.category == TeamCategory.customerService,
          ),
          isTrue,
        );
        expect(
          state.teamMembers.any((m) => m.category == TeamCategory.officeStaff),
          isTrue,
        );
        expect(
          state.teamMembers.any((m) => m.category == TeamCategory.other),
          isTrue,
        );
      });

      test('Customer Service full operations: Add manual order, reschedule, tags, check, contact, delete', () {
        // 1. Manual Order Intake
        final catalogItem = state.catalogItems.first;
        final newOrder = state.createManualOrder(
          customerName: 'Hassan Al-Jaber',
          customerPhone: '+974 5512 3456',
          address: const CustomerAddress(
            buildingNo: '24',
            streetNo: '12',
            zoneNo: '69',
            apartmentRoom: 'Apt 1204',
          ),
          laundryId: state.laundries.first.id,
          laundryName: state.laundries.first.name,
          items: [
            OrderItem(
              catalogItem: catalogItem,
              serviceType: ServiceType.washIron,
              quantity: 3,
            ),
          ],
          specialInstructions: 'Handle with delicate silk treatment',
          pickupDate: DateTime.now().add(const Duration(days: 1)),
          pickupSlot: '10:00 AM - 12:00 PM',
        );

        expect(state.orders.any((o) => o.id == newOrder.id), isTrue);
        expect(newOrder.customerName, 'Hassan Al-Jaber');
        expect(newOrder.items.fold(0, (sum, i) => sum + i.quantity), 3);

        // 2. Reschedule Order
        final newPickup = DateTime.now().add(const Duration(days: 2));
        final newDelivery = DateTime.now().add(const Duration(days: 4));
        final rescheduleSuccess = state.rescheduleOrder(
          newOrder.id,
          pickupDate: newPickup,
          pickupSlot: '02:00 PM - 04:00 PM',
          deliveryDate: newDelivery,
          deliverySlot: '06:00 PM - 08:00 PM',
          reason: 'Customer requested evening slot due to flight schedule.',
        );
        expect(rescheduleSuccess, isTrue);

        final rescheduledOrder = state.orders.firstWhere(
          (o) => o.id == newOrder.id,
        );
        expect(rescheduledOrder.scheduledPickupDate, newPickup);
        expect(rescheduledOrder.scheduledPickupSlot, '02:00 PM - 04:00 PM');
        expect(rescheduledOrder.scheduledDeliveryDate, newDelivery);

        // 3. Update tags and custom QR
        state.updateOrderTags(newOrder.id, [
          'VIP-01',
          'DELICATE-SILK',
          'EXPRESS',
        ]);
        state.overrideCustomQrTag(newOrder.id, 'UNI-QR-9901-VIP');

        final taggedOrder = state.orders.firstWhere((o) => o.id == newOrder.id);
        expect(taggedOrder.tags, contains('VIP-01'));
        expect(taggedOrder.tags.length, 3);
        expect(taggedOrder.customQrTag, 'UNI-QR-9901-VIP');

        // 4. Log Customer Contact & Order Checking
        state.logCustomerContact(
          newOrder.id,
          channel: 'WhatsApp Call',
          outcome: 'Verified with Customer',
          notes: 'Confirmed 3 pieces received in good condition, customer verified starch level.',
        );

        state.verifyOrderCheck(
          newOrder.id,
          checkNotes: 'All 3 Kanduras inspected. Zero stains or fabric tears.',
        );

        final checkedOrder = state.orders.firstWhere(
          (o) => o.id == newOrder.id,
        );
        expect(checkedOrder.isCustomerVerified, isTrue);
        expect(checkedOrder.isCountVerifiedByLaundry, isTrue);
        expect(
          checkedOrder.customerContactNotes.first,
          contains('Confirmed 3 pieces'),
        );

        // 5. Delete / Cancel Order
        final cancelSuccess = state.deleteOrder(
          newOrder.id,
          reason: 'Customer cancelled travel plan and rescheduled entire trip.',
        );
        expect(cancelSuccess, isTrue);

        final cancelledOrder = state.orders.firstWhere(
          (o) => o.id == newOrder.id,
        );
        expect(cancelledOrder.status, OrderStatus.cancelled);
        expect(
          cancelledOrder.cancellationRecord?.reason,
          contains('Customer cancelled travel plan'),
        );
      });

      test('Driver mistake tracking and Admin/CS resolution workflow', () {
        final initialProblemsCount = state.orderProblems.length;

        // 1. Report driver mistake problem
        final problem = OrderProblem(
          id: 'prb-mistake-99',
          orderId: state.orders.first.id,
          orderNumber: state.orders.first.orderNumber,
          customerName: state.orders.first.customerName,
          countryCode: 'QAT',
          branchName: 'Doha Central Hub',
          type: ProblemType.driverMistake,
          severity: ProblemSeverity.high,
          description: 'Driver picked up wrong garment bag from Villa 12 instead of Villa 14.',
          reportedAt: DateTime.now(),
          reportedBy: 'Customer Service Desk',
        );
        state.reportOrderProblem(problem);

        expect(state.orderProblems.length, initialProblemsCount + 1);
        expect(problem.isResolved, isFalse);
        expect(problem.type, ProblemType.driverMistake);

        // 2. Resolve problem from Admin / CS desk
        state.resolveOrderProblem(
          problem.id,
          action: 'Dispatched company fleet driver to swap bags within 20 mins',
          notes: 'Contacted customer, exchanged bags at villa entrance with apology token.',
        );

        final updatedProblem = state.orderProblems.firstWhere(
          (p) => p.id == problem.id,
        );
        expect(updatedProblem.isResolved, isTrue);
        expect(
          updatedProblem.correctedAction,
          contains('Dispatched company fleet driver'),
        );
      });

      test(
        'Dedicated Engineering portal: Bug reporting, diagnostics & resolution',
        () {
          final initialBugsCount = state.systemBugs.length;

          // 1. Report system bug
          final bug = SystemBug(
            id: 'bug-ble-991',
            title: 'Bluetooth Mobile Receipt Printer Timeout on Zebra ZQ521',
            description: 'Driver app encounters BLE disconnect during customer receipt printing on Android 14.',
            module: 'Bluetooth Printer Driver',
            severity: BugSeverity.critical,
            reportedBy: 'Driver Team Support Desk',
            reportedAt: DateTime.now(),
            stackTrace: 'PlatformException(BLE_DISCONNECT, GattStatus 133, ZebraBluetoothConnection.kt:182)',
            deviceInfo: 'Samsung Galaxy XCover 6 Pro (Android 14)',
          );
          state.reportBug(bug);

          expect(state.systemBugs.length, initialBugsCount + 1);
          expect(bug.status, BugStatus.open);
          expect(bug.severity, BugSeverity.critical);

          // 2. Engineer updates bug status to inProgress
          state.updateBugStatus(bug.id, BugStatus.inProgress);
          expect(
            state.systemBugs.firstWhere((b) => b.id == bug.id).status,
            BugStatus.inProgress,
          );

          // 3. Engineer fixes bug with resolution and patch notes
          state.resolveBug(
            bug.id,
            notes: 'Added BLE auto-reconnect retry policy with 300ms backoff in Flutter bluetooth channel.',
            commitRef: 'git-commit-ble-retry-fix-v284',
          );

          final fixedBug = state.systemBugs.firstWhere((b) => b.id == bug.id);
          expect(fixedBug.isResolved, isTrue);
          expect(fixedBug.fixCommitRef, 'git-commit-ble-retry-fix-v284');
          expect(fixedBug.resolvedAt, isNotNull);
        },
      );

      test('UserRole extension supports customerService and engineer', () {
        expect(
          UserRole.customerService.title,
          'Customer Support & Service Specialist',
        );
        expect(UserRole.customerService.shortName, 'Support / CS');
        expect(UserRole.engineer.title, 'Software & System QA Engineer');
        expect(UserRole.engineer.shortName, 'Engineer');

        state.switchRole(UserRole.customerService);
        expect(state.currentUser.role, UserRole.customerService);

        state.switchRole(UserRole.engineer);
        expect(state.currentUser.role, UserRole.engineer);
      });
    },
  );
}
