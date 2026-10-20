import 'package:flutter/material.dart';
import '../Styles/Styles.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Repositorio/pedidos_firebase.dart';

class PedidosAdmin extends StatefulWidget {
  const PedidosAdmin({super.key});

  @override
  State<PedidosAdmin> createState() => _PedidosAdminState();
}

class _PedidosAdminState extends State<PedidosAdmin> {
  List<Map<String, dynamic>> pedidos = [];
  final PedidosFirebase repositorio = PedidosFirebase();
  StreamSubscription<List<Map<String, dynamic>>>? _suscripcion;

  @override
  void dispose() {
    _suscripcion?.cancel();
    super.dispose();
  }

  void aviso(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  @override
  void initState() {
    super.initState();
    cargarPedidos();
  }

  void cargarPedidos() {
    _suscripcion?.cancel();
    _suscripcion = repositorio.escucharPedidos().listen(
      (datos) {
        if (!mounted) return;
        setState(() => pedidos = datos);
      },
      onError: (Object error) {
        aviso('No se pudieron cargar los pedidos: $error');
      },
    );
  }

  Future<void> mostrarDetalle(String pedidoId) async {
    final pedido = pedidos.where((p) => p['id'] == pedidoId).firstOrNull;
    if (pedido == null || !mounted) return;
    final productos = repositorio.detalle(pedido);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColores.cremaClaro,
        title: Text(
          'Pedido #${pedido['id'].toString().length > 8 ? pedido['id'].toString().substring(0, 8).toUpperCase() : pedido['id']}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColores.cafeOscuro,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: productos.isEmpty
            ? const Text('No hay productos en este pedido.')
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: productos.map((producto) {
                    final precio =
                        (producto['precio'] as num?)?.toDouble() ?? 0;
                    final cantidad =
                        (producto['cantidad'] as num?)?.toInt() ?? 0;
                    final subtotal = precio * cantidad;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
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
                              color: AppColores.cafeOscuro,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Future<void> cambiarEstado(String pedidoId, String nuevoEstado) async {
    try {
      final correcto = await repositorio.cambiarEstado(
        pedidoId: pedidoId,
        nuevoEstado: nuevoEstado,
      );
      if (!correcto) aviso('No se puede realizar ese cambio de estado');
    } catch (e) {
      aviso('No se pudo actualizar el pedido: $e');
    }
  }

  Future<void> aceptarPedido(String pedidoId) async {
    try {
      final aceptado = await repositorio.aceptarPedido(pedidoId);
      aviso(
        aceptado
            ? 'Pedido aceptado correctamente'
            : 'No se puede aceptar: verifica stock, precios y estado del pedido',
      );
    } catch (e) {
      aviso('Error al aceptar el pedido: $e');
    }
  }

  String formatoFecha(dynamic fecha) {
    DateTime? valor;
    if (fecha is Timestamp) valor = fecha.toDate();
    if (fecha is String) valor = DateTime.tryParse(fecha);
    if (fecha is DateTime) valor = fecha;
    if (valor == null) return 'Sin fecha';
    return '${valor.day.toString().padLeft(2, '0')}/'
        '${valor.month.toString().padLeft(2, '0')}/${valor.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColores.cremaClaro,

      appBar: AppBar(
        backgroundColor: AppColores.cremaClaro,
        elevation: 0,
        title: const Text(
          'Pedidos',
          style: TextStyle(
            color: AppColores.textoPrincipal,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: pedidos.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 70,
                    color: AppColores.cafeClaro,
                  ),
                  SizedBox(height: 15),
                  Text(
                    'No hay pedidos',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColores.textoPrincipal,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: pedidos.length,
              itemBuilder: (context, index) {
                final pedido = pedidos[index];

                final total = (pedido['total'] as num).toDouble();

                return Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.all(18),
                  decoration: AppEstilos.tarjeta(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Pedido #${pedido['id']}',
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: AppColores.cafeOscuro,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Text(
                        'Cliente: ${pedido['cliente'] ?? 'Sin nombre'}',
                        style: AppEstilos.subtitulo,
                      ),

                      const SizedBox(height: 5),

                      Text(
                        'Fecha: ${formatoFecha(pedido['fecha'])}',
                        style: AppEstilos.subtitulo,
                      ),

                      const SizedBox(height: 10),

                      Text(
                        'Total: \$${total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColores.textoPrincipal,
                        ),
                      ),
                      const SizedBox(height: 15),

                      Text(
                        'Estado: ${pedido['estado']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColores.cafeOscuro,
                        ),
                      ),

                      const SizedBox(height: 15),

                      accionesPedido(pedido),

                      const SizedBox(height: 10),

                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            mostrarDetalle(pedido['id']);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColores.cafeOscuro,
                            side: const BorderSide(
                              color: AppColores.cafeOscuro,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text('Ver productos'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget accionesPedido(Map<String, dynamic> pedido) {
    final estado = pedido['estado'].toString();
    final id = pedido['id'].toString();

    switch (estado) {
      case 'Pendiente':
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  aceptarPedido(id);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColores.cafeOscuro,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Aceptar pedido'),
              ),
            ),

            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  cambiarEstado(id, 'Cancelado');
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
                child: const Text('Cancelar pedido'),
              ),
            ),
          ],
        );

      case 'Aceptado':
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  cambiarEstado(id, 'En preparación');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColores.cafeOscuro,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Comenzar preparación'),
              ),
            ),

            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  cambiarEstado(id, 'Cancelado');
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
                child: const Text('Cancelar pedido'),
              ),
            ),
          ],
        );

      case 'En preparación':
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              cambiarEstado(id, 'Listo');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColores.cafeOscuro,
              foregroundColor: Colors.white,
            ),
            child: const Text('Marcar como listo'),
          ),
        );

      case 'Listo':
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              cambiarEstado(id, 'Entregado');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColores.cafeOscuro,
              foregroundColor: Colors.white,
            ),
            child: const Text('Marcar como entregado'),
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }
}
