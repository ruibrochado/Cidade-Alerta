import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

class RecyclingScannerPage extends StatefulWidget {
  const RecyclingScannerPage({super.key});

  @override
  State<RecyclingScannerPage> createState() => _RecyclingScannerPageState();
}

class _RecyclingScannerPageState extends State<RecyclingScannerPage> {
  final ImagePicker _picker = ImagePicker();
  File? _image;
  String _result = 'No scan yet';

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

  Future<void> _scanObject() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile == null) return;

    setState(() {
      _image = File(pickedFile.path);
      _result = 'Processing...';
    });

    try {
      final inputImage = InputImage.fromFilePath(pickedFile.path);
      final labels = await _labeler.processImage(inputImage);

      final text = labels.map((label) => label.label.toLowerCase()).join(' ');
      final recyclingBin = _inferRecyclingBin(text);

      setState(() {
        _result = recyclingBin;
      });
    } catch (e) {
      setState(() {
        _result = 'Error scanning object: $e';
      });
    }
  }

  String _inferRecyclingBin(String text) {
    if (text.contains('glass')) {
      return 'Green bin (glass)';
    }

    if (text.contains('paper') || text.contains('cardboard')) {
      return 'Blue bin (paper/cardboard)';
    }

    if (text.contains('plastic') ||
        text.contains('bottle') ||
        text.contains('can') ||
        text.contains('metal')) {
      return 'Yellow bin (plastic/metal)';
    }

    return 'Unknown item';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recycling Scanner'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _scanObject,
              child: const Text('Scan object'),
            ),
            const SizedBox(height: 20),
            if (_image != null) Image.file(_image!, height: 220),
            const SizedBox(height: 20),
            Text(
              _result,
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}