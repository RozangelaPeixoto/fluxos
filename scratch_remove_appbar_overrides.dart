import 'dart:io';

void main() {
  final dir = Directory('c:/Users/roxpm/Projetos_Java/FluxOS/lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  for (final file in files) {
    String content = file.readAsStringSync();
    if (content.contains('AppBar(')) {
      // Remove backgroundColor: ...
      content = content.replaceAll(RegExp(r'backgroundColor:\s*const Color\([^)]+\),\s*'), '');
      content = content.replaceAll(RegExp(r'backgroundColor:\s*Colors\.\w+,\s*'), '');
      
      // Remove elevation: ...
      content = content.replaceAll(RegExp(r'elevation:\s*\d+\.?\d*,\s*'), '');
      
      file.writeAsStringSync(content);
    }
  }
}
