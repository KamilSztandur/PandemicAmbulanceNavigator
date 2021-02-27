import 'dart:io';

class FileReader {
  const FileReader();

  Future<List<String>> read(String path) => File(path).readAsLines();
}
