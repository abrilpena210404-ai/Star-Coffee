import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
class ClimaService {
  // Coloca temporalmente tu clave actual de OpenWeatherMap.
   static const String apiKey = '3c3bbcb2e3726187a9da0e02b833a015';
  Future<Map<String, dynamic>> obtenerClima() async {
    try {
      // Verificar si la ubicación está activada.
      final servicioActivo =
          await Geolocator.isLocationServiceEnabled();

      if (!servicioActivo) {
        return await obtenerClimaIxmiquilpan();
      }

      // Revisar los permisos.
      LocationPermission permiso =
          await Geolocator.checkPermission();

      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
      }

      // Si no permite acceder, usar Ixmiquilpan.
      if (permiso == LocationPermission.denied ||
          permiso == LocationPermission.deniedForever) {
        return await obtenerClimaIxmiquilpan();
      }

      // Obtener la ubicación actual del teléfono.
      final posicion = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 15),
        ),
      );

      final latitud = posicion.latitude;
      final longitud = posicion.longitude;

      // Consultar el clima de la ubicación obtenida.
      final url = Uri.https(
        'api.openweathermap.org',
        '/data/2.5/weather',
        {
          'lat': latitud.toString(),
          'lon': longitud.toString(),
          'appid': apiKey,
          'units': 'metric',
          'lang': 'es',
        },
      );

      return await consultarClima(url);
    } catch (e) {
      // Si falla el GPS, se intenta consultar Ixmiquilpan.
      return await obtenerClimaIxmiquilpan();
    }
  }

  // Clima alternativo.
  Future<Map<String, dynamic>> obtenerClimaIxmiquilpan() {
    final url = Uri.https(
      'api.openweathermap.org',
      '/data/2.5/weather',
      {
        'q': 'Ixmiquilpan,MX',
        'appid': apiKey,
        'units': 'metric',
        'lang': 'es',
      },
    );

    return consultarClima(url);
  }

  Future<Map<String, dynamic>> consultarClima(Uri url) async {
    final respuesta = await http.get(url).timeout(
      const Duration(seconds: 15),
    );

    if (respuesta.statusCode == 200) {
      final datos = jsonDecode(respuesta.body);

      if (datos is Map<String, dynamic>) {
        return datos;
      }
    }

    throw Exception(
      'No se pudo obtener el clima '
      '(HTTP ${respuesta.statusCode})',
    );
  }
}
