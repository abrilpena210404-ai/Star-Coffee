import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Styles/Styles.dart';

class MiPerfil extends StatefulWidget {
  const MiPerfil({super.key});

  @override
  State<MiPerfil> createState() => _MiPerfilState();
}

class _MiPerfilState extends State<MiPerfil> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  bool guardando = false;

  void mostrarMensaje(String mensaje) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: AppColores.cafeOscuro,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  String metodoAcceso(User usuario) {
    final proveedores = usuario.providerData
        .map((proveedor) => proveedor.providerId)
        .toList();

    if (proveedores.contains('google.com')) {
      return 'Google';
    }

    if (proveedores.contains('password')) {
      return 'Correo y contraseña';
    }

    return 'Otro método';
  }

  Future<void> editarDato({
    required String campo,
    required String titulo,
    required String valorActual,
  }) async {
    final usuario = _auth.currentUser;
    if (usuario == null || guardando) return;

    final esTelefono = campo == 'telefono';
    String nuevoValor = valorActual;
    String? error;
    bool procesando = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColores.cremaClaro,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              title: Text(
                titulo,
                style: const TextStyle(
                  color: AppColores.cafeOscuro,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: TextFormField(
                  initialValue: valorActual,
                  enabled: !procesando,
                  autofocus: true,
                  keyboardType: esTelefono
                      ? TextInputType.phone
                      : TextInputType.name,
                  textCapitalization: esTelefono
                      ? TextCapitalization.none
                      : TextCapitalization.words,
                  inputFormatters: esTelefono
                      ? [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ]
                      : [LengthLimitingTextInputFormatter(80)],
                  onChanged: (valor) {
                    nuevoValor = valor;
                    if (error != null) {
                      setDialogState(() => error = null);
                    }
                  },
                  decoration: AppEstilos.inputDecoration(
                    hint: esTelefono
                        ? 'Teléfono de 10 dígitos'
                        : 'Nombre completo',
                    icono: esTelefono
                        ? Icons.phone_outlined
                        : Icons.person_outline_rounded,
                  ).copyWith(errorText: error),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: procesando
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: AppColores.cafeOscuro),
                  ),
                ),
                ElevatedButton(
                  onPressed: procesando
                      ? null
                      : () async {
                          final valor = nuevoValor.trim().replaceAll(
                            RegExp(r'\s+'),
                            ' ',
                          );

                          if (esTelefono) {
                            if (!RegExp(r'^\d{10}$').hasMatch(valor)) {
                              setDialogState(() {
                                error = 'Ingresa un teléfono de 10 dígitos';
                              });
                              return;
                            }
                          } else {
                            if (valor.length < 3 || valor.length > 80) {
                              setDialogState(() {
                                error = 'Nombre de 3 a 80 caracteres';
                              });
                              return;
                            }
                          }

                          if (valor == valorActual) {
                            Navigator.of(dialogContext).pop();
                            return;
                          }

                          setDialogState(() {
                            procesando = true;
                            error = null;
                          });

                          try {
                            await _db
                                .collection('usuarios')
                                .doc(usuario.uid)
                                .update({campo: valor});

                            if (!dialogContext.mounted) return;

                            Navigator.of(dialogContext).pop();

                            if (!mounted) return;

                            mostrarMensaje(
                              esTelefono
                                  ? 'Teléfono actualizado correctamente'
                                  : 'Nombre actualizado correctamente',
                            );
                          } on FirebaseException catch (e) {
                            if (!dialogContext.mounted) return;

                            setDialogState(() {
                              procesando = false;
                              error = e.code == 'permission-denied'
                                  ? 'No tienes permiso para editar este dato'
                                  : 'No se pudo guardar el cambio';
                            });
                          } catch (e) {
                            if (!dialogContext.mounted) return;

                            setDialogState(() {
                              procesando = false;
                              error = 'Error al guardar. Intenta nuevamente';
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColores.cafeOscuro,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: procesando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget datoPerfil({
    required IconData icono,
    required String titulo,
    required String valor,
    String? campoEditable,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icono, color: AppColores.cafeOscuro, size: 24),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: AppColores.textoSecundario,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  valor.isEmpty ? 'Sin registrar' : valor,
                  style: const TextStyle(
                    color: AppColores.textoPrincipal,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          if (campoEditable != null)
            IconButton(
              tooltip: 'Editar $titulo',
              onPressed: guardando
                  ? null
                  : () => editarDato(
                      campo: campoEditable,
                      titulo: 'Editar $titulo',
                      valorActual: valor,
                    ),
              icon: const Icon(
                Icons.edit_outlined,
                color: AppColores.cafeOscuro,
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final usuario = _auth.currentUser;

    return Scaffold(
      backgroundColor: AppColores.cremaClaro,
      appBar: AppBar(
        backgroundColor: AppColores.cremaClaro,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColores.cafeOscuro),
        title: const Text(
          'Mi perfil',
          style: TextStyle(
            color: AppColores.textoPrincipal,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: usuario == null
          ? const Center(child: Text('Debes iniciar sesión'))
          : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: _db.collection('usuarios').doc(usuario.uid).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'No se pudo cargar tu perfil. Revisa tu conexión o permisos.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColores.cafeOscuro,
                    ),
                  );
                }

                if (!snapshot.data!.exists) {
                  return const Center(child: Text('No se encontró tu perfil.'));
                }

                final datos = snapshot.data!.data() ?? {};

                final nombre = datos['nombre']?.toString() ?? '';
                final telefono = datos['telefono']?.toString() ?? '';
                final correo =
                    datos['correo']?.toString() ?? usuario.email ?? '';

                return SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      children: [
                        const SizedBox(height: 15),

                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColores.crema,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColores.beige,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.person_outline_rounded,
                            size: 65,
                            color: AppColores.cafeOscuro,
                          ),
                        ),

                        const SizedBox(height: 15),

                        Text(
                          nombre.isEmpty ? 'Mi perfil' : nombre,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColores.cafeOscuro,
                          ),
                        ),

                        const SizedBox(height: 5),

                        const Text(
                          'Mi información personal',
                          style: AppEstilos.subtitulo,
                        ),

                        const SizedBox(height: 30),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: AppEstilos.tarjeta(),
                          child: Column(
                            children: [
                              datoPerfil(
                                icono: Icons.person_outline_rounded,
                                titulo: 'Nombre',
                                valor: nombre,
                                campoEditable: 'nombre',
                              ),

                              const Divider(color: AppColores.beige),

                              datoPerfil(
                                icono: Icons.phone_outlined,
                                titulo: 'Teléfono',
                                valor: telefono,
                                campoEditable: 'telefono',
                              ),

                              const Divider(color: AppColores.beige),

                              datoPerfil(
                                icono: Icons.email_outlined,
                                titulo: 'Correo electrónico',
                                valor: correo,
                              ),

                              const Divider(color: AppColores.beige),

                              datoPerfil(
                                icono: Icons.verified_user_outlined,
                                titulo: 'Método de acceso',
                                valor: metodoAcceso(usuario),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
