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

      body: Container(
        width: double.infinity,
        height: double.infinity,

        // ==========================================
        // FONDO DEGRADADO
        // ==========================================
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColores.blanco,
              AppColores.cremaClaro,
              AppColores.crema,
            ],
            stops: [0.0, 0.55, 1.0],
          ),
        ),

        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Text(
                  'Mis Favoritos',
                  style: TextStyle(
                    fontSize: 28,
                    height: 1,
                    fontWeight: FontWeight.w800,
                    color: AppColores.textoPrincipal,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: favoritos.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 35),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 85,
                                height: 85,
                                decoration: BoxDecoration(
                                  color: AppColores.beige.withOpacity(0.75),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.favorite_border_rounded,
                                  size: 42,
                                  color: AppColores.cafeOscuro,
                                ),
                              ),

                              const SizedBox(height: 17),

                              const Text(
                                'Aún no tienes favoritos',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColores.textoPrincipal,
                                ),
                              ),

                              const SizedBox(height: 6),

                              const Text(
                                'Guarda los productos que más te gusten.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColores.textoSecundario,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 3, 20, 30),
                        itemCount: favoritos.length,
                        itemBuilder: (context, index) {
                          final producto = favoritos[index];
                          final String imagen =
                              producto['imagen']?.toString() ?? '';
                          final String nombre =
                              producto['nombre']?.toString() ?? 'Producto';
                          final String descripcion =
                              producto['descripcion']?.toString() ?? '';
                          return Container(
                            height: 125,
                            margin: const EdgeInsets.only(bottom: 13),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColores.beige.withOpacity(0.75),
                                width: 0.8,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColores.cafeOscuro.withOpacity(
                                    0.07,
                                  ),
                                  blurRadius: 12,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),

                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.horizontal(
                                    left: Radius.circular(20),
                                  ),
                                  child: SizedBox(
                                    width: 120,
                                    height: double.infinity,
                                    child: imagen.isNotEmpty
                                        ? Image.asset(
                                            imagen,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                                  return Container(
                                                    color: AppColores.beige,
                                                    child: const Icon(
                                                      Icons.local_cafe_rounded,
                                                      size: 45,
                                                      color:
                                                          AppColores.cafeOscuro,
                                                    ),
                                                  );
                                                },
                                          )
                                        : Container(
                                            color: AppColores.beige,
                                            child: const Icon(
                                              Icons.local_cafe_rounded,
                                              size: 45,
                                              color: AppColores.cafeOscuro,
                                            ),
                                          ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      13,
                                      11,
                                      8,
                                      11,
                                    ),

                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                nombre,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w800,
                                                  color:
                                                      AppColores.textoPrincipal,
                                                ),
                                              ),
                                            ),

                                            const SizedBox(width: 5),

                                            const Icon(
                                              Icons.favorite_rounded,
                                              color: AppColores.cafeMedio,
                                              size: 20,
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 4),

                                        // DESCRIPCIÓN
                                        if (descripcion.isNotEmpty)
                                          Text(
                                            descripcion,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppColores.textoSecundario,
                                            ),
                                          ),

                                        const Spacer(),

                                        // PRECIO + ELIMINAR
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                '\$${producto['precio']} MXN',
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w800,
                                                  color: AppColores.cafeOscuro,
                                                ),
                                              ),
                                            ),

                                            // =========================
                                            // BASURITA
                                            // =========================
                                            Material(
                                              color: AppColores.crema,
                                              shape: const CircleBorder(),
                                              child: InkWell(
                                                customBorder:
                                                    const CircleBorder(),

                                                onTap: () {
                                                  eliminar(producto['id']);
                                                },

                                                child: const SizedBox(
                                                  width: 37,
                                                  height: 37,

                                                  child: Icon(
                                                    Icons
                                                        .delete_outline_rounded,
                                                    size: 20,
                                                    color:
                                                        AppColores.cafeOscuro,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
