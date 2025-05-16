import 'dart:typed_data';
import 'package:app_core/data/mappers/data_mapper.dart';

import '../../domain/entities/image_panorama.dart';

class ImagePanoramaUploadModel extends DataMapper<ImagePanorama> {
  final Uint8List images;

  ImagePanoramaUploadModel({required this.images});

    static Future<ImagePanoramaUploadModel> fromByteStream(Uint8List byteStream) async =>
      ImagePanoramaUploadModel(images: byteStream);

  @override
  ImagePanorama mapToEntity() {
    return ImagePanorama(imagePanorama: images);
  }
}
