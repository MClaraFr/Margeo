import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../core/routes/app_routes.dart';
import '../../services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const Color _green = Color(0xFF193E2D);
  static const Color _background = Color(0xFFF3F6F1);

  Future<void> _logout(BuildContext context) async {
    await AuthService().signOut();

    if (context.mounted) {
      context.goNamed(AppRoutes.loginName);
    }
  }

  void _navigate(BuildContext context, String route) {
    context.goNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 760;

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/images/margeo_icone.svg',
              width: 34,
              height: 34,
            ),
            const SizedBox(width: 10),
            const Text(
              'Margeo',
              style: TextStyle(color: _green, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          if (isWide) ...[
            _navButton(context, 'Início', null),
            _navButton(context, 'Talhões', AppRoutes.plotsName),
            _navButton(context, 'Produtos', AppRoutes.productsName),
            _navButton(context, 'Aplicações', AppRoutes.applicationsName),
            IconButton(
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout),
              tooltip: 'Sair',
            ),
            const SizedBox(width: 12),
          ] else
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'logout') {
                  _logout(context);
                } else {
                  _navigate(context, value);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: AppRoutes.plotsName,
                  child: Text('Talhões'),
                ),
                const PopupMenuItem(
                  value: AppRoutes.productsName,
                  child: Text('Produtos'),
                ),
                const PopupMenuItem(
                  value: AppRoutes.applicationsName,
                  child: Text('Aplicações'),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(value: 'logout', child: Text('Sair')),
              ],
            ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcome(context, isWide),
                    const SizedBox(height: 32),
                    const Text(
                      'Visão geral',
                      style: TextStyle(
                        color: _green,
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _overviewCard(
                          constraints.maxWidth,
                          Icons.grass,
                          'Talhões',
                          'Áreas da propriedade',
                          const Color(0xFF5D8B6B),
                          () => _navigate(context, AppRoutes.plotsName),
                        ),
                        _overviewCard(
                          constraints.maxWidth,
                          Icons.inventory_2_outlined,
                          'Produtos',
                          'Insumos cadastrados',
                          const Color(0xFF6F9B7C),
                          () => _navigate(context, AppRoutes.productsName),
                        ),
                        _overviewCard(
                          constraints.maxWidth,
                          Icons.agriculture,
                          'Aplicações',
                          'Histórico de aplicações',
                          const Color(0xFFA88B55),
                          () => _navigate(context, AppRoutes.applicationsName),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Acesso rápido',
                      style: TextStyle(
                        color: _green,
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _quickAccessCard(
                          constraints.maxWidth,
                          Icons.add_location_alt_outlined,
                          'Cadastrar talhão',
                          'Adicione uma nova área à propriedade.',
                          () => _navigate(context, AppRoutes.plotsName),
                        ),
                        _quickAccessCard(
                          constraints.maxWidth,
                          Icons.playlist_add,
                          'Registrar aplicação',
                          'Registre os produtos utilizados e seus custos.',
                          () => _navigate(context, AppRoutes.applicationsName),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6EFE7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: _green,
                            size: 25,
                          ),
                          SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              'Mantenha seus registros atualizados para acompanhar melhor os custos e resultados da propriedade.',
                              style: TextStyle(color: _green, height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _navButton(BuildContext context, String label, String? route) {
    return TextButton(
      onPressed: route == null ? null : () => _navigate(context, route),
      child: Text(label, style: const TextStyle(color: _green)),
    );
  }

  Widget _buildWelcome(BuildContext context, bool isWide) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isWide ? 32 : 24),
      decoration: BoxDecoration(
        color: _green,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PAINEL DA PROPRIEDADE',
                  style: TextStyle(
                    color: Color(0xFFB9CFC0),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Olá, seja bem-vindo!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isWide ? 30 : 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Acompanhe seus talhões, produtos e aplicações em um só lugar.',
                  style: TextStyle(color: Color(0xFFE0E9E1), fontSize: 16),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: _green,
                      ),
                      onPressed: () =>
                          _navigate(context, AppRoutes.applicationsName),
                      icon: const Icon(Icons.add),
                      label: const Text('Registrar aplicação'),
                    ),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white70),
                      ),
                      onPressed: () => _navigate(context, AppRoutes.plotsName),
                      icon: const Icon(Icons.grass),
                      label: const Text('Novo talhão'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isWide) ...[
            const SizedBox(width: 24),
            const Icon(Icons.agriculture, color: Color(0xFF9FC5A8), size: 100),
          ],
        ],
      ),
    );
  }

  Widget _overviewCard(
    double availableWidth,
    IconData icon,
    String title,
    String subtitle,
    Color iconColor,
    VoidCallback onTap,
  ) {
    final width = availableWidth >= 900
        ? (availableWidth - 32) / 3
        : availableWidth >= 580
        ? (availableWidth - 16) / 2
        : availableWidth;

    return SizedBox(
      width: width,
      child: Card(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0xFFE1E8E0)),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: CircleAvatar(
            backgroundColor: const Color(0xFFEAF1EB),
            child: Icon(icon, color: iconColor),
          ),
          title: Text(
            title,
            style: const TextStyle(color: _green, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
      ),
    );
  }

  Widget _quickAccessCard(
    double availableWidth,
    IconData icon,
    String title,
    String description,
    VoidCallback onTap,
  ) {
    final width = availableWidth >= 700
        ? (availableWidth - 16) / 2
        : availableWidth;

    return SizedBox(
      width: width,
      child: Card(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0xFFE1E8E0)),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(18),
          leading: CircleAvatar(
            backgroundColor: const Color(0xFFEAF1EB),
            child: Icon(icon, color: _green),
          ),
          title: Text(
            title,
            style: const TextStyle(color: _green, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(description),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
      ),
    );
  }
}
