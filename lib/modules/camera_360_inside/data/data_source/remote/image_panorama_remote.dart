import 'dart:typed_data';

import 'package:app_core/data/data_source/base_remote.dart';
import 'package:app_util/domain/entities/api_response.dart';
import 'package:app_util/helpers/api_config.dart';
import 'package:app_util/services/api_service.dart';
import 'package:flutter_plugin_camera360/helper/api_path.dart';
import 'package:http/http.dart' as http;

class ImagePanoramaRemote extends BaseRemoteDataSource {
  @override
  final ApiService apiService;
  @override
  final ApiConfig apiConfig;
  final PackageApiPath apiPath;

  ImagePanoramaRemote({required this.apiService, required this.apiConfig, required this.apiPath})
  : super(apiService: apiService, apiConfig: apiConfig);

  Future<ApiResponse> uploadListImages(List<Uint8List> images) async {
    return await apiService.post(
      isHttps: false,
      isFormData: true,
      apiConfig.domain,
      apiPath.uploadListImages,
      files: List.generate( images.length, (index) => http.MultipartFile.fromBytes("file", images[index], filename: "image_$index.jpg")),
    );
  }

  Future<ApiResponse> postImagePanorama({
      required Uint8List imagePanorama, required String mappingKey, required int entityId
    }) async {
      return await apiService.post(
        isFormData: true,
        apiConfig.domain,
        apiPath.postImagePanorama,
        files: [http.MultipartFile.fromBytes('file', imagePanorama, filename: 'image_panorama.jpg')],
        body: {'mappingKey': mappingKey, 'entityId': entityId.toString()},
      );
  }
}