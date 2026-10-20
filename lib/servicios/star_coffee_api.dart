import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class StarCoffeeApi {
  static const String baseUrl =
      'https://star-coffee-api.abrilpena210404.workers.dev';

  static Future<Map<String, dynamic>> crearPedido({
    required List<String> productoIds,
    required String requestId,
  }) async {
    final usuario = FirebaseAuth.instance.currentUser;
    if (usuario == null) {
      throw Exception('Debes iniciar sesión para realizar un pedido');
    }
    if (productoIds.isEmpty) throw Exception('Tu carrito está vacío');

    final token = await usuario.getIdToken();
    final respuesta = await http
        .post(
          Uri.parse('$baseUrl/pedidos'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'requestId': requestId,
            'productoIds': productoIds,
          }),
        )
        .timeout(const Duration(seconds: 35));

    Map<String, dynamic> datos;
    try {
      datos = Map<String, dynamic>.from(jsonDecode(respuesta.body) as Map);
    } catch (_) {
      throw Exception(
        'Respuesta inesperada del servidor (${respuesta.statusCode})',
      );
    }
    if (respuesta.statusCode != 200 && respuesta.statusCode != 201) {
      debugPrint('Código HTTP del pedido: ${respuesta.statusCode}');

      throw Exception(
        'Error HTTP ${respuesta.statusCode}: '
        '${datos['mensaje'] ?? 'No se pudo registrar el pedido'}',
      );
    }
    if (datos['ok'] != true || datos['pedidoId'] == null) {
      throw Exception('El servidor no confirmó el pedido');
    }
    return datos;
  }

  static Future<String> probarAutenticacion() async {
    final usuario = FirebaseAuth.instance.currentUser;
    if (usuario == null) throw Exception('Debes iniciar sesión');
    final token = await usuario.getIdToken();
    final respuesta = await http
        .get(
          Uri.parse('$baseUrl/auth-test'),
          headers: {'Authorization': 'Bearer $token'},
        )
        .timeout(const Duration(seconds: 15));
    final datos = jsonDecode(respuesta.body) as Map<String, dynamic>;
    if (respuesta.statusCode != 200) {
      throw Exception(datos['mensaje'] ?? 'No se pudo verificar la sesión');
    }
    return datos['mensaje']?.toString() ?? 'Autenticación correcta';
  }

  static Future<String> probarFirestore() async {
    final usuario = FirebaseAuth.instance.currentUser;
    if (usuario == null) throw Exception('Debes iniciar sesión');
    final token = await usuario.getIdToken();
    final respuesta = await http
        .get(
          Uri.parse('$baseUrl/firestore-test'),
          headers: {'Authorization': 'Bearer $token'},
        )
        .timeout(const Duration(seconds: 20));
    final datos = jsonDecode(respuesta.body) as Map<String, dynamic>;
    if (respuesta.statusCode != 200) {
      throw Exception(datos['mensaje'] ?? 'Error al consultar Firestore');
    }
    return datos['mensaje']?.toString() ?? 'Conexión correcta';
  }
}
