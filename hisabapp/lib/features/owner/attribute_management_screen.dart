import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hisabapp/application/di.dart';
import 'package:hisabapp/core/presentation/theme/app_colors.dart';

class AttributeManagementScreen extends StatefulWidget {
  const AttributeManagementScreen({super.key});

  @override
  State<AttributeManagementScreen> createState() => _AttributeManagementScreenState();
}

class _AttributeManagementScreenState extends State<AttributeManagementScreen> {
  final TextEditingController _attributeController = TextEditingController();
  final List<String> _attributes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAttributes();
  }

  @override
  void dispose() {
    _attributeController.dispose();
    super.dispose();
  }

  Future<void> _loadAttributes() async {
    try {
      final saved = await appRepository.getProductAttributes();
      if (!mounted) return;
      setState(() {
        _attributes.addAll(saved);
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _addAttribute() async {
    final text = _attributeController.text.trim();
    if (text.isEmpty) return;
    if (text.toLowerCase() == 'product name') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot use "Product Name" as a custom attribute.')),
      );
      return;
    }
    if (_attributes.contains(text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This attribute already exists.')),
      );
      return;
    }
    
    setState(() {
      _attributes.add(text);
      _attributeController.clear();
    });

    try {
      await appRepository.saveProductAttributes(_attributes);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save attribute: $e')),
        );
      }
    }
  }

  Future<void> _deleteAttribute(int index) async {
    setState(() {
      _attributes.removeAt(index);
    });

    try {
      await appRepository.saveProductAttributes(_attributes);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete attribute: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Attributes', style: TextStyle(color: AppColors.textMain)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: AppColors.textMain),
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      backgroundColor: Colors.white,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add or delete product attributes (e.g. Storage, RAM, Color).',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _attributeController,
                          decoration: InputDecoration(
                            hintText: 'New Attribute',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onSubmitted: (_) => _addAttribute(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _addAttribute,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryYellow,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        ),
                        child: const Text('Add', style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_attributes.isEmpty)
                    const Text('No custom attributes yet.', style: TextStyle(color: Colors.grey))
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: _attributes.length,
                        itemBuilder: (context, index) {
                          final attr = _attributes[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Expanded(child: Text(attr, style: const TextStyle(fontSize: 14))),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                                  onPressed: () => _deleteAttribute(index),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
