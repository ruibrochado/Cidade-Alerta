import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../models/report_data.dart';
import '../widgets/custom_alert_card.dart';
import '../widgets/primary_button.dart';

class PhotoPage extends StatefulWidget {
  const PhotoPage({super.key, required this.report});

  final ReportData report;

  @override
  State<PhotoPage> createState() => _PhotoPageState();
}

enum PhotoState { idle, taking, processing }

class _PhotoPageState extends State<PhotoPage> {
  final ImagePicker _picker = ImagePicker();
  bool showErrorAlert = false;
  String? _photo;
  PhotoState _state = PhotoState.idle;

  @override
  void initState() {
    super.initState();
    _recoverLostData();

    _photo = widget.report.photos.isNotEmpty
        ? widget.report.photos.first
        : null;
  }

  /// Recovers the photo if the app was killed while opening the camera.
  Future<void> _recoverLostData() async {
    final response = await _picker.retrieveLostData();

    if (response.isEmpty) return;

    final XFile? file = response.file;

    if (file != null && mounted) {
      setState(() {
        _photo = file.path;
      });
    }
  }

  /// Takes a photo using the device camera.
  Future<void> _takePhoto() async {
    if (_state != PhotoState.idle) return;

    setState(() {
      _state = PhotoState.taking;
    });

    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 75,
        maxWidth: 1600,
        maxHeight: 1600,
      );

      if (!mounted) return;

      if (file == null) {
        setState(() => _state = PhotoState.idle);
        return;
      }

      setState(() {
        _photo = file.path;
        _state = PhotoState.idle;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao tirar foto. Tenta novamente.'),
          backgroundColor: Colors.red,
        ),
      );

      setState(() {
        _state = PhotoState.idle;
      });
    }
  }

  /// Continues to the next report step.
  void _continue() {
    if (_photo == null) {
      setState(() {
        showErrorAlert = true;
      });
      return;
    }

    final updatedReport = widget.report.copyWith(photos: <String>[_photo!]);

    Navigator.pushNamed(context, '/detect-location', arguments: updatedReport);
  }

  @override
  Widget build(BuildContext context) {
    const Color headerGreen = Color(0xFFCDE5CB);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: headerGreen,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: headerGreen,
        body: Stack(
          children: [
            Column(
              children: [
                Container(height: 300, color: headerGreen),
                Expanded(child: Container(color: const Color(0xFFF8F8F8))),
              ],
            ),

            SafeArea(
              child: Stack(
                children: [
                  // Back button
                  Positioned(
                    top: 16,
                    left: 16,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ),

                  // Page title
                  const Positioned(
                    top: 74,
                    left: 24,
                    right: 24,
                    child: Column(
                      children: [
                        Text(
                          'Adicionar Foto',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tire uma foto do problema',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF4B5563),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Main card
                  Positioned(
                    top: 175,
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 24,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  // Photo preview
                                  if (_photo != null)
                                    Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          child: Image.file(
                                            File(_photo!),
                                            width: double.infinity,
                                            height: 220,
                                            fit: BoxFit.cover,
                                          ),
                                        ),

                                        Positioned(
                                          top: 10,
                                          right: 10,
                                          child: IconButton(
                                            onPressed: () {
                                              setState(() => _photo = null);
                                            },
                                            icon: const Icon(Icons.close),
                                            color: Colors.white,
                                            style: IconButton.styleFrom(
                                              backgroundColor: Colors.red,
                                            ),
                                          ),
                                        ),

                                        if (_state == PhotoState.processing)
                                          const Positioned.fill(
                                            child: ColoredBox(
                                              color: Colors.black26,
                                              child: Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),

                                  const SizedBox(height: 16),

                                  // Camera button
                                  InkWell(
                                    onTap: _state == PhotoState.idle
                                        ? _takePhoto
                                        : null,
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 32,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: const Color(0xFFD1D5DB),
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        color: const Color(0xFFF9FAFB),
                                      ),
                                      child: Column(
                                        children: [
                                          const Icon(
                                            Icons.camera_alt_outlined,
                                            size: 28,
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            _state == PhotoState.taking
                                                ? 'A abrir câmara...'
                                                : _state ==
                                                      PhotoState.processing
                                                ? 'A processar...'
                                                : _photo == null
                                                ? 'Tirar Foto'
                                                : 'Tirar Nova Foto',
                                            style: const TextStyle(
                                              color: Color(0xFF4B5563),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Continue button
                          SizedBox(
                            width: double.infinity,
                            child: PrimaryButton(
                              label: 'Continuar',
                              onPressed: _continue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (showErrorAlert)
              CustomAlertCard(
                icon: Icons.camera_enhance_outlined,
                iconColor: Colors.red,
                title: "Falta a fotografia",
                message:
                    "Para prosseguires com o reporte, precisas de tirar uma foto do problema.",
                primaryButtonText: "Entendido",
                onPrimaryPressed: () {
                  setState(() => showErrorAlert = false);
                },
              ),
          ],
        ),
      ),
    );
  }
}
