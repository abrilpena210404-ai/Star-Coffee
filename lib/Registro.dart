import 'package:flutter/material.dart';
import 'Styles/Styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Login.dart';
import 'package:flutter/services.dart';

class Registro extends StatefulWidget {
  const Registro({super.key});

  @override
  State<Registro> createState() => _RegistroState();
}

class _RegistroState extends State<Registro> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController correoController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmarPasswordController =
      TextEditingController();

  bool ocultarPassword = true;
  bool ocultarConfirmarPassword = true;
  bool cargando = false;

  @override
  void dispose() {
    nombreController.dispose();
    correoController.dispose();
    telefonoController.dispose();
    passwordController.dispose();
    confirmarPasswordController.dispose();
    super.dispose();
  }

  Future<void> registrarUsuario() async {
    if (cargando) return;

    final nombre = nombreController.text.trim().replaceAll(RegExp(r'\s+'), ' ');
    final correo = correoController.text.trim().toLowerCase();
    final telefono = telefonoController.text.trim();
    final password = passwordController.text;
    final confirmar = confirmarPasswordController.text;

    if ([
      nombre,
      correo,
      telefono,
      password,
      confirmar,
    ].any((valor) => valor.isEmpty)) {
      mostrarMensaje('Completa todos los campos');
      return;
    }
    if (nombre.length < 3 || nombre.length > 80) {
      mostrarMensaje('Ingresa un nombre válido (3 a 80 caracteres)');
      return;
    }
    final correoValido = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!correoValido.hasMatch(correo)) {
      mostrarMensaje('Ingresa un correo electrónico válido');
      return;
    }
    if (!RegExp(r'^\d{10}$').hasMatch(telefono)) {
      mostrarMensaje('Ingresa un teléfono de 10 dígitos');
      return;
    }
    if (password.length < 8 ||
        !RegExp(r'[A-Za-z]').hasMatch(password) ||
        !RegExp(r'\d').hasMatch(password) ||
        !RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=;/\\[\]~`]').hasMatch(password)) {
      mostrarMensaje(
        'La contraseña debe tener mínimo 8 caracteres, '
        'una letra, un número y un carácter especial '
        '(por ejemplo: @, #, ! o *).',
      );
      return;
    }

    if (password != confirmar) {
      mostrarMensaje('Las contraseñas no coinciden');
      return;
    }

    setState(() => cargando = true);

    User? cuentaCreada;
    bool perfilGuardado = false;
    String? aviso;
    try {
      final credencial = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: correo, password: password);
      cuentaCreada = credencial.user;
      if (cuentaCreada == null) {
        throw StateError('Firebase no devolvió la cuenta creada');
      }

      final uid = cuentaCreada.uid;
      await FirebaseFirestore.instance.collection('usuarios').doc(uid).set({
        'uid': uid,
        'nombre': nombre,
        'correo': correo,
        'telefono': telefono,
        'rol': 'cliente',
        'fechaRegistro': FieldValue.serverTimestamp(),
      });
      perfilGuardado = true;

      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      mostrarMensaje('Cuenta creada correctamente. Ahora inicia sesión.');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Login()),
      );
      return;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          aviso = 'Este correo ya está registrado';
          break;
        case 'invalid-email':
          aviso = 'Ingresa un correo válido';
          break;
        case 'weak-password':
          aviso = 'La contraseña es demasiado débil';
          break;
        case 'network-request-failed':
          aviso = 'Sin conexión a internet. Intenta nuevamente';
          break;
        case 'operation-not-allowed':
          aviso = 'El registro por correo no está habilitado';
          break;
        case 'too-many-requests':
          aviso = 'Demasiados intentos. Intenta más tarde';
          break;
        default:
          aviso = 'No se pudo registrar la cuenta (${e.code})';
      }
    } on FirebaseException catch (e) {
      aviso = 'No se pudieron guardar los datos (${e.code})';
    } catch (_) {
      aviso = 'Ocurrió un error al registrar la cuenta';
    } finally {
      // Si Auth creó una cuenta pero falló Firestore, evitamos en lo
      // posible dejar una cuenta sin perfil. Si no se puede eliminar,
      // se informa al usuario para que no vuelva a crearla a ciegas.
      if (cuentaCreada != null && !perfilGuardado) {
        try {
          await cuentaCreada.delete();
        } catch (_) {
          aviso =
              'La cuenta se creó, pero no se guardó el perfil. '
              'Contacta al administrador antes de intentar registrarte otra vez.';
        }
        try {
          await FirebaseAuth.instance.signOut();
        } catch (_) {}
      }
      if (mounted) {
        setState(() => cargando = false);
        if (aviso != null) mostrarMensaje(aviso);
      }
    }
  }

  void mostrarMensaje(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensaje)));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColores.cremaClaro,
      body: Stack(
        children: [
          // ==========================================
          // FONDO GENERAL
          // ==========================================
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

          // ==========================================
          // DEGRADADO DECORATIVO INFERIOR
          // ==========================================
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
                      AppColores.beige.withOpacity(0.30),
                      AppColores.cafeClaro.withOpacity(0.18),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // DECORACIÓN INFERIOR IZQUIERDA
          Positioned(
            left: -70,
            bottom: -70,
            child: IgnorePointer(
              child: Container(
                width: 190,
                height: 190,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColores.cafeClaro.withOpacity(0.10),
                ),
              ),
            ),
          ),

          // DECORACIÓN INFERIOR DERECHA
          Positioned(
            right: -65,
            bottom: -75,
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

          // ==========================================
          // CONTENIDO
          // ==========================================
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom -
                      40,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 5),

                    // ==========================================
                    // LOGO PEQUEÑO SUPERIOR
                    // ==========================================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.65),
                            border: Border.all(color: AppColores.beige),
                            boxShadow: [
                              BoxShadow(
                                color: AppColores.cafeOscuro.withOpacity(0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/Logo_1.jpg',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.local_cafe_rounded,
                                  size: 35,
                                  color: AppColores.cafeOscuro,
                                );
                              },
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Star Coffee',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                                color: AppColores.textoPrincipal,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    // ==========================================
                    // CONTENEDOR PRINCIPAL
                    // ==========================================
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(18, 25, 18, 25),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.75),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColores.cafeOscuro.withOpacity(0.05),
                            blurRadius: 25,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // ==================================
                          // TÍTULO
                          // ==================================
                          const Text(
                            'Crear Cuenta',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 32,
                              height: 1,
                              fontWeight: FontWeight.w800,
                              color: AppColores.textoPrincipal,
                              letterSpacing: -0.7,
                            ),
                          ),

                          const SizedBox(height: 9),

                          const Text(
                            'Únete a la experiencia de \nla mejor Cafetería',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              color: AppColores.textoSecundario,
                            ),
                          ),

                          const SizedBox(height: 26),

                          // ==================================
                          // NOMBRE
                          // ==================================
                          _campoRegistro(
                            controller: nombreController,
                            hint: 'Nombre completo',
                            icono: Icons.person_outline_rounded,
                            capitalization: TextCapitalization.words,
                          ),

                          const SizedBox(height: 13),

                          // ==================================
                          // CORREO
                          // ==================================
                          _campoRegistro(
                            controller: correoController,
                            hint: 'Correo electrónico',
                            icono: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),

                          const SizedBox(height: 13),

                          // ==================================
                          // TELÉFONO
                          // ==================================
                          _campoRegistro(
                            controller: telefonoController,
                            hint: 'Teléfono',
                            icono: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                          ),

                          const SizedBox(height: 13),

                          // ==================================
                          // CONTRASEÑA
                          // ==================================
                          _campoRegistro(
                            controller: passwordController,
                            hint: 'Contraseña',
                            icono: Icons.lock_outline_rounded,
                            obscureText: ocultarPassword,
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
                                size: 21,
                              ),
                            ),
                          ),

                          const SizedBox(height: 13),

                          // ==================================
                          // CONFIRMAR CONTRASEÑA
                          // ==================================
                          _campoRegistro(
                            controller: confirmarPasswordController,
                            hint: 'Confirmar contraseña',
                            icono: Icons.lock_outline_rounded,
                            obscureText: ocultarConfirmarPassword,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  ocultarConfirmarPassword =
                                      !ocultarConfirmarPassword;
                                });
                              },
                              icon: Icon(
                                ocultarConfirmarPassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppColores.cafeOscuro,
                                size: 21,
                              ),
                            ),
                          ),

                          const SizedBox(height: 23),

                          // ==================================
                          // BOTÓN CREAR CUENTA
                          // ==================================
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
                                  color: AppColores.cafeOscuro.withOpacity(
                                    0.20,
                                  ),
                                  blurRadius: 14,
                                  offset: const Offset(0, 7),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: cargando ? null : registrarUsuario,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                disabledBackgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: cargando
                                  ? const SizedBox(
                                      width: 23,
                                      height: 23,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.4,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Crear cuenta',
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 22),

                          // ==================================
                          // INICIAR SESIÓN
                          // ==================================
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                '¿Ya tienes cuenta? ',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColores.textoSecundario,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  'Inicia sesión',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColores.cafeOscuro,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 27),

                    // ==========================================
                    // FRASE FINAL
                    // ==========================================
                    Text(
                      'La vida sabe mejor\nen buena compañía',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.35,
                        fontStyle: FontStyle.italic,
                        color: AppColores.cafeMedio.withOpacity(0.85),
                      ),
                    ),

                    const SizedBox(height: 9),

                    Container(
                      width: 28,
                      height: 2,
                      decoration: BoxDecoration(
                        color: AppColores.cafeOscuro.withOpacity(0.65),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),

                    const SizedBox(height: 25),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CAMPO DE TEXTO PARA EL DISEÑO DEL REGISTRO
  // ============================================================
  Widget _campoRegistro({
    required TextEditingController controller,
    required String hint,
    required IconData icono,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool obscureText = false,
    Widget? suffixIcon,
    TextCapitalization capitalization = TextCapitalization.none,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: AppColores.cafeOscuro.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        obscureText: obscureText,
        textCapitalization: capitalization,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: AppColores.textoSecundario,
            fontSize: 15,
          ),
          prefixIcon: Icon(icono, color: AppColores.cafeOscuro, size: 23),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: Colors.white.withOpacity(0.93),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 17,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: BorderSide(
              color: AppColores.beige.withOpacity(0.90),
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
    );
  }
}
