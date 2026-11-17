import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'permissoes.dart';
import 'velocidade.dart';

class VelocidadeTela extends StatefulWidget {
  const VelocidadeTela({super.key});

  @override
  State<VelocidadeTela> createState() => _VelocidadeTelaState();
}

class _VelocidadeTelaState extends State<VelocidadeTela> {
  final _calculadora = CalculadoraVelocidade();
  StreamSubscription<Position>? _assinatura;
  double _kmh = 0;
  String _mensagem = 'Toque em Iniciar e comece a se mover.';

  bool get _monitorando => _assinatura != null;

  Future<void> _iniciar() async {
    try {
      await garantirLocalizacao();
    } on ErroRecurso catch (e) {
      setState(() => _mensagem = e.mensagem);
      return;
    }

    _calculadora.zerar();
    setState(() {
      _kmh = 0;
      _mensagem = 'Aguardando a primeira leitura do GPS...';
      _assinatura = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          distanceFilter: 3,
        ),
      ).listen(_aoReceber, onError: (_) {
        _parar();
        if (mounted) setState(() => _mensagem = 'O GPS parou de responder. Tente de novo.');
      });
    });
  }

  void _aoReceber(Position atual) {
    final kmh = _calculadora.adicionar(Leitura(
      latitude: atual.latitude,
      longitude: atual.longitude,
      precisao: atual.accuracy,
      horario: atual.timestamp,
    ));
    if (!mounted) return;
    setState(() {
      if (kmh != null) {
        _kmh = kmh;
        _mensagem = 'Monitorando.';
      } else if (atual.accuracy > _calculadora.precisaoMaxima) {
        _mensagem = 'Sinal fraco (precisão de ${atual.accuracy.toStringAsFixed(0)} m). Leitura ignorada.';
      }
    });
  }

  void _parar() {
    _assinatura?.cancel();
    setState(() {
      _assinatura = null;
      _mensagem = 'Monitoramento parado.';
    });
  }

  @override
  void dispose() {
    // Encerra o stream do GPS ao sair da tela.
    _assinatura?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_kmh.toStringAsFixed(1), style: tema.displayLarge),
            Text('km/h', style: tema.titleMedium),
            const SizedBox(height: 8),
            Text('Distância: ${(_calculadora.distanciaTotal / 1000).toStringAsFixed(2)} km'),
            const SizedBox(height: 16),
            Text(_mensagem, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            _monitorando
                ? OutlinedButton.icon(onPressed: _parar, icon: const Icon(Icons.stop), label: const Text('Parar'))
                : FilledButton.icon(onPressed: _iniciar, icon: const Icon(Icons.play_arrow), label: const Text('Iniciar')),
          ],
        ),
      ),
    );
  }
}
