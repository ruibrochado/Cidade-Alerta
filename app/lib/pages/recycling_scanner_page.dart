import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:image_picker/image_picker.dart';

import '../utils/recycling_classifier.dart';
import '../widgets/slide_card.dart';

class RecyclingScannerPage extends StatefulWidget {
  const RecyclingScannerPage({super.key});

  @override
  State<RecyclingScannerPage> createState() => _RecyclingScannerPageState();
}

class _RecyclingScannerPageState extends State<RecyclingScannerPage> {
  final ImagePicker _picker = ImagePicker();

  File? _image;
  bool _isScanning = false;

  String? _identifiedObject;
  double? _confidence;
  String? _recyclingBin;
  String? _validationMessage;

  late final ImageLabeler _labeler;

  @override
  void initState() {
    super.initState();
    _labeler = ImageLabeler(
      options: ImageLabelerOptions(confidenceThreshold: 0.5),
    );
  }

  @override
  void dispose() {
    _labeler.close();
    super.dispose();
  }

  Future<void> _pickAndScanImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);

    if (pickedFile == null) return;

    setState(() {
      _image = File(pickedFile.path);
      _isScanning = true;
      _identifiedObject = null;
      _confidence = null;
      _recyclingBin = null;
      _validationMessage = null;
    });

    try {
      final inputImage = InputImage.fromFilePath(pickedFile.path);
      final labels = await _labeler.processImage(inputImage);

      if (labels.isEmpty) {
        setState(() {
          _identifiedObject = 'Objeto não identificado';
          _recyclingBin = 'Tenta novamente com outra imagem';
          _isScanning = false;
        });
        return;
      }

      labels.sort((a, b) => b.confidence.compareTo(a.confidence));

      final classification = RecyclingClassifier.classify(
        labels.map((label) => label.label).toList(),
      );

      final matchedLabel = labels.firstWhere(
        (label) => label.label.toLowerCase() == classification.objectName,
        orElse: () => labels.first,
      );

      setState(() {
        _identifiedObject = classification.objectName;
        _confidence = matchedLabel.confidence;
        _recyclingBin = classification.recyclingBin;
        _isScanning = false;
      });
    } catch (e) {
      setState(() {
        _identifiedObject = 'Erro ao analisar imagem';
        _recyclingBin = 'Tenta novamente';
        _isScanning = false;
      });
    }
  }

  void _validateResult(bool isCorrect) {
    setState(() {
      _validationMessage = isCorrect
          ? 'Obrigado pelo feedback!'
          : 'Obrigado. Vamos melhorar esta identificação.';
    });
  }

  void _showHowItWorksSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      constraints: const BoxConstraints(
        minWidth: double.infinity,
        maxWidth: double.infinity,
      ),
      builder: (context) {
        return SizedBox(
          width: MediaQuery.of(context).size.width,
          child: SlideCard(
            isActive: false,
            borderRadius: 24,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD0D5DD),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Como funciona?',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.close,
                          color: Color(0xFF98A2B3),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F8F8),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text(
                      'Aponte a câmera para o objeto e capture uma imagem, ou carregue uma fotografia da galeria, para descobrir onde deve ser reciclado.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Color(0xFF475467),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B84A),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Entendido',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color green = Color(0xFF00B84A);
    const Color lightGreen = Color(0xFFCDE5CB);
    const Color darkText = Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 120),
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Escanear Objeto',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: darkText,
                    ),
                  ),
                ),
                SlideCard(
                  isActive: false,
                  onTap: _showHowItWorksSheet,
                  borderRadius: 20,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF3F4F6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.question_mark,
                      size: 20,
                      color: Color(0xFF344054),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 34),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: lightGreen,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Container(
                    height: 300,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: green, width: 3),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _image == null
                        ? const Icon(
                            Icons.camera_alt_outlined,
                            size: 48,
                            color: Color(0xFF98A2B3),
                          )
                        : Image.file(_image!, fit: BoxFit.cover),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _isScanning
                          ? null
                          : () => _pickAndScanImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt_outlined, size: 20),
                      label: Text(_isScanning ? 'A analisar...' : 'Capturar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: green,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _isScanning
                          ? null
                          : () => _pickAndScanImage(ImageSource.gallery),
                      icon: const Icon(Icons.upload, size: 20),
                      label: const Text('Carregar da Galeria'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: darkText,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_isScanning) ...[
              const SizedBox(height: 24),
              const Center(child: CircularProgressIndicator(color: green)),
            ],
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                final offsetAnimation =
                    Tween<Offset>(
                      begin: const Offset(0, 0.12),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(parent: animation, curve: Curves.easeOut),
                    );

                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  ),
                );
              },
              child: _identifiedObject != null && !_isScanning
                  ? Padding(
                      key: ValueKey(_identifiedObject),
                      padding: const EdgeInsets.only(top: 24),
                      child: _buildResultCard(),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    if (_identifiedObject == null) {
      return const SizedBox.shrink();
    }

    final String confidenceText = _confidence == null
        ? 'N/A'
        : '${(_confidence! * 100).toStringAsFixed(0)}%';

    return SlideCard(
      isActive: false,
      borderRadius: 20,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEAEAEA)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resultado da análise',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 16),
            _buildResultItem('Objeto identificado', _identifiedObject!),
            const SizedBox(height: 12),
            _buildResultItem(
              'Ecoponto recomendado',
              _recyclingBin ?? 'Desconhecido',
            ),
            const SizedBox(height: 12),
            _buildResultItem('Confiança', confidenceText),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _validateResult(false),
                    child: const Text('Não está correto'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _validateResult(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00D159),
                      foregroundColor: Colors.white,
                      elevation: 0,
                    ),
                    child: const Text('Está correto'),
                  ),
                ),
              ],
            ),
            if (_validationMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _validationMessage!,
                style: const TextStyle(fontSize: 13, color: Color(0xFF667085)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Color(0xFF667085)),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            height: 1.45,
            fontWeight: FontWeight.w600,
            color: Color(0xFF475467),
          ),
        ),
      ],
    );
  }
}
