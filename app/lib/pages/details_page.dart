import 'package:flutter/material.dart';
import '../models/report_data.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/primary_button.dart';
import 'package:app/pages/photo_page.dart';

class DetailsPage extends StatefulWidget {
  const DetailsPage({super.key, required this.category});

  final String category;

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool canContinue = _titleController.text.trim().isNotEmpty && _descriptionController.text.trim().isNotEmpty;

    return AppScaffold(
      title: 'Descrever Problema',
      subtitle: 'Forneça detalhes sobre a denúncia',
      showBackButton: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('Categoria', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF374151))),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: widget.category,
            enabled: false,
            decoration: InputDecoration(
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              filled: true,
              fillColor: const Color(0xFFF3F4F6),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Título', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF374151))),
          const SizedBox(height: 8),
          TextField(
            controller: _titleController,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(hintText: 'Ex: Buraco na rua...'),
          ),
          const SizedBox(height: 16),
          const Text('Descrição', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF374151))),
          const SizedBox(height: 8),
          TextField(
            controller: _descriptionController,
            onChanged: (_) => setState(() {}),
            minLines: 6,
            maxLines: 6,
            decoration: const InputDecoration(hintText: 'Descreva o problema em detalhes...'),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Continuar',
            enabled: canContinue,
            onPressed: () {
              final ReportData report = ReportData(
                category: widget.category,
                title: _titleController.text.trim(),
                description: _descriptionController.text.trim(),
              );

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PhotoPage(report: report),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}