import 'package:flutter/material.dart';
import '../Styles/Styles.dart';
import '../basedatos/database_helper.dart';

class ProductosAdmin extends StatefulWidget {
  const ProductosAdmin({super.key});

  @override
  State<ProductosAdmin> createState() => _ProductosAdminState();
}

class _ProductosAdminState extends State<ProductosAdmin> {
  List<Map<String, dynamic>> productos = [];

  @override
  void initState() {
    super.initState();
    cargarProductos();
  }

  Future<void> cargarProductos() async {
    final datos = await DatabaseHelper.instancia.obtenerProductos();

    if (!mounted) return;

    setState(() {
      productos = datos;
    });
  }

  Future<void> agregarProducto() async {
    final nombre = TextEditingController();
    final descripcion = TextEditingController();
    final precio = TextEditingController();
    final stock = TextEditingController();

    String categoria = 'Cafés';

    await showDialog(
      context: context,

      builder: (context) {
        return StatefulBuilder(
          builder: (context, cambiarEstado) {
            return AlertDialog(
              backgroundColor: AppColores.cremaClaro,

              title: const Text(
                'Nuevo producto',

                style: TextStyle(
                  color: AppColores.cafeOscuro,

                  fontWeight: FontWeight.bold,
                ),
              ),

              content: SingleChildScrollView(
                child: Column(
                  children: [
                    campo(nombre, 'Nombre del producto'),

                    campo(descripcion, 'Descripción'),

                    campo(precio, 'Precio'),

                    campo(stock, 'Stock'),

                    DropdownButtonFormField<String>(
                      value: categoria,

                      decoration: const InputDecoration(labelText: 'Categoría'),

                      items: const [
                        DropdownMenuItem(value: 'Cafés', child: Text('Cafés')),

                        DropdownMenuItem(value: 'Fríos', child: Text('Fríos')),

                        DropdownMenuItem(
                          value: 'Postres',

                          child: Text('Postres'),
                        ),

                        DropdownMenuItem(
                          value: 'Snacks',

                          child: Text('Snacks'),
                        ),
                      ],

                      onChanged: (valor) {
                        cambiarEstado(() {
                          categoria = valor!;
                        });
                      },
                    ),
                  ],
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },

                  child: const Text('Cancelar'),
                ),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColores.cafeOscuro,

                    foregroundColor: Colors.white,
                  ),

                  onPressed: () async {
                    await DatabaseHelper.instancia.agregarProducto(
                      nombre: nombre.text,

                      descripcion: descripcion.text,

                      precio: double.parse(precio.text),

                      imagen: '',

                      categoria: categoria,

                      stock: int.parse(stock.text),
                    );

                    Navigator.pop(context);

                    cargarProductos();
                  },

                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget campo(TextEditingController controlador, String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),

      child: TextField(
        controller: controlador,

        decoration: InputDecoration(
          labelText: texto,

          filled: true,

          fillColor: Colors.white,

          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }

  Future<void> eliminar(int id) async {
    await DatabaseHelper.instancia.eliminarProducto(id);

    cargarProductos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColores.cremaClaro,

      appBar: AppBar(
        backgroundColor: AppColores.cremaClaro,

        elevation: 0,

        title: const Text(
          'Productos',

          style: TextStyle(
            color: AppColores.textoPrincipal,

            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColores.cafeOscuro,

        foregroundColor: Colors.white,

        onPressed: agregarProducto,

        child: const Icon(Icons.add),
      ),

      body: productos.isEmpty
          ? const Center(
              child: Text(
                'No hay productos registrados',

                style: TextStyle(color: AppColores.cafeOscuro),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),

              itemCount: productos.length,

              itemBuilder: (context, index) {
                final producto = productos[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 15),

                  padding: const EdgeInsets.all(15),

                  decoration: AppEstilos.tarjeta(),

                  child: Row(
                    children: [
                      Container(
                        width: 60,

                        height: 60,

                        decoration: BoxDecoration(
                          color: AppColores.beige,

                          borderRadius: BorderRadius.circular(15),
                        ),

                        child: const Icon(
                          Icons.local_cafe,

                          color: AppColores.cafeOscuro,
                        ),
                      ),

                      const SizedBox(width: 15),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text(
                              producto['nombre'],

                              style: const TextStyle(
                                fontWeight: FontWeight.bold,

                                fontSize: 17,
                              ),
                            ),

                            Text(
                              producto['categoria'],

                              style: AppEstilos.subtitulo,
                            ),

                            Text(
                              '\$${producto['precio']}',

                              style: const TextStyle(
                                color: AppColores.cafeOscuro,

                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      IconButton(
                        onPressed: () {
                          eliminar(producto['id']);
                        },

                        icon: const Icon(
                          Icons.delete_outline,

                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
