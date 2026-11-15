import 'package:flutter/material.dart';

import '../../core/utils/validators.dart';
import '../../models/plot.dart';
import '../../services/plot_service.dart';

class PlotsScreen extends StatefulWidget {
  const PlotsScreen({super.key});

  @override
  State<PlotsScreen> createState() => _PlotsScreenState();
}

class _PlotsScreenState extends State<PlotsScreen> {
  final PlotService _service = PlotService();
  final TextEditingController _searchController = TextEditingController();

  List<Plot> _plots = [];
  bool _loading = true;
  String? _error;
  String _search = '';

  static const Color primary = Color(0xFF386641);
  static const Color darkGreen = Color(0xFF263D2B);
  static const Color background = Color(0xFFF5F7F3);

  @override
  void initState() {
    super.initState();
    _loadPlots();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPlots() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final plots = await _service.getPlots();
      if (!mounted) return;

      setState(() {
        _plots = plots;
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

  Future<void> _showPlotForm({Plot? plot}) async {
    final nameController = TextEditingController(text: plot?.name ?? '');
    final areaController = TextEditingController(
      text: plot?.areaHa.toString() ?? '',
    );
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.landscape_outlined, color: primary),
            const SizedBox(width: 10),
            Text(plot == null ? 'Novo talhão' : 'Editar talhão'),
          ],
        ),
        content: Form(
          key: formKey,
          child: SizedBox(
            width: 380,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome do talhão',
                    prefixIcon: Icon(Icons.grass_outlined),
                  ),
                  validator: Validators.requiredField,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: areaController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Área em hectares',
                    prefixIcon: Icon(Icons.square_foot),
                    suffixText: 'ha',
                  ),
                  validator: Validators.positiveNumber,
                ),
              ],
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
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              final name = nameController.text.trim();
              final area = double.parse(
                areaController.text.replaceAll(',', '.'),
              );

              try {
                if (plot == null) {
                  await _service.createPlot(name, area);
                } else {
                  await _service.updatePlot(plot.id, name, area);
                }

                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);

                await _loadPlots();
                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Talhão salvo com sucesso!')),
                );
              } catch (error) {
                if (!dialogContext.mounted) return;
                ScaffoldMessenger.of(
                  dialogContext,
                ).showSnackBar(SnackBar(content: Text(error.toString())));
              }
            },
            icon: const Icon(Icons.save_outlined),
            label: const Text('Salvar'),
          ),
        ],
      ),
    );

    nameController.dispose();
    areaController.dispose();
  }

  Future<void> _deletePlot(Plot plot) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir talhão'),
        content: Text('Deseja excluir o talhão ${plot.name}?'),
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
      await _service.deletePlot(plot.id);
      await _loadPlots();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Talhão excluído com sucesso!')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  Widget _buildPlotCard(Plot plot) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E9E0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 9,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF2EB),
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(Icons.grass, color: primary, size: 25),
        ),
        title: Text(
          plot.name,
          style: const TextStyle(
            color: darkGreen,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Row(
            children: [
              const Icon(Icons.square_foot, size: 15, color: primary),
              const SizedBox(width: 5),
              Text('${plot.areaHa.toStringAsFixed(2)} hectares'),
            ],
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (action) {
            if (action == 'edit') {
              _showPlotForm(plot: plot);
            } else if (action == 'delete') {
              _deletePlot(plot);
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
                  Icon(Icons.delete_outline, size: 19, color: Colors.red),
                  SizedBox(width: 10),
                  Text('Excluir'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredPlots = _plots.where((plot) {
      return plot.name.toLowerCase().contains(_search.toLowerCase());
    }).toList();

    final totalArea = _plots.fold<double>(
      0,
      (total, plot) => total + plot.areaHa,
    );

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        title: const Text(
          'Talhões',
          style: TextStyle(color: darkGreen, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            onPressed: _loadPlots,
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
                      onPressed: _loadPlots,
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadPlots,
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
                                'GESTÃO DE ÁREAS',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  letterSpacing: 1.2,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '${_plots.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 34,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                'Talhões cadastrados',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '${totalArea.toStringAsFixed(2)} hectares no total',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
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
                            Icons.landscape_outlined,
                            color: Colors.white,
                            size: 38,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _search = value),
                    decoration: InputDecoration(
                      hintText: 'Pesquisar talhão...',
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Seus talhões',
                        style: TextStyle(
                          color: darkGreen,
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${filteredPlots.length} registros',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (_plots.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.grass_outlined,
                            size: 45,
                            color: Color(0xFF9AA99A),
                          ),
                          SizedBox(height: 12),
                          Text('Nenhum talhão cadastrado.'),
                        ],
                      ),
                    )
                  else if (filteredPlots.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: Text('Nenhum talhão encontrado.')),
                    )
                  else
                    ...filteredPlots.map(_buildPlotCard),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPlotForm(),
        backgroundColor: const Color(0xFFB5F0BC),
        foregroundColor: darkGreen,
        elevation: 3,
        icon: const Icon(Icons.add),
        label: const Text(
          'Novo talhão',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
