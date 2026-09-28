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
  List<Map<String, dynamic>> categorias = [];
  List<Map<String, dynamic>> productosFiltrados = [];

  final TextEditingController buscarController = TextEditingController();

  void initState() {
    super.initState();
    cargarProductos();
    cargarCategorias();
  }

  Future<void> cargarProductos() async {
    final datos = await DatabaseHelper.instancia.obtenerProductos();
    if (!mounted) return;
    setState(() {
      productos = datos;
      productosFiltrados = datos;
    });
  }

  void buscarProducto(String texto) {
    final resultado = productos.where((producto) {
      final nombre = producto['nombre'].toString().toLowerCase();
      return nombre.contains(texto.toLowerCase());
    }).toList();
    setState(() {
      productosFiltrados = resultado;
    });
  }

  Future<void> cargarCategorias() async {
    final datos = await DatabaseHelper.instancia.obtenerCategorias();
    if (!mounted) return;
    setState(() {
      categorias = datos;
    });
  }

  Future<void> agregarProducto() async {
    final nombre = TextEditingController();
    final descripcion = TextEditingController();
    final precio = TextEditingController();
    final stock = TextEditingController();
    final imagenes = [
      {'nombre': 'Latte', 'ruta': 'assets/images/Latte.jpg'},
      {'nombre': 'Cappuccino2', 'ruta': 'assets/images/Cappuccino2.jpg'},
      {'nombre': 'Frappe1', 'ruta': 'assets/images/Frappe1.jpg'},
      {'nombre': 'pan', 'ruta': 'assets/images/pan.jpg'},
      {'nombre': 'cuernito', 'ruta': 'assets/images/cuernito.jpg'},
      {'nombre': 'pastel1', 'ruta': 'assets/images/pastel1.jpg'},
    ];

    String? categoria;
    String imagenSeleccionada = '';

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
                      items: categorias.map((categoriaBD) {
                        return DropdownMenuItem<String>(
                          value: categoriaBD['nombre'],
                          child: Text(categoriaBD['nombre']),
                        );
                      }).toList(),
                      onChanged: (valor) {
                        cambiarEstado(() {
                          categoria = valor!;
                        });
                      },
                      hint: const Text('Selecciona categoría'), //PENDIENTE
                    ),
                    const SizedBox(height: 15),

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Seleccionar imagen',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),

                    const SizedBox(height: 10),

                    DropdownButtonFormField<String>(
                      value: imagenSeleccionada.isEmpty
                          ? null
                          : imagenSeleccionada,
                      decoration: InputDecoration(
                        labelText: 'Imagen del producto',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),

                      hint: const Text('Selecciona una imagen'),

                      items: imagenes.map((imagen) {
                        return DropdownMenuItem<String>(
                          value: imagen['ruta']!,
                          child: Text(imagen['nombre']!),
                        );
                      }).toList(),

                      onChanged: (valor) {
                        cambiarEstado(() {
                          imagenSeleccionada = valor ?? '';
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
                      imagen: imagenSeleccionada,
                      categoria: categoria ?? '',
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

  Future<void> editarProducto(Map<String, dynamic> producto) async {
    final nombre = TextEditingController(text: producto['nombre']);
    final descripcion = TextEditingController(text: producto['descripcion']);
    final precio = TextEditingController(text: producto['precio'].toString());
    final stock = TextEditingController(text: producto['stock'].toString());
    String? categoria = producto['categoria'];

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, cambiarEstado) {
            return AlertDialog(
              backgroundColor: AppColores.cremaClaro,
              title: const Text('Editar producto'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    campo(nombre, 'Nombre'),
                    campo(descripcion, 'Descripción'),
                    campo(precio, 'Precio'),
                    campo(stock, 'Stock'),
                    DropdownButtonFormField<String>(
                      value: categoria,
                      decoration: const InputDecoration(labelText: 'Categoría'),
                      items: categorias.map<DropdownMenuItem<String>>((cat) {
                        return DropdownMenuItem<String>(
                          value: cat['nombre'].toString(),
                          child: Text(cat['nombre'].toString()),
                        );
                      }).toList(),
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
                  onPressed: () async {
                    await DatabaseHelper.instancia.actualizarProducto(
                      id: producto['id'],
                      nombre: nombre.text,
                      descripcion: descripcion.text,
                      precio: double.parse(precio.text),
                      imagen: producto['imagen'],
                      categoria: categoria ?? '',
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
        actions: [
          TextButton(
            onPressed: agregarProducto,
            child: const Text(
              '+ Crear',
              style: TextStyle(
                color: AppColores.cafeOscuro,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextField(
              controller: buscarController,
              onChanged: buscarProducto,
              decoration: InputDecoration(
                hintText: 'Buscar productos...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          Expanded(
            child: productosFiltrados.isEmpty
                ? const Center(
                    child: Text(
                      'No hay productos registrados',
                      style: TextStyle(color: AppColores.cafeOscuro),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),

                    itemCount: productosFiltrados.length,

                    itemBuilder: (context, index) {
                      final producto = productosFiltrados[index];

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

                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.asset(
                                  producto['imagen'],
                                  fit: BoxFit.cover,
                                ),
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
                                editarProducto(producto);
                              },

                              icon: const Icon(
                                Icons.edit_outlined,
                                color: AppColores.cafeOscuro,
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
          ),
        ],
      ),
    );
  }
}
