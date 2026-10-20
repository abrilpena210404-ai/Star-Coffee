import 'package:flutter/material.dart';
import '../Styles/Styles.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../servicios/star_coffee_api.dart';

class CarritoScreen extends StatefulWidget {
  const CarritoScreen({super.key});

  @override
  State<CarritoScreen> createState() => _CarritoScreenState();
}

class _CarritoScreenState extends State<CarritoScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _suscripcion;
  List<Map<String, dynamic>> carrito = [];
  bool cargando = true;
  String? errorCarga;
  final Set<String> _procesando = {};
  bool _enviandoPedido = false;
  String? _requestIdPendiente;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  CollectionReference<Map<String, dynamic>>? get _carritoRef {
    final uid = _uid;
    if (uid == null) return null;
    return _db.collection('usuarios').doc(uid).collection('carrito');
  }

  @override
  void initState() {
    super.initState();
    cargarCarrito();
  }

  void cargarCarrito() {
    _suscripcion?.cancel();
    final ref = _carritoRef;
    if (ref == null) {
      if (mounted)
        setState(() {
          cargando = false;
          errorCarga = 'Inicia sesión para consultar tu carrito';
        });
      return;
    }
    _suscripcion = ref.snapshots().listen(
      (snapshot) {
        final datos = snapshot.docs
            .map(
              (doc) => <String, dynamic>{
                ...doc.data(),
                'id': doc.id,
                'productoId': doc.id,
              },
            )
            .toList();
        if (!mounted) return;
        setState(() {
          carrito = datos;
          cargando = false;
          errorCarga = null;
        });
      },
      onError: (Object error) {
        if (!mounted) return;
        setState(() {
          cargando = false;
          errorCarga = 'No se pudo consultar el carrito: $error';
        });
      },
    );
  }

  void _mensaje(String texto) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto), duration: const Duration(seconds: 3)),
    );
  }

  Future<void> _cambiarCantidad(String id, int diferencia) async {
    final ref = _carritoRef;
    if (ref == null || _procesando.contains(id)) return;
    setState(() => _procesando.add(id));
    try {
      await _db.runTransaction((transaction) async {
        final documentoRef = ref.doc(id);
        final documento = await transaction.get(documentoRef);
        if (!documento.exists) return;
        final actual = (documento.data()?['cantidad'] as num?)?.toInt() ?? 0;
        final siguiente = actual + diferencia;
        if (siguiente <= 0) {
          transaction.delete(documentoRef);
        } else {
          // Firestore valida que no exceda el stock disponible.
          transaction.update(documentoRef, {'cantidad': siguiente});
        }
      });
    } catch (e) {
      _mensaje(
        'No se pudo actualizar la cantidad. Revisa el stock disponible.',
      );
      debugPrint('Error al cambiar cantidad: $e');
    } finally {
      if (mounted) setState(() => _procesando.remove(id));
    }
  }

  Future<void> aumentar(String id) => _cambiarCantidad(id, 1);
  Future<void> disminuir(String id) => _cambiarCantidad(id, -1);

  Future<void> eliminar(String id) async {
    final ref = _carritoRef;
    if (ref == null || _procesando.contains(id)) return;
    setState(() => _procesando.add(id));
    try {
      await ref.doc(id).delete();
    } catch (e) {
      debugPrint('Error al eliminar producto: $e');
      _mensaje('No se pudo eliminar el producto');
    } finally {
      if (mounted) setState(() => _procesando.remove(id));
    }
  }

  Future<void> _hacerPedido() async {
    if (_enviandoPedido || carrito.isEmpty || _procesando.isNotEmpty) return;
    final ids = carrito.map((p) => p['productoId'].toString()).toList();
    _requestIdPendiente ??= const Uuid().v4();
    setState(() => _enviandoPedido = true);
    try {
      final resultado = await StarCoffeeApi.crearPedido(
        productoIds: ids,
        requestId: _requestIdPendiente!,
      );
      if (!mounted) return;
      final id = resultado['pedidoId'].toString();
      _requestIdPendiente = null;
      _mensaje('Pedido registrado correctamente: $id ☕');
      // Firestore actualiza automáticamente el carrito cuando la API elimina los items.
    } catch (e) {
      if (mounted) {
        _mensaje(
          'No se pudo confirmar el pedido: $e. Si reintentas, se usará la misma solicitud.',
        );
      }
    } finally {
      if (mounted) setState(() => _enviandoPedido = false);
    }
  }

  double calcularTotal() {
    double total = 0;
    for (final producto in carrito) {
      final precio = (producto['precio'] as num?)?.toDouble() ?? 0.0;
      final cantidad = (producto['cantidad'] as num?)?.toInt() ?? 0;
      total += precio * cantidad;
    }
    return total;
  }

  Widget imagenCarrito(String ruta) {
    Widget respaldo() => Container(
      width: 75,
      height: 75,
      color: AppColores.beige,
      child: const Icon(Icons.local_cafe, color: AppColores.cafeOscuro),
    );
    if (ruta.isEmpty) return respaldo();
    if (ruta.startsWith('https://')) {
      return Image.network(
        ruta,
        width: 75,
        height: 75,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => respaldo(),
      );
    }
    return Image.asset(
      ruta,
      width: 75,
      height: 75,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => respaldo(),
    );
  }

  @override
  void dispose() {
    _suscripcion?.cancel();
    super.dispose();
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

      body: cargando
          ? const Center(
              child: CircularProgressIndicator(color: AppColores.cafeOscuro),
            )
          : errorCarga != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(errorCarga!, textAlign: TextAlign.center),
              ),
            )
          : carrito.isEmpty
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
                      final precio =
                          (producto['precio'] as num?)?.toDouble() ?? 0.0;
                      final cantidad =
                          (producto['cantidad'] as num?)?.toInt() ?? 0;
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
                              child: imagenCarrito(
                                producto['imagen']?.toString() ?? '',
                              ),
                            ),

                            const SizedBox(width: 12),

                            // INFORMACIÓN
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    producto['nombre']?.toString() ??
                                        'Producto',
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
                                          disminuir(producto['id'].toString());
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
                                          aumentar(producto['id'].toString());
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
                                    eliminar(producto['id'].toString());
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
                          onPressed:
                              carrito.isEmpty ||
                                  _enviandoPedido ||
                                  _procesando.isNotEmpty
                              ? null
                              : _hacerPedido,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColores.cafeOscuro,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(17),
                            ),
                          ),
                          child: Text(
                            _enviandoPedido
                                ? 'Registrando pedido...'
                                : 'Hacer pedido',
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
