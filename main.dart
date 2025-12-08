import 'package:flutter/material.dart';
// Para la llamada al servicio real, se necesitan los siguientes imports.
// ¡IMPORTANTE!: En tu proyecto Flutter real, debes añadir 'http: ^0.13.5'
// (o la versión más reciente) a tu archivo pubspec.yaml para que funcione.
import 'dart:convert';
import 'package:http/http.dart'
    as http; // Este import puede causar errores en Canvas.

void main() {
  runApp(const FoodPleaseLoginApp());
}

// Clase principal de la aplicación.
class FoodPleaseLoginApp extends StatelessWidget {
  const FoodPleaseLoginApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FoodPlease Login',
      theme: ThemeData(
        // Tema basado en el color naranja principal de la imagen.
        primarySwatch: Colors.orange,
        // Configuración de la fuente para un look más moderno.
        fontFamily: 'Inter',
        // Quitar el 'debug' banner.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Usamos un fondo ligeramente gris claro para simular el diseño de la imagen.
      home: const Scaffold(
        backgroundColor: Color(0xFFEBEBEB),
        body: Center(child: LoginFormScreen()),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// PANTALLA DE LOGIN
// -----------------------------------------------------------------------------
class LoginFormScreen extends StatefulWidget {
  const LoginFormScreen({super.key});

  @override
  State<LoginFormScreen> createState() => _LoginFormScreenState();
}

class _LoginFormScreenState extends State<LoginFormScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Simulación de la llamada a la API de login
  Future<void> _login() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    final email = _emailController.text;
    final password = _passwordController.text;
    // Nueva URL de la API
    const url = 'https://api.restful-api.dev/objects';

    try {
      final body = jsonEncode({
        "name": "$email $password",
        "data": {
          "year": DateTime.now().year,
          "price": 0.00,
          "CPU model": "Login Attempt",
          "Hard disk size": "N/A",
        },
      });

      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);
        final loginSuccessful = responseBody.containsKey('id');

        if (loginSuccessful) {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const RestaurantListScreen(),
              ),
            );
          }
        } else {
          _showErrorDialog(
            context,
            'Petición enviada, pero el servidor no devolvió el ID de objeto esperado.',
          );
        }
      } else {
        _showErrorDialog(
          context,
          'Error de servidor (${response.statusCode}). Por favor, inténtalo de nuevo más tarde.',
        );
      }
    } catch (e) {
      _showErrorDialog(
        context,
        'No se pudo conectar al servicio. Asegúrate de tener conexión. Error: $e',
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
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.08;

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 50),

              // 1. Logo/Icono Central
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFF05B3A),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.restaurant_menu,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 30),

              // 2. Título de Bienvenida
              const Text(
                'Bienvenido de vuelta',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),

              // 3. Subtítulo
              const Text(
                'Inicia sesión en tu cuenta de FoodPlease',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 40),

              // 4. Campo de Email
              const Text(
                'Email',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _emailController,
                hintText: 'ejemplo@correo.com',
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 25),

              // 5. Campo de Contraseña
              const Text(
                'Contraseña',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              _buildPasswordTextField(controller: _passwordController),
              const SizedBox(height: 15),

              // 6. Enlace "¿Olvidaste tu contraseña?"
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          // Acción para recuperar contraseña
                        },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(50, 30),
                    alignment: Alignment.centerRight,
                  ),
                  child: Text(
                    '¿Olvidaste tu contraseña?',
                    style: TextStyle(
                      color: _isLoading ? Colors.grey : const Color(0xFFF05B3A),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // 7. Botón "Ingresar"
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF05B3A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : const Text(
                        'Ingresar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // Widget para construir los campos de texto normales.
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required TextInputType keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hintText,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          border: InputBorder.none,
          hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
        ),
        style: const TextStyle(color: Colors.black87),
      ),
    );
  }

  // Widget específico para el campo de contraseña.
  Widget _buildPasswordTextField({required TextEditingController controller}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: !_isPasswordVisible,
        decoration: InputDecoration(
          hintText: 'Ingresa tu contraseña',
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          border: InputBorder.none,
          hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: const Color(0xFF9E9E9E),
            ),
            onPressed: _isLoading
                ? null
                : () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
          ),
        ),
        style: const TextStyle(color: Colors.black87),
      ),
    );
  }

  // Función para mostrar un mensaje modal de error.
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Error de Inicio de Sesión'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Aceptar',
                style: TextStyle(color: Color(0xFFF05B3A)),
              ),
            ),
          ],
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// PANTALLA DE DETALLE DEL PRODUCTO (NUEVA)
// -----------------------------------------------------------------------------
class ProductDetailScreen extends StatelessWidget {
  final String productName;
  final String productPrice;
  final String productDescription;
  final String imageUrl;

  const ProductDetailScreen({
    super.key,
    required this.productName,
    required this.productPrice,
    required this.productDescription,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    // Ingredientes de ejemplo
    final List<String> ingredients = [
      'Carne',
      'Queso',
      'Lechuga',
      'Tomate',
      'Pan Brioche',
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      // Stack para que el contenido de la imagen pueda superponerse al AppBar
      body: Stack(
        children: [
          CustomScrollView(
            slivers: <Widget>[
              // 1. Imagen Grande (SliverAppBar con flexible space)
              SliverAppBar(
                expandedHeight: 250.0,
                floating: false,
                pinned: true,
                backgroundColor:
                    Colors.transparent, // Transparente para ver la imagen
                elevation: 0,
                // Íconos flotantes
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.5),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.black.withOpacity(0.5),
                      child: IconButton(
                        icon: const Icon(
                          Icons.favorite_border,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          // Acción para añadir a favoritos
                        },
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    // Fallback visual si la URL no carga
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(
                        0xFFF05B3A,
                      ), // Color principal de FoodPlease
                      child: Center(
                        child: Text(
                          productName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 2. Contenido principal con Scroll
              SliverList(
                delegate: SliverChildListDelegate([
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nombre y Precio
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                productName,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  height: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              productPrice,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFF05B3A), // Naranja principal
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),

                        // Descripción
                        Text(
                          productDescription,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Ingredientes Título
                        const Text(
                          'Ingredientes',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 15),

                        // Chips de Ingredientes
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: ingredients
                              .map((ing) => _buildIngredientChip(ing))
                              .toList(),
                        ),
                        const SizedBox(height: 30),

                        // Título de Adiciones/Opciones (Simulación)
                        const Text(
                          'Opciones y Especiales',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 15),

                        // Lista de opciones/modificadores (Simulación)
                        _buildOptionTile('Agregar Bacon', r'+$2.00', false),
                        _buildOptionTile('Doble Queso', r'+$1.50', true),
                        _buildOptionTile('Sin Tomate', r'$0.00', false),

                        const SizedBox(
                          height: 100,
                        ), // Espacio para que el botón flotante no tape el contenido
                      ],
                    ),
                  ),
                ]),
              ),
            ],
          ),

          // 3. Botón flotante "Agregar al carrito" (siempre visible en la parte inferior)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  // Acción de añadir al carrito
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF05B3A), // Naranja principal
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Agregar al carrito',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget para construir los chips de ingredientes.
  Widget _buildIngredientChip(String label) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: Colors.grey[200],
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  // Widget para construir una opción de modificador (ej. doble queso)
  Widget _buildOptionTile(String option, String price, bool isChecked) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(
          option,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(price, style: TextStyle(color: Colors.grey[600])),
            Checkbox(
              value: isChecked,
              onChanged: (bool? newValue) {
                // Simulación de cambio de estado (en una app real se usaría setState)
              },
              activeColor: const Color(0xFFF05B3A),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// PANTALLA DE DETALLE DEL MENÚ
// -----------------------------------------------------------------------------
class MenuDetailScreen extends StatelessWidget {
  final String restaurantName;

  const MenuDetailScreen({super.key, required this.restaurantName});

  @override
  Widget build(BuildContext context) {
    // Definición de colores principales de la imagen adjunta
    const Color primaryGreen = Color(0xFF389F43);
    const Color purpleBackground = Color(0xFFEFE8F6);

    // Listado de productos de ejemplo
    final List<Map<String, dynamic>> products = [
      {
        'name': 'Combo Clásico de Queso',
        'description':
            'Nuestra hamburguesa clásica con queso cheddar, lechuga, tomate...',
        'price': r'$8.50',
        'imageUrl': 'https://placehold.co/100x100/EFE8F6/7A5E9C?text=Taco',
        'fullImageUrl':
            'https://placehold.co/800x400/222222/FFFFFF?text=Combo+Clasico',
        'fullDescription':
            'Nuestra hamburguesa estrella con carne de res premium, queso cheddar derretido, lechuga fresca y nuestra salsa especial.',
        'isAvailable': true,
      },
      {
        'name': 'Combo Doble Bacon',
        'description':
            'Doble carne, doble queso y mucho bacon crujiente. Una explosión de...',
        'price': r'$9.99',
        'imageUrl': 'https://placehold.co/100x100/EFE8F6/7A5E9C?text=Burgers',
        'fullImageUrl':
            'https://placehold.co/800x400/222222/FFFFFF?text=Combo+Doble+Bacon',
        'fullDescription':
            'Una porción generosa de dos carnes de res, bañadas en queso fundido y las mejores tiras de bacon crujiente.',
        'isAvailable': true,
      },
      {
        'name': 'Combo Pollo Crispy',
        'description':
            'Filete de pollo empanizado y frito, con mayonesa y lechuga....',
        'price': r'$7.75',
        'imageUrl': 'https://placehold.co/100x100/EFE8F6/7A5E9C?text=Wrap',
        'fullImageUrl':
            'https://placehold.co/800x400/222222/FFFFFF?text=Combo+Pollo+Crispy',
        'fullDescription':
            'Delicioso filete de pollo empanizado, crujiente por fuera y jugoso por dentro, servido con mayonesa y lechuga fresca.',
        'isAvailable': false,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          restaurantName,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: const [
          IconButton(
            icon: Icon(Icons.search, color: Colors.black),
            onPressed: null,
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.black),
            onPressed: null,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chips de navegación (categorías)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCategoryChip('Combos', true, primaryGreen),
                    _buildCategoryChip('Bebidas', false, primaryGreen),
                    _buildCategoryChip('Postres', false, primaryGreen),
                    _buildCategoryChip('Individuales', false, primaryGreen),
                    _buildCategoryChip('Adicionales', false, primaryGreen),
                  ],
                ),
              ),
            ),

            // Separador (Línea sutil)
            const Divider(height: 1, color: Color(0xFFF0F0F0)),

            // Lista de productos
            ListView.builder(
              shrinkWrap: true,
              physics:
                  const NeverScrollableScrollPhysics(), // Evita el scroll doble
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return _buildProductItem(
                  product['name'] as String,
                  product['description'] as String,
                  product['price'] as String,
                  product['imageUrl'] as String,
                  product['fullImageUrl'] as String,
                  product['fullDescription'] as String,
                  product['isAvailable'] as bool,
                  purpleBackground,
                  context,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Widget para construir los chips de categorías.
  Widget _buildCategoryChip(
    String label,
    bool isSelected,
    Color selectedColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: Chip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isSelected ? selectedColor : Colors.grey[200],
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // Widget para construir un ítem de producto individual.
  Widget _buildProductItem(
    String name,
    String description,
    String price,
    String imageUrl,
    String fullImageUrl,
    String fullDescription,
    bool isAvailable,
    Color imageBgColor,
    BuildContext context,
  ) {
    final double opacity = isAvailable ? 1.0 : 0.5;

    return Opacity(
      opacity: opacity,
      child: GestureDetector(
        // --- NAVEGACIÓN A LA PANTALLA DE DETALLE DEL PRODUCTO AL HACER CLICK ---
        onTap: isAvailable
            ? () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ProductDetailScreen(
                      productName: name,
                      productPrice: price,
                      productDescription:
                          fullDescription, // Usamos la descripción completa para el detalle
                      imageUrl: fullImageUrl, // Usamos la URL de imagen grande
                    ),
                  ),
                );
              }
            : null, // Deshabilitar onTap si no está disponible
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Detalles del producto (Texto)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          price,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Etiqueta de "Agotado"
                        if (!isAvailable)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Agotado',
                              style: TextStyle(
                                color: Colors.red[800],
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Imagen del producto
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: imageBgColor, // Fondo morado claro
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.grey[500],
                        size: 30,
                      ),
                    ),
                  ),
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
// PANTALLA DE LISTADO DE RESTAURANTES
// -----------------------------------------------------------------------------
class RestaurantListScreen extends StatelessWidget {
  const RestaurantListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // Regresar al login (simulando cerrar sesión)
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const FoodPleaseLoginApp(),
              ),
            );
          },
        ),
        title: const Text(
          'Encuentra tu FoodPlease',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 10),

              // Campo de búsqueda
              TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre o dirección',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
              const SizedBox(height: 20),

              // Opciones de filtro (Más cercano, Menor tiempo de entrega)
              Row(
                children: [
                  _buildFilterChip('Más cercano', true),
                  const SizedBox(width: 10),
                  _buildFilterChip('Menor tiempo de entrega', false),
                  const SizedBox(width: 10),
                  _buildFilterChip('Score', false),
                ],
              ),
              const SizedBox(height: 20),

              // Lista de Restaurantes (Usando datos de ejemplo)
              _buildRestaurantCard(
                context,
                name: 'FoodPlease – Centro',
                address: 'Av. Siempre Viva 123, Centro',
                category: 'Pizzas y Hamburguesas',
                status: 'Abierto',
                statusColor: Colors.green,
                details: '25–30 min • 1.4 km de ti',
                imageUrl:
                    'https://placehold.co/400x200/F5F5F5/808080?text=FoodPlease+Centro',
              ),
              _buildRestaurantCard(
                context,
                name: 'FoodPlease – Norte',
                address: 'Calle Falsa 456, Zona Norte',
                category: 'Pizzas y Pastas',
                status: 'Abierto',
                statusColor: Colors.green,
                details: '35–40 min • 3.5 km de ti',
                imageUrl:
                    'https://placehold.co/400x200/F5F5F5/808080?text=FoodPlease+Norte',
              ),
              _buildRestaurantCard(
                context,
                name: 'FoodPlease – Sur',
                address: 'Blvd. de los Sueños Rotos 789',
                category: 'Hamburguesas y Alitas',
                status: 'Cerrado',
                statusColor: Colors.red,
                details: '40–50 min • 5.1 km de ti',
                imageUrl:
                    'https://placehold.co/400x200/F5F5F5/808080?text=FoodPlease+Sur',
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // Widget para construir los botones/chips de filtro.
  Widget _buildFilterChip(String label, bool isSelected) {
    return Chip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: isSelected ? const Color(0xFFF05B3A) : Colors.grey[200],
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  // Widget para construir cada tarjeta de restaurante.
  Widget _buildRestaurantCard(
    BuildContext context, {
    required String name,
    required String address,
    required String category,
    required String status,
    required Color statusColor,
    required String details,
    required String imageUrl,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => MenuDetailScreen(restaurantName: name),
            ),
          );
        },
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen Placeholder con bordes redondeados en la parte superior.
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Image.network(
                  imageUrl,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 150,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ),

              // Contenido de texto
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      address,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      category,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Fila de Status y Detalles
                    Row(
                      children: [
                        Icon(Icons.circle, size: 8, color: statusColor),
                        const SizedBox(width: 5),
                        Text(
                          status,
                          style: TextStyle(
                            fontSize: 14,
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Separador
                        const Text('•', style: TextStyle(color: Colors.grey)),
                        const SizedBox(width: 10),

                        Text(
                          details,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
