import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';
import 'Styles/styles.dart';
import 'Login.dart';
import 'sesion.dart';
import 'Admin/NavegacionAdmin.dart';
import 'Cliente/NavegacionCliente.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
        colorScheme: ColorScheme.fromSeed(seedColor: AppColores.cafeOscuro),
        useMaterial3: true,
      ),
      home: const VerificarSesion(),
    );
  }
}

class VerificarSesion extends StatefulWidget {
  const VerificarSesion({super.key});

  @override
  State<VerificarSesion> createState() => _VerificarSesionState();
}

class _VerificarSesionState extends State<VerificarSesion> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const PantallaCarga();
        }

        if (snapshot.hasError) {
          return const Login();
        }

        final usuarioFirebase = snapshot.data;

        if (usuarioFirebase == null) {
          Sesion.cerrar();
          return const Login();
        }

        return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          key: ValueKey(usuarioFirebase.uid),
          future: FirebaseFirestore.instance
              .collection('usuarios')
              .doc(usuarioFirebase.uid)
              .get(),
          builder: (context, perfilSnapshot) {
            if (perfilSnapshot.connectionState == ConnectionState.waiting) {
              return const PantallaCarga();
            }

            if (perfilSnapshot.hasError) {
              return const PantallaErrorSesion();
            }

            final documento = perfilSnapshot.data;

            if (documento == null ||
                !documento.exists ||
                documento.data() == null) {
              return const PantallaErrorSesion();
            }

            final datos = documento.data()!;
            final rol = datos['rol']?.toString() ?? '';

            if (rol != 'admin' && rol != 'cliente') {
              return const PantallaErrorSesion();
            }

            Sesion.iniciar({...datos, 'uid': usuarioFirebase.uid});

            if (rol == 'admin') {
              return const Navegacionadmin();
            }

            return const NavegacionCliente();
          },
        );
      },
    );
  }
}

class PantallaCarga extends StatelessWidget {
  const PantallaCarga({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColores.cremaClaro,
      body: Center(
        child: CircularProgressIndicator(color: AppColores.cafeOscuro),
      ),
    );
  }
}

class PantallaErrorSesion extends StatelessWidget {
  const PantallaErrorSesion({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColores.cremaClaro,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: AppColores.cafeOscuro,
                size: 55,
              ),
              const SizedBox(height: 15),
              const Text(
                'No pudimos cargar tu perfil',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColores.textoPrincipal,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Comprueba tu conexión o vuelve '
                'a iniciar sesión.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: () async {
                  await Sesion.cerrarSesion();
                },
                child: const Text('Cerrar sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
