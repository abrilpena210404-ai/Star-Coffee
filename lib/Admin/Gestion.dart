import 'package:flutter/material.dart';
import 'package:star_coffee/Admin/Usuarios.dart';
import '../Styles/Styles.dart';
import '../basedatos/database_helper.dart';

class Gestion extends StatefulWidget {
  const Gestion({super.key});
  @override
  State<Gestion> createState() => _GestionState();
}

class _GestionState extends State<Gestion> {
  List<Map<String, dynamic>> categorias = [];
  List<Map<String, dynamic>> usuarios = [];

  @override
  void initState() {
    super.initState();
    cargarCategorias();
    cargarUsuarios();
  }

  Future<void> cargarCategorias() async {
    final datos = await DatabaseHelper.instancia.obtenerCategorias();
    if (!mounted) return;
    setState(() {
      categorias = datos;
    });
  }

  Future<void> cargarUsuarios() async {
    final datos = await DatabaseHelper.instancia.obtenerUsuarios();
    final clientes = datos.where((usuario) {
      return usuario['rol'] == 'cliente';
    }).toList();
    if (!mounted) return;
    setState(() {
      usuarios = clientes;
    });
  }

  Future<void> agregarCategoria() async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColores.cremaClaro,
          title: const Text(
            'Nueva categoría',
            style: TextStyle(
              color: AppColores.cafeOscuro,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Nombre categoría'),
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
                if (controller.text.trim().isEmpty) {
                  return;
                }
                await DatabaseHelper.instancia.agregarCategoria(
                  controller.text.trim(),
                );
                Navigator.pop(context);
                cargarCategorias();
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> eliminarCategoria(int id) async {
    await DatabaseHelper.instancia.eliminarCategoria(id);
    cargarCategorias();
  }

  Future<void> editarCategoria(Map<String, dynamic> categoria) async {
    final nombre = TextEditingController(text: categoria['nombre']);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColores.cremaClaro,
          title: const Text(
            'Editar categoría',
            style: TextStyle(
              color: AppColores.cafeOscuro,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: nombre,
            decoration: const InputDecoration(labelText: 'Nombre'),
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
                await DatabaseHelper.instancia.actualizarCategoria(
                  id: categoria['id'],
                  nombre: nombre.text,
                );
                Navigator.pop(context);
                cargarCategorias();
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColores.cremaClaro,

      body: Container(
        width: double.infinity,
        height: double.infinity,

        // ==========================================
        // FONDO DEGRADADO
        // ==========================================
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
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ========================================
                // ENCABEZADO
                // ========================================
                const Text(
                  'Gestión',
                  style: TextStyle(
                    fontSize: 28,
                    height: 1,
                    fontWeight: FontWeight.w800,
                    color: AppColores.textoPrincipal,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 25),

                // ========================================
                // CATEGORÍAS - TÍTULO + NUEVA
                // ========================================
                Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Categorías',
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                              color: AppColores.textoPrincipal,
                            ),
                          ),
                          SizedBox(height: 3),
                        ],
                      ),
                    ),

                    SizedBox(
                      height: 40,
                      child: ElevatedButton.icon(
                        onPressed: agregarCategoria,

                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColores.cafeOscuro,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),

                        icon: const Icon(Icons.add_rounded, size: 18),

                        label: const Text(
                          'Nueva',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // ========================================
                // CONTENEDOR DE CATEGORÍAS
                // ========================================
                categorias.isEmpty
                    ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(25),

                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.92),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColores.beige),
                        ),

                        child: const Column(
                          children: [
                            Icon(
                              Icons.category_outlined,
                              size: 38,
                              color: AppColores.cafeOscuro,
                            ),

                            SizedBox(height: 10),

                            Text(
                              'No hay categorías',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColores.textoPrincipal,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(
                        width: double.infinity,

                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.94),

                          borderRadius: BorderRadius.circular(18),

                          border: Border.all(
                            color: AppColores.beige.withOpacity(0.75),
                          ),

                          boxShadow: [
                            BoxShadow(
                              color: AppColores.cafeOscuro.withOpacity(0.06),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),

                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),

                          itemCount: categorias.length,

                          separatorBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(left: 62),
                              child: Divider(
                                height: 1,
                                thickness: 0.7,
                                color: AppColores.beige.withOpacity(0.8),
                              ),
                            );
                          },

                          itemBuilder: (context, index) {
                            final categoria = categorias[index];

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 11,
                                vertical: 10,
                              ),

                              child: Row(
                                children: [
                                  // ICONO
                                  Container(
                                    width: 42,
                                    height: 42,

                                    decoration: BoxDecoration(
                                      color: AppColores.crema,
                                      borderRadius: BorderRadius.circular(13),
                                    ),

                                    child: const Icon(
                                      Icons.local_cafe_rounded,
                                      color: AppColores.cafeOscuro,
                                      size: 23,
                                    ),
                                  ),

                                  const SizedBox(width: 11),

                                  // NOMBRE
                                  Expanded(
                                    child: Text(
                                      categoria['nombre']?.toString() ??
                                          'Categoría',

                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,

                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColores.textoPrincipal,
                                      ),
                                    ),
                                  ),

                                  // EDITAR
                                  _botonGestion(
                                    icono: Icons.edit_outlined,
                                    color: AppColores.cafeOscuro,
                                    onTap: () {
                                      editarCategoria(categoria);
                                    },
                                  ),

                                  const SizedBox(width: 6),

                                  // ELIMINAR
                                  _botonGestion(
                                    icono: Icons.delete_outline_rounded,
                                    color: Colors.red,
                                    onTap: () {
                                      eliminarCategoria(categoria['id']);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                // ========================================
                // SEPARADOR CAFÉ
                // ========================================
                const SizedBox(height: 27),

                Container(
                  width: double.infinity,
                  height: 1,
                  color: AppColores.cafeClaro,
                ),

                const SizedBox(height: 25),

                // ========================================
                // USUARIOS REGISTRADOS
                // ========================================
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Usuarios Registrados',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          color: AppColores.textoPrincipal,
                        ),
                      ),
                    ),

                    // ====================================
                    // VER TODOS
                    // ====================================
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const UsuariosAdmin(),
                          ),
                        );
                      },

                      style: TextButton.styleFrom(
                        foregroundColor: AppColores.cafeOscuro,
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                      ),

                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Ver todos',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          SizedBox(width: 2),

                          Icon(Icons.chevron_right_rounded, size: 18),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ========================================
                // USUARIOS
                // ========================================
                usuarios.isEmpty
                    ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(25),

                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.92),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColores.beige),
                        ),

                        child: const Column(
                          children: [
                            Icon(
                              Icons.people_outline_rounded,
                              size: 38,
                              color: AppColores.cafeOscuro,
                            ),

                            SizedBox(height: 10),

                            Text(
                              'No hay usuarios registrados',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColores.textoPrincipal,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),

                        itemCount: usuarios.length,

                        itemBuilder: (context, index) {
                          final usuario = usuarios[index];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),

                            padding: const EdgeInsets.fromLTRB(11, 10, 9, 10),

                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.94),

                              borderRadius: BorderRadius.circular(17),

                              border: Border.all(
                                color: AppColores.beige.withOpacity(0.75),
                              ),

                              boxShadow: [
                                BoxShadow(
                                  color: AppColores.cafeOscuro.withOpacity(
                                    0.05,
                                  ),
                                  blurRadius: 9,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),

                            child: Row(
                              children: [
                                // USUARIO ICONO
                                Container(
                                  width: 43,
                                  height: 43,

                                  decoration: const BoxDecoration(
                                    color: AppColores.crema,
                                    shape: BoxShape.circle,
                                  ),

                                  child: const Icon(
                                    Icons.person_rounded,
                                    color: AppColores.cafeOscuro,
                                    size: 23,
                                  ),
                                ),

                                const SizedBox(width: 11),

                                // NOMBRE Y CORREO
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        usuario['nombre']?.toString() ??
                                            'Usuario',

                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,

                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: AppColores.textoPrincipal,
                                        ),
                                      ),

                                      const SizedBox(height: 3),

                                      Text(
                                        usuario['correo']?.toString() ?? '',

                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,

                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColores.textoSecundario,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 7),

                                // SOLO BASURITA
                                _botonGestion(
                                  icono: Icons.delete_outline_rounded,
                                  color: Colors.red,
                                  onTap: () async {
                                    await DatabaseHelper.instancia
                                        .eliminarUsuario(usuario['id']);

                                    cargarUsuarios();
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _botonGestion({
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
