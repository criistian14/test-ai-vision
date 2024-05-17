import 'package:flutter/services.dart';

class ImageUtils {
  static final ImageUtils _instance = ImageUtils._internal();
  factory ImageUtils() => _instance;
  ImageUtils._internal();

  Uint8List? image;
}
