import 'package:app_util/helpers/api_config.dart';
import 'package:app_util/services/api_service.dart';
import 'package:flutter_plugin_camera360/helper/api_path.dart';
import 'package:get_it/get_it.dart';
import 'data/data_source/remote/image_panorama_remote.dart';
import 'data/repo/data_image_panorama_repository.dart';
import 'domain/repositories/image_panorama_repository.dart';
import 'domain/use_cases/post_image_panorama_usecase.dart';
import 'domain/use_cases/upload_image_usecase.dart';

void configPanoramaDI(
  GetIt injector,
  ApiConfig apiServiceConfig,
  ApiService apiService,
  PackageApiPath apiPath,
) {
  if (!injector.isRegistered<ImagePanoramaRemote>()) {
    injector.registerFactory<ImagePanoramaRemote>(
      () => ImagePanoramaRemote(
        apiService: injector.get<ApiService>(instanceName: 'apiService'),
        apiConfig: injector.get<ApiConfig>(instanceName: 'apiServiceConfig'),
        apiPath: apiPath,
      ),
    );
    injector.registerFactory<ImagePanoramaRepository>(
      () => DataImagePanoramaRepository(
        remote: injector.get<ImagePanoramaRemote>(),
      ),
    );
    injector.registerFactory<UploadImageUsecase>(
      () => UploadImageUsecase(repo: injector.get<ImagePanoramaRepository>()),
    );
  }
}

void configPostPanoramaDI(
  GetIt injector,
  ApiConfig aiAPIServiceConfig,
  ApiService aiAPIService,
  PackageApiPath apiPath,
) {
  if (!injector.isRegistered<ImagePanoramaRemote>()) {
    injector.registerSingleton<ApiConfig>(
      aiAPIServiceConfig,
      instanceName: 'aiAPIServiceConfig',
    );
    injector.registerSingleton<ApiService>(
      aiAPIService,
      instanceName: 'aiAPIService',
    );
    injector.registerFactory<ImagePanoramaRemote>(
      () => ImagePanoramaRemote(
        apiService: injector.get<ApiService>(instanceName: 'aiAPIService'),
        apiConfig: injector.get<ApiConfig>(instanceName: 'aiAPIServiceConfig'),
        apiPath: apiPath,
      ),
    );
    injector.registerFactory<ImagePanoramaRepository>(
      () => DataImagePanoramaRepository(
        remote: injector.get<ImagePanoramaRemote>(),
      ),
    );
    injector.registerFactory<PostImagePanoramaUsecase>(
      () => PostImagePanoramaUsecase(
        repo: injector.get<ImagePanoramaRepository>(),
      ),
    );
  }
}