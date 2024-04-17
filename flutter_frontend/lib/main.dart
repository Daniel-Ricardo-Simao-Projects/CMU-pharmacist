import 'package:flutter/material.dart';
import 'package:flutter_frontend/product_service.dart';
import 'package:flutter_frontend/product_model.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final _productService = ProductService();

  @override
  Widget build(BuildContext context) {
    const title = 'Product List';

    return MaterialApp(
      title: title,
      theme: ThemeData(scaffoldBackgroundColor: const Color(0xffdddddd)),
      home: Scaffold(
        appBar: AppBar(
          title: const Text(title),
        ),
        body: ProductList(),
      ),
    );
  }
}

class ProductList extends StatefulWidget {
  @override
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
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
          return Center(child: CircularProgressIndicator());
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
