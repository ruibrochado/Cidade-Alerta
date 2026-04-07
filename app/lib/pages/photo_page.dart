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
  late List<String> _photos;

  @override
  void initState() {
    super.initState();
    _photos = List<String>.from(widget.report.photos);
  }

  Future<void> _pickPhotos() async {
    final List<XFile> files = await _picker.pickMultiImage(imageQuality: 85);
    if (files.isEmpty) {
      return;
    }

    setState(() {
      _photos.addAll(files.map((XFile file) => file.path));
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Adicionar Fotos',
      subtitle: 'Tire fotos do problema',
      showBackButton: true,
      child: Column(
        children: <Widget>[
          if (_photos.isNotEmpty)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _photos.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemBuilder: (BuildContext context, int index) {
                final String photo = _photos[index];
                return Stack(
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        File(photo),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
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
                    Positioned(
                      top: 8,
                      right: 8,
                      child: InkWell(
                        onTap: () => setState(() => _photos.removeAt(index)),
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
                );
              },
            ),
          if (_photos.isNotEmpty) const SizedBox(height: 16),
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: _pickPhotos,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300, width: 2),
                borderRadius: BorderRadius.circular(16),
                color: const Color(0xFFFDFDFD),
              ),
              child: const Column(
                children: <Widget>[
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Color(0xFFDCFCE7),
                    child: Icon(
                      Icons.camera_alt_outlined,
                      size: 32,
                      color: Color(0xFF16A34A),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Tirar Foto',
                    style: TextStyle(color: Color(0xFF4B5563)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Continuar',
            onPressed: () {
              final updatedReport = widget.report.copyWith(photos: _photos);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetectLocationPage(report: updatedReport),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}