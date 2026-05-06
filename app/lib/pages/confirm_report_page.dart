import 'dart:async';
import 'dart:io';
//import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';

import '../models/report_data.dart';
import '../services/issue_service.dart';
import '../widgets/primary_button.dart';
import '../utils/location_formatter.dart';

class ConfirmPage extends StatefulWidget {
  const ConfirmPage({super.key, required this.report});

  final ReportData report;

  @override
  State<ConfirmPage> createState() => _ConfirmPageState();
}

class _ConfirmPageState extends State<ConfirmPage> {
  bool _sending = false;
  bool _sent = false;

  String? _address;
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
    if (widget.report.address != null ||
        widget.report.city != null ||
        widget.report.country != null) {
      setState(() {
        _address = widget.report.address;
        _city = widget.report.city;
        _country = widget.report.country;
        _locationError = '';
      });
      return;
    }

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

      final String? address = buildAddressFromPlacemark(place);
      final String? city = buildCityFromPlacemark(place);
      final String? country = buildCityFromPlacemark(place);

      if (!mounted) return;

      setState(() {
        _address = address;
        _city = city;
        _country = country;
        _locationError = '';
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _address = null;
        _city = null;
        _country = null;
        _locationError = 'Não foi possível obter a morada.';
      });
    }
  }

  /*
  String _generateTicketNumber() {
    final DateTime now = DateTime.now();
    final Random random = Random();

    final String year = now.year.toString();
    final String month = now.month.toString().padLeft(2, '0');
    final String day = now.day.toString().padLeft(2, '0');
    final String hour = now.hour.toString().padLeft(2, '0');
    final String minute = now.minute.toString().padLeft(2, '0');
    final String randomPart =
        random.nextInt(9000 + 1).toString().padLeft(4, '0');

    return 'TKT-$year$month$day-$hour$minute-$randomPart';
  }

   */

  Future<void> _handleSend() async {
    if (_sending) return;

    setState(() {
      _sending = true;
    });

    try {
      final issueService = IssueService();

      // Criamos a morada para a DB
      String? moradaFinal = _address;
      if (_city != null && _address != null) {
        moradaFinal = '$_address, $_city';
      }

      // Tenta criar a issue
      final String ticketNumber = await issueService.createIssue(
        title: widget.report.title,
        description: widget.report.description,
        category: widget.report.category,
        latitude: widget.report.latitude!,
        longitude: widget.report.longitude!,
        street: moradaFinal,
        photoPath: widget.report.photos.isNotEmpty
            ? widget.report.photos.first
            : null,
      );

      if (!mounted) return;

      setState(() {
        _sending = false;
        _sent = true;
        _ticketNumber = ticketNumber;
      });

      // SÓ SAI DAQUI SE TUDO DER CERTO
      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return;

      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    } catch (e) {
      // FIX CRÍTICO: Se der erro, apenas paramos o loading.
      // NÃO há comandos de Navigator aqui, logo a página NÃO VOLTA À HOME.
      if (!mounted) return;

      setState(() {
        _sending = false;
      });

      // Mostra o erro num popup para tu leres o que o Supabase rejeitou
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Erro Detectado"),
          content: Text("Erro ao guardar denúncia: $e"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("OK"),
            ),
          ],
        ),
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

    return PopScope(
      canPop: false, // Bloqueia o comportamento automático de voltar atrás
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        // Se a página já fechou, não fazemos nada
        if (didPop) return;

        // Se já enviou com sucesso, NÃO deixa voltar
        if (_sent) return;

        // Se está a enviar, também não deixa voltar
        if (_sending) return;

        // Se ainda não enviou, pergunta se quer cancelar
        final bool? confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Cancelar Denúncia'),
            content: const Text(
              'Tem certeza que quer cancelar? Os dados serão perdidos.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Não'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Sim, cancelar'),
              ),
            ],
          ),
        );

        // Se o utilizador disser que "Sim, cancelar", forçamos a saída da página
        if (confirm == true && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
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
                  Expanded(child: Container(color: const Color(0xFFF8F8F8))),
                ],
              ),
              SafeArea(
                child: Stack(
                  children: <Widget>[
                    // SETINHA REMOVIDA - Completamente removida da tela
                    // Positioned(
                    //   top: 16,
                    //   left: 16,
                    //   child: IconButton(
                    //     onPressed: () => Navigator.of(context).maybePop(),
                    //     icon: const Icon(Icons.arrow_back),
                    //     style: IconButton.styleFrom(
                    //       backgroundColor: Colors.white.withValues(alpha: 0.85),
                    //     ),
                    //   ),
                    // ),
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
                        child: _sent
                            ? Column(
                                children: <Widget>[
                                  const SizedBox(height: 8),
                                  const CircleAvatar(
                                    radius: 48,
                                    backgroundColor: Color(0xFFDCFCE7),
                                    child: Icon(
                                      Icons.check_circle,
                                      size: 56,
                                      color: Color(0xFF16A34A),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  const Text(
                                    'Denúncia Enviada!',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1F2937),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Sua denúncia foi registrada e será analisada em breve.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Color(0xFF4B5563)),
                                  ),
                                  const SizedBox(height: 20),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF3F4F6),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      children: <Widget>[
                                        const Text(
                                          'Ticket Number',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF6B7280),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          _ticketNumber ?? '-',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF1F2937),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : LayoutBuilder(
                                builder: (BuildContext context, BoxConstraints constraints) {
                                  return SingleChildScrollView(
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        minHeight: constraints.maxHeight,
                                      ),
                                      child: IntrinsicHeight(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            _buildSectionCard(
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  const Padding(
                                                    padding: EdgeInsets.only(
                                                      top: 2,
                                                    ),
                                                    child: Icon(
                                                      Icons
                                                          .description_outlined,
                                                      color: Color(0xFF4B5563),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: <Widget>[
                                                        const Text(
                                                          'Categoria',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: Color(
                                                              0xFF6B7280,
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 4,
                                                        ),
                                                        Text(
                                                          widget
                                                              .report
                                                              .category,
                                                          style:
                                                              const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: Color(
                                                                  0xFF1F2937,
                                                                ),
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            _buildSectionCard(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  const Text(
                                                    'Título',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Color(0xFF6B7280),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    widget.report.title,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Color(0xFF1F2937),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 12),
                                                  const Text(
                                                    'Descrição',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Color(0xFF6B7280),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    widget.report.description,
                                                    style: const TextStyle(
                                                      color: Color(0xFF374151),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (widget
                                                .report
                                                .photos
                                                .isNotEmpty) ...<Widget>[
                                              const SizedBox(height: 12),
                                              _buildSectionCard(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Row(
                                                      children: <Widget>[
                                                        const Icon(
                                                          Icons
                                                              .camera_alt_outlined,
                                                          color: Color(
                                                            0xFF4B5563,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        Text(
                                                          '${widget.report.photos.length} foto(s) anexada(s)',
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 12,
                                                                color: Color(
                                                                  0xFF6B7280,
                                                                ),
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 12),
                                                    SingleChildScrollView(
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      child: Row(
                                                        children: widget.report.photos.map((
                                                          String photo,
                                                        ) {
                                                          return Padding(
                                                            padding:
                                                                const EdgeInsets.only(
                                                                  right: 8,
                                                                ),
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    12,
                                                                  ),
                                                              child: Image.file(
                                                                File(photo),
                                                                width: 64,
                                                                height: 64,
                                                                fit: BoxFit
                                                                    .cover,
                                                                errorBuilder:
                                                                    (
                                                                      context,
                                                                      error,
                                                                      stackTrace,
                                                                    ) => Container(
                                                                      width: 64,
                                                                      height:
                                                                          64,
                                                                      color: Colors
                                                                          .grey
                                                                          .shade200,
                                                                      child: const Icon(
                                                                        Icons
                                                                            .image,
                                                                      ),
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
                                            _buildSectionCard(
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  const Padding(
                                                    padding: EdgeInsets.only(
                                                      top: 2,
                                                    ),
                                                    child: Icon(
                                                      Icons
                                                          .location_on_outlined,
                                                      color: Color(0xFF4B5563),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: <Widget>[
                                                        const Text(
                                                          'Localização',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: Color(
                                                              0xFF6B7280,
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 4,
                                                        ),
                                                        if (_address != null &&
                                                            _address!
                                                                .isNotEmpty) ...<
                                                          Widget
                                                        >[
                                                          Text(
                                                            _address!,
                                                            style:
                                                                const TextStyle(
                                                                  color: Color(
                                                                    0xFF1F2937,
                                                                  ),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                          ),
                                                        ],
                                                        if (_city != null &&
                                                            _city!
                                                                .isNotEmpty) ...<
                                                          Widget
                                                        >[
                                                          const SizedBox(
                                                            height: 4,
                                                          ),
                                                          Text(
                                                            _city!,
                                                            style:
                                                                const TextStyle(
                                                                  color: Color(
                                                                    0xFF374151,
                                                                  ),
                                                                ),
                                                          ),
                                                        ],
                                                        if (_country != null &&
                                                            _country!
                                                                .isNotEmpty) ...<
                                                          Widget
                                                        >[
                                                          const SizedBox(
                                                            height: 4,
                                                          ),
                                                          Text(
                                                            _country!,
                                                            style:
                                                                const TextStyle(
                                                                  color: Color(
                                                                    0xFF374151,
                                                                  ),
                                                                ),
                                                          ),
                                                        ],
                                                        if (_locationError
                                                            .isNotEmpty) ...<
                                                          Widget
                                                        >[
                                                          const SizedBox(
                                                            height: 4,
                                                          ),
                                                          Text(
                                                            _locationError,
                                                            style:
                                                                const TextStyle(
                                                                  color: Colors
                                                                      .red,
                                                                  fontSize: 12,
                                                                ),
                                                          ),
                                                        ],
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const Spacer(),
                                            const SizedBox(height: 24),
                                            SizedBox(
                                              width: double.infinity,
                                              child: PrimaryButton(
                                                label: _sending
                                                    ? 'Enviando...'
                                                    : 'Enviar Denúncia',
                                                loading: _sending,
                                                onPressed: _handleSend,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
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
  }
}
