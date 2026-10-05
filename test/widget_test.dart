import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:uniwash_laundry/main.dart';
import 'package:uniwash_laundry/services/state_service.dart';

void main() {
  testWidgets('UniWash smoke test boots without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => StateService()),
        ],
        child: const UniWashApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Deliver to'), findsOneWidget);
  });
}
