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
  bool cargando = true;
  String? errorCarga;
  int pestanaActual = 0;
  int limiteVisible = 20;
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

  String folioCorto(dynamic id) {
    final texto = id?.toString() ?? '';
    final identificador = texto.split('_').last;

    return identificador.length > 8
        ? identificador.substring(0, 8).toUpperCase()
        : identificador.toUpperCase();
  }

  @override
  void initState() {
    super.initState();
    cargarPedidos();
  }

  void cargarPedidos() {
    _suscripcion?.cancel();
    setState(() {
      cargando = true;
      errorCarga = null;
    });
    _suscripcion = repositorio.escucharPedidos().listen(
      (datos) {
        if (!mounted) return;

        setState(() {
          pedidos = datos;
          cargando = false;
          errorCarga = null;
        });
      },
      onError: (Object error) {
        debugPrint('Error al cargar pedidos del administrador: $error');
        if (!mounted) return;
        setState(() {
          cargando = false;
          errorCarga = 'No se pudieron cargar los pedidos. Revisa tu conexión.';
        });
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
          'Pedido #${folioCorto(pedido['id'])}',
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

  DateTime fechaPedido(dynamic fecha) {
    if (fecha is Timestamp) return fecha.toDate();
    if (fecha is DateTime) return fecha;
    if (fecha is String) return DateTime.tryParse(fecha) ?? DateTime(1970);
    return DateTime(1970);
  }

  @override
  Widget build(BuildContext context) {
    final activos = pedidos.where((p) {
      final estado = p['estado']?.toString() ?? 'Pendiente';
      return estado != 'Entregado' && estado != 'Cancelado';
    }).toList();
    final entregados = pedidos
        .where((p) => p['estado'] == 'Entregado')
        .toList();
    final cancelados = pedidos
        .where((p) => p['estado'] == 'Cancelado')
        .toList();

    final grupos = [activos, entregados, cancelados];
    final seleccionados = List<Map<String, dynamic>>.from(
      grupos[pestanaActual],
    );
    seleccionados.sort(
      (a, b) => fechaPedido(b['fecha']).compareTo(fechaPedido(a['fecha'])),
    );
    final visibles = seleccionados.take(limiteVisible).toList();
    final hayMas = seleccionados.length > visibles.length;

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
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 14, 12, 4),
                  child: Row(
                    children: [
                      for (int i = 0; i < 3; i++)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: OutlinedButton(
                              onPressed: () => setState(() {
                                pestanaActual = i;
                                limiteVisible = 20;
                              }),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 2,
                                  vertical: 12,
                                ),
                                backgroundColor: pestanaActual == i
                                    ? AppColores.cafeOscuro
                                    : AppColores.cremaClaro,
                                foregroundColor: pestanaActual == i
                                    ? Colors.white
                                    : AppColores.cafeOscuro,
                                side: const BorderSide(
                                  color: AppColores.cafeOscuro,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  '${['Activos', 'Entregados', 'Cancelados'][i]} (${grupos[i].length})',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: seleccionados.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.receipt_long_outlined,
                                size: 70,
                                color: AppColores.cafeClaro,
                              ),
                              const SizedBox(height: 15),
                              Text(
                                [
                                  'No hay pedidos activos',
                                  'No hay pedidos entregados',
                                  'No hay pedidos cancelados',
                                ][pestanaActual],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColores.textoPrincipal,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: visibles.length + (hayMas ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == visibles.length) {
                              return Center(
                                child: OutlinedButton(
                                  onPressed: () => setState(() {
                                    limiteVisible += 20;
                                  }),
                                  child: const Text('Mostrar más pedidos'),
                                ),
                              );
                            }
                            final pedido = visibles[index];
                            final total =
                                (pedido['total'] as num?)?.toDouble() ?? 0.0;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 15),
                              padding: const EdgeInsets.all(18),
                              decoration: AppEstilos.tarjeta(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Pedido #${folioCorto(pedido['id'])}',
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
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
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
                ),
              ],
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
