import 'package:flutter/material.dart';
import '../Styles/Styles.dart';
import '../basedatos/database_helper.dart';
import '../sesion.dart';

class DetalleProducto extends StatefulWidget {
  final Map<String, dynamic> producto;

  const DetalleProducto({super.key, required this.producto});

  @override
  State<DetalleProducto> createState() => _DetalleProductoState();
}

class _DetalleProductoState extends State<DetalleProducto> {
  bool agregadoAlCarrito = false;
  bool cargandoCarrito = true;

  @override
  void initState() {
    super.initState();
    comprobarCarrito();
  }

  Future<void> comprobarCarrito() async {
    final usuarioId = Sesion.usuarioId;

    if (usuarioId == null) {
      if (mounted) {
        setState(() {
          cargandoCarrito = false;
        });
      }
      return;
    }

    final carrito = await DatabaseHelper.instancia.obtenerCarrito(usuarioId);

    final productoId = widget.producto['id'];

    final existe = carrito.any((item) => item['productoId'] == productoId);

    if (!mounted) return;

    setState(() {
      agregadoAlCarrito = existe;
      cargandoCarrito = false;
    });
  }

  Future<void> cambiarCarrito() async {
    final usuarioId = Sesion.usuarioId;

    if (usuarioId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes iniciar sesión para usar el carrito'),
        ),
      );
      return;
    }

    final carrito = await DatabaseHelper.instancia.obtenerCarrito(usuarioId);

    final productoId = widget.producto['id'];

    final productoEnCarrito = carrito.where(
      (item) => item['productoId'] == productoId,
    );

    if (productoEnCarrito.isNotEmpty) {
      final idCarrito = productoEnCarrito.first['id'];

      await DatabaseHelper.instancia.eliminarDelCarrito(idCarrito);

      if (!mounted) return;

      setState(() {
        agregadoAlCarrito = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Producto eliminado del carrito'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      await DatabaseHelper.instancia.agregarAlCarrito(
        usuarioId: usuarioId,
        producto: widget.producto,
      );

      if (!mounted) return;

      setState(() {
        agregadoAlCarrito = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Producto agregado al carrito'),
          duration: Duration(seconds: 2),
        ),
      );
    }
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
              child:
                  producto['imagen'] != null &&
                      producto['imagen'].toString().isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: Image.asset(producto['imagen'], fit: BoxFit.cover),
                    )
                  : const Icon(
                      Icons.local_cafe,
                      size: 90,
                      color: AppColores.cafeOscuro,
                    ),
            ),

            const SizedBox(height: 25),

            Text(
              producto['nombre'],
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColores.textoPrincipal,
              ),
            ),

            const SizedBox(height: 10),

            Text(producto['descripcion'], style: AppEstilos.subtitulo),

            const SizedBox(height: 25),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: AppEstilos.tarjeta(),
              child: Column(
                children: [
                  filaDato('Categoría', producto['categoria']),
                  filaDato('Precio', '\$${producto['precio']}'),
                  filaDato('Stock', '${producto['stock']}'),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // =========================
            // CARRITO
            // =========================
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

            // =========================
            // FAVORITOS
            // =========================
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final usuarioId = Sesion.usuarioId;

                  if (usuarioId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Debes iniciar sesión para usar favoritos',
                        ),
                      ),
                    );
                    return;
                  }

                  await DatabaseHelper.instancia.agregarFavorito(
                    usuarioId: usuarioId,
                    producto: producto,
                  );

                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Producto agregado a favoritos'),
                    ),
                  );
                },
                icon: const Icon(Icons.favorite_border),
                label: const Text('Agregar a favoritos'),
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
