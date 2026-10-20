import 'package:firebase_auth/firebase_auth.dart';

class Sesion {
  static Map<String, dynamic>? usuario;

  // Identificador de Firebase.
  static String? get uid {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  // Nombre del usuario.
  static String get nombre {
    return usuario?['nombre']?.toString() ?? 'Cliente';
  }

  // Correo electrónico.
  static String get correo {
    return usuario?['correo']?.toString() ??
        FirebaseAuth.instance.currentUser?.email ??
        '';
  }

  // Rol del usuario.
  static String get rol {
    return usuario?['rol']?.toString() ?? '';
  }

  // Comprobar que existe un usuario autenticado
  // y que se ha cargado su perfil.
  static bool get hayUsuario {
    return FirebaseAuth.instance.currentUser != null && usuario != null;
  }

  // Guardar los datos de la sesión.
  static void iniciar(Map<String, dynamic> datosUsuario) {
    usuario = Map<String, dynamic>.from(datosUsuario);
  }

  // Limpiar la información local de la sesión.
  static void cerrar() {
    usuario = null;
  }

  // Cerrar sesión completamente en Firebase.
  static Future<void> cerrarSesion() async {
    await FirebaseAuth.instance.signOut();
    cerrar();
  }
}
