import 'package:app_util/helpers/api_config.dart';
import 'package:app_util/helpers/app_localization.dart';
import 'package:app_util/services/api_service.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_plugin_camera360/modules/camera_360_inside/di.dart';
import 'package:get_it/get_it.dart';

import 'api_path.dart';

GetIt getIt = GetIt.instance;

class ImagePanoramaController {
  final ApiConfig apiServiceConfig;
  final ApiService apiService;
  final ApiConfig aiAPIServiceConfig;
  final ApiService aiAPIService;
  final PackageApiPath apiPath;

  ImagePanoramaController({
    required this.apiServiceConfig,
    required this.apiService,
    required this.aiAPIServiceConfig,
    required this.aiAPIService,
    required this.apiPath,
  });

  void configDI(BuildContext context) {
    getIt.enableRegisteringMultipleInstancesOfOneType();
    if (!getIt.isRegistered<AppLocalization>()) {
      getIt.registerSingleton(AppLocalization(context));
    }
    if (!getIt.isRegistered<PackageApiPath>()) {
      getIt.registerSingleton(apiPath);
    }
    configPanoramaDI(getIt, apiServiceConfig, apiService, apiPath);
    // configPostPanoramaDI(getIt, aiAPIServiceConfig, aiAPIService);
}

  Future<void> dispose() async {
    getIt.unregister<AppLocalization>();
}
}
