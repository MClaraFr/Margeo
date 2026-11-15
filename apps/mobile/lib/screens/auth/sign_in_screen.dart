import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../core/routes/app_routes.dart';
import '../../core/utils/validators.dart';
import '../../services/auth_service.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _whatsappController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;

  static const Color _green = Color(0xFF193E2D);
  static const Color _background = Color(0xFFF3F6F1);

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      await AuthService().signIn(
        whatsapp: _whatsappController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        context.goNamed(AppRoutes.homeName);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  void dispose() {
    _whatsappController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 760;

            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: Container(
                    width: isWide ? 1100 : constraints.maxWidth - 32,
                    margin: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: isWide ? 32 : 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildHeader(),

                        if (isWide)
                          SizedBox(
                            height: 540,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(child: _buildBrandPanel()),
                                Expanded(child: _buildLoginPanel()),
                              ],
                            ),
                          )
                        else ...[
                          _buildBrandPanel(compact: true),
                          _buildLoginPanel(),
                        ],

                        _buildFooter(),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE8ECE6))),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/images/margeo_icone.svg',
            width: 30,
            height: 30,
          ),
          const SizedBox(width: 10),
          const Text(
            'Margeo',
            style: TextStyle(
              color: _green,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandPanel({bool compact = false}) {
    return Container(
      padding: EdgeInsets.all(compact ? 24 : 48),
      decoration: const BoxDecoration(color: _green),
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _TopographicPainter())),
          SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bem-vindo de volta!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: compact ? 23 : 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Aproveite nossas funcionalidades para simplificar sua gestão agrícola.',
                    style: TextStyle(
                      color: const Color(0xFFE0E9E1),
                      fontSize: compact ? 14 : 17,
                      height: 1.6,
                    ),
                  ),
                  if (!compact) ...[
                    const SizedBox(height: 32),
                    _buildFeature(Icons.agriculture, 'Acompanhe seus talhões'),
                    const SizedBox(height: 18),
                    _buildFeature(Icons.attach_money, 'Controle seus custos'),
                    const SizedBox(height: 18),
                    _buildFeature(
                      Icons.analytics_outlined,
                      'Visualize seus resultados',
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeature(IconData icon, String label) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: const Color(0xFF9FC5A8), size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginPanel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
      color: Colors.white,
      child: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Acessar',
                    style: TextStyle(
                      color: _green,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Entre com seus dados para continuar.',
                    style: TextStyle(color: Color(0xFF737B74), fontSize: 15),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 58,
                    child: TextFormField(
                      controller: _whatsappController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'WhatsApp',
                        hintText: 'Digite seu número',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                      validator: Validators.requiredField,
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    height: 58,
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Senha',
                        hintText: 'Digite sua senha',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      validator: Validators.requiredField,
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: _green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _loading ? null : _signIn,
                      child: _loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Entrar',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: const Color(0xFFF1F4EF),
      child: const Text(
        '© Margeo',
        textAlign: TextAlign.center,
        style: TextStyle(color: Color(0xFF7B857B), fontSize: 11),
      ),
    );
  }
}

class _TopographicPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color.fromARGB(255, 214, 225, 217).withValues(alpha: 0.30)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    for (int i = 0; i < 8; i++) {
      final y = size.height * (i / 7);

      final path = Path()
        ..moveTo(-20, y)
        ..cubicTo(
          size.width * 0.25,
          y + 65,
          size.width * 0.25,
          y - 65,
          size.width * 0.48,
          y + 5,
        )
        ..cubicTo(
          size.width * 0.72,
          y + 85,
          size.width * 0.82,
          y + 45,
          size.width + 20,
          y - 25,
        );

      canvas.drawPath(path, linePaint);
    }

    final dotPaint = Paint()
      ..color = const Color(0xFFD5E1D7).withValues(alpha: 0.75)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 35; i++) {
      final progress = i / 34;

      canvas.drawCircle(
        Offset(
          size.width * (0.15 + progress * 0.48),
          size.height * (0.95 - progress * 0.85),
        ),
        1.5,
        dotPaint,
      );
    }

    final pointPaint = Paint()
      ..color = const Color(0xFFD5E1D7).withValues(alpha: 0.8);

    canvas.drawCircle(
      Offset(size.width * 0.42, size.height * 0.55),
      3,
      pointPaint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.72, size.height * 0.78),
      3,
      pointPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
