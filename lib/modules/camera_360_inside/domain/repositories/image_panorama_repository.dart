import 'package:app_util/domain/entities/data_state.dart';
import 'package:flutter_plugin_camera360/modules/camera_360_inside/domain/entities/image_panorama.dart';
import 'package:flutter_plugin_camera360/modules/camera_360_inside/domain/entities/uploaded_panorama.dart';

import '../use_cases/post_image_panorama_usecase.dart';
import '../use_cases/upload_image_usecase.dart';

abstract class ImagePanoramaRepository {
  Future<DataState<ImagePanorama>> uploadListImages(UploadImagePanoramaUsecaseParams params);
  Future<DataState<UploadedPanorama>> postImagePanorama(PostImagePanoramaUsecaseParams params);
}