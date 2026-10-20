import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../Styles/Styles.dart';

class UsuariosAdmin extends StatefulWidget {
  const UsuariosAdmin({super.key});

  @override
  State<UsuariosAdmin> createState() => _UsuariosAdminState();
}

class _UsuariosAdminState extends State<UsuariosAdmin> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Obtener únicamente los clientes desde Firebase.
  Stream<QuerySnapshot<Map<String, dynamic>>> escucharUsuarios() {
    return _db
        .collection('usuarios')
        .where('rol', isEqualTo: 'cliente')
        .snapshots();
  }

  // La eliminación definitiva se implementará mediante
  // Cloudflare para proteger Firebase Authentication.
  void eliminarUsuario(String uid) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'La eliminación de cuentas requiere '
          'autorización segura desde Cloudflare.',
        ),
        duration: Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColores.cremaClaro,
      appBar: AppBar(
        backgroundColor: AppColores.cremaClaro,
        elevation: 0,
        title: const Text(
          'Usuarios',
          style: TextStyle(
            color: AppColores.textoPrincipal,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: escucharUsuarios(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'No se pudieron cargar los clientes. '
                  'Revisa los permisos de Firestore.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColores.cafeOscuro, fontSize: 16),
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: AppColores.cafeOscuro),
            );
          }

          final usuarios = snapshot.data?.docs ?? [];

          if (usuarios.isEmpty) {
            return const Center(
              child: Text(
                'No hay clientes registrados',
                style: TextStyle(color: AppColores.cafeOscuro, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: usuarios.length,
            itemBuilder: (context, index) {
              final documento = usuarios[index];
              final usuario = documento.data();

              final nombre = usuario['nombre']?.toString() ?? 'Sin nombre';
              final correo = usuario['correo']?.toString() ?? 'Sin correo';
              final telefono =
                  usuario['telefono']?.toString() ?? 'Sin teléfono';

              return Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.all(18),
                decoration: AppEstilos.tarjeta(),
                child: Row(
                  children: [
                    Container(
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(
                        color: AppColores.beige,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: AppColores.cafeOscuro,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nombre,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppColores.textoPrincipal,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            correo,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppEstilos.subtitulo,
                          ),
                          Text(
                            telefono,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppEstilos.subtitulo,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Eliminar usuario',
                      onPressed: () {
                        eliminarUsuario(documento.id);
                      },
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
