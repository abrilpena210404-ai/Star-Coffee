import 'package:flutter/material.dart';
import '../Styles/styles.dart';
import 'Login.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

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