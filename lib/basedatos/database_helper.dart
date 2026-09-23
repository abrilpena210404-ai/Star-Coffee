import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instancia = DatabaseHelper._internal();
  static Database? _database;
  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _iniciarBaseDatos();
    return _database!;
  }

  Future<Database> _iniciarBaseDatos() async {
    final rutaBaseDatos = await getDatabasesPath();
    final ruta = join(rutaBaseDatos, 'star_coffee.db');

    return await openDatabase(
      ruta,
      version: 4,
      onCreate: _crearBaseDatos,
      onUpgrade: _actualizarBaseDatos,
    );
  }

  Future<void> _actualizarBaseDatos(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {}

  Future<void> _crearBaseDatos(Database db, int version) async {
    await db.execute('''
      CREATE TABLE usuarios(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        correo TEXT NOT NULL UNIQUE,
        telefono TEXT NOT NULL,
        password TEXT NOT NULL,
        rol TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE favoritos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuarioId INTEGER NOT NULL,
        productoId INTEGER NOT NULL,
        nombre TEXT NOT NULL,
        descripcion TEXT,
        precio REAL NOT NULL,
        imagen TEXT,
        categoria TEXT
      )
    ''');

    await db.execute('''
     CREATE TABLE productos(
       id INTEGER PRIMARY KEY AUTOINCREMENT,
       nombre TEXT NOT NULL,
       descripcion TEXT,
       precio REAL NOT NULL,
       imagen TEXT,
       categoria TEXT NOT NULL,
       stock INTEGER NOT NULL DEFAULT 0,
       activo INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
     CREATE TABLE categorias(
       id INTEGER PRIMARY KEY AUTOINCREMENT,
       nombre TEXT NOT NULL UNIQUE
     )
    ''');

    await db.insert('categorias', {'nombre': 'Cafés'});
    await db.insert('categorias', {'nombre': 'Fríos'});
    await db.insert('categorias', {'nombre': 'Postres'});
    await db.insert('categorias', {'nombre': 'Snacks'});

    await db.execute('''
     CREATE TABLE promociones(
       id INTEGER PRIMARY KEY AUTOINCREMENT,
       titulo TEXT NOT NULL,
       descripcion TEXT NOT NULL,
       descuento REAL NOT NULL,
      estado TEXT NOT NULL
      )
    ''');
    // ADMIN PREDETERMINADO
    await db.insert('usuarios', {
      'nombre': 'Administrador',
      'correo': 'admin@starcoffee.com',
      'telefono': '',
      'password': 'Admin123',
      'rol': 'admin',
    });
  }

  Future<int> registrarUsuario({
    required String nombre,
    required String correo,
    required String telefono,
    required String password,
  }) async {
    final db = await database;

    return await db.insert('usuarios', {
      'nombre': nombre,
      'correo': correo,
      'telefono': telefono,
      'password': password,
      'rol': 'cliente',
    }, conflictAlgorithm: ConflictAlgorithm.abort);
  }

  Future<Map<String, dynamic>?> iniciarSesion(
    String correo,
    String password,
  ) async {
    final db = await database;
    final todos = await db.query('usuarios');
    print("USUARIOS EN BD:");
    print(todos);

    final resultado = await db.query(
      'usuarios',
      where: 'correo = ? AND password = ?',
      whereArgs: [correo, password],
      limit: 1,
    );

    print("BUSCANDO:");
    print(correo);
    print(password);
    print(resultado);
    if (resultado.isEmpty) {
      return null;
    }
    return resultado.first;
  }

  Future<bool> correoExiste(String correo) async {
    final db = await database;
    final resultado = await db.query(
      'usuarios',
      where: 'correo = ?',
      whereArgs: [correo],
      limit: 1,
    );
    return resultado.isNotEmpty;
  }

  Future<List<Map<String, dynamic>>> obtenerUsuarios() async {
    final db = await database;
    return await db.query('usuarios', orderBy: 'nombre ASC');
  }

  Future<int> agregarProducto({
    required String nombre,
    required String descripcion,
    required double precio,
    required String imagen,
    required String categoria,
    required int stock,
  }) async {
    final db = await database;
    return await db.insert('productos', {
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'imagen': imagen,
      'categoria': categoria,
      'stock': stock,
      'activo': 1,
    });
  }

  Future<List<Map<String, dynamic>>> obtenerProductos() async {
    final db = await database;
    return await db.query(
      'productos',
      where: 'activo = ?',
      whereArgs: [1],
      orderBy: 'nombre ASC',
    );
  }

  Future<int> actualizarProducto({
    required int id,
    required String nombre,
    required String descripcion,
    required double precio,
    required String imagen,
    required String categoria,
    required int stock,
  }) async {
    final db = await database;
    return await db.update(
      'productos',
      {
        'nombre': nombre,
        'descripcion': descripcion,
        'precio': precio,
        'imagen': imagen,
        'categoria': categoria,
        'stock': stock,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> eliminarProducto(int id) async {
    final db = await database;
    return await db.delete('productos', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> contarProductos() async {
    final db = await database;
    final resultado = await db.rawQuery('SELECT COUNT(*) FROM productos');
    return Sqflite.firstIntValue(resultado) ?? 0;
  }

  Future<List<Map<String, dynamic>>> obtenerCategorias() async {
    final db = await database;
    return await db.query('categorias', orderBy: 'nombre ASC');
  }

  Future<int> agregarCategoria(String nombre) async {
    final db = await database;
    return await db.insert('categorias', {'nombre': nombre});
  }

  Future<int> eliminarCategoria(int id) async {
    final db = await database;
    return await db.delete('categorias', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> obtenerPromociones() async {
    final db = await database;
    return await db.query('promociones', orderBy: 'id DESC');
  }

  Future<int> agregarPromocion({
    required String titulo,
    required String descripcion,
    required double descuento,
  }) async {
    final db = await database;
    return await db.insert('promociones', {
      'titulo': titulo,
      'descripcion': descripcion,
      'descuento': descuento,
      'estado': 'Activa',
    });
  }

  Future<int> eliminarPromocion(int id) async {
    final db = await database;
    return await db.delete('promociones', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> contarCategorias() async {
    final db = await database;
    final resultado = await db.rawQuery('SELECT COUNT(*) FROM categorias');
    return Sqflite.firstIntValue(resultado) ?? 0;
  }

  Future<int> contarPromociones() async {
    final db = await database;
    final resultado = await db.rawQuery(
      "SELECT COUNT(*) FROM promociones WHERE estado = 'Activa'",
    );
    return Sqflite.firstIntValue(resultado) ?? 0;
  }

  Future<int> agregarFavorito({
    required int usuarioId,
    required Map<String, dynamic> producto,
  }) async {
    final db = await database;
    return await db.insert('favoritos', {
      'usuarioId': usuarioId,
      'productoId': producto['id'],
      'nombre': producto['nombre'],
      'descripcion': producto['descripcion'],
      'precio': producto['precio'],
      'imagen': producto['imagen'],
      'categoria': producto['categoria'],
    });
  }

  Future<List<Map<String, dynamic>>> obtenerFavoritos(int usuarioId) async {
    final db = await database;
    return await db.query(
      'favoritos',
      where: 'usuarioId = ?',
      whereArgs: [usuarioId],
      orderBy: 'id DESC',
    );
  }

  Future<int> eliminarFavorito(int id) async {
    final db = await database;
    return await db.delete('favoritos', where: 'id = ?', whereArgs: [id]);
  }
}
