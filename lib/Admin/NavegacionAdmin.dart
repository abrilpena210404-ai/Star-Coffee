import 'package:flutter/material.dart';
import 'InicioAdmin.dart';
import 'Productos.dart';
import 'Promociones.dart';
import 'Gestion.dart';
import '../Styles/Styles.dart';

class Navegacionadmin extends StatefulWidget {
  const Navegacionadmin({super.key});
  @override
  State<Navegacionadmin> createState() => _NavegacionadminState();
}

class _NavegacionadminState extends State<Navegacionadmin> {
  int paginaActual = 0;
  final List<Widget> paginas = [
    const InicioAdmin(),
    const ProductosAdmin(),
    const PromocionesAdmin(),
    const Gestion(),
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
                  icono: Icons.coffee_outlined,
                  texto: 'Productos',
                  index: 1,
                ),
                boton(
                  icono: Icons.local_offer_outlined,
                  texto: 'Promociones',
                  index: 2,
                ),
                boton(icono: Icons.settings_outlined, texto: 'Gestión', index: 3),
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
