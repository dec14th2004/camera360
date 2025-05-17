import 'package:app_util/helpers/api_config.dart';
import 'package:app_util/helpers/app_localization.dart';
import 'package:app_util/services/api_service.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_plugin_camera360/helper/api_path.dart';
import 'package:get_it/get_it.dart';
import '../modules/camera_360_inside/di.dart';

GetIt getIt = GetIt.instance;

class ImagePanoramaController {
  final ApiConfig apiServiceConfig;
  final ApiService apiService;
  final PackageApiPath apiPath;

  ImagePanoramaController({
    required this.apiServiceConfig,
    required this.apiService,
    required this.apiPath,
  });

  void configDI(BuildContext context) {
    getIt.enableRegisteringMultipleInstancesOfOneType();
    if (!getIt.isRegistered<AppLocalization>()) {
      getIt.registerSingleton(AppLocalization(context));
    }
    if (!getIt.isRegistered<ApiConfig>(instanceName: 'apiServiceConfig')) {
      getIt.registerSingleton<ApiConfig>(
        apiServiceConfig,
        instanceName: 'apiServiceConfig',
      );
    }
    if (!getIt.isRegistered<ApiService>(instanceName: 'apiService')) {
      getIt.registerSingleton<ApiService>(
        apiService,
        instanceName: 'apiService',
      );
    }
    if (!getIt.isRegistered<PackageApiPath>()) {
      getIt.registerSingleton(apiPath);
    }
    configPanoramaDI(getIt, apiServiceConfig, apiService, apiPath);
  }

  Future<void> dispose() async {
    getIt.unregister<AppLocalization>();
  }
}