import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hisabapp/application/di.dart';
import 'package:hisabapp/core/presentation/theme/app_colors.dart';

class EditProductAttributesPage extends StatefulWidget {
  const EditProductAttributesPage({super.key});

  @override
  State<EditProductAttributesPage> createState() => _EditProductAttributesPageState();
}

class _EditProductAttributesPageState extends State<EditProductAttributesPage> {
  final TextEditingController _attributeController = TextEditingController();
  final List<String> _attributes = [];
  bool _loading = true;
  bool _saving = false;

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

  void _addAttribute() {
    final text = _attributeController.text.trim();
    if (text.isEmpty) return;
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
  }

  Future<void> _saveAttributes() async {
    setState(() => _saving = true);
    try {
      await appRepository.saveProductAttributes(_attributes);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product attributes saved.')),
      );
      context.pop();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save attributes: $error')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Attributes', style: TextStyle(color: AppColors.textMain)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: AppColors.textMain),
        elevation: 1,
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
                    'Edit the attributes you use to describe products (e.g. Model, Color, Size).',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _attributeController,
                          decoration: InputDecoration(
                            hintText: 'e.g. Model',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onSubmitted: (_) => _addAttribute(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        onPressed: _addAttribute,
                        icon: const Icon(Icons.add, color: AppColors.textMain),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_attributes.isEmpty)
                    const Text('No attributes yet. Add at least one.', style: TextStyle(color: Colors.grey))
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
                                  icon: const Icon(Icons.close, size: 18),
                                  onPressed: () => setState(() => _attributes.removeAt(index)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _saving || _attributes.isEmpty ? null : _saveAttributes,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryYellow,
                        disabledBackgroundColor: AppColors.primaryYellow.withOpacity(0.4),
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'Save Attributes',
                              style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
