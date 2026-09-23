import 'package:flutter/material.dart';
import '../Styles/Styles.dart';
import '../basedatos/database_helper.dart';
import 'package:star_coffee/Admin/Productos.dart';

class InicioAdmin extends StatefulWidget {
  const InicioAdmin({super.key});

  @override
  State<InicioAdmin> createState() => _InicioAdminState();
}

class _InicioAdminState extends State<InicioAdmin> {
  int usuariosRegistrados = 0;

  @override
  void initState() {
    super.initState();
    cargarUsuarios();
  }

  Future<void> cargarUsuarios() async {
    final usuarios = await DatabaseHelper.instancia.obtenerUsuarios();

    final clientes = usuarios.where((usuario) {
      return usuario['rol'] == 'cliente';
    }).toList();

    if (!mounted) return;

    setState(() {
      usuariosRegistrados = clientes.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColores.cremaClaro,

      body: SafeArea(
        child: Column(
          children: [
            // CONTENIDO
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    // HEADER
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
                            const Text(
                              'Hola, Admin',

                              style: TextStyle(
                                color: AppColores.textoPrincipal,

                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(width: 10),

                            CircleAvatar(
                              backgroundColor: AppColores.cafeOscuro,

                              child: const Icon(
                                Icons.person,

                                color: Colors.white,
                              ),
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
                    Container(
                      height: 170,

                      width: double.infinity,

                      decoration: BoxDecoration(
                        color: AppColores.cafeMedio,

                        borderRadius: BorderRadius.circular(22),
                      ),

                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,

                          children: [
                            Icon(
                              Icons.local_cafe_rounded,

                              size: 60,

                              color: Colors.white,
                            ),

                            SizedBox(height: 10),

                            Text(
                              'Todo funciona mejor\ncon un gran café',

                              textAlign: TextAlign.center,

                              style: TextStyle(
                                color: Colors.white,

                                fontSize: 22,

                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // ESTADISTICAS
                    GridView.count(
                      shrinkWrap: true,

                      physics: const NeverScrollableScrollPhysics(),

                      crossAxisCount: 2,

                      crossAxisSpacing: 14,

                      mainAxisSpacing: 14,

                      children: [
                        tarjetaEstadistica(
                          'Total Productos',

                          '0',

                          Icons.inventory_2_outlined,
                        ),

                        tarjetaEstadistica(
                          'Promociones Activas',

                          '0',

                          Icons.local_offer_outlined,
                        ),

                        tarjetaEstadistica(
                          'Categorías',

                          '0',

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

                    // ESTADO
                    Container(
                      padding: const EdgeInsets.all(18),

                      decoration: AppEstilos.tarjeta(),

                      child: Row(
                        children: [
                          Container(
                            width: 45,

                            height: 45,

                            decoration: const BoxDecoration(
                              color: Colors.green,

                              shape: BoxShape.circle,
                            ),
                          ),

                          const SizedBox(width: 15),

                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                Text(
                                  'Estado de la Cafetería',

                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),

                                Text(
                                  'Abierta - Operando normalmente',

                                  style: AppEstilos.subtitulo,
                                ),
                              ],
                            ),
                          ),

                          ElevatedButton(
                            onPressed: () {},

                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColores.beige,

                              foregroundColor: AppColores.cafeOscuro,
                            ),

                            child: const Text('Cambiar'),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    const Text(
                      'Acciones rápidas',

                      style: TextStyle(
                        fontSize: 20,

                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    GridView.count(
                      shrinkWrap: true,

                      physics: const NeverScrollableScrollPhysics(),

                      crossAxisCount: 2,

                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ProductosAdmin(),
                              ),
                            );
                          },

                          child: accion(Icons.inventory_2, 'Productos'),
                        ),
                        accion(Icons.local_offer, 'Promociones'),

                        accion(Icons.category, 'Categorías'),

                        accion(Icons.people, 'Usuarios'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // BARRA INFERIOR
            Container(
              height: 70,

              decoration: const BoxDecoration(color: AppColores.cafeOscuro),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,

                children: [
                  menuInferior(Icons.home, 'Inicio', true),

                  menuInferior(Icons.inventory_2, 'Productos', false),

                  menuInferior(Icons.local_offer, 'Promos', false),

                  menuInferior(Icons.settings, 'Gestión', false),
                ],
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

  Widget menuInferior(IconData icono, String texto, bool seleccionado) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,

      children: [
        Icon(icono, color: Colors.white),

        Text(texto, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }
}
