import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class CloudinaryService {
  static const String cloudName = 'pnwkncll';
  static const String uploadPreset = 'starcoffee_productos';

  static Future<String> subirImagen(XFile imagen) async {
    final bytes = await imagen.readAsBytes();

    if (bytes.length > 5 * 1024 * 1024) {
      throw Exception('La imagen no debe superar los 5 MB');
    }

    final extension = imagen.name.split('.').last.toLowerCase();
    if (!['jpg', 'jpeg', 'png', 'webp'].contains(extension)) {
      throw Exception('Selecciona una imagen JPG, PNG o WebP');
    }

    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    final solicitud = http.MultipartRequest('POST', url);
    solicitud.fields['upload_preset'] = uploadPreset;
    solicitud.files.add(
      http.MultipartFile.fromBytes('file', bytes, filename: imagen.name),
    );

    final respuesta = await solicitud.send().timeout(
      const Duration(seconds: 40),
    );

    final contenido = await respuesta.stream.bytesToString();
    final datos = jsonDecode(contenido);

    if (respuesta.statusCode != 200 && respuesta.statusCode != 201) {
      throw Exception('No se pudo subir la imagen a Cloudinary');
    }

    if (datos is! Map || datos['secure_url'] is! String) {
      throw Exception('Cloudinary no devolvió una URL válida');
    }

    return datos['secure_url'] as String;
  }
}
