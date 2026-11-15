import 'package:flutter/material.dart';

import '../../models/product.dart';
import '../../services/product_service.dart';
import '../../core/utils/validators.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final ProductService _service = ProductService();
  final TextEditingController _searchController = TextEditingController();

  List<Product> _products = [];
  bool _loading = true;
  String? _error;
  String _search = '';

  static const Color primary = Color(0xFF386641);
  static const Color darkGreen = Color(0xFF263D2B);
  static const Color background = Color(0xFFF5F7F3);

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final products = await _service.getProducts();

      if (!mounted) return;

      setState(() {
        _products = products;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  // FORMULÁRIO DE CADASTRO E EDIÇÃO
  Future<void> _showProductForm({Product? product}) async {
    final nameController = TextEditingController(text: product?.name ?? '');

    final priceController = TextEditingController(
      text: product?.pricePerUnit.toString() ?? '',
    );

    final formKey = GlobalKey<FormState>();
    String selectedUnit = product?.unit ?? 'L';
    bool saving = false;

    InputDecoration fieldDecoration({
      required String label,
      required IconData icon,
      String? suffix,
      String? prefix,
    }) {
      return InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primary, size: 21),
        prefixText: prefix,
        suffixText: suffix,
        filled: true,
        fillColor: const Color(0xFFF7F9F5),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: Color(0xFFE1E9DE)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: Color(0xFFE1E9DE)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
      );
    }

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> saveProduct() async {
              if (saving || !formKey.currentState!.validate()) return;

              setDialogState(() => saving = true);

              final name = nameController.text.trim();
              final price = double.parse(
                priceController.text.replaceAll(',', '.'),
              );

              try {
                if (product == null) {
                  await _service.createProduct(name, selectedUnit, price);
                } else {
                  await _service.updateProduct(
                    product.id,
                    name,
                    selectedUnit,
                    price,
                  );
                }

                if (!dialogContext.mounted) return;

                Navigator.pop(dialogContext);
                await _loadProducts();

                if (!mounted) return;

                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,
                    content: Text(
                      product == null
                          ? 'Produto cadastrado com sucesso!'
                          : 'Produto atualizado com sucesso!',
                    ),
                  ),
                );
              } catch (error) {
                if (!dialogContext.mounted) return;

                setDialogState(() => saving = false);

                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,
                    content: Text('Não foi possível salvar: $error'),
                  ),
                );
              }
            }

            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 24,
              ),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 460),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // CABEÇALHO
                        Container(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 25),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF386641), Color(0xFF58865D)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.16),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Icon(
                                  product == null
                                      ? Icons.add_box_outlined
                                      : Icons.edit_note,
                                  color: Colors.white,
                                  size: 29,
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product == null
                                          ? 'Novo produto'
                                          : 'Editar produto',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 21,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    const Text(
                                      'Cadastre as informações do insumo',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: saving
                                    ? null
                                    : () => Navigator.pop(dialogContext),
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                ),
                                tooltip: 'Fechar',
                              ),
                            ],
                          ),
                        ),

                        // CAMPOS DO FORMULÁRIO
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 22),
                          child: Form(
                            key: formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'INFORMAÇÕES DO PRODUTO',
                                  style: TextStyle(
                                    color: primary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                TextFormField(
                                  controller: nameController,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  decoration: fieldDecoration(
                                    label: 'Nome do produto',
                                    icon: Icons.inventory_2_outlined,
                                  ),
                                  validator: Validators.requiredField,
                                ),

                                const SizedBox(height: 21),

                                const Text(
                                  'UNIDADE DE MEDIDA',
                                  style: TextStyle(
                                    color: primary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 10),

                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildUnitOption(
                                        label: 'Litros',
                                        abbreviation: 'L',
                                        icon: Icons.water_drop_outlined,
                                        selected: selectedUnit == 'L',
                                        onTap: () {
                                          setDialogState(
                                            () => selectedUnit = 'L',
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildUnitOption(
                                        label: 'Quilogramas',
                                        abbreviation: 'kg',
                                        icon: Icons.grain,
                                        selected: selectedUnit == 'kg',
                                        onTap: () {
                                          setDialogState(
                                            () => selectedUnit = 'kg',
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 21),

                                const Text(
                                  'VALOR DO PRODUTO',
                                  style: TextStyle(
                                    color: primary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 10),

                                TextFormField(
                                  controller: priceController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  decoration: fieldDecoration(
                                    label: 'Preço por unidade',
                                    icon: Icons.attach_money,
                                    prefix: 'R\$ ',
                                    suffix: '/ $selectedUnit',
                                  ),
                                  validator: Validators.positiveNumber,
                                ),

                                const SizedBox(height: 10),

                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF0F5EF),
                                    borderRadius: BorderRadius.circular(11),
                                  ),
                                  child: const Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        color: primary,
                                        size: 18,
                                      ),
                                      SizedBox(width: 9),
                                      Expanded(
                                        child: Text(
                                          'Informe o preço de compra por litro ou quilograma para ajudar no controle dos custos.',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF526453),
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 25),

                                // BOTÕES
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: saving
                                            ? null
                                            : () {
                                                Navigator.pop(dialogContext);
                                              },
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: darkGreen,
                                          side: const BorderSide(
                                            color: Color(0xFFDCE5D9),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 16,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                        child: const Text('Cancelar'),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      flex: 2,
                                      child: FilledButton.icon(
                                        onPressed: saving ? null : saveProduct,
                                        style: FilledButton.styleFrom(
                                          backgroundColor: primary,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 16,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                        icon: saving
                                            ? const SizedBox(
                                                width: 17,
                                                height: 17,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: Colors.white,
                                                    ),
                                              )
                                            : const Icon(
                                                Icons.check_circle_outline,
                                                size: 19,
                                              ),
                                        label: Text(
                                          saving
                                              ? 'Salvando...'
                                              : 'Salvar produto',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    nameController.dispose();
    priceController.dispose();
  }

  // SELEÇÃO VISUAL DA UNIDADE
  Widget _buildUnitOption({
    required String label,
    required String abbreviation,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(13),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEAF2EB) : const Color(0xFFF7F9F5),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: selected ? primary : const Color(0xFFE1E9DE),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: selected ? primary : Colors.black54, size: 21),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: selected ? darkGreen : Colors.black87,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    abbreviation,
                    style: TextStyle(
                      color: selected ? primary : Colors.black54,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (selected) ...[
              const SizedBox(width: 5),
              const Icon(Icons.check_circle, color: primary, size: 17),
            ],
          ],
        ),
      ),
    );
  }

  // EXCLUSÃO DE PRODUTO
  Future<void> _deleteProduct(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir produto'),
        content: Text('Deseja excluir o produto ${product.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _service.deleteProduct(product.id);

      if (!mounted) return;

      await _loadProducts();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produto excluído com sucesso!')),
      );
    } catch (error) {
      if (!mounted) return;

      final errorMessage = error.toString().toLowerCase();

      final isProductInUse =
          errorMessage.contains('1451') ||
          errorMessage.contains('integrity constraint') ||
          errorMessage.contains('foreign key') ||
          errorMessage.contains('application_product');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          backgroundColor: isProductInUse
              ? Colors.orange.shade800
              : Colors.red.shade700,
          content: Text(
            isProductInUse
                ? 'Este produto está vinculado a uma ou mais aplicações e não pode ser excluído.'
                : 'Não foi possível excluir o produto. Tente novamente.',
          ),
        ),
      );
    }
  }

  // CARDS DE RESUMO
  Widget _buildSummaryCard({
    required String label,
    required int count,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE4EAE1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: color, size: 21),
            ),
            const SizedBox(height: 13),
            Text(
              '$count',
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: darkGreen,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  // CARD DE PRODUTO
  Widget _buildProductCard(Product product) {
    final isLiquid = product.unit == 'L';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE5EAE2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isLiquid
                    ? const Color(0xFFE7F1EA)
                    : const Color(0xFFF3EEDF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                isLiquid ? Icons.water_drop_outlined : Icons.grain,
                color: isLiquid ? primary : const Color(0xFF9A783C),
                size: 25,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      color: darkGreen,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isLiquid
                              ? const Color(0xFFEAF2EB)
                              : const Color(0xFFF5F0E5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isLiquid ? 'Líquido' : 'Sólido',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isLiquid ? primary : const Color(0xFF8A6D36),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Unidade: ${product.unit}',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'R\$ ${product.pricePerUnit.toStringAsFixed(2)} / ${product.unit}',
                    style: const TextStyle(
                      color: primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.black54),
              onSelected: (action) {
                if (action == 'edit') {
                  _showProductForm(product: product);
                } else if (action == 'delete') {
                  _deleteProduct(product);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 19),
                      SizedBox(width: 10),
                      Text('Editar'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, size: 19, color: Colors.red),
                      SizedBox(width: 10),
                      Text('Excluir'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // TELA PRINCIPAL
  @override
  Widget build(BuildContext context) {
    final filteredProducts = _products.where((product) {
      return product.name.toLowerCase().contains(_search.toLowerCase());
    }).toList();

    final liquidCount = _products.where((p) => p.unit == 'L').length;
    final kgCount = _products.where((p) => p.unit == 'kg').length;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        title: const Text(
          'Produtos',
          style: TextStyle(fontWeight: FontWeight.w700, color: darkGreen),
        ),
        actions: [
          IconButton(
            onPressed: _loadProducts,
            tooltip: 'Atualizar',
            icon: const Icon(Icons.refresh, color: primary),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: primary))
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 42,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 12),
                    Text(_error!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _loadProducts,
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadProducts,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
                children: [
                  // CABEÇALHO DE RESUMO
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF386641), Color(0xFF58865D)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'GESTÃO DE INSUMOS',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  letterSpacing: 1.2,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '${_products.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 34,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                'Produtos cadastrados',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(17),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.14),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.inventory_2_outlined,
                            color: Colors.white,
                            size: 38,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // RESUMO POR UNIDADE
                  Row(
                    children: [
                      _buildSummaryCard(
                        label: 'Líquidos',
                        count: liquidCount,
                        icon: Icons.water_drop_outlined,
                        color: primary,
                      ),
                      const SizedBox(width: 12),
                      _buildSummaryCard(
                        label: 'Sólidos',
                        count: kgCount,
                        icon: Icons.grain,
                        color: const Color(0xFF9A783C),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // PESQUISA
                  TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() => _search = value);
                    },
                    decoration: InputDecoration(
                      hintText: 'Pesquisar produto...',
                      prefixIcon: const Icon(Icons.search, color: primary),
                      suffixIcon: _search.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _search = '');
                              },
                              icon: const Icon(Icons.close),
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE2E8DF)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE2E8DF)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // LISTA DE PRODUTOS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Seus produtos',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          color: darkGreen,
                        ),
                      ),
                      Text(
                        '${filteredProducts.length} registros',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  if (_products.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 45,
                            color: Color(0xFF9AA99A),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Nenhum produto cadastrado.',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    )
                  else if (filteredProducts.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: Text('Nenhum produto encontrado.')),
                    )
                  else
                    ...filteredProducts.map(_buildProductCard),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFB5F0BC),
        foregroundColor: darkGreen,
        elevation: 3,
        onPressed: () => _showProductForm(),
        icon: const Icon(Icons.add),
        label: const Text(
          'Novo produto',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
