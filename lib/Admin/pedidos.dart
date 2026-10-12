import 'package:flutter/material.dart';
import '../Styles/Styles.dart';
import '../basedatos/database_helper.dart';

class PedidosAdmin extends StatefulWidget {
  const PedidosAdmin({super.key});

  @override
  State<PedidosAdmin> createState() => _PedidosAdminState();
}

class _PedidosAdminState extends State<PedidosAdmin> {
  List<Map<String, dynamic>> pedidos = [];

  @override
  void initState() {
    super.initState();
    cargarPedidos();
  }

  Future<void> cargarPedidos() async {
    final datos = await DatabaseHelper.instancia.obtenerPedidos();

    if (!mounted) return;

    setState(() {
      pedidos = datos;
    });
  }

  Future<void> mostrarDetalle(int pedidoId) async {
    final productos = await DatabaseHelper.instancia.obtenerDetallePedido(
      pedidoId,
    );

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColores.cremaClaro,
          title: Text(
            'Pedido #$pedidoId',
            style: const TextStyle(
              color: AppColores.cafeOscuro,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: productos.isEmpty
              ? const Text('No hay productos en este pedido.')
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: productos.map((producto) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              producto['nombre'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            'x${producto['cantidad']}',
                            style: const TextStyle(
                              color: AppColores.textoSecundario,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Text(
                            '\$${(producto['subtotal'] as num).toStringAsFixed(2)}',
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
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> cambiarEstado(int pedidoId, String nuevoEstado) async {
    final correcto = await DatabaseHelper.instancia.actualizarEstadoPedido(
      pedidoId: pedidoId,
      nuevoEstado: nuevoEstado,
    );

    await cargarPedidos();

    if (!mounted) return;

    if (!correcto) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se puede realizar ese cambio de estado'),
        ),
      );
    }
  }

  Future<void> aceptarPedido(int pedidoId) async {
    final aceptado = await DatabaseHelper.instancia.aceptarPedido(pedidoId);

    await cargarPedidos();

    if (!mounted) return;

    if (aceptado) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pedido aceptado correctamente')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay suficiente stock para aceptar este pedido'),
        ),
      );
    }
  }

  String formatoFecha(String fecha) {
    final fechaConvertida = DateTime.tryParse(fecha);

    if (fechaConvertida == null) {
      return fecha;
    }

    return '${fechaConvertida.day.toString().padLeft(2, '0')}/'
        '${fechaConvertida.month.toString().padLeft(2, '0')}/'
        '${fechaConvertida.year}';
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
    final id = pedido['id'] as int;

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
