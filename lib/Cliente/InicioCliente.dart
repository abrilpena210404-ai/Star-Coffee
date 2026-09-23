import 'package:flutter/material.dart';
import 'Catalogo.dart';
import '../Styles/Styles.dart';

class InicioCliente extends StatefulWidget {
  const InicioCliente({super.key});

  @override
  State<InicioCliente> createState() => _InicioClienteState();
}

class _InicioClienteState extends State<InicioCliente> {
  String nombreUsuario = 'Cliente';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColores.cremaClaro,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ENCABEZADO
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 10),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: AppColores.cafeOscuro,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.coffee,
                        color: Colors.white,
                        size: 27,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Hola,',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColores.textoSecundario,
                            ),
                          ),

                          Text(
                            nombreUsuario,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColores.textoPrincipal,
                            ),
                          ),
                        ],
                      ),
                    ),

                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.notifications_none_rounded,
                        color: AppColores.cafeOscuro,
                        size: 29,
                      ),
                    ),
                  ],
                ),
              ),

              // BUSCADOR
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 12,
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: '¿Qué se te antoja hoy?',
                    hintStyle: const TextStyle(
                      color: AppColores.textoSecundario,
                      fontSize: 15,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColores.cafeOscuro,
                    ),
                    suffixIcon: const Icon(
                      Icons.tune,
                      color: AppColores.cafeOscuro,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
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

              // BANNER PRINCIPAL
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Container(
                  height: 190,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: AppColores.cafeOscuro,
                    image: const DecorationImage(
                      image: AssetImage('assets/images/banner_inicio.jpg'),
                      fit: BoxFit.cover,
                      opacity: 0.55,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Tu momento,\ntu café',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            height: 1.05,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          'Disfruta sabores que hacen\nespecial cada momento.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),

                        const SizedBox(height: 14),

                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColores.crema,
                            foregroundColor: AppColores.cafeOscuro,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 11,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            'Ver menú',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // CATEGORÍAS
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 22),
                child: Text(
                  'Categorías',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColores.textoPrincipal,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              SizedBox(
                height: 105,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  children: [
                    categoria(icono: Icons.coffee, titulo: 'Cafés'),
                    categoria(
                      icono: Icons.local_drink_outlined,
                      titulo: 'Fríos',
                    ),
                    categoria(icono: Icons.cake_outlined, titulo: 'Postres'),
                    categoria(
                      icono: Icons.breakfast_dining_outlined,
                      titulo: 'Snacks',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // DESTACADOS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Destacados',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColores.textoPrincipal,
                      ),
                    ),

                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Ver todos',
                        style: TextStyle(
                          color: AppColores.cafeOscuro,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                height: 255,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  children: [
                    producto(
                      imagen: 'assets/images/Logo_1.png',
                      nombre: 'Cappuccino',
                      descripcion: 'Cremoso y suave',
                      precio: '\$65',
                    ),
                    producto(
                      imagen: 'assets/images/latte.jpg',
                      nombre: 'Latte',
                      descripcion: 'Clásico y delicioso',
                      precio: '\$70',
                    ),
                    producto(
                      imagen: 'assets/images/frappe.jpg',
                      nombre: 'Frappé',
                      descripcion: 'Dulce y refrescante',
                      precio: '\$75',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // PROMOCIÓN
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 22),
                child: Text(
                  'Promociones',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColores.textoPrincipal,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColores.beige,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Row(
                    children: [
                      ContainerPromocion(),

                      SizedBox(width: 15),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '2x1 en Cappuccino',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: AppColores.textoPrincipal,
                              ),
                            ),

                            SizedBox(height: 5),

                            Text(
                              'Disfruta el doble de sabor este viernes.',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColores.textoSecundario,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
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
                  seleccionado: true,
                  onTap: () {},
                ),
                itemNavegacion(
                  icono: Icons.menu_book_rounded,
                  titulo: 'Catálogo',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CatalogoScreen()),
                    );
                  },
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

  Widget categoria({required IconData icono, required String titulo}) {
    return Container(
      width: 90,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: AppColores.beige,
              shape: BoxShape.circle,
              border: Border.all(color: AppColores.cafeClaro.withOpacity(0.5)),
            ),
            child: Icon(icono, color: AppColores.cafeOscuro, size: 29),
          ),

          const SizedBox(height: 7),

          Text(
            titulo,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColores.textoPrincipal,
            ),
          ),
        ],
      ),
    );
  }

  Widget producto({
    required String imagen,
    required String nombre,
    required String descripcion,
    required String precio,
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
              ClipRRect(
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
                  child: const Icon(
                    Icons.favorite_border,
                    color: AppColores.cafeOscuro,
                    size: 21,
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

                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: AppColores.cafeOscuro,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                ),
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
