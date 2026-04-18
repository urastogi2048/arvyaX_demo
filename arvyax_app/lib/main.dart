import 'package:arvyax_app/data/models/journal_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'features/ambience/presentation/screens/home_screen.dart';
import 'shared/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(JournalEntryAdapter());
  await Hive.openBox<dynamic>('sessions');
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.resumed:
        _validateStoredSession();
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.inactive:
        break;
    }
  }

  Future<void> _validateStoredSession() async {
    try {
      final box = Hive.box<dynamic>('sessions');
      final sessionData = box.get('currentSession');
      if (sessionData != null) {
        final startedAt = DateTime.parse(sessionData['startedAt']);
        final elapsed = sessionData['elapsedSeconds'] ?? 0;
        final total = sessionData['totalSeconds'] ?? 0;
        final timePassed = DateTime.now().difference(startedAt).inSeconds;
        if (elapsed + timePassed >= total) {
          await box.delete('currentSession');
        }
      }
    } catch (e) {
      print('Error validating session: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'ArvyaX',
          theme: AppTheme.lightTheme(),
          home: const HomeScreen(),
        );
      },
    );
  }
}

