import 'package:flutter/material.dart';
import 'package:flutter_frontend/pages/maps.dart';
import 'package:flutter_frontend/product_service.dart';
import 'package:flutter_frontend/product_model.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    //const title = 'Product List';

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PharmacIST',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 73, 168, 112)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'PharmacIST'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
  });

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: ElevatedButton(
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.map),
                SizedBox(width: 8),
                Text('Show Map'),
              ],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MapsPage()),
              );
            }),
      ),
    );
  }
}

class ProductList extends StatefulWidget {
  const ProductList({super.key});

  @override
  ProductListState createState() => ProductListState();
}

class ProductListState extends State<ProductList> {
  final _productService = ProductService();
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = _productService.getProducts();
  }

  Future<void> _refreshProducts() async {
    setState(() {
      _productsFuture = _productService.getProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Product>>(
      future: _productsFuture,
      builder: (context, snapshot) {
        var products = snapshot.data ?? [];

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: _refreshProducts,
          child: ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              var product = products[index];
              return ListTile(
                title: Text(products[index].name),
                subtitle: Text('#${product.id} ${product.description}'),
                trailing: Text('\$${product.price}'),
              );
            },
          ),
        );
      },
    );
  }
}
