import 'package:cloud_firestore/cloud_firestore.dart';

class ProductoFirebase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _productos =>
      _firestore.collection('productos');

  // OBTENER PRODUCTOS
  Future<List<Map<String, dynamic>>> obtenerProductos() async {
    final resultado = await _productos.where('activo', isEqualTo: true).get();

    final productos = resultado.docs.map((doc) {
      return {'id': doc.id, ...doc.data()};
    }).toList();

    productos.sort(
      (a, b) => a['nombre'].toString().compareTo(b['nombre'].toString()),
    );

    return productos;
  }

  // AGREGAR PRODUCTO
  Future<void> agregarProducto({
    required String nombre,
    required String descripcion,
    required double precio,
    required String imagen,
    required String categoria,
    required int stock,
  }) async {
    await _productos.add({
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'imagen': imagen,
      'categoria': categoria,
      'stock': stock,
      'activo': true,
    });
  }

  // ACTUALIZAR PRODUCTO
  Future<void> actualizarProducto({
    required String id,
    required String nombre,
    required String descripcion,
    required double precio,
    required String imagen,
    required String categoria,
    required int stock,
  }) async {
    await _productos.doc(id).update({
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'imagen': imagen,
      'categoria': categoria,
      'stock': stock,
    });
  }

  // ELIMINAR PRODUCTO
  Future<void> eliminarProducto(String id) async {
    await _productos.doc(id).delete();
  }
}
