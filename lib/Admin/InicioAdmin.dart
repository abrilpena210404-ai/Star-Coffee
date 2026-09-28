import 'dart:async';
import 'package:flutter/material.dart';
import '../Styles/Styles.dart';
import '../basedatos/database_helper.dart';
import 'package:star_coffee/Admin/Productos.dart';
import '../Login.dart';

class InicioAdmin extends StatefulWidget {
  const InicioAdmin({super.key});
  @override
  State<InicioAdmin> createState() => _InicioAdminState();
}

class _InicioAdminState extends State<InicioAdmin> {
  List<Map<String, dynamic>> productos = [];
  int usuariosRegistrados = 0;
  int totalProductos = 0;
  int totalCategorias = 0;
  int totalPromociones = 0;

  String estadoCafeteria = 'Abierta';

  final PageController bannerController = PageController();
  Timer? bannerTimer;
  int bannerActual = 0;

  final List<String> banners = [
    'assets/images/banner1.jpg',
    'assets/images/banner2.webp',
    'assets/images/banner3.jpg',
    'assets/images/banner4.jpg',
    'assets/images/banner5.jpg',
  ];

  @override
  void initState() {
    super.initState();
    cargarDatos();
    iniciarCarrusel();
    cargarProductos();
  }

  void iniciarCarrusel() {
    if (banners.length <= 1) return;
    bannerTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!bannerController.hasClients) return;
      bannerActual++;
      if (bannerActual >= banners.length) {
        bannerActual = 0;
      }
      bannerController.animateToPage(
        bannerActual,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> cargarDatos() async {
    final usuarios = await DatabaseHelper.instancia.obtenerUsuarios();
    final productos = await DatabaseHelper.instancia.contarProductos();
    final categorias = await DatabaseHelper.instancia.contarCategorias();
    final promociones = await DatabaseHelper.instancia.contarPromociones();

    final clientes = usuarios.where((usuario) {
      return usuario['rol'] == 'cliente';
    }).toList();
    if (!mounted) return;
    setState(() {
      usuariosRegistrados = clientes.length;
      totalProductos = productos;
      totalCategorias = categorias;
      totalPromociones = promociones;
    });
  }

  Future<void> cargarProductos() async {
    final datos = await DatabaseHelper.instancia.obtenerProductos();
    if (!mounted) return;
    setState(() {
      productos = datos;
    });
  }

  @override
  void dispose() {
    bannerTimer?.cancel();
    bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColores.cremaClaro,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // parte de arriba de la pantalla
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                color: AppColores.beige,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.local_cafe,
                                color: AppColores.cafeOscuro,
                              ),
                            ),

                            const SizedBox(width: 12),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Star Coffee',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: AppColores.textoPrincipal,
                                  ),
                                ),
                                Text(
                                  'ADMINISTRADOR',
                                  style: AppEstilos.subtitulo.copyWith(
                                    fontSize: 11,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        Row(
                          children: [
                            const SizedBox(width: 10),
                            PopupMenuButton(
                              icon: const CircleAvatar(
                                backgroundColor: AppColores.cafeOscuro,
                                child: Icon(Icons.person, color: Colors.white),
                              ),
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'salir',
                                  child: Text('Cerrar sesión'),
                                ),
                              ],
                              onSelected: (valor) {
                                if (valor == 'salir') {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const Login(),
                                    ),
                                    (route) => false,
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    // TITULO
                    const Text(
                      'Inicio',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: AppColores.textoPrincipal,
                      ),
                    ),

                    const Text(
                      'Resumen de tu cafetería en tiempo real.',
                      style: AppEstilos.subtitulo,
                    ),

                    const SizedBox(height: 20),

                    // BANNER
                    Column(
                      children: [
                        SizedBox(
                          height: 170,
                          width: double.infinity,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: PageView.builder(
                              controller: bannerController,
                              itemCount: banners.length,
                              onPageChanged: (index) {
                                setState(() {
                                  bannerActual = index;
                                });
                              },
                              itemBuilder: (context, index) {
                                return Container(
                                  color: AppColores.beige,
                                  child: Image.asset(
                                    banners[index],
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: AppColores.beige,
                                        child: const Center(
                                          child: Icon(
                                            Icons.image_outlined,
                                            size: 55,
                                            color: AppColores.cafeOscuro,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(banners.length, (index) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: bannerActual == index ? 22 : 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: bannerActual == index
                                    ? AppColores.cafeOscuro
                                    : AppColores.beige,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    // Tarjeta de ESTADISTICAS
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      children: [
                        tarjetaEstadistica(
                          'Total Productos',
                          '$totalProductos',
                          Icons.inventory_2_outlined,
                        ),
                        tarjetaEstadistica(
                          'Promociones Activas',
                          '$totalPromociones',
                          Icons.local_offer_outlined,
                        ),
                        tarjetaEstadistica(
                          'Categorías',
                          '$totalCategorias',
                          Icons.category_outlined,
                        ),
                        tarjetaEstadistica(
                          'Usuarios Registrados',
                          '$usuariosRegistrados',
                          Icons.people_outline,
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Productos',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ProductosAdmin(),
                              ),
                            );
                          },
                          child: const Text('Ver todos >'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),

                      // SOLO MOSTRAMOS LOS PRIMEROS 6
                      itemCount: productos.take(6).length,

                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 14,
                            childAspectRatio: 0.78,
                          ),

                      itemBuilder: (context, index) {
                        final producto = productos[index];

                        final String imagen =
                            producto['imagen']?.toString() ?? '';

                        return Container(
                          decoration: BoxDecoration(
                            color: AppColores.blanco,
                            borderRadius: BorderRadius.circular(18),

                            border: Border.all(
                              color: AppColores.beige.withOpacity(0.75),
                              width: 0.8,
                            ),

                            boxShadow: [
                              BoxShadow(
                                color: AppColores.cafeOscuro.withOpacity(0.07),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),

                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),

                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ================================
                                // IMAGEN DEL PRODUCTO
                                // ================================
                                Expanded(
                                  flex: 6,
                                  child: SizedBox(
                                    width: double.infinity,

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
                                                      size: 48,
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
                                              size: 48,
                                              color: AppColores.cafeOscuro,
                                            ),
                                          ),
                                  ),
                                ),

                                // ================================
                                // INFORMACIÓN
                                // ================================
                                Expanded(
                                  flex: 4,
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      11,
                                      9,
                                      11,
                                      10,
                                    ),

                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // NOMBRE
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

                                        const Spacer(),

                                        // PRECIO
                                        Text(
                                          '\$${producto['precio']} MXN',

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
                      },
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

  Widget tarjetaEstadistica(String titulo, String numero, IconData icono) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppEstilos.tarjeta(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: AppColores.cafeOscuro),
          const Spacer(),
          Text(
            numero,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          Text(titulo, style: AppEstilos.subtitulo),
        ],
      ),
    );
  }

  Widget accion(IconData icono, String texto) {
    return Container(
      margin: const EdgeInsets.all(6),
      decoration: AppEstilos.tarjeta(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icono, size: 35, color: AppColores.cafeOscuro),
          const SizedBox(height: 10),
          Text(texto, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
