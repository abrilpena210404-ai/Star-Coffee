import 'package:flutter/material.dart';
import '../Styles/Styles.dart';
import '../basedatos/database_helper.dart';

//CATEGORIAS ADMINISTRADOR CRUD
class CategoriasAdmin extends StatefulWidget {
  const CategoriasAdmin({super.key});
  @override
  State<CategoriasAdmin> createState() => _CategoriasAdminState();
}

class _CategoriasAdminState extends State<CategoriasAdmin> {
  List<Map<String, dynamic>> categorias = [];
  List<Map<String, dynamic>> usuarios = [];

  @override
  void initState() {
    super.initState();
    cargarCategorias();
    cargarUsuarios();
  }

  Future<void> cargarCategorias() async {
    final datos = await DatabaseHelper.instancia.obtenerCategorias();
    if (!mounted) return;
    setState(() {
      categorias = datos;
    });
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

  Future<void> agregarCategoria() async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColores.cremaClaro,
          title: const Text(
            'Nueva categoría',
            style: TextStyle(
              color: AppColores.cafeOscuro,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Nombre categoría'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColores.cafeOscuro,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                if (controller.text.trim().isEmpty) {
                  return;
                }
                await DatabaseHelper.instancia.agregarCategoria(
                  controller.text.trim(),
                );
                Navigator.pop(context);
                cargarCategorias();
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> eliminarCategoria(int id) async {
    await DatabaseHelper.instancia.eliminarCategoria(id);
    cargarCategorias();
  }

  Future<void> editarCategoria(Map<String, dynamic> categoria) async {
    final nombre = TextEditingController(text: categoria['nombre']);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColores.cremaClaro,
          title: const Text(
            'Editar categoría',
            style: TextStyle(
              color: AppColores.cafeOscuro,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: nombre,
            decoration: const InputDecoration(labelText: 'Nombre'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColores.cafeOscuro,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                await DatabaseHelper.instancia.actualizarCategoria(
                  id: categoria['id'],
                  nombre: nombre.text,
                );
                Navigator.pop(context);
                cargarCategorias();
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
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
          'Categorías',
          style: TextStyle(
            color: AppColores.textoPrincipal,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColores.cafeOscuro,
        foregroundColor: Colors.white,
        onPressed: agregarCategoria,
        child: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =========================
            // CATEGORÍAS
            // =========================
            const Text(
              'Categorías',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColores.textoPrincipal,
              ),
            ),
            const SizedBox(height: 15),
            categorias.isEmpty
                ? const Text(
                    'No hay categorías',
                    style: TextStyle(color: AppColores.cafeOscuro),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: categorias.length,
                    itemBuilder: (context, index) {
                      final categoria = categorias[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        padding: const EdgeInsets.all(18),
                        decoration: AppEstilos.tarjeta(),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: AppColores.beige,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Icon(
                                Icons.category,
                                color: AppColores.cafeOscuro,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Text(
                                categoria['nombre'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                editarCategoria(categoria);
                              },
                              icon: const Icon(
                                Icons.edit_outlined,
                                color: AppColores.cafeOscuro,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                eliminarCategoria(categoria['id']);
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

            const SizedBox(height: 35),

            // =========================
            // USUARIOS
            // =========================
            const Text(
              'Usuarios registrados',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColores.textoPrincipal,
              ),
            ),
            const SizedBox(height: 15),
            usuarios.isEmpty
                ? const Text(
                    'No hay usuarios registrados',
                    style: TextStyle(color: AppColores.cafeOscuro),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
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
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: AppColores.beige,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Icon(
                                Icons.person,
                                color: AppColores.cafeOscuro,
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
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                    ),
                                  ),
                                  Text(
                                    usuario['correo'],
                                    style: AppEstilos.subtitulo,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () async {
                                await DatabaseHelper.instancia.eliminarUsuario(
                                  usuario['id'],
                                );
                                cargarUsuarios();
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
          ],
        ),
      ),
    );
  }
}
