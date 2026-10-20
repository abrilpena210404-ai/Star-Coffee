import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../Styles/Styles.dart';
import '../Repositorio/promocion_firebase.dart';
import 'package:image_picker/image_picker.dart';
import '../servicios/cloudinary_service.dart';

class PromocionesAdmin extends StatefulWidget {
  const PromocionesAdmin({super.key});

  @override
  State<PromocionesAdmin> createState() => _PromocionesAdminState();
}

class _PromocionesAdminState extends State<PromocionesAdmin> {
  final PromocionFirebase _repositorio = PromocionFirebase();
  List<Map<String, dynamic>> promociones = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarPromociones();
  }

  void _mensaje(String texto) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(texto)));
  }

  Future<void> cargarPromociones() async {
    try {
      final datos = await _repositorio.obtenerPromociones();
      if (!mounted) return;
      setState(() {
        promociones = datos;
        cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => cargando = false);
      _mensaje('No se pudieron cargar las promociones: $e');
    }
  }

  Future<void> agregarPromocion() async {
    await _formularioPromocion();
  }

  Future<void> editarPromocion(Map<String, dynamic> promo) async {
    await _formularioPromocion(promo: promo);
  }

  Future<void> _formularioPromocion({Map<String, dynamic>? promo}) async {
    final titulo = TextEditingController(
      text: promo?['titulo']?.toString() ?? '',
    );
    final descripcion = TextEditingController(
      text: promo?['descripcion']?.toString() ?? '',
    );
    final descuento = TextEditingController(
      text: promo?['descuento']?.toString() ?? '',
    );
    XFile? imagenSeleccionada;
    String imagenUrl = promo?['imagen']?.toString() ?? '';
    Uint8List? vistaPrevia;
    bool guardando = false;
    final editando = promo != null;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, actualizarDialogo) => AlertDialog(
          backgroundColor: AppColores.cremaClaro,
          title: Text(
            editando ? 'Editar promoción' : 'Nueva promoción',
            style: const TextStyle(
              color: AppColores.cafeOscuro,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                campo(titulo, 'Título'),
                campo(descripcion, 'Descripción'),
                campo(descuento, 'Descuento %', numerico: true),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: SizedBox(
                    height: 130,
                    width: double.infinity,
                    child: vistaPrevia != null
                        ? Image.memory(vistaPrevia!, fit: BoxFit.cover)
                        : imagenUrl.startsWith('https://')
                        ? Image.network(
                            imagenUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.image_not_supported_outlined),
                          )
                        : const ColoredBox(
                            color: AppColores.beige,
                            child: Center(
                              child: Icon(
                                Icons.image_outlined,
                                size: 42,
                                color: AppColores.cafeOscuro,
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: guardando
                      ? null
                      : () async {
                          try {
                            final foto = await ImagePicker().pickImage(
                              source: ImageSource.gallery,
                              imageQuality: 80,
                              maxWidth: 1200,
                            );
                            if (foto == null) return;
                            final bytes = await foto.readAsBytes();
                            if (bytes.length > 5 * 1024 * 1024) {
                              _mensaje('La imagen no debe superar los 5 MB');
                              return;
                            }
                            if (!dialogContext.mounted) return;
                            actualizarDialogo(() {
                              imagenSeleccionada = foto;
                              vistaPrevia = bytes;
                            });
                          } catch (e) {
                            _mensaje('No se pudo seleccionar la foto: $e');
                          }
                        },
                  icon: const Icon(Icons.photo_library_outlined),
                  label: Text(
                    editando ? 'Cambiar imagen' : 'Seleccionar imagen',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: guardando ? null : () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColores.cafeOscuro,
                foregroundColor: Colors.white,
              ),
              onPressed: guardando
                  ? null
                  : () async {
                      final porcentaje = double.tryParse(
                        descuento.text.trim().replaceAll(',', '.'),
                      );
                      if (titulo.text.trim().isEmpty ||
                          descripcion.text.trim().isEmpty) {
                        _mensaje('Completa el título y la descripción');
                        return;
                      }
                      if (porcentaje == null ||
                          !porcentaje.isFinite ||
                          porcentaje <= 0 ||
                          porcentaje > 100) {
                        _mensaje(
                          'Ingresa un descuento entre 0 y 100 (mayor a 0)',
                        );
                        return;
                      }
                      if (!editando && imagenSeleccionada == null) {
                        _mensaje('Selecciona una imagen para la promoción');
                        return;
                      }
                      actualizarDialogo(() => guardando = true);
                      try {
                        if (imagenSeleccionada != null) {
                          imagenUrl = await CloudinaryService.subirImagen(
                            imagenSeleccionada!,
                          );
                        }
                        if (editando) {
                          await _repositorio.actualizarPromocion(
                            id: promo['id'].toString(),
                            titulo: titulo.text,
                            descripcion: descripcion.text,
                            descuento: porcentaje,
                            imagen: imagenUrl,
                          );
                        } else {
                          await _repositorio.agregarPromocion(
                            titulo: titulo.text,
                            descripcion: descripcion.text,
                            descuento: porcentaje,
                            imagen: imagenUrl,
                          );
                        }
                        if (!dialogContext.mounted) return;
                        Navigator.pop(dialogContext);
                        await cargarPromociones();
                        _mensaje(
                          editando
                              ? 'Promoción actualizada'
                              : 'Promoción creada',
                        );
                      } catch (e) {
                        _mensaje('No se pudo guardar la promoción: $e');
                        if (dialogContext.mounted) {
                          actualizarDialogo(() => guardando = false);
                        }
                      }
                    },
              child: Text(guardando ? 'Guardando...' : 'Guardar'),
            ),
          ],
        ),
      ),
    );
    //titulo.dispose();
    //descripcion.dispose();
    //descuento.dispose();
  }

  Widget campo(
    TextEditingController controller,
    String texto, {
    bool numerico = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: numerico
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        decoration: InputDecoration(
          labelText: texto,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }

  Future<void> eliminar(String id) async {
    try {
      await _repositorio.eliminarPromocion(id);
      await cargarPromociones();
      _mensaje('Promoción eliminada');
    } catch (e) {
      _mensaje('No se pudo eliminar la promoción: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColores.cremaClaro,
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
              Expanded(
                child: cargando
                    ? const Center(child: CircularProgressIndicator())
                    : promociones.isEmpty
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
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(18, 2, 18, 30),
                        itemCount: promociones.length,
                        itemBuilder: (context, index) {
                          final promo = promociones[index];
                          final imagen = promo['imagen']?.toString() ?? '';
                          final tieneImagen = imagen.startsWith('https://');
                          return Container(
                            height: 115,
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95),
                              image: tieneImagen
                                  ? DecorationImage(
                                      image: NetworkImage(imagen),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
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
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                gradient: tieneImagen
                                    ? LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.black.withOpacity(0.35),
                                          Colors.black.withOpacity(0.7),
                                        ],
                                      )
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      color: tieneImagen
                                          ? Colors.white.withOpacity(0.18)
                                          : AppColores.beige,
                                      borderRadius: BorderRadius.circular(17),
                                    ),
                                    child: Icon(
                                      Icons.local_offer_rounded,
                                      size: 33,
                                      color: tieneImagen
                                          ? Colors.white
                                          : AppColores.cafeOscuro,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          promo['titulo']?.toString() ??
                                              'Promoción',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w800,
                                            color: tieneImagen
                                                ? Colors.white
                                                : AppColores.textoPrincipal,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          promo['descripcion']?.toString() ??
                                              '',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 11,
                                            height: 1.25,
                                            color: tieneImagen
                                                ? Colors.white70
                                                : AppColores.textoSecundario,
                                          ),
                                        ),
                                        const SizedBox(height: 7),
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
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _botonAccionPromo(
                                        icono: Icons.edit_outlined,
                                        color: AppColores.cafeOscuro,
                                        onTap: () => editarPromocion(promo),
                                      ),
                                      const SizedBox(width: 6),
                                      _botonAccionPromo(
                                        icono: Icons.delete_outline_rounded,
                                        color: Colors.red,
                                        onTap: () =>
                                            eliminar(promo['id'].toString()),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
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
