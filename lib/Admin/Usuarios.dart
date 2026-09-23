import 'package:flutter/material.dart';
import '../Styles/Styles.dart';
import '../basedatos/database_helper.dart';

class UsuariosAdmin extends StatefulWidget {
  const UsuariosAdmin({super.key});

  @override
  State<UsuariosAdmin> createState() => _UsuariosAdminState();
}

class _UsuariosAdminState extends State<UsuariosAdmin> {
  List<Map<String, dynamic>> usuarios = [];

  @override
  void initState() {
    super.initState();
    cargarUsuarios();
  }

  Future<void> cargarUsuarios() async {
    final datos = await DatabaseHelper.instancia.obtenerUsuarios();
    final clientes = datos.where((usuario) {
      return usuario['rol'] == 'cliente';
    }).toList();
    if (!mounted) return;
    setState(() {
      usuarios = clientes;
    });
  }

  Future<void> eliminarUsuario(int id) async {
    final db = await DatabaseHelper.instancia.database;
    await db.delete('usuarios', where: 'id = ?', whereArgs: [id]);
    cargarUsuarios();
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

      body: usuarios.isEmpty
          ? const Center(
              child: Text(
                'No hay clientes registrados',
                style: TextStyle(color: AppColores.cafeOscuro, fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: usuarios.length,
              itemBuilder: (context, index) {
                final usuario = usuarios[index];
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
                              usuario['nombre'],
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: AppColores.textoPrincipal,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              usuario['correo'],
                              style: AppEstilos.subtitulo,
                            ),
                            Text(
                              usuario['telefono'],
                              style: AppEstilos.subtitulo,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          eliminarUsuario(usuario['id']);
                        },
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
