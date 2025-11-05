import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final _dbRef = FirebaseDatabase.instance.ref('products');

  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();
  final _imageController = TextEditingController();

  // ✅ Thêm kiểm tra rỗng
  void _addProduct() {
    if (_nameController.text.trim().isEmpty ||
        _priceController.text.trim().isEmpty ||
        _imageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Vui lòng nhập đầy đủ thông tin sản phẩm")),
      );
      return;
    }

    final newProduct = {
      'name': _nameController.text.trim(),
      'price': int.tryParse(_priceController.text) ?? 0,
      'desc': _descController.text.trim(),
      'image': _imageController.text.trim(),
    };

    _dbRef.push().set(newProduct);
    _clearFields();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Đã thêm sản phẩm thành công")),
    );
  }

  void _clearFields() {
    _nameController.clear();
    _priceController.clear();
    _descController.clear();
    _imageController.clear();
  }

  void _confirmDelete(String key) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: const Text("Bạn có chắc muốn xóa sản phẩm này không?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Hủy"),
          ),
          TextButton(
            onPressed: () {
              _dbRef.child(key).remove();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("🗑️ Đã xóa sản phẩm")),
              );
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _editProduct(String key, Map product) {
    _nameController.text = product['name'] ?? '';
    _priceController.text = product['price']?.toString() ?? '';
    _descController.text = product['desc'] ?? '';
    _imageController.text = product['image'] ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Chỉnh sửa sản phẩm"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Tên sản phẩm"),
              ),
              TextField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: "Giá"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _descController,
                decoration: const InputDecoration(labelText: "Mô tả"),
              ),
              TextField(
                controller: _imageController,
                decoration: const InputDecoration(labelText: "Link ảnh"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _dbRef.child(key).update({
                'name': _nameController.text.trim(),
                'price': int.tryParse(_priceController.text) ?? 0,
                'desc': _descController.text.trim(),
                'image': _imageController.text.trim(),
              });
              Navigator.pop(context);
              _clearFields();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("✅ Đã cập nhật sản phẩm")),
              );
            },
            child: const Text("Lưu"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("👨‍💼 Quản lý sản phẩm")),
      body: Column(
        children: [
          // 🔹 Form thêm sản phẩm
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: "Tên sản phẩm"),
                ),
                TextField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: "Giá"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _descController,
                  decoration: const InputDecoration(labelText: "Mô tả"),
                ),
                TextField(
                  controller: _imageController,
                  decoration: const InputDecoration(labelText: "Link ảnh"),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _addProduct,
                    icon: const Icon(Icons.add),
                    label: const Text("Thêm sản phẩm"),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),

          // 🔹 Danh sách sản phẩm hiện tại
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: _dbRef.onValue,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData ||
                    snapshot.data!.snapshot.value == null) {
                  return const Center(child: Text("Chưa có sản phẩm nào"));
                }

                // ✅ Ép kiểu an toàn
                final data = Map<String, dynamic>.from(
                    snapshot.data!.snapshot.value as Map);

                final entries = data.entries.toList().reversed.toList();

                return ListView.builder(
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final key = entries[index].key;
                    final product =
                        Map<String, dynamic>.from(entries[index].value);

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      elevation: 3,
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            product['image'] ?? '',
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.image_not_supported, size: 40),
                          ),
                        ),
                        title: Text(product['name'] ?? 'Không tên'),
                        subtitle: Text(
                          "${product['price']}₫\n${product['desc'] ?? ''}",
                        ),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editProduct(key, product),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmDelete(key),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
