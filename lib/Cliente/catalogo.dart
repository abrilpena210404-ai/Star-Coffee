import 'package:flutter/material.dart';
import '../Styles/Styles.dart';
import 'package:star_coffee/basedatos/database_helper.dart';

class CatalogoScreen extends StatefulWidget {
  const CatalogoScreen({super.key});
  @override
  State<CatalogoScreen> createState() => _CatalogoScreenState();
}

class _CatalogoScreenState extends State<CatalogoScreen> {
  String categoriaSeleccionada = 'Todos';
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

  List<Map<String, dynamic>> get productosFiltrados {
    if (categoriaSeleccionada == 'Todos') {
      return productos;
    }

    return productos
        .where((producto) => producto['categoria'] == categoriaSeleccionada)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColores.cremaClaro,
      body: SafeArea(
        child: Column(
          children: [
            // ENCABEZADO
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColores.cafeOscuro,
                    ),
                  ),

                  const Expanded(
                    child: Text(
                      'Catálogo',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                        color: AppColores.textoPrincipal,
                      ),
                    ),
                  ),

                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.shopping_bag_outlined,
                      color: AppColores.cafeOscuro,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),

            // BUSCADOR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar bebidas o alimentos',
                  hintStyle: const TextStyle(color: AppColores.textoSecundario),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColores.cafeOscuro,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(17),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(17),
                    borderSide: const BorderSide(color: AppColores.beige),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(17),
                    borderSide: const BorderSide(
                      color: AppColores.cafeMedio,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // CATEGORÍAS
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                children: [
                  botonCategoria('Todos'),
                  botonCategoria('Cafés'),
                  botonCategoria('Fríos'),
                  botonCategoria('Postres'),
                  botonCategoria('Snacks'),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // PRODUCTOS
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(20, 5, 20, 25),
                itemCount: productosFiltrados.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.68,
                ),
                itemBuilder: (context, index) {
                  final producto = productosFiltrados[index];

                  return tarjetaProducto(
                    nombre: producto['nombre'] ?? '',
                    descripcion: producto['descripcion'] ?? '',
                    precio: (producto['precio'] as num).toDouble(),
                    imagen: producto['imagen'] ?? '',
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // BARRA INFERIOR
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x18000000),
              blurRadius: 12,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                itemNavegacion(
                  icono: Icons.home_rounded,
                  titulo: 'Inicio',
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                itemNavegacion(
                  icono: Icons.menu_book_rounded,
                  titulo: 'Catálogo',
                  seleccionado: true,
                  onTap: () {},
                ),
                itemNavegacion(
                  icono: Icons.favorite_border_rounded,
                  titulo: 'Favoritos',
                  onTap: () {},
                ),
                itemNavegacion(
                  icono: Icons.grid_view_rounded,
                  titulo: 'Más',
                  onTap: () {},
                ),
              ],
            ),
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
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 10),
        decoration: BoxDecoration(
          color: seleccionado ? AppColores.cafeOscuro : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: seleccionado ? AppColores.cafeOscuro : AppColores.beige,
          ),
        ),
        child: Center(
          child: Text(
            categoria,
            style: TextStyle(
              color: seleccionado ? Colors.white : AppColores.cafeOscuro,
              fontWeight: FontWeight.w600,
              fontSize: 13,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 6,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: imagen.isNotEmpty
                      ? Image.asset(
                          imagen,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppColores.beige,
                              width: double.infinity,
                              child: const Icon(
                                Icons.local_cafe_rounded,
                                size: 55,
                                color: AppColores.cafeOscuro,
                              ),
                            );
                          },
                        )
                      : Container(
                          color: AppColores.beige,
                          width: double.infinity,
                          height: double.infinity,
                          child: const Icon(
                            Icons.local_cafe_rounded,
                            size: 55,
                            color: AppColores.cafeOscuro,
                          ),
                        ),
                ),

                Positioned(
                  top: 9,
                  right: 9,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {},
                      icon: const Icon(
                        Icons.favorite_border,
                        color: AppColores.cafeOscuro,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColores.textoPrincipal,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    descripcion,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      height: 1.3,
                      color: AppColores.textoSecundario,
                    ),
                  ),

                  const Spacer(),

                  Row(
                    children: [
                      Text(
                        '\$${precio.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColores.cafeOscuro,
                        ),
                      ),

                      const Spacer(),

                      Container(
                        width: 31,
                        height: 31,
                        decoration: const BoxDecoration(
                          color: AppColores.cafeOscuro,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 19,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
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
