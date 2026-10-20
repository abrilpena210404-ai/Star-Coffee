import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../Styles/Styles.dart';

class UsuariosAdmin extends StatefulWidget {
  const UsuariosAdmin({super.key});

  @override
  State<UsuariosAdmin> createState() => _UsuariosAdminState();
}

class _UsuariosAdminState extends State<UsuariosAdmin> {
  static const String _api =
      'https://star-coffee-api.abrilpena210404.workers.dev';
  final Set<String> _eliminando = {};

  Future<void> eliminarUsuario(String uid, String nombre) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColores.cremaClaro,
        title: const Text('Eliminar cliente'),
        content: Text(
          '¿Eliminar definitivamente la cuenta de $nombre? Esta acción no se puede deshacer. Los pedidos históricos se conservarán.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Sí, eliminar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (confirmar != true || !mounted || _eliminando.contains(uid)) return;
    setState(() => _eliminando.add(uid));
    try {
      final usuario = FirebaseAuth.instance.currentUser;
      if (usuario == null) throw Exception('Inicia sesión como administrador.');
      final token = await usuario.getIdToken();
      if (token == null || token.isEmpty)
        throw Exception('No se pudo validar tu sesión.');
      final respuesta = await http
          .post(
            Uri.parse('$_api/usuarios/${Uri.encodeComponent(uid)}/eliminar'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 30));
      Map<String, dynamic> datos = {};
      try {
        final json = jsonDecode(respuesta.body);
        if (json is Map) datos = Map<String, dynamic>.from(json);
      } catch (_) {}
      if (respuesta.statusCode != 200 || datos['ok'] != true) {
        throw Exception(
          datos['mensaje']?.toString() ??
              'No se pudo eliminar el cliente (HTTP ${respuesta.statusCode}).',
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cliente eliminado correctamente')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _eliminando.remove(uid));
    }
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
        stream: FirebaseFirestore.instance
            .collection('usuarios')
            .where('rol', isEqualTo: 'cliente')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'No se pudieron cargar los clientes. Verifica los permisos de Firestore.',
                textAlign: TextAlign.center,
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: AppColores.cafeOscuro),
            );
          }
          final usuarios = snapshot.data!.docs;
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
              final doc = usuarios[index];
              final usuario = doc.data();
              final nombre = usuario['nombre']?.toString() ?? 'Sin nombre';
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
                            usuario['correo']?.toString() ?? 'Sin correo',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppEstilos.subtitulo,
                          ),
                          Text(
                            usuario['telefono']?.toString() ?? 'Sin teléfono',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppEstilos.subtitulo,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Eliminar cliente',
                      onPressed: _eliminando.contains(doc.id)
                          ? null
                          : () => eliminarUsuario(doc.id, nombre),
                      icon: _eliminando.contains(doc.id)
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.delete_outline, color: Colors.red),
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
