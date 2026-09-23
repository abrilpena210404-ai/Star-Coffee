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
      appBar: AppBar(
        backgroundColor: AppColores.cremaClaro,
        elevation: 0,
        title: const Text(
          'Promociones',
          style: TextStyle(
            color: AppColores.textoPrincipal,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColores.cafeOscuro,
        foregroundColor: Colors.white,
        onPressed: agregarPromocion,
        child: const Icon(Icons.add),
      ),

      body: promociones.isEmpty
          ? const Center(
              child: Text(
                'No hay promociones',
                style: TextStyle(color: AppColores.cafeOscuro),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: promociones.length,
              itemBuilder: (context, index) {
                final promo = promociones[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.all(18),
                  decoration: AppEstilos.tarjeta(),
                  child: Row(
                    children: [
                      Container(
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(
                          color: AppColores.beige,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(
                          Icons.local_offer,
                          color: AppColores.cafeOscuro,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              promo['titulo'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                            Text(
                              promo['descripcion'],
                              style: AppEstilos.subtitulo,
                            ),
                            Text(
                              '${promo['descuento']}% descuento',
                              style: const TextStyle(
                                color: AppColores.cafeOscuro,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          eliminar(promo['id']);
                        },
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
