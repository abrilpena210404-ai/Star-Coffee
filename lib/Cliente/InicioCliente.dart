import 'dart:async';
import 'package:flutter/material.dart';
import 'Catalogo.dart';
import '../Styles/Styles.dart';
import '../basedatos/database_helper.dart';
import '../Login.dart';
import '../servicios/clima_service.dart';

class InicioCliente extends StatefulWidget {
  const InicioCliente({super.key});
  @override
  State<InicioCliente> createState() => _InicioClienteState();
}

class _InicioClienteState extends State<InicioCliente> {
  String nombreUsuario = 'Cliente';
  List<Map<String, dynamic>> promociones = [];
  List<Map<String, dynamic>> productos = [];
  List<int> favoritosIds = [];
  Map<String, dynamic>? clima;
  bool cargandoClima = true;

  final PageController clienteBannerController = PageController();
  Timer? clienteBannerTimer;
  int bannerClienteActual = 0;
  final List<String> bannersCliente = [
    'assets/images/banner5.jpg',
    'assets/images/banner6.jpg',
    'assets/images/banner7.jpg',
    'assets/images/banner2.jpg',
    'assets/images/banner3.jpg',
  ];

  @override
  void initState() {
    super.initState();
    cargarPromociones();
    iniciarCarruselCliente();
    cargarProductos();
    cargarFavoritos();
    cargarClima();
  }

  Future<void> cargarPromociones() async {
    final datos = await DatabaseHelper.instancia.obtenerPromociones();
    final activas = datos.where((promo) {
      return promo['estado'] == 'Activa';
    }).toList();
    if (!mounted) return;
    setState(() {
      promociones = activas;
    });
  }

  Future<void> cargarProductos() async {
    final datos = await DatabaseHelper.instancia.obtenerProductos();
    if (!mounted) return;
    setState(() {
      productos = datos;
    });
  }

  Future<void> cargarFavoritos() async {
    final datos = await DatabaseHelper.instancia.obtenerFavoritos(1);
    if (!mounted) return;
    setState(() {
      favoritosIds = datos.map((e) => e['productoId'] as int).toList();
    });
  }

  Future<void> cambiarFavorito(Map<String, dynamic> producto) async {
    final id = producto['id'];
    if (favoritosIds.contains(id)) {
      final favoritos = await DatabaseHelper.instancia.obtenerFavoritos(1);
      final favoritoEncontrado = favoritos.firstWhere(
        (f) => f['productoId'] == id,
      );
      await DatabaseHelper.instancia.eliminarFavorito(favoritoEncontrado['id']);
    } else {
      await DatabaseHelper.instancia.agregarFavorito(
        usuarioId: 1,
        producto: producto,
      );
    }
    cargarFavoritos();
  }

  Future<void> cargarClima() async {
    try {
      final datos = await ClimaService().obtenerClima();
      if (!mounted) return;
      setState(() {
        clima = datos;
        cargandoClima = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        cargandoClima = false;
      });
      print('Error al obtener clima: $e');
    }
  }

  Widget productoInicio({
    required String imagen,
    required String nombre,
    required String descripcion,
    required String precio,
    required Map<String, dynamic> productoBD,
  }) {
    final bool esFavorito = favoritosIds.contains(productoBD['id']);

    return GestureDetector(
      onTap: () {
        mostrarDetalleProducto(productoBD);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.96),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColores.beige.withOpacity(0.70),
            width: 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColores.cafeOscuro.withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ======================================
              // IMAGEN
              // ======================================
              Expanded(
                flex: 6,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
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
                    ),

                    // DEGRADADO SUAVE SOBRE FOTO
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
                              Colors.black.withOpacity(0.13),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // FAVORITO
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 33,
                        height: 33,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.93),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            cambiarFavorito(productoBD);
                          },
                          icon: Icon(
                            esFavorito
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            size: 19,
                            color: esFavorito
                                ? Colors.red
                                : AppColores.cafeOscuro,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ======================================
              // INFORMACIÓN
              // ======================================
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(11, 9, 11, 9),
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

                      const SizedBox(height: 3),

                      Text(
                        precio,
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
      ),
    );
  }

  void iniciarCarruselCliente() {
    clienteBannerTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!clienteBannerController.hasClients) {
        return;
      }
      bannerClienteActual++;
      if (bannerClienteActual >= bannersCliente.length) {
        bannerClienteActual = 0;
      }
      clienteBannerController.animateToPage(
        bannerClienteActual,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      if (mounted) {
        setState(() {});
      }
    });
  }

  void mostrarDetalleProducto(Map<String, dynamic> producto) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(25),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 80,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColores.beige,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Center(
                child: Container(
                  height: 180,
                  width: 180,
                  decoration: BoxDecoration(
                    color: AppColores.beige,
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: producto['imagen'] != null && producto['imagen'] != ''
                      ? Image.asset(producto['imagen'], fit: BoxFit.cover)
                      : const Icon(
                          Icons.local_cafe,
                          size: 70,
                          color: AppColores.cafeOscuro,
                        ),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                producto['nombre'],
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColores.textoPrincipal,
                ),
              ),

              const SizedBox(height: 8),

              Text(producto['descripcion'] ?? '', style: AppEstilos.subtitulo),
              const SizedBox(height: 15),
              Text(
                '\$${producto['precio']}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColores.cafeOscuro,
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    cambiarFavorito(producto);
                  },
                  icon: const Icon(Icons.favorite),
                  label: const Text('Agregar a favoritos'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColores.cafeOscuro,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String mensajeClima(double temperatura) {
    if (temperatura >= 28) {
      return 'Hace calor, ¡disfruta algo frío!';
    }
    if (temperatura >= 22) {
      return 'Un clima perfecto para disfrutar un buen café';
    }
    return 'Hace frío, ¡disfruta algo calientito! ';
  }

  IconData iconoClima(double temperatura) {
    if (temperatura >= 28) {
      return Icons.wb_sunny_rounded;
    }
    if (temperatura >= 22) {
      return Icons.wb_cloudy_rounded;
    }
    return Icons.ac_unit_rounded;
  }

  Widget tarjetaClima() {
    if (cargandoClima) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 22),
        padding: const EdgeInsets.all(18),
        decoration: AppEstilos.tarjeta(),
        child: const Center(
          child: CircularProgressIndicator(color: AppColores.cafeOscuro),
        ),
      );
    }

    if (clima == null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 22),
        padding: const EdgeInsets.all(18),
        decoration: AppEstilos.tarjeta(),
        child: const Row(
          children: [
            Icon(Icons.cloud_off, color: AppColores.cafeOscuro, size: 35),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'No se pudo obtener el clima',
                style: TextStyle(
                  color: AppColores.textoPrincipal,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final double temperatura = (clima!['main']['temp'] as num).toDouble();

    final String descripcion = clima!['weather'][0]['description'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 22),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColores.beige,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              iconoClima(temperatura),
              color: AppColores.cafeOscuro,
              size: 32,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${temperatura.toStringAsFixed(0)} °C',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColores.textoPrincipal,
                  ),
                ),

                Text(
                  'Ixmiquilpan',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColores.textoSecundario,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  mensajeClima(temperatura),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColores.cafeOscuro,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColores.cremaClaro,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFDFC), Color(0xFFFFFBF7), Color(0xFFF8F1E8)],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==================================================
                // ENCABEZADO
                // ==================================================
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    children: [
                      // LOGO
                      Container(
                        width: 52,
                        height: 52,
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColores.beige, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: AppColores.cafeOscuro.withOpacity(0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/Logo_1.png',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.local_cafe,
                                color: AppColores.cafeOscuro,
                                size: 27,
                              );
                            },
                          ),
                        ),
                      ),

                      const SizedBox(width: 11),

                      // NOMBRE
                      Expanded(
                        child: Column(
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
                            const SizedBox(height: 1),
                            Text(
                              'Cafe, pan y momentos dulces',
                              style: AppEstilos.subtitulo.copyWith(
                                fontSize: 11,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // PERFIL / CERRAR SESIÓN
                      PopupMenuButton<String>(
                        color: Colors.white,
                        elevation: 6,
                        offset: const Offset(0, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        onSelected: (value) {
                          if (value == 'cerrar') {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => const Login()),
                              (route) => false,
                            );
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem<String>(
                            value: 'cerrar',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.logout_rounded,
                                  color: AppColores.cafeOscuro,
                                  size: 21,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Cerrar sesión',
                                  style: TextStyle(
                                    color: AppColores.textoPrincipal,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        child: Container(
                          width: 43,
                          height: 43,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColores.beige),
                            boxShadow: [
                              BoxShadow(
                                color: AppColores.cafeOscuro.withOpacity(0.07),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.person_outline_rounded,
                            color: AppColores.cafeOscuro,
                            size: 25,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // ==================================================
                // BANNER PRINCIPAL
                // ==================================================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Container(
                        height: 165,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: AppColores.cafeOscuro.withOpacity(0.10),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: PageView.builder(
                            controller: clienteBannerController,
                            itemCount: bannersCliente.length,
                            onPageChanged: (index) {
                              setState(() {
                                bannerClienteActual = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              return Image.asset(
                                bannersCliente[index],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: AppColores.beige,
                                    child: const Icon(
                                      Icons.local_cafe,
                                      size: 55,
                                      color: AppColores.cafeOscuro,
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(bannersCliente.length, (index) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: bannerClienteActual == index ? 20 : 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: bannerClienteActual == index
                                  ? AppColores.cafeOscuro
                                  : AppColores.cafeClaro.withOpacity(0.45),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ==================================================
                // CLIMA
                // ==================================================
                tarjetaClima(),

                const SizedBox(height: 23),

                // ==================================================
                // PRODUCTOS
                // ==================================================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Productos',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            color: AppColores.textoPrincipal,
                          ),
                        ),
                      ),

                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CatalogoScreen(),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 35),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Ver todos',
                              style: TextStyle(
                                color: AppColores.cafeMedio,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 2),
                            Icon(
                              Icons.chevron_right_rounded,
                              size: 18,
                              color: AppColores.cafeMedio,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // ==================================================
                // 6 PRODUCTOS - 2 POR FILA / 3 FILAS
                // ==================================================
                if (productos.isEmpty)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.symmetric(vertical: 35),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.75),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColores.beige),
                    ),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.local_cafe_outlined,
                          size: 40,
                          color: AppColores.cafeClaro,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Aún no hay productos',
                          style: TextStyle(color: AppColores.textoSecundario),
                        ),
                      ],
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),

                      // SOLO 6 EN INICIO
                      itemCount: productos.length > 6 ? 6 : productos.length,

                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 11,
                            mainAxisSpacing: 13,
                            childAspectRatio: 0.72,
                          ),

                      itemBuilder: (context, index) {
                        final productoBD = productos[index];

                        return productoInicio(
                          productoBD: productoBD,
                          imagen: productoBD['imagen'] ?? '',
                          nombre: productoBD['nombre'] ?? 'Producto',
                          descripcion: productoBD['descripcion'] ?? '',
                          precio: '\$${productoBD['precio']}',
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 25),

                // ==================================================
                // PROMOCIONES
                // ==================================================
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Promociones',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      color: AppColores.textoPrincipal,
                    ),
                  ),
                ),

                const SizedBox(height: 11),

                if (promociones.isEmpty)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.symmetric(
                      vertical: 25,
                      horizontal: 18,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.70),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColores.beige),
                    ),
                    child: const Center(
                      child: Text(
                        'No hay promociones disponibles',
                        style: TextStyle(color: AppColores.textoSecundario),
                      ),
                    ),
                  )
                else
                  SizedBox(
                    height: 145,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,

                      // AQUÍ QUEDA ALINEADO CON TODO
                      padding: const EdgeInsets.symmetric(horizontal: 20),

                      itemCount: promociones.length,
                      itemBuilder: (context, index) {
                        final promo = promociones[index];

                        return Container(
                          width: 230,
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF4A210F), Color(0xFF7A4A2A)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColores.cafeOscuro.withOpacity(0.13),
                                blurRadius: 12,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.local_offer_outlined,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),

                                  const Spacer(),

                                  Text(
                                    '${promo['descuento']}% OFF',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),

                              const Spacer(),

                              Text(
                                promo['titulo'] ?? 'Promoción',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                promo['descripcion'] ?? '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 25),
                // ==================================================
                // HORARIOS
                // ==================================================
                tarjetaHorarios(context),

                const SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget producto({
    required String imagen,
    required String nombre,
    required String descripcion,
    required String precio,
    required Map<String, dynamic> productoBD,
  }) {
    return Container(
      width: 175,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              GestureDetector(
                onTap: () {
                  mostrarDetalleProducto(productoBD);
                },
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: Image.asset(
                    imagen,
                    height: 135,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 135,
                        width: double.infinity,
                        color: AppColores.beige,
                        child: const Icon(
                          Icons.coffee,
                          size: 55,
                          color: AppColores.cafeOscuro,
                        ),
                      );
                    },
                  ),
                ),
              ),

              Positioned(
                top: 9,
                right: 9,
                child: Container(
                  width: 35,
                  height: 35,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      cambiarFavorito(productoBD);
                    },
                    icon: Icon(
                      favoritosIds.contains(productoBD['id'])
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: favoritosIds.contains(productoBD['id'])
                          ? Colors.red
                          : AppColores.cafeOscuro,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(13, 12, 13, 0),
            child: Text(
              nombre,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColores.textoPrincipal,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13),
            child: Text(
              descripcion,
              style: const TextStyle(
                fontSize: 12,
                color: AppColores.textoSecundario,
              ),
            ),
          ),

          const Spacer(),

          Padding(
            padding: const EdgeInsets.fromLTRB(13, 0, 13, 13),
            child: Row(
              children: [
                Text(
                  precio,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColores.cafeOscuro,
                  ),
                ),

                const Spacer(),
              ],
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

  Widget tarjetaHorarios(BuildContext context) {
    return GestureDetector(
      onTap: () {
        mostrarHorarios(context);
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 22),
        padding: const EdgeInsets.all(18),
        decoration: AppEstilos.tarjeta(),
        child: Row(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: const BoxDecoration(
                color: AppColores.beige,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.access_time_rounded,
                color: AppColores.cafeOscuro,
              ),
            ),

            const SizedBox(width: 15),

            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Horarios',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColores.textoPrincipal,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Lun - Dom\n7:00 a 22:00',
                    style: TextStyle(color: AppColores.textoSecundario),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColores.cafeOscuro),
          ],
        ),
      ),
    );
  }

  void mostrarHorarios(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: AppColores.cremaClaro,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Horarios de Star Coffee',
            style: TextStyle(
              color: AppColores.textoPrincipal,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Lunes - Viernes'),
              Text('7:00 AM - 10:00 PM'),
              SizedBox(height: 12),
              Text('Sábado'),
              Text('8:00 AM - 10:00 PM'),
              SizedBox(height: 12),
              Text('Domingo'),
              Text('8:00 AM - 9:00 PM'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cerrar',
                style: TextStyle(color: AppColores.cafeOscuro),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    clienteBannerTimer?.cancel();
    clienteBannerController.dispose();
    super.dispose();
  }
}

class ContainerPromocion extends StatelessWidget {
  const ContainerPromocion({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        color: AppColores.crema,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Icon(
        Icons.local_cafe_rounded,
        color: AppColores.cafeOscuro,
        size: 37,
      ),
    );
  }
}
