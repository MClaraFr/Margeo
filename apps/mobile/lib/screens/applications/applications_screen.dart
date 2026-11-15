import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/utils/validators.dart';
import '../../models/application.dart';
import '../../models/plot.dart';
import '../../models/product.dart';
import '../../services/application_service.dart';

class ApplicationsScreen extends StatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  State<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends State<ApplicationsScreen> {
  final ApplicationService _service = ApplicationService();

  List<AgriculturalApplication> _applications = [];
  List<Plot> _plots = [];
  List<Product> _products = [];

  bool _loading = true;
  String? _error;

  static const Color primary = Color(0xFF386641);
  static const Color darkGreen = Color(0xFF263D2B);
  static const Color background = Color(0xFFF5F7F3);

  String _currency(double value) {
    return NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(value);
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final applications = await _service.getApplications();
      final plots = await _service.getPlots();
      final products = await _service.getProducts();

      if (!mounted) return;

      setState(() {
        _applications = applications;
        _plots = plots;
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

  Future<void> _showForm({AgriculturalApplication? application}) async {
    if (_plots.isEmpty || _products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cadastre pelo menos um talhão e um produto.'),
        ),
      );
      return;
    }

    final formKey = GlobalKey<FormState>();
    final areaController = TextEditingController(
      text: application?.areaHa.toString() ?? '',
    );

    int? selectedPlot = application?.plot?.id ?? _plots.first.id;
    DateTime selectedDate = application?.applicationDate ?? DateTime.now();

    final dateController = TextEditingController(
      text: DateFormat('dd/MM/yyyy').format(selectedDate),
    );

    final entries = <_ProductEntry>[];

    if (application != null) {
      for (final item in application.products) {
        entries.add(
          _ProductEntry(
            productId: item.productId,
            controller: TextEditingController(
              text: item.quantityPerHa.toString(),
            ),
          ),
        );
      }
    } else {
      entries.add(
        _ProductEntry(
          productId: _products.first.id,
          controller: TextEditingController(),
        ),
      );
    }

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Icon(Icons.agriculture_outlined, color: primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  application == null ? 'Nova aplicação' : 'Editar aplicação',
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 440,
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<int>(
                      initialValue: selectedPlot,
                      decoration: const InputDecoration(
                        labelText: 'Talhão',
                        prefixIcon: Icon(Icons.landscape_outlined),
                      ),
                      items: _plots.map((plot) {
                        return DropdownMenuItem(
                          value: plot.id,
                          child: Text(plot.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() => selectedPlot = value);
                      },
                      validator: (value) => Validators.requiredSelection(
                        value,
                        message: 'Selecione um talhão',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: dateController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Data da aplicação',
                        prefixIcon: Icon(Icons.calendar_month_outlined),
                      ),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: dialogContext,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2035),
                        );

                        if (date != null) {
                          setDialogState(() {
                            selectedDate = date;
                            dateController.text = DateFormat(
                              'dd/MM/yyyy',
                            ).format(date);
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: areaController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Área aplicada',
                        prefixIcon: Icon(Icons.square_foot),
                        suffixText: 'ha',
                      ),
                      validator: Validators.positiveNumber,
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF2EB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.science_outlined, color: primary),
                          SizedBox(width: 9),
                          Text(
                            'Produtos utilizados',
                            style: TextStyle(
                              color: darkGreen,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    ...entries.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F9F6),
                          borderRadius: BorderRadius.circular(13),
                          border: Border.all(color: const Color(0xFFE2E9E0)),
                        ),
                        child: Column(
                          children: [
                            DropdownButtonFormField<int>(
                              initialValue: item.productId,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: 'Produto',
                                prefixIcon: Icon(Icons.inventory_2_outlined),
                              ),
                              items: _products.map((product) {
                                return DropdownMenuItem(
                                  value: product.id,
                                  child: Text(product.name),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setDialogState(() => item.productId = value);
                              },
                              validator: (value) =>
                                  Validators.requiredSelection(
                                    value,
                                    message: 'Selecione um produto',
                                  ),
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: item.controller,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: const InputDecoration(
                                labelText: 'Dose por hectare',
                                prefixIcon: Icon(Icons.science_outlined),
                              ),
                              validator: Validators.positiveNumber,
                            ),
                            if (entries.length > 1)
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: () {
                                    setDialogState(() {
                                      final removed = entries.removeAt(index);
                                      removed.controller.dispose();
                                    });
                                  },
                                  icon: const Icon(Icons.delete_outline),
                                  label: const Text('Remover produto'),
                                ),
                              ),
                          ],
                        ),
                      );
                    }),
                    TextButton.icon(
                      onPressed: () {
                        setDialogState(() {
                          entries.add(
                            _ProductEntry(
                              productId: _products.first.id,
                              controller: TextEditingController(),
                            ),
                          );
                        });
                      },
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Adicionar produto'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (!formKey.currentState!.validate()) return;

                final area = double.parse(
                  areaController.text.replaceAll(',', '.'),
                );

                final products = entries.map((entry) {
                  return {
                    'product_id': entry.productId,
                    'quantity_per_ha': double.parse(
                      entry.controller.text.replaceAll(',', '.'),
                    ),
                  };
                }).toList();

                Navigator.pop(dialogContext, {
                  'plot_id': selectedPlot,
                  'application_date': DateFormat(
                    'yyyy-MM-dd',
                  ).format(selectedDate),
                  'area_ha': area,
                  'products': products,
                });
              },
              icon: const Icon(Icons.save_outlined),
              label: const Text('Salvar aplicação'),
            ),
          ],
        ),
      ),
    );

    areaController.dispose();
    dateController.dispose();

    for (final entry in entries) {
      entry.controller.dispose();
    }

    if (result == null) return;

    try {
      if (application == null) {
        await _service.createApplication(result);
      } else {
        await _service.updateApplication(application.id, result);
      }

      await _loadData();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aplicação salva com sucesso!')),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  Future<void> _deleteApplication(AgriculturalApplication application) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir aplicação'),
        content: const Text('Deseja excluir este registro?'),
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
      await _service.deleteApplication(application.id);
      await _loadData();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aplicação excluída com sucesso!')),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  Widget _buildMetric({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFFE4EAE1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                color: darkGreen,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.black54, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4EF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: primary, size: 15),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: darkGreen,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationCard(AgriculturalApplication application) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE2E9E0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 15, 8, 12),
            child: Row(
              children: [
                Container(
                  width: 43,
                  height: 43,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF2EB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.agriculture_outlined,
                    color: primary,
                    size: 23,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        application.plot?.name ?? 'Talhão não informado',
                        style: const TextStyle(
                          color: darkGreen,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat(
                          'dd/MM/yyyy',
                        ).format(application.applicationDate),
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (action) {
                    if (action == 'edit') {
                      _showForm(application: application);
                    } else if (action == 'delete') {
                      _deleteApplication(application);
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 19),
                          SizedBox(width: 10),
                          Text('Editar'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 19,
                            color: Colors.red,
                          ),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 9,
              runSpacing: 8,
              children: [
                _buildInfoChip(
                  Icons.landscape_outlined,
                  '${application.areaHa} ha aplicados',
                ),
                _buildInfoChip(
                  Icons.science_outlined,
                  '${application.products.length} produto(s)',
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Divider(height: 1, color: Color(0xFFE8ECE6)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PRODUTOS UTILIZADOS',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 10,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                ...application.products.map((product) {
                  final quantity = application.areaHa * product.quantityPerHa;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 9),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          margin: const EdgeInsets.only(top: 6, right: 9),
                          decoration: const BoxDecoration(
                            color: Color(0xFF79A77D),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: const TextStyle(
                                  color: darkGreen,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${product.quantityPerHa} ${product.unit}/ha  ·  Total: ${quantity.toStringAsFixed(2)} ${product.unit}',
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xFFF0F5EF),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(17),
                bottomRight: Radius.circular(17),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.payments_outlined, color: primary, size: 21),
                const SizedBox(width: 9),
                const Expanded(
                  child: Text(
                    'Custo total',
                    style: TextStyle(
                      color: darkGreen,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                Text(
                  _currency(application.totalCost),
                  style: const TextStyle(
                    color: primary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalArea = _applications.fold<double>(
      0,
      (total, item) => total + item.areaHa,
    );

    final totalCost = _applications.fold<double>(
      0,
      (total, item) => total + item.totalCost,
    );

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        title: const Text(
          'Aplicações',
          style: TextStyle(color: darkGreen, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            onPressed: _loadData,
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
                      color: Colors.red,
                      size: 42,
                    ),
                    const SizedBox(height: 12),
                    Text(_error!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _loadData,
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
                children: [
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
                                'CONTROLE DE OPERAÇÕES',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                  letterSpacing: 1.2,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '${_applications.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 34,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                'Aplicações registradas',
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
                            Icons.agriculture_outlined,
                            color: Colors.white,
                            size: 38,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _buildMetric(
                        label: 'Área aplicada',
                        value: '${totalArea.toStringAsFixed(1)} ha',
                        icon: Icons.landscape_outlined,
                        color: primary,
                      ),
                      const SizedBox(width: 12),
                      _buildMetric(
                        label: 'Custo acumulado',
                        value: _currency(totalCost),
                        icon: Icons.payments_outlined,
                        color: const Color(0xFF9A783C),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Histórico de aplicações',
                        style: TextStyle(
                          color: darkGreen,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${_applications.length} registros',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (_applications.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.agriculture_outlined,
                            size: 45,
                            color: Color(0xFF9AA99A),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Nenhuma aplicação cadastrada.',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    )
                  else
                    ..._applications.map(_buildApplicationCard),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(),
        backgroundColor: const Color(0xFFB5F0BC),
        foregroundColor: darkGreen,
        elevation: 3,
        icon: const Icon(Icons.add),
        label: const Text(
          'Nova aplicação',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _ProductEntry {
  int? productId;
  final TextEditingController controller;

  _ProductEntry({required this.productId, required this.controller});
}
