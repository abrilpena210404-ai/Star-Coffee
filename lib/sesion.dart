class Sesion {
  static Map<String, dynamic>? usuario;
  // Identificador de Firebase
  static String? get uid {
    return usuario?['uid']?.toString();
  }
  // Identificador temporal de SQLite
  static int? get usuarioId {
    final id = usuario?['id'];
    if (id is int) return id;
    return null;
  }
  static String get nombre {
    return usuario?['nombre']?.toString() ?? 'Cliente';
  }
  static String get correo {
    return usuario?['correo']?.toString() ?? '';
  }
  static String get rol {
    return usuario?['rol']?.toString() ?? '';
  }
  static bool get hayUsuario {
    return usuario != null;
  }
  static void iniciar(Map<String, dynamic> datosUsuario) {
    usuario = datosUsuario;
  }
  static void cerrar() {
    usuario = null;
  }
}
