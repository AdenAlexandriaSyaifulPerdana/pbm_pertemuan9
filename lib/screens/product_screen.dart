import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../services/product_service.dart';
import '../services/storage_service.dart';
import '../widgets/product_card.dart';
import 'add_product_screen.dart';
import 'login_screen.dart';
import 'submit_task_screen.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final StorageService _storageService = StorageService();

  String? _token;
  bool _isLoading = true;
  String? _errorMessage;
  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    _prepareData();
  }

  Future<void> _prepareData() async {
    final token = await _storageService.getToken();

    if (!mounted) return;

    if (token == null || token.isEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    setState(() {
      _token = token;
    });

    await _loadProducts();
  }

  Future<void> _loadProducts() async {
    if (_token == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final service = ProductService(token: _token!);
      final products = await service.getProducts();

      if (!mounted) return;

      setState(() {
        _products = products;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = error.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    await _storageService.deleteToken();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  Future<void> _openAddProductScreen() async {
    if (_token == null) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddProductScreen(token: _token!)),
    );

    if (result == true) {
      await _loadProducts();
    }
  }

  Future<void> _openSubmitScreen() async {
    if (_token == null) return;

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SubmitTaskScreen(token: _token!)),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 34),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF134E4A), Color(0xFF0F766E)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(34),
          bottomRight: Radius.circular(34),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.28),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.storefront_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _loadProducts,
                tooltip: 'Refresh',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.16),
                ),
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _logout,
                tooltip: 'Logout',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.16),
                ),
                icon: const Icon(Icons.logout_rounded, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const Text(
            'Produk Saya',
            style: TextStyle(
              fontSize: 29,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _products.isEmpty
                ? 'Kelola draft produk yang akan kamu tambahkan.'
                : '${_products.length} produk tersimpan sebagai draft.',
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: Colors.white.withOpacity(0.88),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFF0F766E)),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBF5),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFE7DCCB), width: 1),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 44,
                color: Color(0xFFDC2626),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _loadProducts,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F766E),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Coba Lagi',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return RefreshIndicator(
      color: const Color(0xFF0F766E),
      onRefresh: _loadProducts,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 34, 24, 24),
        children: [
          const SizedBox(height: 70),
          Center(
            child: Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBF5),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: const Color(0xFFE7DCCB), width: 1),
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                size: 46,
                color: Color(0xFF0F766E),
              ),
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Belum Ada Produk',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tambahkan draft produk terlebih dahulu agar katalog produk kamu muncul di halaman ini.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 26),
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _openAddProductScreen,
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                'Tambah Produk',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F766E),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    return RefreshIndicator(
      color: const Color(0xFF0F766E),
      onRefresh: _loadProducts,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 110),
        itemCount: _products.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Container(
              margin: const EdgeInsets.only(bottom: 18),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBF5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE7DCCB), width: 1),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFF0F766E),
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${_products.length} produk sudah tersimpan. Tarik layar ke bawah untuk refresh data.',
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: Color(0xFF475569),
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final product = _products[index - 1];
          return ProductCard(product: product);
        },
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return _buildLoading();
    }

    if (_errorMessage != null) {
      return _buildError();
    }

    if (_products.isEmpty) {
      return _buildEmpty();
    }

    return _buildProductList();
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
      decoration: const BoxDecoration(
        color: Color(0xFFF8EFE3),
        border: Border(top: BorderSide(color: Color(0xFFE7DCCB), width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: _openAddProductScreen,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text(
                    'Tambah',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0F766E),
                    side: const BorderSide(
                      color: Color(0xFF0F766E),
                      width: 1.3,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _openSubmitScreen,
                  icon: const Icon(Icons.send_rounded),
                  label: const Text(
                    'Submit',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F766E),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8EFE3),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }
}
