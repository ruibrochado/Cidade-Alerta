import 'package:flutter/material.dart';
import '../models/ecocenter_data.dart';
import '../widgets/slide_card.dart';

class EcocenterDetailPage extends StatelessWidget {
  final EcocenterData ecocenter;

  const EcocenterDetailPage({super.key, required this.ecocenter});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTopBar(context),
        const Divider(height: 1, color: Color(0xFFE5E7EB)),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            children: [
              _buildEcocenterImage(),
              const SizedBox(height: 18),
              _buildMainInfoCard(),
              const SizedBox(height: 18),
              _buildContactInfoCard(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 10, 10),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Detalhes do Ecocentro',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Color(0xFF6B7280), size: 26),
          ),
        ],
      ),
    );
  }

  Widget _buildEcocenterImage() {
    return SlideCard(
      isActive: false,
      borderRadius: 20,
      child: Container(
        height: 185,
        decoration: BoxDecoration(
          color: const Color(0xFF16A34A).withValues(alpha: 0.1),
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
        child: const Center(
          child: Icon(
            Icons.recycling_rounded,
            size: 64,
            color: Color(0xFF16A34A),
          ),
        ),
      ),
    );
  }

  Widget _buildMainInfoCard() {
    return SlideCard(
      isActive: false,
      borderRadius: 20,
      child: Container(
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
            _buildTitleAndEntity(),
            if (ecocenter.address != null || ecocenter.city != null) ...[
              const SizedBox(height: 12),
              _buildLocation(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfoCard() {
    return SlideCard(
      isActive: false,
      borderRadius: 20,
      child: Container(
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
              'Informações de Contacto',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 14),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            const SizedBox(height: 16),
            if (ecocenter.schedule != null)
              _buildInfoRow(
                Icons.access_time_outlined,
                'Horário',
                ecocenter.schedule!,
              ),
            if (ecocenter.phone != null)
              _buildInfoRow(Icons.phone_outlined, 'Telefone', ecocenter.phone!),
            if (ecocenter.email != null)
              _buildInfoRow(Icons.email_outlined, 'E-mail', ecocenter.email!),
            if (ecocenter.website != null)
              _buildInfoRow(
                Icons.language_outlined,
                'Website',
                ecocenter.website!,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleAndEntity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ecocenter.name,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2937),
          ),
        ),
        if (ecocenter.entity != null) ...[
          const SizedBox(height: 4),
          Text(
            ecocenter.entity!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF16A34A),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLocation() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.location_on_outlined,
          size: 20,
          color: Color(0xFF6B7280),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '${ecocenter.address ?? ''}${ecocenter.address != null && ecocenter.city != null ? ', ' : ''}${ecocenter.city ?? ''}',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF4B5563),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, size: 20, color: const Color(0xFF6B7280)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1F2937),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
