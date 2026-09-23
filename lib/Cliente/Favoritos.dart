import 'package:flutter/material.dart';
import '../Styles/Styles.dart';
import '../basedatos/database_helper.dart';

class FavoritosScreen extends StatefulWidget {
  final int usuarioId;
  const FavoritosScreen({super.key, required this.usuarioId});
  @override
  State<FavoritosScreen> createState() => _FavoritosScreenState();
}

class _FavoritosScreenState extends State<FavoritosScreen> {
  List<Map<String, dynamic>> favoritos = [];
  @override
  void initState() {
    super.initState();
    cargarFavoritos();
  }

  Future<void> cargarFavoritos() async {
    final datos = await DatabaseHelper.instancia.obtenerFavoritos(
      widget.usuarioId,
    );
    if (!mounted) return;
    setState(() {
      favoritos = datos;
    });
  }

  Future<void> eliminar(int id) async {
    await DatabaseHelper.instancia.eliminarFavorito(id);
    cargarFavoritos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColores.cremaClaro,
      appBar: AppBar(
        backgroundColor: AppColores.cremaClaro,
        elevation: 0,
        title: const Text(
          'Favoritos ❤️',
          style: TextStyle(
            color: AppColores.textoPrincipal,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: favoritos.isEmpty
          ? const Center(child: Text('No tienes favoritos todavía'))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: favoritos.length,
              itemBuilder: (context, index) {
                final producto = favoritos[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.all(15),
                  decoration: AppEstilos.tarjeta(),
                  child: ListTile(
                    leading: const Icon(Icons.favorite, color: Colors.red),
                    title: Text(producto['nombre']),
                    subtitle: Text('\$${producto['precio']}'),
                    trailing: IconButton(
                      onPressed: () {
                        eliminar(producto['id']);
                      },
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
