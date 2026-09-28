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
      {'nombre': 'Cafe', 'ruta': 'assets/images/Cafe.png'},
      {'nombre': 'Frappe1', 'ruta': 'assets/images/Frappe1.jpg'},
      {'nombre': 'pan', 'ruta': 'assets/images/pan.jpg'},
      {'nombre': 'cuernito', 'ruta': 'assets/images/cuernito.jpg'},
      {'nombre': 'pastel1', 'ruta': 'assets/images/pastel1.jpg'},
      {'nombre': 'cheescake', 'ruta': 'assets/images/cheescake.jpg'},
      {'nombre': 'capuccino', 'ruta': 'assets/images/capuccino.jpg'},
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

      body: Container(
        width: double.infinity,
        height: double.infinity,

        // ==========================================
        // FONDO DEGRADADO SUAVE
        // ==========================================
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColores.blanco,
              AppColores.cremaClaro,
              AppColores.crema,
            ],
            stops: [0.0, 0.55, 1.0],
          ),
        ),

        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==========================================
              // ENCABEZADO
              // ==========================================
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Productos',
                            style: TextStyle(
                              fontSize: 27,
                              height: 1,
                              fontWeight: FontWeight.w800,
                              color: AppColores.textoPrincipal,
                              letterSpacing: -0.5,
                            ),
                          ),

                          SizedBox(height: 6),

                          Text(
                            'Gestiona el catálogo de tu cafetería.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColores.textoSecundario,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ======================================
                    // BOTÓN CREAR
                    // ======================================
                    SizedBox(
                      height: 42,
                      child: ElevatedButton.icon(
                        onPressed: agregarProducto,

                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColores.cafeOscuro,
                          foregroundColor: Colors.white,
                          elevation: 0,

                          padding: const EdgeInsets.symmetric(horizontal: 16),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),

                        icon: const Icon(Icons.add_rounded, size: 19),

                        label: const Text(
                          'Crear',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 17),

              // ==========================================
              // BUSCADOR
              // ==========================================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(17),
                    boxShadow: [
                      BoxShadow(
                        color: AppColores.cafeOscuro.withOpacity(0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),

                  child: TextField(
                    controller: buscarController,
                    onChanged: buscarProducto,

                    decoration: InputDecoration(
                      hintText: 'Buscar productos...',

                      hintStyle: const TextStyle(
                        fontSize: 13,
                        color: AppColores.textoSecundario,
                      ),

                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: AppColores.cafeOscuro,
                        size: 21,
                      ),

                      filled: true,
                      fillColor: Colors.white.withOpacity(0.94),

                      contentPadding: const EdgeInsets.symmetric(vertical: 14),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(17),
                        borderSide: BorderSide.none,
                      ),

                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(17),
                        borderSide: BorderSide(
                          color: AppColores.beige.withOpacity(0.85),
                        ),
                      ),

                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(17),
                        borderSide: const BorderSide(
                          color: AppColores.cafeMedio,
                          width: 1.4,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),
              // ==========================================
              // LISTA DE PRODUCTOS
              // ==========================================
              Expanded(
                child: productosFiltrados.isEmpty
                    ? const Center(
                        child: Text(
                          'No hay productos registrados',
                          style: TextStyle(color: AppColores.textoSecundario),
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),

                        padding: const EdgeInsets.fromLTRB(18, 2, 18, 25),

                        itemCount: productosFiltrados.length,

                        itemBuilder: (context, index) {
                          final producto = productosFiltrados[index];

                          final int stock =
                              (producto['stock'] as num?)?.toInt() ?? 0;

                          final String imagen =
                              producto['imagen']?.toString() ?? '';

                          return Container(
                            height: 105,
                            margin: const EdgeInsets.only(bottom: 11),

                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95),

                              borderRadius: BorderRadius.circular(17),

                              border: Border.all(
                                color: AppColores.beige.withOpacity(0.75),
                                width: 0.8,
                              ),

                              boxShadow: [
                                BoxShadow(
                                  color: AppColores.cafeOscuro.withOpacity(
                                    0.06,
                                  ),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),

                            child: Row(
                              children: [
                                // ==================================
                                // IMAGEN
                                // ==================================
                                ClipRRect(
                                  borderRadius: const BorderRadius.horizontal(
                                    left: Radius.circular(17),
                                  ),

                                  child: SizedBox(
                                    width: 95,
                                    height: double.infinity,

                                    child: imagen.isNotEmpty
                                        ? Image.asset(
                                            imagen,
                                            fit: BoxFit.cover,

                                            errorBuilder:
                                                (context, error, stackTrace) {
                                                  return Container(
                                                    color: AppColores.beige,

                                                    child: const Icon(
                                                      Icons.local_cafe_rounded,
                                                      size: 40,
                                                      color:
                                                          AppColores.cafeOscuro,
                                                    ),
                                                  );
                                                },
                                          )
                                        : Container(
                                            color: AppColores.beige,

                                            child: const Icon(
                                              Icons.local_cafe_rounded,
                                              size: 40,
                                              color: AppColores.cafeOscuro,
                                            ),
                                          ),
                                  ),
                                ),

                                // ==================================
                                // INFORMACIÓN
                                // ==================================
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      11,
                                      9,
                                      5,
                                      8,
                                    ),

                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,

                                      children: [
                                        Text(
                                          producto['nombre']?.toString() ??
                                              'Producto',

                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,

                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                            color: AppColores.textoPrincipal,
                                          ),
                                        ),

                                        const SizedBox(height: 2),

                                        Text(
                                          producto['categoria']?.toString() ??
                                              '',

                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,

                                          style: const TextStyle(
                                            fontSize: 10.5,
                                            color: AppColores.textoSecundario,
                                          ),
                                        ),

                                        const SizedBox(height: 4),

                                        Text(
                                          '\$${producto['precio']} MXN',

                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w800,
                                            color: AppColores.cafeOscuro,
                                          ),
                                        ),

                                        const Spacer(),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 9),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // EDITAR
                                      _botonAccionAdmin(
                                        icono: Icons.edit_outlined,
                                        color: AppColores.cafeOscuro,
                                        onTap: () {
                                          editarProducto(producto);
                                        },
                                      ),

                                      const SizedBox(width: 6),

                                      // ELIMINAR
                                      _botonAccionAdmin(
                                        icono: Icons.delete_outline_rounded,
                                        color: Colors.red,
                                        onTap: () {
                                          eliminar(producto['id']);
                                        },
                                      ),
                                    ],
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
        ),
      ),
    );
  }

  Widget _botonAccionAdmin({
    required IconData icono,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColores.beige),
          ),
          child: Icon(icono, size: 18, color: color),
        ),
      ),
    );
  }
}
