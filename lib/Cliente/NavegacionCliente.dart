import 'package:flutter/material.dart';

import 'InicioCliente.dart';
import 'Catalogo.dart';
import 'Favoritos.dart';
import 'Ubicacion.dart';

import '../Styles/Styles.dart';

class NavegacionCliente extends StatefulWidget {
  const NavegacionCliente({super.key});
  @override
  State<NavegacionCliente> createState() => _NavegacionClienteState();
}

class _NavegacionClienteState extends State<NavegacionCliente> {
  int paginaActual = 0;
  final List<Widget> paginas = [
    const InicioCliente(),
    const CatalogoScreen(),
    const FavoritosScreen(usuarioId: 1),
    const UbicacionScreen(),
  ];

  void cambiarPagina(int index) {
    setState(() {
      paginaActual = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: paginas[paginaActual],
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
                boton(icono: Icons.home_rounded, texto: 'Inicio', index: 0),

                boton(
                  icono: Icons.menu_book_rounded,

                  texto: 'Catálogo',

                  index: 1,
                ),

                boton(
                  icono: Icons.favorite_rounded,

                  texto: 'Favoritos',

                  index: 2,
                ),

                boton(icono: Icons.location_on_rounded, texto: 'Más', index: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget boton({
    required IconData icono,

    required String texto,

    required int index,
  }) {
    final seleccionado = paginaActual == index;

    return InkWell(
      onTap: () {
        cambiarPagina(index);
      },

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
              texto,

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
