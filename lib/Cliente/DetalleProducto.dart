import 'package:flutter/material.dart';
import '../Styles/Styles.dart';
import '../basedatos/database_helper.dart';

class DetalleProducto extends StatelessWidget {
  final Map<String, dynamic> producto;

  const DetalleProducto({super.key, required this.producto});

  @override
  Widget build(BuildContext context) {
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

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await DatabaseHelper.instancia.agregarFavorito(
                    usuarioId: 1,
                    producto: producto,
                  );
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Producto agregado a favoritos ❤️'),
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
