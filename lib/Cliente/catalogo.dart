import 'package:flutter/material.dart';
import 'package:star_coffee/Cliente/DetalleProducto.dart';
import '../Styles/Styles.dart';
import 'package:star_coffee/basedatos/database_helper.dart';

class CatalogoScreen extends StatefulWidget {
  const CatalogoScreen({super.key});
  @override
  State<CatalogoScreen> createState() => _CatalogoScreenState();
}

class _CatalogoScreenState extends State<CatalogoScreen> {
  String categoriaSeleccionada = 'Todos';
  String textoBusqueda = '';
  List<Map<String, dynamic>> productos = [];
  List<Map<String, dynamic>> categorias = [];

  @override
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
    });
  }

  Future<void> cargarCategorias() async {
    final datos = await DatabaseHelper.instancia.obtenerCategorias();
    if (!mounted) return;
    setState(() {
      categorias = datos;
    });
  }

  List<Map<String, dynamic>> get productosFiltrados {
    return productos.where((producto) {
      final coincideCategoria =
          categoriaSeleccionada == 'Todos' ||
          producto['categoria'].toString() == categoriaSeleccionada;
      final texto = textoBusqueda.toLowerCase();
      final coincideBusqueda =
          producto['nombre'].toString().toLowerCase().contains(texto) ||
          producto['descripcion'].toString().toLowerCase().contains(texto);
      return coincideCategoria && coincideBusqueda;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColores.cremaClaro,

      body: Container(
        width: double.infinity,
        height: double.infinity,

        // ==========================================
        // FONDO DEGRADADO MUY SUAVE
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
            stops: [0.0, 0.50, 1.0],
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
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
                child: Row(
                  children: [
                  const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nuestro Catálogo',
                            style: TextStyle(
                              fontSize: 26,
                              height: 1,
                              fontWeight: FontWeight.w800,
                              color: AppColores.textoPrincipal,
                              letterSpacing: -0.5,
                            ),
                          ),

                          SizedBox(height: 6),

                          Text(
                            'Gran variedad de alimentos y bebidas',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColores.textoSecundario,
                            ),
                          ),
                        ],
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
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColores.cafeOscuro.withOpacity(0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: (valor) {
                      setState(() {
                        textoBusqueda = valor;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Buscar café, bebidas o postres',
                      hintStyle: const TextStyle(
                        color: AppColores.textoSecundario,
                        fontSize: 13,
                      ),

                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: AppColores.cafeOscuro,
                        size: 22,
                      ),

                      filled: true,
                      fillColor: Colors.white.withOpacity(0.92),

                      contentPadding: const EdgeInsets.symmetric(vertical: 15),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),

                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(
                          color: AppColores.beige.withOpacity(0.9),
                        ),
                      ),

                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(
                          color: AppColores.cafeMedio,
                          width: 1.4,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ==========================================
              // CATEGORÍAS DINÁMICAS
              // ==========================================
              SizedBox(
                height: 43,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  children: [
                    botonCategoria('Todos'),

                    ...categorias.map(
                      (categoria) =>
                          botonCategoria(categoria['nombre'].toString()),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              Expanded(
                child: productosFiltrados.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 35),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 75,
                                height: 75,
                                decoration: const BoxDecoration(
                                  color: AppColores.beige,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.local_cafe_outlined,
                                  size: 37,
                                  color: AppColores.cafeOscuro,
                                ),
                              ),

                              const SizedBox(height: 15),

                              const Text(
                                'No encontramos productos',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: AppColores.textoPrincipal,
                                ),
                              ),

                              const SizedBox(height: 5),

                              const Text(
                                'Prueba con otra búsqueda o categoría.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColores.textoSecundario,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 3, 20, 30),
                        itemCount: productosFiltrados.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 11,
                              mainAxisSpacing: 13,

                              childAspectRatio: 0.72,
                            ),
                        itemBuilder: (context, index) {
                          final producto = productosFiltrados[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      DetalleProducto(producto: producto),
                                ),
                              );
                            },
                            child: tarjetaProducto(
                              nombre: producto['nombre'] ?? 'Producto',
                              descripcion: producto['descripcion'] ?? '',
                              precio: (producto['precio'] as num).toDouble(),
                              imagen: producto['imagen'] ?? '',
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

  Widget botonCategoria(String categoria) {
    final seleccionado = categoriaSeleccionada == categoria;
    return GestureDetector(
      onTap: () {
        setState(() {
          categoriaSeleccionada = categoria;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: seleccionado
              ? AppColores.cafeOscuro
              : Colors.white.withOpacity(0.82),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: seleccionado ? AppColores.cafeOscuro : AppColores.beige,
          ),
          boxShadow: seleccionado
              ? [
                  BoxShadow(
                    color: AppColores.cafeOscuro.withOpacity(0.12),
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Text(
            categoria,
            style: TextStyle(
              color: seleccionado ? Colors.white : AppColores.textoPrincipal,
              fontWeight: seleccionado ? FontWeight.w700 : FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget tarjetaProducto({
    required String nombre,
    required String descripcion,
    required double precio,
    required String imagen,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),

        borderRadius: BorderRadius.circular(18),

        border: Border.all(
          color: AppColores.beige.withOpacity(0.75),
          width: 0.8,
        ),

        boxShadow: [
          BoxShadow(
            color: AppColores.cafeOscuro.withOpacity(0.07),
            blurRadius: 11,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================
            // IMAGEN
            // ==========================================
            Expanded(
              flex: 6,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  imagen.isNotEmpty
                      ? Image.asset(
                          imagen,
                          fit: BoxFit.cover,

                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppColores.beige,

                              child: const Icon(
                                Icons.local_cafe_rounded,
                                size: 48,
                                color: AppColores.cafeOscuro,
                              ),
                            );
                          },
                        )
                      : Container(
                          color: AppColores.beige,

                          child: const Icon(
                            Icons.local_cafe_rounded,
                            size: 48,
                            color: AppColores.cafeOscuro,
                          ),
                        ),

                  // DEGRADADO MUY SUAVE EN LA FOTO
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 45,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            AppColores.cafeOscuro.withOpacity(0.10),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // CORAZÓN
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.92),
                        shape: BoxShape.circle,

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 6,
                          ),
                        ],
                      ),

                      child: const Icon(
                        Icons.favorite_border_rounded,
                        color: AppColores.cafeOscuro,
                        size: 19,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ==========================================
            // INFORMACIÓN
            // ==========================================
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(11, 9, 11, 10),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColores.textoPrincipal,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Expanded(
                      child: Text(
                        descripcion,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10.5,
                          height: 1.2,
                          color: AppColores.textoSecundario,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${precio.toStringAsFixed(0)} MXN',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColores.cafeOscuro,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget itemNavegacion({
    required IconData icono,
    required String titulo,
    bool seleccionado = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icono,
              color: seleccionado
                  ? AppColores.cafeOscuro
                  : AppColores.textoSecundario,
              size: 25,
            ),
            const SizedBox(height: 3),
            Text(
              titulo,
              style: TextStyle(
                fontSize: 11,
                fontWeight: seleccionado ? FontWeight.bold : FontWeight.normal,
                color: seleccionado
                    ? AppColores.cafeOscuro
                    : AppColores.textoSecundario,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
