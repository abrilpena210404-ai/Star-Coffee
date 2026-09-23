import 'package:star_coffee/Admin/InicioAdmin.dart';
import 'package:star_coffee/Cliente/InicioCliente.dart';
import 'package:flutter/material.dart';
import 'package:star_coffee/Styles/Styles.dart';
import 'registro.dart';
import 'package:star_coffee/basedatos/database_helper.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController correoController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool ocultarPassword = true;

  @override
  void dispose() {
    correoController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> iniciarSesion() async {
    final correo = correoController.text.trim();
    final password = passwordController.text.trim();

    if (correo.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa tu correo y contraseña')),
      );
      return;
    }

    try {
      final usuario = await DatabaseHelper.instancia.iniciarSesion(
        correo,
        password,
      );
      if (!mounted) return;
      if (usuario == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Correo o contraseña incorrectos')),
        );
        return;
      }
      final rol = usuario['rol'];
      if (rol == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const InicioAdmin()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const InicioCliente()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ocurrió un error al iniciar sesión')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColores.crema,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 30),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // IMAGEN PRINCIPAL
              Container(
                width: 270,
                height: 270,
                decoration: BoxDecoration(
                  color: AppColores.beige,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/Logo_1.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.local_cafe,
                        size: 90,
                        color: AppColores.cafeOscuro,
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                'Iniciar Sesión',
                style: AppEstilos.tituloPrincipal,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 6),

              const Text(
                'Tu café favorito te espera.',
                style: AppEstilos.subtitulo,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              TextField(
                controller: correoController,
                keyboardType: TextInputType.emailAddress,
                decoration: AppEstilos.inputDecoration(
                  hint: 'Correo electrónico',
                  icono: Icons.person_outline,
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: passwordController,
                obscureText: ocultarPassword,
                decoration: AppEstilos.inputDecoration(
                  hint: 'Contraseña',
                  icono: Icons.lock_outline,
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        ocultarPassword = !ocultarPassword;
                      });
                    },
                    icon: Icon(
                      ocultarPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColores.cafeOscuro,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    iniciarSesion();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColores.cafeOscuro,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text('Entrar', style: AppEstilos.textoBoton),
                ),
              ),

              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Aquí después mandamos al inicio como invitado.
                  },
                  icon: const Icon(
                    Icons.coffee_outlined,
                    color: AppColores.cafeOscuro,
                  ),
                  label: const Text(
                    'Continuar como invitado',
                    style: TextStyle(
                      color: AppColores.cafeOscuro,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: AppColores.cafeOscuro,
                      width: 1.2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 26),

              Row(
                children: [
                  const Expanded(child: Divider(color: AppColores.beige)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      '¿No tienes cuenta?',
                      style: AppEstilos.subtitulo.copyWith(fontSize: 14),
                    ),
                  ),
                  const Expanded(child: Divider(color: AppColores.beige)),
                ],
              ),

              const SizedBox(height: 8),

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const Registro()),
                  );
                },
                child: const Text(
                  'Regístrate aquí',
                  style: AppEstilos.textoEnlace,
                ),
              ),

              const SizedBox(height: 25),

              Text(
                'Más que café, una experiencia',
                style: AppEstilos.subtitulo.copyWith(
                  fontStyle: FontStyle.italic,
                  color: AppColores.cafeMedio,
                ),
              ),
              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}
