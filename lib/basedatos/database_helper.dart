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
      version: 2,
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
}
