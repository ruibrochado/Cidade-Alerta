import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import '../models/report_data.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/info_card.dart';
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

  Future<void> _handleSend() async {
    setState(() {
      _sending = true;
    });

    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) {
      return;
    }

    setState(() {
      _sending = false;
      _sent = true;
    });

    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) {
      return;
    }

    Navigator.of(context).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    if (_sent) {
      return AppScaffold(
        title: 'Sucesso!',
        subtitle: 'Denúncia enviada com sucesso',
        child: const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Column(
              children: <Widget>[
                CircleAvatar(
                  radius: 48,
                  backgroundColor: Color(0xFFDCFCE7),
                  child: Icon(Icons.check_circle, size: 56, color: Color(0xFF16A34A)),
                ),
                SizedBox(height: 24),
                Text(
                  'Denúncia Enviada!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                ),
                SizedBox(height: 8),
                Text(
                  'Sua denúncia foi registrada e será analisada em breve.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF4B5563)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return AppScaffold(
      title: 'Confirmar Denúncia',
      subtitle: 'Confirme os dados antes de enviar',
      showBackButton: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          InfoCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(Icons.description_outlined, color: Color(0xFF4B5563)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text('Categoria', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                      const SizedBox(height: 4),
                      Text(widget.report.category, style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('Título', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                const SizedBox(height: 4),
                Text(widget.report.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                const Text('Descrição', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                const SizedBox(height: 4),
                Text(widget.report.description, style: const TextStyle(color: Color(0xFF374151))),
              ],
            ),
          ),
          if (widget.report.photos.isNotEmpty) ...<Widget>[
            const SizedBox(height: 12),
            InfoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const Icon(Icons.camera_alt_outlined, color: Color(0xFF4B5563)),
                      const SizedBox(width: 8),
                      Text('${widget.report.photos.length} foto(s) anexada(s)', style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: widget.report.photos.map((String photo) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(photo),
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 64,
                                height: 64,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.image),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          InfoCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(Icons.location_on_outlined, color: Color(0xFF4B5563)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text('Localização', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.report.latitude?.toStringAsFixed(6) ?? '-'}, ${widget.report.longitude?.toStringAsFixed(6) ?? '-'}',
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: _sending ? 'Enviando...' : 'Enviar Denúncia',
            loading: _sending,
            onPressed: _handleSend,
          ),
        ],
      ),
    );
  }
}