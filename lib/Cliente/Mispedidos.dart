import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Styles/Styles.dart';

/// Pedidos del cliente autenticado.
/// Lectura desde Firestore; los cambios de estado pertenecen al Worker.
class MisPedidosScreen extends StatefulWidget {
  const MisPedidosScreen({super.key});

  @override
  State<MisPedidosScreen> createState() => _MisPedidosScreenState();
}

class _MisPedidosScreenState extends State<MisPedidosScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _suscripcion;
  List<Map<String, dynamic>> pedidos = [];
  bool cargando = true;
  final Set<String> cancelando = <String>{};
  String? errorCarga;

  @override
  void initState() {
    super.initState();
    cargarPedidos();
  }

  void cargarPedidos() {
    _suscripcion?.cancel();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() {
        cargando = false;
        errorCarga = 'Inicia sesión para consultar tus pedidos';
        pedidos = [];
      });
      return;
    }

    _suscripcion = _db
        .collection('pedidos')
        .where('uid', isEqualTo: uid)
        .snapshots()
        .listen(
          (snapshot) {
            final lista = snapshot.docs
                .map((doc) => <String, dynamic>{...doc.data(), 'id': doc.id})
                .toList();
            lista.sort(
              (a, b) => _fecha(b['fecha']).compareTo(_fecha(a['fecha'])),
            );
            if (!mounted) return;
            setState(() {
              pedidos = lista;
              cargando = false;
              errorCarga = null;
            });
          },
          onError: (Object error) {
            debugPrint('Error al consultar Mis pedidos: $error');
            if (!mounted) return;
            setState(() {
              cargando = false;
              errorCarga =
                  'No se pudieron consultar tus pedidos. Revisa tu conexión o permisos.';
            });
          },
        );
  }

  DateTime _fecha(dynamic fecha) {
    if (fecha is Timestamp) return fecha.toDate();
    if (fecha is DateTime) return fecha;
    if (fecha is String) return DateTime.tryParse(fecha) ?? DateTime(1970);
    return DateTime(1970);
  }

  String formatoFecha(dynamic fecha) {
    final valor = _fecha(fecha);
    if (valor.year == 1970) return 'Sin fecha';
    final local = valor.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/${local.year}';
  }

  String folioCorto(dynamic id) {
    final texto = id?.toString() ?? '';
    return texto.length > 8 ? texto.substring(0, 8).toUpperCase() : texto;
  }

  String estadoTexto(String estado) {
    switch (estado) {
      case 'Pendiente':
      case 'Aceptado':
      case 'En preparación':
      case 'Listo':
      case 'Entregado':
      case 'Cancelado':
        return estado;
      default:
        return estado;
    }
  }

  Color colorEstado(String estado) {
    switch (estado) {
      case 'Pendiente':
        return Colors.orange;
      case 'Aceptado':
        return Colors.blue;
      case 'En preparación':
        return Colors.deepOrange;
      case 'Listo':
        return Colors.green;
      case 'Entregado':
        return Colors.teal;
      case 'Cancelado':
        return Colors.red;
      default:
        return AppColores.cafeOscuro;
    }
  }

  Future<void> verDetalle(Map<String, dynamic> pedido) async {
    final raw = pedido['productos'];
    final productos = raw is List
        ? raw
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList()
        : <Map<String, dynamic>>[];

    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColores.cremaClaro,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pedido #${folioCorto(pedido['id'])}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColores.textoPrincipal,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (productos.isEmpty)
                    const Text('No hay productos en este pedido.'),
                  ...productos.map((producto) {
                    final precio =
                        (producto['precio'] as num?)?.toDouble() ?? 0.0;
                    final cantidad =
                        (producto['cantidad'] as num?)?.toInt() ?? 0;
                    final subtotal = precio * cantidad;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              producto['nombre']?.toString() ?? 'Producto',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text('x$cantidad'),
                          const SizedBox(width: 15),
                          Text(
                            '\$${subtotal.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColores.cafeOscuro,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '\$${((pedido['total'] as num?)?.toDouble() ?? 0).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColores.cafeOscuro,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static const String _api =
      'https://star-coffee-api.abrilpena210404.workers.dev';

  Future<void> cancelarPedido(String pedidoId) async {
    if (cancelando.contains(pedidoId)) return;

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColores.cremaClaro,
        title: const Text('Cancelar pedido'),
        content: const Text(
          '¿Seguro que quieres cancelar este pedido pendiente?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );
    if (confirmado != true || !mounted) return;
    setState(() => cancelando.add(pedidoId));

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Debes iniciar sesión');
      final token = await user.getIdToken();
      if (token == null || token.isEmpty)
        throw Exception('Sesión no disponible');

      final res = await http
          .post(
            Uri.parse(
              '$_api/pedidos/${Uri.encodeComponent(pedidoId)}/cancelar',
            ),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 30));

      Map<String, dynamic> respuesta;
      try {
        final decoded = jsonDecode(res.body);
        respuesta = decoded is Map<String, dynamic>
            ? decoded
            : <String, dynamic>{};
      } catch (_) {
        throw Exception('Respuesta inesperada (HTTP ${res.statusCode})');
      }

      if (res.statusCode != 200 || respuesta['ok'] != true) {
        throw Exception(
          respuesta['mensaje']?.toString() ??
              'No fue posible cancelar (HTTP ${res.statusCode})',
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pedido cancelado correctamente')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No se pudo cancelar: $e')));
    } finally {
      if (mounted) setState(() => cancelando.remove(pedidoId));
    }
  }

  @override
  void dispose() {
    _suscripcion?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColores.cremaClaro,
      appBar: AppBar(
        backgroundColor: AppColores.cremaClaro,
        elevation: 0,
        title: const Text(
          'Mis pedidos',
          style: TextStyle(
            color: AppColores.textoPrincipal,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: cargando
          ? const Center(
              child: CircularProgressIndicator(color: AppColores.cafeOscuro),
            )
          : errorCarga != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(errorCarga!, textAlign: TextAlign.center),
              ),
            )
          : pedidos.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 75,
                    color: AppColores.cafeClaro,
                  ),
                  SizedBox(height: 15),
                  Text(
                    'No tienes pedidos',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColores.textoPrincipal,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Tus pedidos aparecerán aquí',
                    style: TextStyle(color: AppColores.textoSecundario),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                final uid = FirebaseAuth.instance.currentUser?.uid;
                if (uid == null) return;
                try {
                  await _db
                      .collection('pedidos')
                      .where('uid', isEqualTo: uid)
                      .get(const GetOptions(source: Source.server));
                } catch (e) {
                  debugPrint('Error al actualizar pedidos: $e');
                }
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: pedidos.length,
                itemBuilder: (context, index) {
                  final pedido = pedidos[index];
                  final estado = pedido['estado']?.toString() ?? 'Pendiente';
                  final total = (pedido['total'] as num?)?.toDouble() ?? 0;
                  final puedeCancelar = estado == 'Pendiente';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    padding: const EdgeInsets.all(18),
                    decoration: AppEstilos.tarjeta(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Pedido #${folioCorto(pedido['id'])}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  color: AppColores.cafeOscuro,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: colorEstado(estado).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                estadoTexto(estado),
                                style: TextStyle(
                                  color: colorEstado(estado),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Fecha: ${formatoFecha(pedido['fecha'])}',
                          style: AppEstilos.subtitulo,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Total: \$${total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColores.textoPrincipal,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => verDetalle(pedido),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColores.cafeOscuro,
                                  side: const BorderSide(
                                    color: AppColores.cafeOscuro,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Text('Ver detalle'),
                              ),
                            ),
                            if (puedeCancelar) ...[
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed:
                                      cancelando.contains(
                                        pedido['id'].toString(),
                                      )
                                      ? null
                                      : () => cancelarPedido(
                                          pedido['id'].toString(),
                                        ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: const Text('Cancelar'),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}
