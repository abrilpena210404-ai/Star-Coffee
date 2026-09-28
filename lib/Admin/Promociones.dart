import 'package:flutter/material.dart';
import '../Styles/Styles.dart';
import '../basedatos/database_helper.dart';

class PromocionesAdmin extends StatefulWidget {
  const PromocionesAdmin({super.key});

  @override
  State<PromocionesAdmin> createState() => _PromocionesAdminState();
}

class _PromocionesAdminState extends State<PromocionesAdmin> {
  List<Map<String, dynamic>> promociones = [];

  @override
  void initState() {
    super.initState();
    cargarPromociones();
  }

  Future<void> cargarPromociones() async {
    final datos = await DatabaseHelper.instancia.obtenerPromociones();
    if (!mounted) return;
    setState(() {
      promociones = datos;
    });
  }

  Future<void> agregarPromocion() async {
    final titulo = TextEditingController();
    final descripcion = TextEditingController();
    final descuento = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColores.cremaClaro,
          title: const Text(
            'Nueva promoción',
            style: TextStyle(
              color: AppColores.cafeOscuro,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                campo(titulo, 'Título'),
                campo(descripcion, 'Descripción'),
                campo(descuento, 'Descuento %'),
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
                await DatabaseHelper.instancia.agregarPromocion(
                  titulo: titulo.text,
                  descripcion: descripcion.text,
                  descuento: double.parse(descuento.text),
                );
                Navigator.pop(context);
                cargarPromociones();
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> editarPromocion(Map<String, dynamic> promo) async {
    final titulo = TextEditingController(text: promo['titulo']);
    final descripcion = TextEditingController(text: promo['descripcion']);
    final descuento = TextEditingController(
      text: promo['descuento'].toString(),
    );
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColores.cremaClaro,
          title: const Text(
            'Editar promoción',
            style: TextStyle(
              color: AppColores.cafeOscuro,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                campo(titulo, 'Título'),
                campo(descripcion, 'Descripción'),
                campo(descuento, 'Descuento %'),
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
                await DatabaseHelper.instancia.actualizarPromocion(
                  id: promo['id'],
                  titulo: titulo.text,
                  descripcion: descripcion.text,
                  descuento: double.parse(descuento.text),
                );
                Navigator.pop(context);
                cargarPromociones();
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Widget campo(TextEditingController controller, String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
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
    await DatabaseHelper.instancia.eliminarPromocion(id);
    cargarPromociones();
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
                            'Promociones',
                            style: TextStyle(
                              fontSize: 27,
                              height: 1,
                              fontWeight: FontWeight.w800,
                              color: AppColores.textoPrincipal,
                              letterSpacing: -0.5,
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
                        onPressed: agregarPromocion,

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

              const SizedBox(height: 22),

              // ==========================================
              // LISTA DE PROMOCIONES
              // ==========================================
              Expanded(
                child: promociones.isEmpty
                    // ======================================
                    // SIN PROMOCIONES
                    // ======================================
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 35),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: const BoxDecoration(
                                  color: AppColores.beige,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.local_offer_outlined,
                                  size: 38,
                                  color: AppColores.cafeOscuro,
                                ),
                              ),

                              const SizedBox(height: 15),

                              const Text(
                                'No hay promociones',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColores.textoPrincipal,
                                ),
                              ),

                              const SizedBox(height: 5),

                              const Text(
                                'Crea una promoción para tus clientes.',
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
                    // ======================================
                    // PROMOCIONES
                    // ======================================
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),

                        padding: const EdgeInsets.fromLTRB(18, 2, 18, 30),

                        itemCount: promociones.length,

                        itemBuilder: (context, index) {
                          final promo = promociones[index];

                          return Container(
                            height: 115,
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),

                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95),

                              borderRadius: BorderRadius.circular(18),

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
                                // ICONO PROMOCIÓN
                                // ==================================
                                Container(
                                  width: 70,
                                  height: 70,

                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        AppColores.crema,
                                        AppColores.beige,
                                      ],
                                    ),

                                    borderRadius: BorderRadius.circular(17),
                                  ),

                                  child: const Icon(
                                    Icons.local_offer_rounded,
                                    size: 33,
                                    color: AppColores.cafeOscuro,
                                  ),
                                ),

                                const SizedBox(width: 12),

                                // ==================================
                                // INFORMACIÓN
                                // ==================================
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        promo['titulo']?.toString() ??
                                            'Promoción',

                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,

                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          color: AppColores.textoPrincipal,
                                        ),
                                      ),

                                      const SizedBox(height: 4),

                                      Text(
                                        promo['descripcion']?.toString() ?? '',

                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,

                                        style: const TextStyle(
                                          fontSize: 11,
                                          height: 1.25,
                                          color: AppColores.textoSecundario,
                                        ),
                                      ),

                                      const SizedBox(height: 7),

                                      // ==============================
                                      // DESCUENTO
                                      // ==============================
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 9,
                                          vertical: 4,
                                        ),

                                        decoration: BoxDecoration(
                                          color: AppColores.crema,

                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),

                                        child: Text(
                                          '${promo['descuento']}% de descuento',

                                          style: const TextStyle(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w700,
                                            color: AppColores.cafeOscuro,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 7),

                                // ==================================
                                // EDITAR + ELIMINAR
                                // ==================================
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _botonAccionPromo(
                                      icono: Icons.edit_outlined,
                                      color: AppColores.cafeOscuro,
                                      onTap: () {
                                        editarPromocion(promo);
                                      },
                                    ),

                                    const SizedBox(width: 6),

                                    _botonAccionPromo(
                                      icono: Icons.delete_outline_rounded,
                                      color: Colors.red,
                                      onTap: () {
                                        eliminar(promo['id']);
                                      },
                                    ),
                                  ],
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

  Widget _botonAccionPromo({
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
