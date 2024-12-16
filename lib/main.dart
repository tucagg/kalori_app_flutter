import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:kalori/route/router.dart' as router;
import 'package:kalori/theme/app_theme.dart';
import 'package:kalori/route/route_constants.dart';

void main() async {
  // Flutter ile Firebase'i başlatmak için gerekli.
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase'i başlatıyoruz.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  String initialRoute = entryPointScreenRoute;
  // Uygulamayı çalıştırıyoruz.
  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kalori Uygulaması',
      theme: AppTheme.lightTheme(context),
      themeMode: ThemeMode.light,
      onGenerateRoute: router.generateRoute,
      initialRoute: initialRoute,
    );
  }
}
