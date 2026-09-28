import 'dart:convert';
import 'package:http/http.dart' as http;

class ClimaService {
  static const String apiKey = '3c3bbcb2e3726187a9da0e02b833a015';

  Future<Map<String, dynamic>> obtenerClima() async {
    const ciudad = 'Ixmiquilpan,MX';

    final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather'
      '?q=$ciudad'
      '&appid=$apiKey'
      '&units=metric'
      '&lang=es',
    );

    final respuesta = await http.get(url);

    if (respuesta.statusCode == 200) {
      return jsonDecode(respuesta.body);
    }

    print('STATUS CLIMA: ${respuesta.statusCode}');
    print('RESPUESTA CLIMA: ${respuesta.body}');

    throw Exception('No se pudo obtener el clima');
  }
}
