import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'Styles/styles.dart';
import 'Login.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const StarCoffeeApp());
}

class StarCoffeeApp extends StatelessWidget {
  const StarCoffeeApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Star Coffee',
      theme: ThemeData(
        scaffoldBackgroundColor: AppColores.cremaClaro,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColores.cafeOscuro,
        ),
        useMaterial3: true,
      ),
      home: const Login(),
    );
  }
}
