import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/state_service.dart';
import 'theme/app_theme.dart';
import 'screens/portal_switcher_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StateService()),
      ],
      child: const UniWashApp(),
    ),
  );
}

class UniWashApp extends StatelessWidget {
  const UniWashApp({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<StateService>();
    return MaterialApp(
      title: 'UniWash Laundry & Dry Cleaning Platform',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getDynamicTheme(state.currentOccasionTheme),
      home: const PortalSwitcherScreen(),
    );
  }
}
