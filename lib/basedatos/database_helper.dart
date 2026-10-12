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
      version: 6,
      onCreate: _crearBaseDatos,
      onUpgrade: _actualizarBaseDatos,
    );
  }

  Future<void> _actualizarBaseDatos(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 5) {
      await db.execute('''
      CREATE TABLE carrito(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuarioId INTEGER NOT NULL,
        productoId INTEGER NOT NULL,
        nombre TEXT NOT NULL,
        precio REAL NOT NULL,
        imagen TEXT,
        cantidad INTEGER NOT NULL DEFAULT 1,
        UNIQUE(usuarioId, productoId)
      )
    ''');

      await db.execute('''
      CREATE TABLE pedidos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuarioId INTEGER NOT NULL,
        fecha TEXT NOT NULL,
        total REAL NOT NULL,
        estado TEXT NOT NULL
      )
    ''');

      await db.execute('''
      CREATE TABLE detalle_pedido(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        pedidoId INTEGER NOT NULL,
        productoId INTEGER NOT NULL,
        nombre TEXT NOT NULL,
        precio REAL NOT NULL,
        cantidad INTEGER NOT NULL,
        subtotal REAL NOT NULL
      )
    ''');
    }
    if (oldVersion < 6) {
      await db.execute('''
    ALTER TABLE pedidos
    ADD COLUMN fechaFinalizacion TEXT
  ''');
    }
  }

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

    await db.execute('''
     CREATE TABLE carrito(
       id INTEGER PRIMARY KEY AUTOINCREMENT,
       usuarioId INTEGER NOT NULL,
       productoId INTEGER NOT NULL,
       nombre TEXT NOT NULL,
       precio REAL NOT NULL,
       imagen TEXT,
       cantidad INTEGER NOT NULL DEFAULT 1,
       UNIQUE(usuarioId, productoId)
      )
    ''');

    await db.execute('''
     CREATE TABLE pedidos(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  usuarioId INTEGER NOT NULL,
  fecha TEXT NOT NULL,
  total REAL NOT NULL,
  estado TEXT NOT NULL,
  fechaFinalizacion TEXT
)
    ''');

    await db.execute('''
      CREATE TABLE detalle_pedido(
       id INTEGER PRIMARY KEY AUTOINCREMENT,
       pedidoId INTEGER NOT NULL,
       productoId INTEGER NOT NULL,
       nombre TEXT NOT NULL,
       precio REAL NOT NULL,
       cantidad INTEGER NOT NULL,
       subtotal REAL NOT NULL
      )
    ''');
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

  Future<int> eliminarUsuario(int id) async {
    final db = await database;
    return await db.delete('usuarios', where: 'id = ?', whereArgs: [id]);
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

  Future<int> actualizarCategoria({
    required int id,
    required String nombre,
  }) async {
    final db = await database;
    return await db.update(
      'categorias',
      {'nombre': nombre},
      where: 'id = ?',
      whereArgs: [id],
    );
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

  Future<int> actualizarPromocion({
    required int id,
    required String titulo,
    required String descripcion,
    required double descuento,
  }) async {
    final db = await database;
    return await db.update(
      'promociones',
      {'titulo': titulo, 'descripcion': descripcion, 'descuento': descuento},
      where: 'id = ?',
      whereArgs: [id],
    );
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

  // ==================== CARRITO ====================

  Future<int> agregarAlCarrito({
    required int usuarioId,
    required Map<String, dynamic> producto,
  }) async {
    final db = await database;

    final existente = await db.query(
      'carrito',
      where: 'usuarioId = ? AND productoId = ?',
      whereArgs: [usuarioId, producto['id']],
      limit: 1,
    );

    if (existente.isNotEmpty) {
      return await db.update(
        'carrito',
        {'cantidad': (existente.first['cantidad'] as int) + 1},
        where: 'usuarioId = ? AND productoId = ?',
        whereArgs: [usuarioId, producto['id']],
      );
    }

    return await db.insert('carrito', {
      'usuarioId': usuarioId,
      'productoId': producto['id'],
      'nombre': producto['nombre'],
      'precio': producto['precio'],
      'imagen': producto['imagen'],
      'cantidad': 1,
    });
  }

  Future<List<Map<String, dynamic>>> obtenerCarrito(int usuarioId) async {
    final db = await database;

    return await db.query(
      'carrito',
      where: 'usuarioId = ?',
      whereArgs: [usuarioId],
      orderBy: 'id DESC',
    );
  }

  Future<int> aumentarCantidad(int id) async {
    final db = await database;

    final resultado = await db.query(
      'carrito',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (resultado.isEmpty) return 0;

    final cantidadActual = resultado.first['cantidad'] as int;

    return await db.update(
      'carrito',
      {'cantidad': cantidadActual + 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> disminuirCantidad(int id) async {
    final db = await database;

    final resultado = await db.query(
      'carrito',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (resultado.isEmpty) return 0;

    final cantidadActual = resultado.first['cantidad'] as int;

    if (cantidadActual <= 1) {
      return await eliminarDelCarrito(id);
    }

    return await db.update(
      'carrito',
      {'cantidad': cantidadActual - 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> eliminarDelCarrito(int id) async {
    final db = await database;
    return await db.delete('carrito', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> vaciarCarrito(int usuarioId) async {
    final db = await database;
    return await db.delete(
      'carrito',
      where: 'usuarioId = ?',
      whereArgs: [usuarioId],
    );
  }

  Future<int> crearPedido({
    required int usuarioId,
    required double total,
    required List<Map<String, dynamic>> productos,
  }) async {
    final db = await database;

    final fecha = DateTime.now().toIso8601String();

    final pedidoId = await db.insert('pedidos', {
      'usuarioId': usuarioId,
      'fecha': fecha,
      'total': total,
      'estado': 'Pendiente',
    });

    for (final producto in productos) {
      final precio = (producto['precio'] as num).toDouble();
      final cantidad = producto['cantidad'] as int;
      final subtotal = precio * cantidad;

      await db.insert('detalle_pedido', {
        'pedidoId': pedidoId,
        'productoId': producto['productoId'],
        'nombre': producto['nombre'],
        'precio': precio,
        'cantidad': cantidad,
        'subtotal': subtotal,
      });
    }

    await vaciarCarrito(usuarioId);

    return pedidoId;
  }

  Future<List<Map<String, dynamic>>> obtenerPedidos() async {
    await eliminarPedidosFinalizados();
    final db = await database;

    return await db.rawQuery('''
    SELECT 
      pedidos.id,
      pedidos.usuarioId,
      pedidos.fecha,
      pedidos.total,
      pedidos.estado,
      usuarios.nombre AS cliente
    FROM pedidos
    LEFT JOIN usuarios
      ON pedidos.usuarioId = usuarios.id
    ORDER BY pedidos.id DESC
  ''');
  }

  Future<bool> actualizarEstadoPedido({
    required int pedidoId,
    required String nuevoEstado,
  }) async {
    final db = await database;

    final resultado = await db.query(
      'pedidos',
      where: 'id = ?',
      whereArgs: [pedidoId],
      limit: 1,
    );

    if (resultado.isEmpty) {
      return false;
    }

    final estadoActual = resultado.first['estado'].toString();

    bool permitido = false;

    if (estadoActual == 'Pendiente') {
      permitido = nuevoEstado == 'Aceptado' || nuevoEstado == 'Cancelado';
    } else if (estadoActual == 'Aceptado') {
      permitido = nuevoEstado == 'En preparación' || nuevoEstado == 'Cancelado';
    } else if (estadoActual == 'En preparación') {
      permitido = nuevoEstado == 'Listo';
    } else if (estadoActual == 'Listo') {
      permitido = nuevoEstado == 'Entregado';
    }

    if (!permitido) {
      return false;
    }

    final datosActualizar = <String, dynamic>{'estado': nuevoEstado};

    if (nuevoEstado == 'Cancelado' || nuevoEstado == 'Entregado') {
      datosActualizar['fechaFinalizacion'] = DateTime.now().toIso8601String();
    }

    await db.update(
      'pedidos',
      datosActualizar,
      where: 'id = ?',
      whereArgs: [pedidoId],
    );

    return true;
  }

  Future<bool> aceptarPedido(int pedidoId) async {
    final db = await database;

    return await db.transaction((txn) async {
      final pedido = await txn.query(
        'pedidos',
        where: 'id = ?',
        whereArgs: [pedidoId],
        limit: 1,
      );

      if (pedido.isEmpty) {
        return false;
      }

      final estado = pedido.first['estado'].toString();

      if (estado != 'Pendiente') {
        return false;
      }

      final detalles = await txn.query(
        'detalle_pedido',
        where: 'pedidoId = ?',
        whereArgs: [pedidoId],
      );

      // Primero comprobamos TODO el stock
      for (final detalle in detalles) {
        final productoId = detalle['productoId'] as int;
        final cantidad = detalle['cantidad'] as int;

        final producto = await txn.query(
          'productos',
          columns: ['stock'],
          where: 'id = ?',
          whereArgs: [productoId],
          limit: 1,
        );

        if (producto.isEmpty) {
          return false;
        }

        final stockActual = producto.first['stock'] as int;

        if (stockActual < cantidad) {
          return false;
        }
      }

      // Si hay stock suficiente, ahora sí lo descontamos
      for (final detalle in detalles) {
        final productoId = detalle['productoId'] as int;
        final cantidad = detalle['cantidad'] as int;

        await txn.rawUpdate(
          '''
        UPDATE productos
        SET stock = stock - ?
        WHERE id = ?
        ''',
          [cantidad, productoId],
        );
      }

      await txn.update(
        'pedidos',
        {'estado': 'Aceptado'},
        where: 'id = ?',
        whereArgs: [pedidoId],
      );

      return true;
    });
  }

  Future<List<Map<String, dynamic>>> obtenerPedidosUsuario(
    int usuarioId,
  ) async {
    final db = await database;

    return await db.query(
      'pedidos',
      where: 'usuarioId = ?',
      whereArgs: [usuarioId],
      orderBy: 'id DESC',
    );
  }

  Future<void> eliminarPedidosFinalizados() async {
    final db = await database;

    final limite = DateTime.now().subtract(const Duration(hours: 12));

    final pedidosFinalizados = await db.query(
      'pedidos',
      columns: ['id'],
      where: '''
      (estado = ? OR estado = ?)
      AND fechaFinalizacion IS NOT NULL
      AND fechaFinalizacion <= ?
    ''',
      whereArgs: ['Cancelado', 'Entregado', limite.toIso8601String()],
    );

    for (final pedido in pedidosFinalizados) {
      final pedidoId = pedido['id'];

      await db.delete(
        'detalle_pedido',
        where: 'pedidoId = ?',
        whereArgs: [pedidoId],
      );

      await db.delete('pedidos', where: 'id = ?', whereArgs: [pedidoId]);
    }
  }

  Future<List<Map<String, dynamic>>> obtenerDetallePedido(int pedidoId) async {
    final db = await database;

    return await db.query(
      'detalle_pedido',
      where: 'pedidoId = ?',
      whereArgs: [pedidoId],
      orderBy: 'id ASC',
    );
  }

  Future<void> cancelarPedido(int pedidoId) async {
    final db = await database;

    await db.transaction((txn) async {
      await txn.delete(
        'detalle_pedido',
        where: 'pedidoId = ?',
        whereArgs: [pedidoId],
      );

      await txn.delete('pedidos', where: 'id = ?', whereArgs: [pedidoId]);
    });
  }
}
