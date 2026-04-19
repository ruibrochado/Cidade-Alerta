import 'dart:io';

import 'package:app/pages/detect_location_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../models/report_data.dart';
import '../widgets/primary_button.dart';

class PhotoPage extends StatefulWidget {
  const PhotoPage({super.key, required this.report});

  final ReportData report;

  @override
  State<PhotoPage> createState() => _PhotoPageState();
}

class _PhotoPageState extends State<PhotoPage> {
  final ImagePicker _picker = ImagePicker();

  String? _photo;
  bool _isTakingPhoto = false;

  @override
  void initState() {
    super.initState();
    _photo = widget.report.photos.isNotEmpty ? widget.report.photos.first : null;
  }

  Future<void> _takePhoto() async {
    try {
      setState(() {
        _isTakingPhoto = true;
      });

      final XFile? file = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (file == null) {
        return;
      }

      setState(() {
        _photo = file.path;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível tirar a foto.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isTakingPhoto = false;
        });
      }
    }
  }

  void _continue() {
    final updatedReport = widget.report.copyWith(
      photos: _photo != null ? <String>[_photo!] : <String>[],
    );

    Navigator.pushNamed(
      context,
      '/detect-location',
      arguments: updatedReport,
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
                        backgroundColor: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                  const Positioned(
                    top: 74,
                    left: 24,
                    right: 24,
                    child: Column(
                      children: <Widget>[
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
                      child: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            if (_photo != null)
                              Stack(
                                children: <Widget>[
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: SizedBox(
                                      width: double.infinity,
                                      height: 240,
                                      child: Image.file(
                                        File(_photo!),
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) =>
                                            Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade200,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: const Center(
                                            child: Icon(Icons.image, size: 40),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: InkWell(
                                      onTap: () => setState(() => _photo = null),
                                      child: Container(
                                        width: 30,
                                        height: 30,
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          size: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            if (_photo != null) const SizedBox(height: 16),
                            InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: _isTakingPhoto ? null : _takePhoto,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 48,
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xFFD1D5DB),
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  color: const Color(0xFFF9FAFB),
                                ),
                                child: Column(
                                  children: <Widget>[
                                    const CircleAvatar(
                                      radius: 28,
                                      backgroundColor: Color(0xFFDCFCE7),
                                      child: Icon(
                                        Icons.camera_alt_outlined,
                                        size: 28,
                                        color: Color(0xFF16A34A),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      _isTakingPhoto
                                          ? 'A abrir câmara...'
                                          : _photo == null
                                              ? 'Tirar Foto'
                                              : 'Tirar Nova Foto',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF4B5563),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}