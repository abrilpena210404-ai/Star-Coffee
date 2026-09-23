import 'package:flutter/material.dart';

class AppColores {
  static const Color cafeOscuro = Color(0xFF5A2D14);
  static const Color cafeMedio = Color(0xFF7A4A2A);
  static const Color cafeClaro = Color(0xFFC9A27B);

  static const Color crema = Color(0xFFF8F1E8);
  static const Color cremaClaro = Color(0xFFFFFBF7);
  static const Color beige = Color(0xFFEADCCB);

  static const Color textoPrincipal = Color(0xFF2E160D);
  static const Color textoSecundario = Color(0xFF7A6A61);

  static const Color blanco = Colors.white;
}

class AppEstilos {
  static const TextStyle tituloPrincipal = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.bold,
    color: AppColores.textoPrincipal,
  );

  static const TextStyle subtitulo = TextStyle(
    fontSize: 16,
    color: AppColores.textoSecundario,
  );

  static const TextStyle textoNormal = TextStyle(
    fontSize: 15,
    color: AppColores.textoPrincipal,
  );

  static const TextStyle textoBoton = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const TextStyle textoEnlace = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColores.cafeOscuro,
  );

  static InputDecoration inputDecoration({
    required String hint,
    required IconData icono,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: AppColores.textoSecundario,
        fontSize: 15,
      ),
      prefixIcon: Icon(icono, color: AppColores.cafeOscuro),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColores.blanco,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColores.beige, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColores.cafeMedio, width: 1.5),
      ),
    );
  }

  static BoxDecoration tarjeta() {
    return BoxDecoration(
      color: AppColores.blanco,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 15,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }
}
