import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Styles/Styles.dart';

class UbicacionScreen extends StatefulWidget {
  const UbicacionScreen({super.key});

  @override
  State<UbicacionScreen> createState() => _UbicacionScreenState();
}

class _UbicacionScreenState extends State<UbicacionScreen> {
  static const LatLng ubicacionCafe = LatLng(20.494459, -99.182332);

  Future<void> abrirGoogleMaps() async {
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1'
      '&query=${ubicacionCafe.latitude},${ubicacionCafe.longitude}',
    );

    try {
      final abierto = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );

      if (!abierto && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir Google Maps')),
        );
      }
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir Google Maps')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final alturaPantalla = MediaQuery.sizeOf(context).height;

    return Scaffold(
      backgroundColor: AppColores.cremaClaro,
      appBar: AppBar(
        backgroundColor: AppColores.cremaClaro,
        elevation: 0,
        title: const Text(
          'Ubicación',
          style: TextStyle(
            fontSize: 25,
            color: AppColores.textoPrincipal,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¡Ven a visitarnos!',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColores.textoPrincipal,
              ),
            ),

            const SizedBox(height: 7),

            const Text(
              'Encuéntranos fácilmente en el mapa.',
              style: TextStyle(fontSize: 14, color: AppColores.textoSecundario),
            ),

            const SizedBox(height: 22),

            // ===================================
            // MAPA GRANDE
            // ===================================
            Container(
              height: alturaPantalla * 0.46,
              constraints: const BoxConstraints(minHeight: 290, maxHeight: 470),
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColores.cafeOscuro.withOpacity(0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: ubicacionCafe,
                    zoom: 16,
                  ),
                  markers: {
                    const Marker(
                      markerId: MarkerId('starcoffee'),
                      position: ubicacionCafe,
                      infoWindow: InfoWindow(
                        title: 'Star Coffee',
                        snippet:
                            'Universidad Tecnológica del Valle del Mezquital',
                      ),
                    ),
                  },
                  zoomControlsEnabled: true,
                  myLocationButtonEnabled: false,
                  mapToolbarEnabled: true,
                  compassEnabled: true,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ===================================
            // TARJETA DE INFORMACIÓN
            // ===================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColores.blanco,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColores.beige),
                boxShadow: [
                  BoxShadow(
                    color: AppColores.cafeOscuro.withOpacity(0.06),
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
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColores.beige,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.local_cafe_rounded,
                          color: AppColores.cafeOscuro,
                          size: 28,
                        ),
                      ),

                      const SizedBox(width: 14),

                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Star Coffee',
                              style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                                color: AppColores.textoPrincipal,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Tu cafetería favorita',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColores.textoSecundario,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  const Divider(color: AppColores.beige),

                  const SizedBox(height: 15),

                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: AppColores.cafeOscuro,
                        size: 24,
                      ),

                      SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          'Universidad Tecnológica del '
                          'Valle del Mezquital',
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.4,
                            color: AppColores.textoSecundario,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // ===================================
                  // BOTÓN DE GOOGLE MAPS
                  // ===================================
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: abrirGoogleMaps,
                      icon: const Icon(Icons.directions_outlined),
                      label: const Text(
                        'Cómo llegar',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColores.cafeOscuro,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
