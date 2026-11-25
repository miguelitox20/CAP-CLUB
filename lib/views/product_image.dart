import 'dart:convert';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/cap_icon.dart';

class ProductImage extends StatelessWidget {
  final String url;
  final double capSize;
  final BoxFit fit;

  const ProductImage({super.key, required this.url, this.capSize = 90, this.fit = BoxFit.cover});

  // Respaldo cuando no hay foto o no carga: gorra dibujada.
  Widget _sinFoto() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2B2B2B), Colors.black],
        ),
      ),
      child: Center(child: CapIcon(size: capSize)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return _sinFoto();

    // Foto elegida desde la galería.
    if (url.startsWith('base64:')) {
      try {
        final bytes = base64Decode(url.substring(7));
        return Image.memory(
          bytes,
          fit: fit,
          gaplessPlayback: true,
          errorBuilder: (context, error, stack) => _sinFoto(),
        );
      } catch (_) {
        return _sinFoto();
      }
    }

    // Foto de la carpeta assets/.
    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        fit: fit,
        errorBuilder: (context, error, stack) => _sinFoto(),
      );
    }

    // Foto desde internet.
    return Image.network(
      url,
      fit: fit,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const Center(
          child: CircularProgressIndicator(color: AppColors.red),
        );
      },
      errorBuilder: (context, error, stack) => _sinFoto(),
    );
  }
}
