import 'package:flutter/material.dart';
import 'package:star_coffee/Admin/NavegacionAdmin.dart';
import 'package:star_coffee/Cliente/NavegacionCliente.dart';
import 'package:star_coffee/Styles/Styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'registro.dart';
import 'sesion.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController correoController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool ocultarPassword = true;
  bool iniciandoConGoogle = false;

  @override
  void dispose() {
    correoController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> iniciarSesion() async {
    final correo = correoController.text.trim();
    final password = passwordController.text;

    if (correo.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa tu correo y contraseña')),
      );
      return;
    }

    try {
      // Autenticar usuario en Firebase
      final credencial = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: correo,
        password: password,
      );

      final uid = credencial.user!.uid;

      // Obtener los datos del usuario desde Firestore
      final documento = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .get();

      if (!documento.exists || documento.data() == null) {
        await FirebaseAuth.instance.signOut();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se encontró el perfil del usuario')),
        );
        return;
      }

      final usuario = documento.data()!;

      final rol = usuario['rol']?.toString() ?? '';

      if (rol != 'admin' && rol != 'cliente') {
        await FirebaseAuth.instance.signOut();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rol de usuario no válido')),
        );
        return;
      }

      // Guardar los datos de la sesión
      Sesion.iniciar({...usuario, 'uid': uid});

      if (!mounted) return;

      // Mantener la navegación original
      if (rol == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Navegacionadmin()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const NavegacionCliente()),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String mensaje = 'No se pudo iniciar sesión';

      if (e.code == 'invalid-email') {
        mensaje = 'Ingresa un correo válido';
      } else if (e.code == 'invalid-credential' ||
          e.code == 'wrong-password' ||
          e.code == 'user-not-found') {
        mensaje = 'Correo o contraseña incorrectos';
      } else if (e.code == 'too-many-requests') {
        mensaje = 'Demasiados intentos. Intenta más tarde';
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mensaje)));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ocurrió un error al iniciar sesión')),
      );
    }
  }

  // INICIO DE SESIÓN CON GOOGLE (google_sign_in 7.x).
  Future<void> iniciarSesionConGoogle() async {
    if (iniciandoConGoogle) return;
    setState(() => iniciandoConGoogle = true);

    try {
      final googleSignIn = GoogleSignIn.instance;
      await googleSignIn.initialize();

      // Muestra el selector de cuentas de Google en Android.
      final cuentaGoogle = await googleSignIn.authenticate();
      final autenticacionGoogle = cuentaGoogle.authentication;
      final idToken = autenticacionGoogle.idToken;
      if (idToken == null) {
        throw StateError('No se recibió el token de Google');
      }

      final credencialGoogle = GoogleAuthProvider.credential(idToken: idToken);
      final resultado = await FirebaseAuth.instance.signInWithCredential(
        credencialGoogle,
      );
      final usuarioFirebase = resultado.user;
      if (usuarioFirebase == null) {
        throw StateError('Firebase no devolvió un usuario');
      }

      final uid = usuarioFirebase.uid;
      final referencia = FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid);
      final documento = await referencia.get();
      Map<String, dynamic> datosUsuario;

      if (!documento.exists) {
        // Solo las cuentas NUEVAS se registran como clientes.
        // Los roles de cuentas existentes nunca se sobrescriben.
        datosUsuario = {
          'uid': uid,
          'nombre': usuarioFirebase.displayName ?? 'Cliente',
          'correo': usuarioFirebase.email ?? '',
          'telefono': '',
          'rol': 'cliente',
          'fechaRegistro': FieldValue.serverTimestamp(),
        };

        await referencia.set(datosUsuario);
        // El perfil local usa un valor concreto en lugar del sentinel.
        datosUsuario = {
          'uid': uid,
          'nombre': usuarioFirebase.displayName ?? 'Cliente',
          'correo': usuarioFirebase.email ?? '',
          'telefono': '',
          'rol': 'cliente',
        };
      } else {
        datosUsuario = documento.data() ?? {};
      }

      final rol = datosUsuario['rol']?.toString() ?? '';
      if (rol != 'admin' && rol != 'cliente') {
        throw StateError('El perfil tiene un rol no válido');
      }

      Sesion.iniciar({...datosUsuario, 'uid': uid});
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => rol == 'admin'
              ? const Navegacionadmin()
              : const NavegacionCliente(),
        ),
      );
    } on GoogleSignInException catch (e) {
      // Cerrar el selector no se considera error.
      if (e.code == GoogleSignInExceptionCode.canceled) return;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo acceder con Google: ${e.code.name}'),
        ),
      );
    } on FirebaseAuthException catch (e) {
      await FirebaseAuth.instance.signOut();
      Sesion.cerrar();
      if (!mounted) return;
      final mensaje = e.code == 'account-exists-with-different-credential'
          ? 'Este correo ya tiene otro método de acceso. Ingresa con el método original.'
          : 'No se pudo autenticar con Google: ${e.code}';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mensaje)));
    } catch (e) {
      // Evita dejar autenticado a alguien sin perfil validado.
      await FirebaseAuth.instance.signOut();
      Sesion.cerrar();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo completar el acceso con Google: $e'),
        ),
      );
    } finally {
      if (mounted) setState(() => iniciandoConGoogle = false);
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

                    const SizedBox(height: 16),

                    // ACCESO CON GOOGLE: no altera el botón Entrar.
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: OutlinedButton.icon(
                        onPressed: iniciandoConGoogle
                            ? null
                            : iniciarSesionConGoogle,
                        icon: iniciandoConGoogle
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.account_circle_outlined,
                                color: AppColores.cafeOscuro,
                              ),
                        label: Text(
                          iniciandoConGoogle
                              ? 'Conectando con Google...'
                              : 'Continuar con Google',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColores.cafeOscuro,
                          backgroundColor: Colors.white,
                          side: BorderSide(color: AppColores.beige),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(17),
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
