import 'dart:typed_data';

import 'package:app_core/domain/use_cases/use_case.dart';
import 'package:app_util/domain/entities/data_state.dart';
import 'package:flutter_plugin_camera360/modules/camera_360_inside/domain/entities/image_panorama.dart';
import '../repositories/image_panorama_repository.dart';

class UploadImageUsecase extends UseCase<DataState<ImagePanorama>, UploadImagePanoramaUsecaseParams> {
  ImagePanoramaRepository repo;

  UploadImageUsecase({required this.repo});

  @override
  Future<DataState<ImagePanorama>> call(UploadImagePanoramaUsecaseParams params) {
    return repo.uploadListImages(params);
  }
}

class UploadImagePanoramaUsecaseParams {
  final List<Uint8List> images;

  UploadImagePanoramaUsecaseParams({required this.images});
}