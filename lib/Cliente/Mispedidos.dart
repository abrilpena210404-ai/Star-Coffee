import 'package:flutter/material.dart';
import '../Styles/Styles.dart';
import '../basedatos/database_helper.dart';
import '../sesion.dart';

class MisPedidosScreen extends StatefulWidget {
  const MisPedidosScreen({super.key});

  @override
  State<MisPedidosScreen> createState() => _MisPedidosScreenState();
}

class _MisPedidosScreenState extends State<MisPedidosScreen> {
  List<Map<String, dynamic>> pedidos = [];

  @override
  void initState() {
    super.initState();
    cargarPedidos();
  }

  Future<void> cargarPedidos() async {
    final usuarioId = Sesion.usuarioId;

    if (usuarioId == null) return;

    final datos = await DatabaseHelper.instancia.obtenerPedidosUsuario(
      usuarioId,
    );

    if (!mounted) return;

    setState(() {
      pedidos = datos;
    });
  }

  String estadoTexto(String estado) {
    switch (estado) {
      case 'Pendiente':
        return 'Pendiente';
      case 'Aceptado':
        return 'Aceptado';
      case 'En preparación':
        return 'En preparación';
      case 'Listo':
        return 'Listo';
      case 'Entregado':
        return 'Entregado';
      case 'Cancelado':
        return 'Cancelado';
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
    final productos = await DatabaseHelper.instancia.obtenerDetallePedido(
      pedido['id'],
    );

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColores.cremaClaro,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pedido #${pedido['id']}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColores.textoPrincipal,
                ),
              ),

              const SizedBox(height: 20),

              ...productos.map((producto) {
                final precio = (producto['precio'] as num).toDouble();

                final cantidad = producto['cantidad'] as int;

                final subtotal = precio * cantidad;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          producto['nombre'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '\$${(pedido['total'] as num).toStringAsFixed(2)}',
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
        );
      },
    );
  }

  Future<void> cancelar(int pedidoId) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColores.cremaClaro,
          title: const Text('Cancelar pedido'),
          content: const Text('¿Seguro que quieres cancelar este pedido?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Sí, cancelar'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;

    await DatabaseHelper.instancia.cancelarPedido(pedidoId);

    await cargarPedidos();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pedido cancelado correctamente')),
    );
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

      body: pedidos.isEmpty
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
              onRefresh: cargarPedidos,
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: pedidos.length,
                itemBuilder: (context, index) {
                  final pedido = pedidos[index];

                  final estado = pedido['estado'].toString();

                  final total = (pedido['total'] as num).toDouble();

                  final puedeCancelar = estado == 'Pendiente';

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
                          'Fecha: ${pedido['fecha']}',
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
                                onPressed: () {
                                  verDetalle(pedido);
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
                                child: const Text('Ver detalle'),
                              ),
                            ),

                            if (puedeCancelar) ...[
                              const SizedBox(width: 10),

                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    cancelar(pedido['id']);
                                  },
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
