class AuthorityTarget {
  final String entityName;
  final String contactEmail;
  final bool requiresInfrastructureInspection;

  const AuthorityTarget({
    required this.entityName,
    required this.contactEmail,
    required this.requiresInfrastructureInspection,
  });
}

class CategoryMapper {
  static AuthorityTarget getAuthorityForCategory(String categoryName) {
    switch (categoryName) {
      case 'Infraestrutura':
      case 'Sinalização':
        return const AuthorityTarget(
          entityName: 'Infraestruturas de Portugal',
          contactEmail: 'reclamacoes@infraestruturasdeportugal.pt',
          requiresInfrastructureInspection: true,
        );
      case 'Iluminação Pública':
        return const AuthorityTarget(
          entityName: 'E-Redes',
          contactEmail: 'apoiocliente@e-redes.pt',
          requiresInfrastructureInspection: true,
        );
      case 'Lixo e Limpeza':
      case 'Meio Ambiente':
        return const AuthorityTarget(
          entityName: 'Serviços Municipalizados',
          contactEmail: 'ambiente@cm-municipio.pt',
          requiresInfrastructureInspection: false,
        );
      case 'Outros':
      default:
        return const AuthorityTarget(
          entityName: 'Câmara Municipal (Geral)',
          contactEmail: 'geral@cm-municipio.pt',
          requiresInfrastructureInspection: false,
        );
    }
  }
}