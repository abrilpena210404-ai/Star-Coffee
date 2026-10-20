import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Styles/Styles.dart';

/// Favoritos guardados en usuarios/{uid}/favoritos/{productoId}.
/// Conserva el diseño original y admite imágenes de assets o URL.
class FavoritosScreen extends StatelessWidget {
  const FavoritosScreen({super.key});

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  Future<void> _eliminar(
    BuildContext context,
    String uid,
    String favoritoId,
  ) async {
    try {
      await _db
          .collection('usuarios')
          .doc(uid)
          .collection('favoritos')
          .doc(favoritoId)
          .delete();
      // El StreamBuilder actualiza automáticamente la lista.
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo quitar el producto de favoritos.'),
        ),
      );
    }
  }

  Widget _imagen(String ruta) {
    final alternativa = Container(
      color: AppColores.beige,
      child: const Icon(
        Icons.local_cafe_rounded,
        size: 45,
        color: AppColores.cafeOscuro,
      ),
    );
    if (ruta.isEmpty) return alternativa;
    if (ruta.startsWith('https://') || ruta.startsWith('http://')) {
      return Image.network(
        ruta,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => alternativa,
      );
    }
    return Image.asset(
      ruta,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => alternativa,
    );
  }

  Widget _vacio() {
    return Center(
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
              style: TextStyle(fontSize: 13, color: AppColores.textoSecundario),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tarjeta(
    BuildContext context, {
    required String uid,
    required String favoritoId,
    required Map<String, dynamic> producto,
  }) {
    final imagen = producto['imagen']?.toString() ?? '';
    final nombre = producto['nombre']?.toString() ?? 'Producto';
    final descripcion = producto['descripcion']?.toString() ?? '';
    final precio = producto['precio'];
    final precioTexto = precio is num
        ? precio.toStringAsFixed(2)
        : (precio?.toString() ?? '0.00');

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
            color: AppColores.cafeOscuro.withOpacity(0.07),
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
              child: _imagen(imagen),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(13, 11, 8, 11),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          nombre,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColores.textoPrincipal,
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '\$$precioTexto MXN',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColores.cafeOscuro,
                          ),
                        ),
                      ),
                      Material(
                        color: AppColores.crema,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => _eliminar(context, uid, favoritoId),
                          child: const SizedBox(
                            width: 37,
                            height: 37,
                            child: Icon(
                              Icons.delete_outline_rounded,
                              size: 20,
                              color: AppColores.cafeOscuro,
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
  }

  Widget _favorito(
    BuildContext context,
    String uid,
    QueryDocumentSnapshot<Map<String, dynamic>> favorito,
  ) {
    final guardado = favorito.data();
    final productoId =
        guardado['productoId']?.toString().trim().isNotEmpty == true
        ? guardado['productoId'].toString()
        : favorito.id;

    // Consultar el producto actual: soporta favoritos que guardan solo el ID.
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _db.collection('productos').doc(productoId).snapshots(),
      builder: (context, snapshot) {
        final productoActual = snapshot.data?.data();
        final producto = <String, dynamic>{
          ...guardado,
          if (productoActual != null) ...productoActual,
        };
        // Si el producto fue eliminado, conservamos los datos guardados
        // (cuando existan) para poder quitarlo de favoritos.
        return _tarjeta(
          context,
          uid: uid,
          favoritoId: favorito.id,
          producto: producto,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppColores.cremaClaro,
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
                child: uid == null
                    ? const Center(
                        child: Text('Inicia sesión para ver tus favoritos'),
                      )
                    : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: _db
                            .collection('usuarios')
                            .doc(uid)
                            .collection('favoritos')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Text(
                                  'No se pudieron cargar los favoritos. Revisa tu conexión y permisos.',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          }
                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          final favoritos = snapshot.data!.docs;
                          if (favoritos.isEmpty) return _vacio();
                          return ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(20, 3, 20, 30),
                            itemCount: favoritos.length,
                            itemBuilder: (context, index) =>
                                _favorito(context, uid, favoritos[index]),
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
