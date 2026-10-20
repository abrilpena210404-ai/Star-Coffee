import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

/// Repositorio de pedidos de Star Coffee.
///
/// Lecturas: Firestore en tiempo real.
/// Cambios de estado e inventario: Cloudflare Worker.
///
/// Flutter NO modifica directamente el stock ni el estado
/// de los pedidos.
class PedidosFirebase {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const String _api =
      'https://star-coffee-api.abrilpena210404.workers.dev';

  // =========================================
  // OBTENER PEDIDOS EN TIEMPO REAL
  // =========================================

  Stream<List<Map<String, dynamic>>> escucharPedidos() {
    return _db.collection('pedidos').snapshots().map((snapshot) {
      final resultado = snapshot.docs
          .map((doc) => <String, dynamic>{...doc.data(), 'id': doc.id})
          .toList();

      resultado.sort((a, b) => _fecha(b).compareTo(_fecha(a)));

      return resultado;
    });
  }

  // =========================================
  // FORMATO DE FECHA
  // =========================================

  DateTime _fecha(Map<String, dynamic> pedido) {
    final fecha = pedido['fecha'];

    if (fecha is Timestamp) {
      return fecha.toDate();
    }

    if (fecha is DateTime) {
      return fecha;
    }

    if (fecha is String) {
      return DateTime.tryParse(fecha) ?? DateTime(1970);
    }

    return DateTime(1970);
  }

  // =========================================
  // DETALLE DE PRODUCTOS
  // =========================================

  List<Map<String, dynamic>> detalle(Map<String, dynamic> pedido) {
    final raw = pedido['productos'];

    if (raw is! List) {
      return [];
    }

    return raw
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  // =========================================
  // CAMBIAR ESTADO DESDE CLOUDFLARE
  // =========================================

  Future<bool> cambiarEstado({
    required String pedidoId,
    required String nuevoEstado,
  }) async {
    final usuario = FirebaseAuth.instance.currentUser;

    if (usuario == null) {
      throw Exception('Debes iniciar sesión como administrador.');
    }

    final token = await usuario.getIdToken();

    if (token == null || token.isEmpty) {
      throw Exception('No se pudo obtener la sesión de Firebase.');
    }

    try {
      final respuesta = await http
          .post(
            Uri.parse('$_api/pedidos/${Uri.encodeComponent(pedidoId)}/estado'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'estado': nuevoEstado}),
          )
          .timeout(const Duration(seconds: 30));

      final dynamic decodificado;

      try {
        decodificado = jsonDecode(respuesta.body);
      } catch (_) {
        throw Exception(
          'Respuesta inesperada del servidor '
          '(HTTP ${respuesta.statusCode}).',
        );
      }

      if (decodificado is! Map) {
        throw Exception('La respuesta del servidor no es válida.');
      }

      final datos = Map<String, dynamic>.from(decodificado);

      if (respuesta.statusCode != 200 || datos['ok'] != true) {
        throw Exception(
          datos['mensaje']?.toString() ??
              'No se pudo actualizar el pedido '
                  '(HTTP ${respuesta.statusCode}).',
        );
      }

      return true;
    } catch (e) {
      rethrow;
    }
  }

  // =========================================
  // ACEPTAR PEDIDO
  // =========================================

  Future<bool> aceptarPedido(String pedidoId) {
    return cambiarEstado(pedidoId: pedidoId, nuevoEstado: 'Aceptado');
  }
}
