import 'package:cloud_firestore/cloud_firestore.dart';

class CategoriaFirebase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _categorias =>
      _firestore.collection('categorias');

  // OBTENER TODAS LAS CATEGORÍAS
  Future<List<Map<String, dynamic>>> obtenerCategorias() async {
    final resultado = await _categorias.get();

    final categorias = resultado.docs.map((doc) {
      return {...doc.data(), 'id': doc.id};
    }).toList();

    categorias.sort(
      (a, b) => a['nombre'].toString().toLowerCase().compareTo(
        b['nombre'].toString().toLowerCase(),
      ),
    );

    return categorias;
  }

  // AGREGAR CATEGORÍA
  Future<void> agregarCategoria(String nombre) async {
    final nombreLimpio = nombre.trim();

    if (nombreLimpio.isEmpty) {
      throw ArgumentError('Ingresa el nombre de la categoría');
    }

    // Evitar categorías duplicadas
    final categorias = await obtenerCategorias();

    final existe = categorias.any(
      (categoria) =>
          categoria['nombre'].toString().toLowerCase() ==
          nombreLimpio.toLowerCase(),
    );

    if (existe) {
      throw Exception('Esta categoría ya existe');
    }

    await _categorias.add({'nombre': nombreLimpio});
  }

  // ACTUALIZAR CATEGORÍA
  Future<void> actualizarCategoria({
    required String id,
    required String nombre,
  }) async {
    final nombreLimpio = nombre.trim();

    if (nombreLimpio.isEmpty) {
      throw ArgumentError('Ingresa el nombre de la categoría');
    }

    final categorias = await obtenerCategorias();

    final existe = categorias.any(
      (categoria) =>
          categoria['id'] != id &&
          categoria['nombre'].toString().toLowerCase() ==
              nombreLimpio.toLowerCase(),
    );

    if (existe) {
      throw Exception('Esta categoría ya existe');
    }

    await _categorias.doc(id).update({'nombre': nombreLimpio});
  }

  // ELIMINAR CATEGORÍA
  Future<void> eliminarCategoria(String id) async {
    await _categorias.doc(id).delete();
  }
}
