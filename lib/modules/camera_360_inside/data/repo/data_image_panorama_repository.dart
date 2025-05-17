import 'package:app_util/domain/entities/data_state.dart';
import 'package:app_util/helpers/api_extension.dart';
import 'package:flutter_plugin_camera360/modules/camera_360_inside/domain/entities/uploaded_panorama.dart';

import '../../domain/entities/image_panorama.dart';
import '../../domain/repositories/image_panorama_repository.dart';
import '../../domain/use_cases/post_image_panorama_usecase.dart';
import '../../domain/use_cases/upload_image_usecase.dart';
import '../data_source/remote/image_panorama_remote.dart';
import '../models/image_panorama_upload.dart';
import '../models/post_image_panorama_model.dart';

class DataImagePanoramaRepository implements ImagePanoramaRepository {
  final ImagePanoramaRemote remote;

  DataImagePanoramaRepository({required this.remote});

  @override
  Future<DataState<ImagePanorama>> uploadListImages (UploadImagePanoramaUsecaseParams params) {
    return remote
        .uploadListImages(params)
        .tryCatch(
          handler: (res) {
            final model = ImagePanoramaUploadModel(images: res.data);
            return model.mapToEntity();
          },
        );
  }

  @override
  Future<DataState<UploadedPanorama>> postImagePanorama(PostImagePanoramaUsecaseParams params) {
    return remote
        .postImagePanorama(imagePanorama: params.imagePanorama, mappingKey: params.mappingKey, entityId: params.entityId)
        .tryCatch(
          handler: (res) {
            return PostImagePanoramaModel.fromJson(res.data).mapToEntity();
          },
        );
  }
}
