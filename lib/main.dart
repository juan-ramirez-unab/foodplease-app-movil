import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart'
    as http; // Asegúrate de agregar 'http' a tu pubspec.yaml

// --- VARIABLE GLOBAL DE CONFIGURACIÓN (Punto 1) ---
const String baseUrl = 'https://foodplease-backend-flask.onrender.com';

// La URL ha sido actualizada a la dirección de Render.
// Si usas Android Emulator, ¡cambia a 'http://10.0.2.2:5000' si quieres probar el backend local!

void main() {
  runApp(const FoodPleaseApp());
}

// --- MODELOS DE DATOS ---

// Modelo para Local (Restaurant)
class Local {
  final int idLocal;
  final String nombre;
  final String direccionLocal;
  // Añadimos campos dummy para UX, aunque el backend no los devuelve en el código original,
  // los inicializaremos con valores predeterminados para evitar errores.
  final String categoria;
  final String detalles;

  Local({
    required this.idLocal,
    required this.nombre,
    required this.direccionLocal,
    this.categoria = "Categoría Desconocida",
    this.detalles = "Tiempo y Distancia Desconocidos",
  });

  factory Local.fromJson(Map<String, dynamic> json) {
    return Local(
      idLocal: json['id_local'] as int,
      nombre: json['nombre'] as String,
      direccionLocal: json['direccion_local'] as String,
      // Usamos get() de forma segura por si el JSON no contiene estos campos extra
      categoria: json['categoria'] as String? ?? "Comida Rápida",
      detalles: json['detalles'] as String? ?? "25-35 min",
    );
  }
}

// Modelo para Producto
class Producto {
  final int idProducto;
  final String nombre;
  final String descripcion;
  final String precio; // Lo manejamos como String para formateo de moneda
  final String imagenUrl;

  Producto({
    required this.idProducto,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    this.imagenUrl = 'https://placehold.co/800x400/CCCCCC/333333?text=Producto',
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    // El backend devuelve 'precio' como Integer/Float. Lo formateamos aquí.
    String formattedPrice;
    if (json['precio'] is num) {
      formattedPrice = json['precio'].toStringAsFixed(2);
    } else {
      formattedPrice = json['precio'] as String;
    }

    return Producto(
      idProducto: json['id_producto'] as int,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String,
      precio: formattedPrice,
      // Usamos get() de forma segura por si el JSON no contiene el campo extra
      imagenUrl:
          json['imagen_url'] as String? ??
          'https://placehold.co/800x400/CCCCCC/333333?text=Producto',
    );
  }
}

// --- WIDGET PRINCIPAL ---
class FoodPleaseApp extends StatelessWidget {
  const FoodPleaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FoodPlease App',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        fontFamily: 'Inter',
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      home: const LoginFormScreen(),
    );
  }
}

// -----------------------------------------------------------------------------
// PANTALLA DE LOGIN (Punto 2: Conexión con /login)
// -----------------------------------------------------------------------------
class LoginFormScreen extends StatefulWidget {
  const LoginFormScreen({super.key});

  @override
  State<LoginFormScreen> createState() => _LoginFormScreenState();
}

class _LoginFormScreenState extends State<LoginFormScreen> {
  final TextEditingController _usernameController = TextEditingController(
    text: 'admin',
  );
  final TextEditingController _passwordController = TextEditingController(
    text: 'admin',
  );
  bool _isLoading = false;

  // Función de utilidad para mostrar modales de error
  void _showSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // Lógica de Login: POST a /login
  Future<void> _login() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    final username = _usernameController.text;
    final password = _passwordController.text;
    final url = Uri.parse('$baseUrl/login');

    try {
      final body = jsonEncode({"username": username, "password": password});

      final response = await http
          .post(
            url,
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: body,
          )
          .timeout(
            const Duration(seconds: 10),
          ); // Timeout para conexiones lentas

      if (response.statusCode == 200) {
        // Login exitoso: Navegar a la lista de locales
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const RestaurantListScreen(),
            ),
          );
        }
      } else if (response.statusCode == 401) {
        _showSnackbar('Credenciales inválidas. Intenta con "user" / "123".');
      } else {
        _showSnackbar(
          'Error de servidor (${response.statusCode}). Por favor, verifica que Flask esté corriendo.',
        );
      }
    } catch (e) {
      // Error de conexión (e.g., servidor no corriendo o URL incorrecta)
      print('Error de conexión: $e');
      _showSnackbar(
        'Error de conexión: Verifica la URL base y que el servidor Flask esté activo.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar Sesión')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Icon(Icons.delivery_dining, size: 80, color: Colors.orange),
              const SizedBox(height: 20),
              const Text(
                'FoodPlease',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),

              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Usuario',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 30),

              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Entrar',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// PANTALLA DE LISTA DE LOCALES (Punto 3: Conexión con /locales)
// -----------------------------------------------------------------------------
class RestaurantListScreen extends StatefulWidget {
  const RestaurantListScreen({super.key});

  @override
  State<RestaurantListScreen> createState() => _RestaurantListScreenState();
}

class _RestaurantListScreenState extends State<RestaurantListScreen> {
  late Future<List<Local>> _localesFuture;

  @override
  void initState() {
    super.initState();
    _localesFuture = _fetchLocales();
  }

  // Lógica de carga: GET a /locales
  Future<List<Local>> _fetchLocales() async {
    final url = Uri.parse('$baseUrl/locales');
    final response = await http.get(url).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Local.fromJson(json)).toList();
    } else {
      throw Exception(
        'Fallo al cargar locales. Status: ${response.statusCode}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Locales Disponibles'),
        automaticallyImplyLeading:
            false, // Deshabilita el botón de retroceso de Login
      ),
      body: FutureBuilder<List<Local>>(
        future: _localesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 50,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Error: ${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _localesFuture = _fetchLocales(); // Reintentar
                        });
                      },
                      child: const Text('Reintentar'),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Asegúrate de que el servidor Flask en Render esté activo.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            // Datos cargados exitosamente
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final local = snapshot.data![index];
                return LocalCard(
                  local: local,
                  onTap: () {
                    // Navegar a la pantalla de menú/productos al hacer click
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => MenuDetailScreen(local: local),
                      ),
                    );
                  },
                );
              },
            );
          } else {
            return const Center(child: Text('No se encontraron locales.'));
          }
        },
      ),
    );
  }
}

// Widget Tarjeta de Local para la lista
class LocalCard extends StatelessWidget {
  final Local local;
  final VoidCallback onTap;

  const LocalCard({super.key, required this.local, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15),
              ),
              child: Image.network(
                'https://placehold.co/600x200/FDDED6/F05B3A?text=${local.nombre.replaceAll(' ', '+')}',
                fit: BoxFit.cover,
                width: double.infinity,
                height: 180,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 180,
                  color: Colors.grey[200],
                  child: Center(
                    child: Text(
                      local.nombre,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    local.nombre,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    local.categoria,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          local.direccionLocal,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 16,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 5),
                          Text(local.detalles),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// PANTALLA DE DETALLE DE MENÚ (Punto 4: Conexión con /productos)
// -----------------------------------------------------------------------------
class MenuDetailScreen extends StatefulWidget {
  final Local local;
  const MenuDetailScreen({super.key, required this.local});

  @override
  State<MenuDetailScreen> createState() => _MenuDetailScreenState();
}

class _MenuDetailScreenState extends State<MenuDetailScreen> {
  late Future<List<Producto>> _productosFuture;

  @override
  void initState() {
    super.initState();
    // En una app real, usarías el ID del local para filtrar.
    // Aquí, llamamos a /productos que trae todos los productos según tu backend.
    _productosFuture = _fetchProductos();
  }

  // Lógica de carga: GET a /productos
  Future<List<Producto>> _fetchProductos() async {
    final url = Uri.parse('$baseUrl/productos');
    final response = await http.get(url).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Producto.fromJson(json)).toList();
    } else {
      throw Exception(
        'Fallo al cargar productos. Status: ${response.statusCode}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.local.nombre), centerTitle: false),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Menú Principal',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.local.direccionLocal,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const Divider(height: 30),
                ],
              ),
            ),
          ),
          FutureBuilder<List<Producto>>(
            future: _productosFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (snapshot.hasError) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Text(
                      'Error al cargar menú: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                );
              } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final producto = snapshot.data![index];
                    return ProductoMenuItem(
                      producto: producto,
                      onTap: () {
                        // Navegar al detalle del producto (Punto 5)
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ProductDetailScreen(
                              idProducto: producto.idProducto,
                            ),
                          ),
                        );
                      },
                    );
                  }, childCount: snapshot.data!.length),
                );
              } else {
                return const SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'Este local aún no tiene productos registrados.',
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

// Widget Tarjeta de Producto para el menú
class ProductoMenuItem extends StatelessWidget {
  final Producto producto;
  final VoidCallback onTap;

  const ProductoMenuItem({
    super.key,
    required this.producto,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    producto.nombre,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    producto.descripcion,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '\$${producto.precio}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 15),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                producto.imagenUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[300],
                  child: const Icon(
                    Icons.image_not_supported,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// PANTALLA DE DETALLE DE PRODUCTO (Punto 5: Conexión con /productos/<id_producto>)
// -----------------------------------------------------------------------------
class ProductDetailScreen extends StatefulWidget {
  final int idProducto;
  const ProductDetailScreen({super.key, required this.idProducto});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Future<Producto> _productoFuture;

  @override
  void initState() {
    super.initState();
    _productoFuture = _fetchProductDetail(widget.idProducto);
  }

  // Lógica de carga: GET a /productos/<id_producto>
  Future<Producto> _fetchProductDetail(int id) async {
    final url = Uri.parse('$baseUrl/productos/$id');
    final response = await http.get(url).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      return Producto.fromJson(json);
    } else if (response.statusCode == 404) {
      throw Exception('Producto no encontrado (404)');
    } else {
      throw Exception(
        'Fallo al cargar el detalle del producto. Status: ${response.statusCode}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Producto>(
        future: _productoFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (snapshot.hasData) {
            final producto = snapshot.data!;
            return CustomScrollView(
              slivers: <Widget>[
                SliverAppBar(
                  expandedHeight: 300.0,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      producto.nombre,
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    background: Image.network(
                      producto.imagenUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.fastfood,
                          size: 80,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate([
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            producto.nombre,
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '\$${producto.precio}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Colors.orange,
                            ),
                          ),
                          const Divider(height: 30),
                          const Text(
                            'Descripción',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            producto.descripcion,
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]),
                ),
              ],
            );
          } else {
            return const Center(child: Text('No hay datos disponibles.'));
          }
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            // Acción simulada de añadir al carrito
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('¡Producto añadido al carrito!')),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Añadir al Carrito -',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
