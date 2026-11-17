import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'permissoes.dart';

class LocalizacaoTela extends StatefulWidget {
  const LocalizacaoTela({super.key});

  @override
  State<LocalizacaoTela> createState() => _LocalizacaoTelaState();
}

class _LocalizacaoTelaState extends State<LocalizacaoTela> {
  Position? _posicao;
  String _mensagem = 'Toque no botão para obter a localização.';
  bool _carregando = false;

  Future<void> _obterLocalizacao() async {
    setState(() {
      _carregando = true;
      _mensagem = 'Obtendo localização...';
    });

    try {
      await garantirLocalizacao();
      final resultado = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
      if (!mounted) return;
      setState(() {
        _posicao = resultado;
        _mensagem = 'Localização obtida com sucesso!';
      });
    } on ErroRecurso catch (e) {
      if (mounted) setState(() => _mensagem = e.mensagem);
    } catch (_) {
      if (mounted) {
        setState(() => _mensagem = 'Não foi possível obter a posição. O sinal do GPS pode estar fraco; tente ao ar livre.');
      }
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = _posicao;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(_mensagem, textAlign: TextAlign.center),
              if (p != null) ...[
                const SizedBox(height: 12),
                Text('Latitude: ${p.latitude.toStringAsFixed(6)}'),
                Text('Longitude: ${p.longitude.toStringAsFixed(6)}'),
                Text('Precisão: ${p.accuracy.toStringAsFixed(1)} m'),
              ],
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _carregando ? null : _obterLocalizacao,
                icon: const Icon(Icons.my_location),
                label: const Text('Obter localização'),
              ),
            ],
          ),
        ),
        Expanded(
          child: p == null
              ? const Center(child: Text('O mapa aparecerá aqui.'))
              : GoogleMap(
                  key: ValueKey('${p.latitude},${p.longitude}'),
                  initialCameraPosition: CameraPosition(target: LatLng(p.latitude, p.longitude), zoom: 16),
                  markers: {
                    Marker(
                      markerId: const MarkerId('minha_posicao'),
                      position: LatLng(p.latitude, p.longitude),
                      infoWindow: const InfoWindow(title: 'Minha posição atual'),
                    ),
                  },
                  myLocationButtonEnabled: false,
                ),
        ),
      ],
    );
  }
}
