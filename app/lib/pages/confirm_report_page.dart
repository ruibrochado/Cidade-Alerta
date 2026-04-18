import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';

import '../models/report_data.dart';
import '../services/issue_service.dart';
import '../widgets/primary_button.dart';

class ConfirmPage extends StatefulWidget {
  const ConfirmPage({super.key, required this.report});

  final ReportData report;

  @override
  State<ConfirmPage> createState() => _ConfirmPageState();
}

class _ConfirmPageState extends State<ConfirmPage> {
  bool _sending = false;
  bool _sent = false;

  String? _street;
  String? _city;
  String? _country;
  String _locationError = '';

  String? _ticketNumber;

  @override
  void initState() {
    super.initState();
    _loadAddress();
  }

  Future<void> _loadAddress() async {
    final double? latitude = widget.report.latitude;
    final double? longitude = widget.report.longitude;

    if (latitude == null || longitude == null) {
      setState(() {
        _locationError = 'Localização indisponível.';
      });
      return;
    }

    try {
      final List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      final Placemark? place = placemarks.isNotEmpty ? placemarks.first : null;

      final String street = <String?>[
        place?.street,
        place?.subThoroughfare,
      ]
          .where((String? value) => value != null && value.trim().isNotEmpty)
          .cast<String>()
          .join(', ');

      final List<String> cityCandidates = <String?>[
        place?.locality,
        place?.subAdministrativeArea,
        place?.administrativeArea,
      ]
          .where((String? value) => value != null && value.trim().isNotEmpty)
          .cast<String>()
          .toList();

      if (!mounted) return;

      setState(() {
        _street = street.isEmpty ? null : street;
        _city = cityCandidates.isEmpty ? null : cityCandidates.first;
        _country = place?.country;
        _locationError = '';
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _street = null;
        _city = null;
        _country = null;
        _locationError = 'Não foi possível obter a morada.';
      });
    }
  }

  // --- AQUI ESTÁ A MUDANÇA PRINCIPAL ---
  Future<void> _handleSend() async {
    if (_sending) return;

    setState(() {
      _sending = true;
    });

    try {
      final issueService = IssueService();

      // Juntamos a rua e cidade para enviar como uma string única de morada
      String? finalAddress;
      if (_street != null) {
        finalAddress = _city != null ? '$_street, $_city' : _street;
      }

      final String ticketNumber = await issueService.createIssue(
        title: widget.report.title,
        description: widget.report.description,
        category: widget.report.category,
        latitude: widget.report.latitude!,
        longitude: widget.report.longitude!,
        street: finalAddress, // AGORA PASSAMOS A RUA AQUI
        photoPath: widget.report.photos.isNotEmpty ? widget.report.photos.first : null,
      );

      if (!mounted) return;

      setState(() {
        _sending = false;
        _sent = true;
        _ticketNumber = ticketNumber;
      });

      await Future<void>.delayed(const Duration(seconds: 3));
      if (!mounted) return;

      Navigator.of(context).pushNamedAndRemoveUntil(
        '/home',
            (Route<dynamic> route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _sending = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao guardar denúncia: $e')),
      );
    }
  }

  Widget _buildSectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color headerGreen = Color(0xFFCDE5CB);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: headerGreen,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: headerGreen,
        body: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Container(
                  height: 300,
                  width: double.infinity,
                  color: headerGreen,
                ),
                Expanded(
                  child: Container(
                    color: const Color(0xFFF8F8F8),
                  ),
                ),
              ],
            ),
            SafeArea(
              child: Stack(
                children: <Widget>[
                  Positioned(
                    top: 16,
                    left: 16,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withAlpha(217),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 74,
                    left: 24,
                    right: 24,
                    child: Column(
                      children: <Widget>[
                        Text(
                          _sent ? 'Sucesso!' : 'Confirmar Denúncia',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _sent
                              ? 'Denúncia enviada com sucesso'
                              : 'Confirme os dados antes de enviar',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF4B5563),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 175,
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: const <BoxShadow>[
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 24,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: _sent ? _buildSuccessView() : _buildConfirmView(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      children: <Widget>[
        const SizedBox(height: 8),
        const CircleAvatar(
          radius: 48,
          backgroundColor: Color(0xFFDCFCE7),
          child: Icon(Icons.check_circle, size: 56, color: Color(0xFF16A34A)),
        ),
        const SizedBox(height: 24),
        const Text(
          'Denúncia Enviada!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
        ),
        const SizedBox(height: 8),
        const Text(
          'Sua denúncia foi registrada e será analisada em breve.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF4B5563)),
        ),
        const SizedBox(height: 20),
        _buildSectionCard(
          child: Column(
            children: <Widget>[
              const Text('Ticket Number', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
              const SizedBox(height: 6),
              Text(
                _ticketNumber ?? '-',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1F2937)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmView() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildSectionCard(
                    child: Row(
                      children: [
                        const Icon(Icons.description_outlined, color: Color(0xFF4B5563)),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Categoria', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                            Text(widget.report.category, style: const TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Título', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                        Text(widget.report.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 12),
                        const Text('Descrição', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                        Text(widget.report.description),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, color: Color(0xFF4B5563)),
                            const SizedBox(width: 12),
                            const Text('Localização', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (_street != null) Text(_street!, style: const TextStyle(fontWeight: FontWeight.w500)),
                        if (_city != null) Text(_city!),
                        if (_locationError.isNotEmpty) Text(_locationError, style: const TextStyle(color: Colors.red, fontSize: 12)),
                      ],
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: _sending ? 'Enviando...' : 'Enviar Denúncia',
                    loading: _sending,
                    onPressed: _handleSend,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}