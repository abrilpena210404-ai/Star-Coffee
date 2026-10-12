import 'package:flutter/material.dart';
import '../Styles/Styles.dart';
import '../basedatos/database_helper.dart';
import '../sesion.dart';

class CarritoScreen extends StatefulWidget {
  const CarritoScreen({super.key});

  @override
  State<CarritoScreen> createState() => _CarritoScreenState();
}

class _CarritoScreenState extends State<CarritoScreen> {
  List<Map<String, dynamic>> carrito = [];

  @override
  void initState() {
    super.initState();
    cargarCarrito();
  }

  Future<void> cargarCarrito() async {
    final usuarioId = Sesion.usuarioId;
    if (usuarioId == null) return;
    final datos = await DatabaseHelper.instancia.obtenerCarrito(usuarioId);
    if (!mounted) return;
    setState(() {
      carrito = datos;
    });
  }

  Future<void> aumentar(int id) async {
    await DatabaseHelper.instancia.aumentarCantidad(id);
    cargarCarrito();
  }

  Future<void> disminuir(int id) async {
    await DatabaseHelper.instancia.disminuirCantidad(id);
    cargarCarrito();
  }

  Future<void> eliminar(int id) async {
    await DatabaseHelper.instancia.eliminarDelCarrito(id);
    cargarCarrito();
  }

  double calcularTotal() {
    double total = 0;

    for (final producto in carrito) {
      final precio = (producto['precio'] as num).toDouble();
      final cantidad = producto['cantidad'] as int;

      total += precio * cantidad;
    }

    return total;
  }

  @override
  Widget build(BuildContext context) {
    final total = calcularTotal();

    return Scaffold(
      backgroundColor: AppColores.cremaClaro,

      appBar: AppBar(
        backgroundColor: AppColores.cremaClaro,
        elevation: 0,
        title: const Text(
          'Mi carrito',
          style: TextStyle(
            color: AppColores.textoPrincipal,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: carrito.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: AppColores.cafeClaro,
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Tu carrito está vacío',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColores.textoPrincipal,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Agrega productos para comenzar tu pedido',
                    style: TextStyle(color: AppColores.textoSecundario),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: carrito.length,
                    itemBuilder: (context, index) {
                      final producto = carrito[index];
                      final precio = (producto['precio'] as num).toDouble();
                      final cantidad = producto['cantidad'] as int;
                      final subtotal = precio * cantidad;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        padding: const EdgeInsets.all(12),
                        decoration: AppEstilos.tarjeta(),
                        child: Row(
                          children: [
                            // IMAGEN
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child:
                                  producto['imagen'] != null &&
                                      producto['imagen'].toString().isNotEmpty
                                  ? Image.asset(
                                      producto['imagen'],
                                      width: 75,
                                      height: 75,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Container(
                                              width: 75,
                                              height: 75,
                                              color: AppColores.beige,
                                              child: const Icon(
                                                Icons.local_cafe,
                                                color: AppColores.cafeOscuro,
                                              ),
                                            );
                                          },
                                    )
                                  : Container(
                                      width: 75,
                                      height: 75,
                                      color: AppColores.beige,
                                      child: const Icon(
                                        Icons.local_cafe,
                                        color: AppColores.cafeOscuro,
                                      ),
                                    ),
                            ),

                            const SizedBox(width: 12),

                            // INFORMACIÓN
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    producto['nombre'],
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: AppColores.textoPrincipal,
                                    ),
                                  ),

                                  const SizedBox(height: 5),

                                  Text(
                                    '\$${precio.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: AppColores.cafeOscuro,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  // CANTIDAD
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          disminuir(producto['id']);
                                        },
                                        icon: const Icon(
                                          Icons.remove_circle_outline,
                                          color: AppColores.cafeOscuro,
                                        ),
                                      ),

                                      Text(
                                        '$cantidad',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      IconButton(
                                        onPressed: () {
                                          aumentar(producto['id']);
                                        },
                                        icon: const Icon(
                                          Icons.add_circle_outline,
                                          color: AppColores.cafeOscuro,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // SUBTOTAL Y ELIMINAR
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    eliminar(producto['id']);
                                  },
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                  ),
                                ),

                                Text(
                                  '\$${subtotal.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColores.cafeOscuro,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // TOTAL
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 15, 20, 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(25),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColores.textoPrincipal,
                            ),
                          ),
                          Text(
                            '\$${total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColores.cafeOscuro,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: carrito.isEmpty
                              ? null
                              : () async {
                                  final usuarioId = Sesion.usuarioId;

                                  if (usuarioId == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Debes iniciar sesión para realizar el pedido',
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  final pedidoId = await DatabaseHelper
                                      .instancia
                                      .crearPedido(
                                        usuarioId: usuarioId,
                                        total: total,
                                        productos: carrito,
                                      );
                                  if (!context.mounted) return;

                                  await cargarCarrito();

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Pedido #$pedidoId realizado correctamente ☕',
                                      ),
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColores.cafeOscuro,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(17),
                            ),
                          ),
                          child: const Text(
                            'Hacer pedido',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
