import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class StorageService {
  static Future<String> uploadProductImage(File file) async {
    final storage = Supabase.instance.client.storage;
    final path = 'products/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final res = await storage.from('product-images').upload(path, file);
    if (res.error != null) throw Exception(res.error!.message);
    return storage.from('product-images').getPublicUrl(path);
  }
}
