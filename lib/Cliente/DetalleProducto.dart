import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Styles/Styles.dart';

class DetalleProducto extends StatefulWidget {
  final Map<String, dynamic> producto;

  const DetalleProducto({super.key, required this.producto});

  @override
  State<DetalleProducto> createState() => _DetalleProductoState();
}

class _DetalleProductoState extends State<DetalleProducto> {
  bool agregadoAlCarrito = false;
  bool cargandoCarrito = true;
  bool cargandoFavorito = false;
  bool agregadoAFavoritos = false;

  String get productoId => widget.producto['id'].toString();
  String? get uid => FirebaseAuth.instance.currentUser?.uid;

  DocumentReference<Map<String, dynamic>>? get referenciaCarrito {
    final usuario = uid;
    if (usuario == null) return null;
    return FirebaseFirestore.instance
        .collection('usuarios')
        .doc(usuario)
        .collection('carrito')
        .doc(productoId);
  }

  DocumentReference<Map<String, dynamic>>? get referenciaFavorito {
    final usuario = uid;
    if (usuario == null) return null;
    return FirebaseFirestore.instance
        .collection('usuarios')
        .doc(usuario)
        .collection('favoritos')
        .doc(productoId);
  }

  @override
  void initState() {
    super.initState();
    comprobarCarrito();
    comprobarFavorito();
  }

  void mostrarMensaje(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), duration: const Duration(seconds: 2)),
    );
  }

  Future<void> comprobarCarrito() async {
    try {
      final referencia = referenciaCarrito;
      if (referencia == null) return;
      final documento = await referencia.get();
      if (!mounted) return;
      setState(() => agregadoAlCarrito = documento.exists);
    } catch (e) {
      mostrarMensaje('No se pudo consultar el carrito');
    } finally {
      if (mounted) setState(() => cargandoCarrito = false);
    }
  }

  Future<void> comprobarFavorito() async {
    try {
      final referencia = referenciaFavorito;
      if (referencia == null) return;
      final documento = await referencia.get();
      if (!mounted) return;
      setState(() => agregadoAFavoritos = documento.exists);
    } catch (e) {
      mostrarMensaje('No se pudieron consultar los favoritos');
    }
  }

  Future<void> cambiarCarrito() async {
    final referencia = referenciaCarrito;
    if (referencia == null) {
      mostrarMensaje('Debes iniciar sesión para usar el carrito');
      return;
    }
    if (cargandoCarrito) return;
    setState(() => cargandoCarrito = true);
    try {
      final documento = await referencia.get();
      if (documento.exists) {
        await referencia.delete();
        if (!mounted) return;
        setState(() => agregadoAlCarrito = false);
        mostrarMensaje('Producto eliminado del carrito');
      } else {
        // Reconsultar el stock actual; no depender de datos viejos del catálogo.
        final productoActual = await FirebaseFirestore.instance
            .collection('productos')
            .doc(productoId)
            .get();
        final datos = productoActual.data();
        final stock = (datos?['stock'] as num?)?.toInt() ?? 0;
        if (!productoActual.exists || datos?['activo'] != true || stock < 1) {
          mostrarMensaje('Producto no disponible por el momento');
          return;
        }
        await referencia.set({
          'productoId': productoId,
          'nombre': datos?['nombre'] ?? '',
          'precio': datos?['precio'] ?? 0,
          'imagen': datos?['imagen'] ?? '',
          'cantidad': 1,
        });
        if (!mounted) return;
        setState(() => agregadoAlCarrito = true);
        mostrarMensaje('Producto agregado al carrito');
      }
    } catch (e) {
      mostrarMensaje('No se pudo actualizar el carrito');
      debugPrint('Error al actualizar carrito: $e');
    } finally {
      if (mounted) setState(() => cargandoCarrito = false);
    }
  }

  Future<void> cambiarFavorito() async {
    final referencia = referenciaFavorito;
    if (referencia == null) {
      mostrarMensaje('Debes iniciar sesión para usar favoritos');
      return;
    }
    if (cargandoFavorito) return;
    setState(() => cargandoFavorito = true);
    try {
      final documento = await referencia.get();
      if (documento.exists) {
        await referencia.delete();
        if (!mounted) return;
        setState(() => agregadoAFavoritos = false);
        mostrarMensaje('Producto eliminado de favoritos');
      } else {
        await referencia.set({
          'productoId': productoId,
          'nombre': widget.producto['nombre'] ?? '',
          'descripcion': widget.producto['descripcion'] ?? '',
          'precio': widget.producto['precio'] ?? 0,
          'imagen': widget.producto['imagen'] ?? '',
          'categoria': widget.producto['categoria'] ?? '',
          'fecha': FieldValue.serverTimestamp(),
        });
        if (!mounted) return;
        setState(() => agregadoAFavoritos = true);
        mostrarMensaje('Producto agregado a favoritos');
      }
    } catch (e) {
      mostrarMensaje('No se pudo actualizar favoritos');
      debugPrint('Error al actualizar favoritos: $e');
    } finally {
      if (mounted) setState(() => cargandoFavorito = false);
    }
  }

  Widget imagenProducto(String ruta) {
    if (ruta.isEmpty) {
      return const Icon(
        Icons.local_cafe,
        size: 90,
        color: AppColores.cafeOscuro,
      );
    }
    Widget errorImagen() =>
        const Icon(Icons.local_cafe, size: 90, color: AppColores.cafeOscuro);
    if (ruta.startsWith('https://')) {
      return Image.network(
        ruta,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => errorImagen(),
      );
    }
    return Image.asset(
      ruta,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => errorImagen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final producto = widget.producto;
    return Scaffold(
      backgroundColor: AppColores.cremaClaro,
      appBar: AppBar(
        backgroundColor: AppColores.cremaClaro,
        elevation: 0,
        title: const Text(
          'Detalle del producto',
          style: TextStyle(
            color: AppColores.textoPrincipal,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 280,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColores.beige,
                borderRadius: BorderRadius.circular(25),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: imagenProducto(producto['imagen']?.toString() ?? ''),
              ),
            ),
            const SizedBox(height: 25),
            Text(
              producto['nombre']?.toString() ?? 'Producto',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColores.textoPrincipal,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              producto['descripcion']?.toString() ?? '',
              style: AppEstilos.subtitulo,
            ),
            const SizedBox(height: 25),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: AppEstilos.tarjeta(),
              child: Column(
                children: [
                  filaDato(
                    'Categoría',
                    producto['categoria']?.toString() ?? '',
                  ),
                  filaDato('Precio', '\$${producto['precio']}'),
                  filaDato('Stock', '${producto['stock']}'),
                ],
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: cargandoCarrito ? null : cambiarCarrito,
                icon: Icon(
                  agregadoAlCarrito
                      ? Icons.check_circle_outline
                      : Icons.shopping_cart_outlined,
                ),
                label: Text(
                  agregadoAlCarrito
                      ? 'Agregado al carrito'
                      : 'Agregar al carrito',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: agregadoAlCarrito
                      ? AppColores.cafeMedio
                      : AppColores.cafeOscuro,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColores.beige,
                  disabledForegroundColor: AppColores.textoSecundario,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: cargandoFavorito ? null : cambiarFavorito,
                icon: Icon(
                  agregadoAFavoritos ? Icons.favorite : Icons.favorite_border,
                ),
                label: Text(
                  agregadoAFavoritos
                      ? 'Agregado a favoritos'
                      : 'Agregar a favoritos',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColores.cafeOscuro,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget filaDato(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(titulo, style: AppEstilos.subtitulo),
          Text(
            valor,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColores.cafeOscuro,
            ),
          ),
        ],
      ),
    );
  }
}
