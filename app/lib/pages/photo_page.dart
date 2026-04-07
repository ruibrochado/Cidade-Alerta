import 'dart:io';

import 'package:app/pages/detect_location_page.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/report_data.dart';
import '../widgets/app_scaffold.dart';
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
      if (!mounted) return;

      setState(() {
        _isTakingPhoto = false;
      });
    }
  }

  void _continue() {
    if (_photo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tire uma foto antes de continuar.'),
        ),
      );
      return;
    }

    final updatedReport = widget.report.copyWith(
      photos: <String>[_photo!],
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetectLocationPage(report: updatedReport),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Adicionar Foto',
      subtitle: 'Tire uma foto do problema',
      showBackButton: true,
      child: Column(
        children: <Widget>[
          if (_photo != null)
            Stack(
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 240,
                    child: Image.file(
                      File(_photo!),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Icon(Icons.image, size: 40),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: InkWell(
                    onTap: () => setState(() => _photo = null),
                    child: Container(
                      width: 28,
                      height: 28,
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
            borderRadius: BorderRadius.circular(16),
            onTap: _isTakingPhoto ? null : _takePhoto,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300, width: 2),
                borderRadius: BorderRadius.circular(16),
                color: const Color(0xFFFDFDFD),
              ),
              child: Column(
                children: <Widget>[
                  const CircleAvatar(
                    radius: 32,
                    backgroundColor: Color(0xFFDCFCE7),
                    child: Icon(
                      Icons.camera_alt_outlined,
                      size: 32,
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
                    style: const TextStyle(color: Color(0xFF4B5563)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Continuar',
            onPressed: _continue,
          ),
        ],
      ),
    );
  }
}