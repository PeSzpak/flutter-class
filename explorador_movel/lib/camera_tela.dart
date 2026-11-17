import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraTela extends StatefulWidget {
  const CameraTela({super.key});

  @override
  State<CameraTela> createState() => _CameraTelaState();
}

class _CameraTelaState extends State<CameraTela> {
  CameraController? _controller;
  XFile? _foto;
  String? _erro;
  bool _capturando = false;

  @override
  void initState() {
    super.initState();
    _iniciarCamera();
  }

  // 1. Descobrir  2. Inicializar
  Future<void> _iniciarCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _erro = 'Este aparelho não tem câmera disponível.');
        return;
      }
      final traseira = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(traseira, ResolutionPreset.medium, enableAudio: false);
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() => _controller = controller);
    } on CameraException catch (e) {
      setState(() => _erro = switch (e.code) {
            'CameraAccessDenied' || 'CameraAccessDeniedWithoutPrompt' || 'CameraAccessRestricted' =>
              'Permissão da câmera negada. Libere nas configurações do aparelho.',
            _ => 'Não foi possível abrir a câmera. Ela pode estar em uso por outro app.',
          });
    }
  }

  // 4. Capturar
  Future<void> _tirarFoto() async {
    final controller = _controller;
    if (controller == null || _capturando) return;
    setState(() => _capturando = true);
    try {
      final foto = await controller.takePicture();
      if (mounted) setState(() => _foto = foto);
    } on CameraException {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Falha ao capturar a foto. Tente de novo.')));
      }
    } finally {
      if (mounted) setState(() => _capturando = false);
    }
  }

  @override
  void dispose() {
    // Libera a câmera ao sair da tela.
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_erro != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.no_photography_outlined, size: 56),
            const SizedBox(height: 12),
            Text(_erro!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                setState(() => _erro = null);
                _iniciarCamera();
              },
              child: const Text('Tentar de novo'),
            ),
          ]),
        ),
      );
    }

    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // 3. Visualizar
        Expanded(child: Center(child: CameraPreview(controller))),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (_foto != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(File(_foto!.path), width: 72, height: 72, fit: BoxFit.cover),
                ),
              const Spacer(),
              FilledButton.icon(
                onPressed: _capturando ? null : _tirarFoto,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Tirar foto'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
