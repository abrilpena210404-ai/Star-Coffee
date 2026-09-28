import 'package:star_coffee/Admin/InicioAdmin.dart';
import 'package:flutter/material.dart';
import 'package:star_coffee/Cliente/NavegacionCliente.dart';
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
          MaterialPageRoute(builder: (_) => const NavegacionCliente()),
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
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColores.cremaClaro,
      body: Stack(
        children: [
          // =========================
          // FONDO GENERAL
          // =========================
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFFBF7), Color(0xFFF8F1E8)],
              ),
            ),
          ),

          // =========================
          // DECORACIÓN INFERIOR
          // =========================
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: IgnorePointer(
              child: Container(
                height: 190,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColores.crema.withOpacity(0.0),
                      AppColores.beige.withOpacity(0.28),
                      AppColores.cafeClaro.withOpacity(0.18),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // CÍRCULO DECORATIVO INFERIOR IZQUIERDO
          Positioned(
            left: -70,
            bottom: -65,
            child: IgnorePointer(
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColores.cafeClaro.withOpacity(0.10),
                ),
              ),
            ),
          ),

          // CÍRCULO DECORATIVO INFERIOR DERECHO
          Positioned(
            right: -50,
            bottom: -80,
            child: IgnorePointer(
              child: Container(
                width: 190,
                height: 190,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColores.cafeMedio.withOpacity(0.07),
                ),
              ),
            ),
          ),

          // GRANOS DECORATIVOS - ESQUINA INFERIOR IZQUIERDA
          Positioned(
            left: -55,
            bottom: -25,
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.22,
                child: Image.asset(
                  'assets/images/Cafe.png',
                  width: 175,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // GRANOS DECORATIVOS - ESQUINA INFERIOR DERECHA
          Positioned(
            right: -60,
            bottom: -35,
            child: IgnorePointer(
              child: Transform.rotate(
                angle: -0.35,
                child: Opacity(
                  opacity: 0.18,
                  child: Image.asset(
                    'assets/images/cafe_granos.png',
                    width: 190,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),

          // =========================
          // CONTENIDO
          // =========================
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 18),

                    // =========================
                    // LOGO
                    // =========================
                    Container(
                      width: 245,
                      height: 245,
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFFFF9F2),
                        border: Border.all(
                          color: AppColores.beige.withOpacity(0.8),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColores.cafeOscuro.withOpacity(0.10),
                            blurRadius: 25,
                            spreadRadius: 2,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/Logo_1.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppColores.beige,
                              child: const Icon(
                                Icons.local_cafe_rounded,
                                size: 90,
                                color: AppColores.cafeOscuro,
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // =========================
                    // TÍTULO
                    // =========================
                    const Text(
                      'Iniciar Sesión',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 34,
                        height: 1,
                        fontWeight: FontWeight.w800,
                        color: AppColores.textoPrincipal,
                        letterSpacing: -0.8,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'Tu café favorito te espera.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColores.textoSecundario,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // =========================
                    // CORREO
                    // =========================
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(17),
                        boxShadow: [
                          BoxShadow(
                            color: AppColores.cafeOscuro.withOpacity(0.05),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: correoController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'Correo electrónico',
                          hintStyle: const TextStyle(
                            color: AppColores.textoSecundario,
                            fontSize: 15,
                          ),
                          prefixIcon: const Icon(
                            Icons.person_outline_rounded,
                            color: AppColores.cafeOscuro,
                            size: 24,
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.90),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 18,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(17),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(17),
                            borderSide: BorderSide(
                              color: AppColores.beige.withOpacity(0.9),
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(17),
                            borderSide: const BorderSide(
                              color: AppColores.cafeMedio,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // =========================
                    // CONTRASEÑA
                    // =========================
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(17),
                        boxShadow: [
                          BoxShadow(
                            color: AppColores.cafeOscuro.withOpacity(0.05),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: passwordController,
                        obscureText: ocultarPassword,
                        decoration: InputDecoration(
                          hintText: 'Contraseña',
                          hintStyle: const TextStyle(
                            color: AppColores.textoSecundario,
                            fontSize: 15,
                          ),
                          prefixIcon: const Icon(
                            Icons.lock_outline_rounded,
                            color: AppColores.cafeOscuro,
                            size: 23,
                          ),
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
                              size: 22,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.90),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 18,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(17),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(17),
                            borderSide: BorderSide(
                              color: AppColores.beige.withOpacity(0.9),
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(17),
                            borderSide: const BorderSide(
                              color: AppColores.cafeMedio,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // =========================
                    // BOTÓN ENTRAR
                    // =========================
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [Color(0xFF4A210F), Color(0xFF6D371C)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColores.cafeOscuro.withOpacity(0.22),
                            blurRadius: 15,
                            offset: const Offset(0, 7),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: iniciarSesion,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: const Text(
                          'Entrar',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // =========================
                    // REGISTRO
                    // =========================
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 1,
                            color: AppColores.cafeClaro.withOpacity(0.45),
                          ),
                        ),

                        const SizedBox(width: 12),

                        const Text(
                          '¿No tienes cuenta?',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColores.textoSecundario,
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Container(
                            height: 1,
                            color: AppColores.cafeClaro.withOpacity(0.45),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const Registro()),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppColores.cafeOscuro,
                      ),
                      child: const Text(
                        'Regístrate aquí',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // =========================
                    // FRASE INFERIOR
                    // =========================
                    Text(
                      'Más que café, una experiencia',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                        color: AppColores.cafeMedio.withOpacity(0.85),
                        letterSpacing: 0.3,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Container(
                      width: 28,
                      height: 2,
                      decoration: BoxDecoration(
                        color: AppColores.cafeOscuro.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),

                    const SizedBox(height: 35),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
