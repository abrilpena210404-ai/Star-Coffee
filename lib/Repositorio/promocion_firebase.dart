import 'package:cloud_firestore/cloud_firestore.dart';

class PromocionFirebase {
  final CollectionReference<Map<String, dynamic>> _promociones =
      FirebaseFirestore.instance.collection('promociones');

  Future<List<Map<String, dynamic>>> obtenerPromociones() async {
    final consulta = await _promociones.get();
    final lista = consulta.docs
        .map((doc) => <String, dynamic>{...doc.data(), 'id': doc.id})
        .toList();
    lista.sort(
      (a, b) => a['titulo'].toString().toLowerCase().compareTo(
        b['titulo'].toString().toLowerCase(),
      ),
    );
    return lista;
  }

  Future<void> agregarPromocion({
    required String titulo,
    required String descripcion,
    required double descuento,
    required String imagen,
  }) async {
    _validar(titulo, descripcion, descuento);
    await _promociones.add({
      'titulo': titulo.trim(),
      'descripcion': descripcion.trim(),
      'descuento': descuento,
      'imagen': imagen,
      'estado': 'Activa',
    });
  }

  Future<void> actualizarPromocion({
    required String id,
    required String titulo,
    required String descripcion,
    required double descuento,
    required String imagen,
  }) async {
    _validar(titulo, descripcion, descuento);
    await _promociones.doc(id).update({
      'titulo': titulo.trim(),
      'descripcion': descripcion.trim(),
      'descuento': descuento,
      'imagen': imagen,
    });
  }

  Future<void> eliminarPromocion(String id) async {
    await _promociones.doc(id).delete();
  }

  void _validar(String titulo, String descripcion, double descuento) {
    if (titulo.trim().isEmpty || descripcion.trim().isEmpty) {
      throw ArgumentError('Completa el título y la descripción');
    }
    if (!descuento.isFinite || descuento <= 0 || descuento > 100) {
      throw ArgumentError('El descuento debe ser mayor a 0 y máximo 100%');
    }
  }
}
