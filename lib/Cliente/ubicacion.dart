import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../Styles/Styles.dart';

class UbicacionScreen extends StatefulWidget {
  const UbicacionScreen({super.key});
  @override
  State<UbicacionScreen> createState() => _UbicacionScreenState();
}

class _UbicacionScreenState extends State<UbicacionScreen> {
  final LatLng ubicacionCafe = LatLng(20.494459, -99.182332);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColores.cremaClaro,
      appBar: AppBar(
        backgroundColor: AppColores.cremaClaro,
        elevation: 0,
        title: const Text(
          'Ubicación',
          style: TextStyle(
            color: AppColores.textoPrincipal,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: ubicacionCafe,
                    zoom: 15,
                  ),

                  markers: {
                    Marker(
                      markerId: const MarkerId('starcoffee'),
                      position: ubicacionCafe,
                      infoWindow: const InfoWindow(
                        title: 'Star Coffee',
                        snippet: 'Cafetería',
                      ),
                    ),
                  },
                ),
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              'Star Coffee',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColores.textoPrincipal,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '📍  Universidad Tecnologica del Valle del Mezquital',
              style: TextStyle(fontSize: 16, color: AppColores.textoSecundario),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
