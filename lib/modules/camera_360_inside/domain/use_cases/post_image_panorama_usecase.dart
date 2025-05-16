import 'dart:typed_data';
import 'package:app_core/domain/use_cases/use_case.dart';
import 'package:app_util/domain/entities/data_state.dart';
import 'package:flutter_plugin_camera360/modules/camera_360_inside/domain/entities/uploaded_panorama.dart';
import '../repositories/image_panorama_repository.dart';

class PostImagePanoramaUsecase extends UseCase<DataState<UploadedPanorama>, PostImagePanoramaUsecaseParams> {
  final ImagePanoramaRepository repo;

  PostImagePanoramaUsecase({required this.repo});

  @override
  Future<DataState<UploadedPanorama>> call(PostImagePanoramaUsecaseParams params) {
    return repo.postImagePanorama(params);
  }
}

class PostImagePanoramaUsecaseParams {
  final Uint8List imagePanorama;
  final String mappingKey;
  final int entityId;

  PostImagePanoramaUsecaseParams({required this.imagePanorama, required this.mappingKey, required this.entityId});
}