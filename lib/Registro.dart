import 'package:flutter/material.dart';
import '../Styles/styles.dart';
import 'package:star_coffee/basedatos/database_helper.dart';
import 'Login.dart';

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
  bool aceptaTerminos = false;
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
    final nombre = nombreController.text.trim();
    final correo = correoController.text.trim();
    final telefono = telefonoController.text.trim();
    final password = passwordController.text.trim();
    final confirmar = confirmarPasswordController.text.trim();

    if (nombre.isEmpty ||
        correo.isEmpty ||
        telefono.isEmpty ||
        password.isEmpty ||
        confirmar.isEmpty) {
      mostrarMensaje('Completa todos los campos');
      return;
    }

    if (password != confirmar) {
      mostrarMensaje('Las contraseñas no coinciden');
      return;
    }

    if (password.length < 6) {
      mostrarMensaje('La contraseña debe tener mínimo 6 caracteres');
      return;
    }

    if (!aceptaTerminos) {
      mostrarMensaje('Debes aceptar los términos y condiciones');
      return;
    }

    try {
      setState(() {
        cargando = true;
      });

      final existe = await DatabaseHelper.instancia.correoExiste(correo);

      if (existe) {
        mostrarMensaje('Este correo ya está registrado');
        return;
      }
      await DatabaseHelper.instancia.registrarUsuario(
        nombre: nombre,
        correo: correo,
        telefono: telefono,
        password: password,
      );
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cuenta creada correctamente')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Login()),
      );
    } catch (e) {
      print('ERROR AL REGISTRAR: $e');
      if (!mounted) return;
      mostrarMensaje('Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          cargando = false;
        });
      }
    }
  }

  void mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColores.crema,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                'Crear Cuenta',
                style: AppEstilos.tituloPrincipal,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),

              const Text(
                'Únete a la experiencia Star Coffee.',
                style: AppEstilos.subtitulo,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              TextField(
                controller: nombreController,
                textCapitalization: TextCapitalization.words,
                decoration: AppEstilos.inputDecoration(
                  hint: 'Nombre completo',
                  icono: Icons.person_outline,
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: correoController,
                keyboardType: TextInputType.emailAddress,
                decoration: AppEstilos.inputDecoration(
                  hint: 'Correo electrónico',
                  icono: Icons.email_outlined,
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: telefonoController,
                keyboardType: TextInputType.phone,
                decoration: AppEstilos.inputDecoration(
                  hint: 'Teléfono',
                  icono: Icons.phone_outlined,
                ),
              ),

              const SizedBox(height: 15),

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

              const SizedBox(height: 15),

              TextField(
                controller: confirmarPasswordController,
                obscureText: ocultarConfirmarPassword,
                decoration: AppEstilos.inputDecoration(
                  hint: 'Confirmar contraseña',
                  icono: Icons.lock_outline,
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        ocultarConfirmarPassword = !ocultarConfirmarPassword;
                      });
                    },
                    icon: Icon(
                      ocultarConfirmarPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColores.cafeOscuro,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Checkbox(
                    value: aceptaTerminos,
                    activeColor: AppColores.cafeOscuro,
                    onChanged: (value) {
                      setState(() {
                        aceptaTerminos = value ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColores.textoPrincipal,
                        ),
                        children: [
                          TextSpan(text: 'Acepto '),
                          TextSpan(
                            text: 'términos y condiciones',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: cargando ? null : registrarUsuario,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColores.cafeOscuro,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child:
                      cargando
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
                            style: AppEstilos.textoBoton,
                          ),
                ),
              ),

              const SizedBox(height: 18),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '¿Ya tienes cuenta? ',
                    style: AppEstilos.subtitulo,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Inicia sesión',
                      style: AppEstilos.textoEnlace,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: AppColores.beige.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.card_giftcard_outlined,
                      color: AppColores.cafeOscuro,
                      size: 30,
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Recibe promociones, guarda favoritos y ordena más fácil.',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColores.textoPrincipal,
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_right, color: AppColores.cafeOscuro),
                  ],
                ),
              ),

              const SizedBox(height: 35),

              Text(
                'La vida sabe mejor\nen buena compañía ♥',
                textAlign: TextAlign.center,
                style: AppEstilos.subtitulo.copyWith(
                  color: AppColores.cafeMedio,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
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
