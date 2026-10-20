import 'package:flutter/material.dart';
import '../Styles/Styles.dart';
import '../Repositorio/producto_firebase.dart';
import '../Repositorio/categoria_firebase.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../Servicios/cloudinary_service.dart';

class ProductosAdmin extends StatefulWidget {
  const ProductosAdmin({super.key});
  @override
  State<ProductosAdmin> createState() => _ProductosAdminState();
}

class _ProductosAdminState extends State<ProductosAdmin> {
  final ProductoFirebase _productosFirebase = ProductoFirebase();
  final CategoriaFirebase _categoriasFirebase = CategoriaFirebase();

  List<Map<String, dynamic>> productos = [];
  List<Map<String, dynamic>> categorias = [];
  List<Map<String, dynamic>> productosFiltrados = [];
  final TextEditingController buscarController = TextEditingController();
  @override
  void initState() {
    super.initState();
    cargarProductos();
    cargarCategorias();
  }

  Future<void> cargarProductos() async {
    try {
      final datos = await _productosFirebase.obtenerProductos();
      if (!mounted) return;
      setState(() {
        productos = datos;
      });
      buscarProducto(buscarController.text);
    } catch (e) {
      _mostrarError('No se pudieron cargar los productos', e);
    }
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
    try {
      final datos = await _categoriasFirebase.obtenerCategorias();
      if (!mounted) return;
      setState(() => categorias = datos);
    } catch (e) {
      _mostrarError('No se pudieron cargar las categorías', e);
    }
  }

  void _mostrarError(String mensaje, Object error) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$mensaje: $error')));
  }

  @override
  void dispose() {
    buscarController.dispose();
    super.dispose();
  }

  Future<void> agregarProducto() async {
    await cargarCategorias();
    if (!mounted) return;
    final nombre = TextEditingController();
    final descripcion = TextEditingController();
    final precio = TextEditingController();
    final stock = TextEditingController();
    String? categoria;
    XFile? fotoSeleccionada;
    Uint8List? vistaPrevia;
    bool guardando = false;
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
                      value: categorias.any((c) => c['nombre'] == categoria)
                          ? categoria
                          : null,
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
                    ElevatedButton.icon(
                      onPressed: guardando
                          ? null
                          : () async {
                              try {
                                final foto = await ImagePicker().pickImage(
                                  source: ImageSource.gallery,
                                  maxWidth: 1200,
                                  imageQuality: 80,
                                );
                                if (foto == null) return;
                                final bytes = await foto.readAsBytes();
                                if (!context.mounted) return;
                                if (bytes.length > 5 * 1024 * 1024) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'La foto no debe superar 5 MB',
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                cambiarEstado(() {
                                  fotoSeleccionada = foto;
                                  vistaPrevia = bytes;
                                });
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'No se pudo seleccionar la foto: $e',
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Seleccionar desde galería'),
                    ),
                    if (vistaPrevia != null) ...[
                      const SizedBox(height: 10),
                      Image.memory(
                        vistaPrevia!,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                      Text(fotoSeleccionada!.name),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: guardando
                      ? null
                      : () {
                          Navigator.pop(context);
                        },
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColores.cafeOscuro,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: guardando
                      ? null
                      : () async {
                          final precioValor = double.tryParse(precio.text);
                          final stockValor = int.tryParse(stock.text);
                          if (precioValor == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Ingresa un precio válido'),
                              ),
                            );
                            return;
                          }
                          if (precioValor < 5) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('El precio mínimo es de \$5.00'),
                              ),
                            );
                            return;
                          }
                          if (stockValor == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Ingresa un stock válido'),
                              ),
                            );
                            return;
                          }
                          if (stockValor < 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('El stock no puede ser negativo'),
                              ),
                            );
                            return;
                          }
                          if (nombre.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Ingresa el nombre del producto'),
                              ),
                            );
                            return;
                          }
                          if (categoria == null || categoria!.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Selecciona una categoría'),
                              ),
                            );
                            return;
                          }
                          if (fotoSeleccionada == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Selecciona una imagen'),
                              ),
                            );
                            return;
                          }
                          cambiarEstado(() => guardando = true);
                          try {
                            final imagenSeleccionada =
                                await CloudinaryService.subirImagen(
                                  fotoSeleccionada!,
                                );
                            await _productosFirebase.agregarProducto(
                              nombre: nombre.text.trim(),
                              descripcion: descripcion.text.trim(),
                              precio: precioValor,
                              imagen: imagenSeleccionada,
                              categoria: categoria!,
                              stock: stockValor,
                            );
                            if (!context.mounted) return;
                            Navigator.pop(context);
                            await cargarProductos();
                          } catch (e) {
                            _mostrarError('No se pudo guardar el producto', e);
                          } finally {
                            if (context.mounted)
                              cambiarEstado(() => guardando = false);
                          }
                        },
                  child: Text(guardando ? 'Guardando...' : 'Guardar'),
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
    await cargarCategorias();
    if (!mounted) return;
    String? categoria = producto['categoria'];
    XFile? fotoNueva;
    Uint8List? vistaPrevia;
    bool guardando = false;
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
                      value: categorias.any((c) => c['nombre'] == categoria)
                          ? categoria
                          : null,
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
                    const SizedBox(height: 15),
                    ElevatedButton.icon(
                      onPressed: guardando
                          ? null
                          : () async {
                              try {
                                final foto = await ImagePicker().pickImage(
                                  source: ImageSource.gallery,
                                  maxWidth: 1200,
                                  imageQuality: 80,
                                );
                                if (foto == null) return;
                                final bytes = await foto.readAsBytes();
                                if (!context.mounted) return;
                                if (bytes.length > 5 * 1024 * 1024) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'La foto no debe superar 5 MB',
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                cambiarEstado(() {
                                  fotoNueva = foto;
                                  vistaPrevia = bytes;
                                });
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'No se pudo seleccionar la foto: $e',
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Cambiar imagen desde galería'),
                    ),
                    if (vistaPrevia != null) ...[
                      const SizedBox(height: 10),
                      Image.memory(
                        vistaPrevia!,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                      Text(fotoNueva!.name),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: guardando
                      ? null
                      : () {
                          Navigator.pop(context);
                        },
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: guardando
                      ? null
                      : () async {
                          final precioValor = double.tryParse(precio.text);
                          final stockValor = int.tryParse(stock.text);
                          if (precioValor == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Ingresa un precio válido'),
                              ),
                            );
                            return;
                          }
                          if (precioValor < 5) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('El precio mínimo es de \$5.00'),
                              ),
                            );
                            return;
                          }
                          if (stockValor == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Ingresa un stock válido'),
                              ),
                            );
                            return;
                          }
                          if (stockValor < 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('El stock no puede ser negativo'),
                              ),
                            );
                            return;
                          }
                          if (nombre.text.trim().isEmpty ||
                              categoria == null ||
                              categoria!.isEmpty) {
                            _mostrarError(
                              'Completa el nombre y la categoría',
                              'Campos obligatorios',
                            );
                            return;
                          }
                          cambiarEstado(() => guardando = true);
                          try {
                            final imagenFinal = fotoNueva == null
                                ? producto['imagen']?.toString() ?? ''
                                : await CloudinaryService.subirImagen(
                                    fotoNueva!,
                                  );
                            await _productosFirebase.actualizarProducto(
                              id: producto['id'].toString(),
                              nombre: nombre.text.trim(),
                              descripcion: descripcion.text.trim(),
                              precio: precioValor,
                              imagen: imagenFinal,
                              categoria: categoria!,
                              stock: stockValor,
                            );
                            if (!context.mounted) return;
                            Navigator.pop(context);
                            await cargarProductos();
                          } catch (e) {
                            _mostrarError(
                              'No se pudo actualizar el producto',
                              e,
                            );
                          } finally {
                            if (context.mounted)
                              cambiarEstado(() => guardando = false);
                          }
                        },
                  child: Text(guardando ? 'Guardando...' : 'Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget campo(TextEditingController controlador, String texto) {
    final esPrecio = texto == 'Precio';
    final esStock = texto == 'Stock';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controlador,
        keyboardType: esPrecio || esStock
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        inputFormatters: esPrecio
            ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))]
            : esStock
            ? [FilteringTextInputFormatter.digitsOnly]
            : [],
        decoration: InputDecoration(
          labelText: texto,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }

  Future<void> eliminar(String id) async {
    try {
      await _productosFirebase.eliminarProducto(id);
      await cargarProductos();
    } catch (e) {
      _mostrarError('No se pudo eliminar el producto', e);
    }
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
                                        ? (imagen.startsWith('https://')
                                              ? Image.network(
                                                  imagen,
                                                  fit: BoxFit.cover,
                                                  errorBuilder:
                                                      (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) => const Icon(
                                                        Icons
                                                            .local_cafe_rounded,
                                                      ),
                                                )
                                              : Image.asset(
                                                  imagen,
                                                  fit: BoxFit.cover,
                                                  errorBuilder:
                                                      (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) {
                                                        return Container(
                                                          color:
                                                              AppColores.beige,
                                                          child: const Icon(
                                                            Icons
                                                                .local_cafe_rounded,
                                                            size: 40,
                                                            color: AppColores
                                                                .cafeOscuro,
                                                          ),
                                                        );
                                                      },
                                                ))
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
                                          eliminar(producto['id'].toString());
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
