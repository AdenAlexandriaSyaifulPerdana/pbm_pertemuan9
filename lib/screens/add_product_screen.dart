import 'package:flutter/material.dart';

import '../services/product_service.dart';

class AddProductScreen extends StatefulWidget {
  final String token;

  const AddProductScreen({super.key, required this.token});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _isLoading = false;

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final service = ProductService(token: widget.token);

      await service.addProduct(
        name: _nameController.text.trim(),
        price: int.parse(_priceController.text.trim()),
        description: _descriptionController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Produk berhasil disimpan.'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
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
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName tidak boleh kosong.';
    }

    return null;
  }

  String? _validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Harga tidak boleh kosong.';
    }

    final price = int.tryParse(value.trim());

    if (price == null) {
      return 'Harga harus berupa angka.';
    }

    if (price <= 0) {
      return 'Harga harus lebih dari 0.';
    }

    return null;
  }

  InputDecoration _inputDecoration({
    required String labelText,
    required IconData prefixIcon,
    Widget? suffixIcon,
    bool alignLabelWithHint = false,
  }) {
    return InputDecoration(
      labelText: labelText,
      alignLabelWithHint: alignLabelWithHint,
      prefixIcon: Icon(prefixIcon, color: const Color(0xFF0F766E)),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFFFFBF5),
      labelStyle: const TextStyle(
        color: Color(0xFF64748B),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE7DCCB), width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF0F766E), width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.6),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
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
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.16),
            ),
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          ),
          const SizedBox(height: 16),
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
              Icons.add_box_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Tambah Produk',
            style: TextStyle(
              fontSize: 29,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Masukkan data produk dengan lengkap sebelum disimpan sebagai draft.',
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: Colors.white.withOpacity(0.88),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE7DCCB), width: 1),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: Color(0xFF0F766E), size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Pastikan nama, harga, dan deskripsi produk sudah benar.',
              style: TextStyle(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8EFE3),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Form Produk',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Isi informasi produk di bawah ini.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 26),
                      TextFormField(
                        controller: _nameController,
                        textInputAction: TextInputAction.next,
                        decoration: _inputDecoration(
                          labelText: 'Nama Produk',
                          prefixIcon: Icons.shopping_bag_outlined,
                        ),
                        validator: (value) {
                          return _validateRequired(value, 'Nama produk');
                        },
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        decoration: _inputDecoration(
                          labelText: 'Harga Produk',
                          prefixIcon: Icons.payments_outlined,
                        ),
                        validator: _validatePrice,
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 4,
                        textInputAction: TextInputAction.newline,
                        decoration: _inputDecoration(
                          labelText: 'Deskripsi Produk',
                          prefixIcon: Icons.description_outlined,
                          alignLabelWithHint: true,
                        ),
                        validator: (value) {
                          return _validateRequired(value, 'Deskripsi produk');
                        },
                      ),
                      const SizedBox(height: 22),
                      _buildInfoBox(),
                      const SizedBox(height: 26),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveProduct,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F766E),
                            disabledBackgroundColor: const Color(0xFF99F6E4),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Simpan Produk',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                        ),
                      ),
                    ],
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
