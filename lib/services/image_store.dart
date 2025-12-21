import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class PersistedImage {
  final String url;
  final String? localPath;

  const PersistedImage({required this.url, this.localPath});

  bool get isCached => !kIsWeb && localPath != null && localPath!.isNotEmpty;

  ImageProvider get provider {
    if (isCached) {
      return FileImage(File(localPath!));
    }
    return NetworkImage(url);
  }

  PersistedImage withLocalPath(String path) {
    return PersistedImage(url: url, localPath: path);
  }

  Map<String, dynamic> toJson() => {'url': url, 'local_path': localPath};

  factory PersistedImage.fromJson(Map<String, dynamic> json) {
    return PersistedImage(url: json['url'], localPath: json['local_path']);
  }
}

class ImageStore {
  static Future<PersistedImage> ensureLocal(
    PersistedImage image, {
    required String namespace,
    required String filename,
  }) async {
    // On web, never cache, just return the original image
    if (kIsWeb || image.isCached) return image;

    final root = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(root.path, namespace));
    await dir.create(recursive: true);

    final path = p.join(dir.path, filename);
    final file = File(path);

    if (!await file.exists()) {
      final response = await http.get(Uri.parse(image.url));
      if (response.statusCode != 200) {
        throw Exception('Failed to download image');
      }
      await file.writeAsBytes(response.bodyBytes);
    }

    return image.withLocalPath(path);
  }
}
