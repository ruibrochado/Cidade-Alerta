import 'package:flutter_test/flutter_test.dart';
import 'package:app/models/category_mapper.dart';

void main() {
  group('CategoryMapper Business Rules', () {
    test('Should route Infraestrutura and Sinalizacao to IP', () {
      final target1 = CategoryMapper.getAuthorityForCategory('Infraestrutura');
      final target2 = CategoryMapper.getAuthorityForCategory('Sinalização');

      expect(target1.entityName, 'Infraestruturas de Portugal');
      expect(target1.requiresInfrastructureInspection, isTrue);

      expect(target2.entityName, 'Infraestruturas de Portugal');
      expect(target2.requiresInfrastructureInspection, isTrue);
    });

    test('Should route Iluminacao Publica to E-Redes', () {
      final target = CategoryMapper.getAuthorityForCategory(
        'Iluminação Pública',
      );

      expect(target.entityName, 'E-Redes');
      expect(target.contactEmail, 'apoiocliente@e-redes.pt');
      expect(target.requiresInfrastructureInspection, isTrue);
    });

    test('Should route Lixo and Meio Ambiente to Servicos Municipalizados', () {
      final target1 = CategoryMapper.getAuthorityForCategory('Lixo e Limpeza');
      final target2 = CategoryMapper.getAuthorityForCategory('Meio Ambiente');

      expect(target1.entityName, 'Serviços Municipalizados');
      expect(target1.requiresInfrastructureInspection, isFalse);

      expect(target2.entityName, 'Serviços Municipalizados');
      expect(target2.requiresInfrastructureInspection, isFalse);
    });

    test('Should fallback unknown categories to Camara Municipal Geral', () {
      final target1 = CategoryMapper.getAuthorityForCategory('Outros');
      final target2 = CategoryMapper.getAuthorityForCategory(
        'Categoria Inexistente',
      );

      expect(target1.entityName, 'Câmara Municipal (Geral)');
      expect(target2.entityName, 'Câmara Municipal (Geral)');
      expect(target1.contactEmail, 'geral@cm-municipio.pt');
    });
  });
}
