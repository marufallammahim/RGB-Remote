import 'package:flutter/material.dart';
import 'package:flutter_dropdown_alert/dropdown_alert.dart';

import 'application/navigation/app_router.dart';
import 'application/services/settings_service.dart';
import 'application/services/smart_control_sync_service.dart';
import 'core/config/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SettingsService().initialize();

  // Rebuild native Smart Controls data after fresh installs, app-data resets,
  // or APK updates that required reinstalling the app.
  try {
    await SmartControlSyncService.syncSelectedRemote();
  } catch (error, stackTrace) {
    debugPrint('Smart Control startup sync failed: $error');
    debugPrintStack(stackTrace: stackTrace);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: SettingsService().settingsNotifier,
      builder: (context, settings, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: settings.themeName == 'amoled'
              ? AppTheme.amoled
              : AppTheme.dark,
          builder: (context, child) => Stack(
            children: [
              if (child != null) child,
              DropdownAlert(),
            ],
          ),
          initialRoute: Routes.remote,
          onGenerateRoute: generatedRoutes,
        );
      },
    );
  }
}
