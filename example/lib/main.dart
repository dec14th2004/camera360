import 'package:app_util/helpers/api_config.dart';
import 'package:app_util/services/api_service.dart';
import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_plugin_camera360/helper/api_path.dart';
import 'package:flutter_plugin_camera360/helper/image_panorama_controller.dart';
import 'package:flutter_plugin_camera360/modules/camera_360_inside/presentation/cubit/control_overlay/control_overlay_cubit.dart';
import 'package:flutter_plugin_camera360/modules/camera_360_inside/presentation/cubit/video_ready/video_ready_cubit.dart';
import 'package:flutter_plugin_camera360/modules/camera_360_inside/presentation/screens/camera_360_record_screen/camera_360_record_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  final cameras = await availableCameras();

  final controller = ImagePanoramaController(
    apiServiceConfig: ApiConfig(
      domain: 'ai-gate-dev.aurora-tech.com/view-360-inside',
      domainSocketTracking: '',
    ),
    apiService: ApiService(
      shouldIgnoreRefreshToken: (baseRequest) => false,
      onRefreshTokenFail: () {
        debugPrint('Refresh token failed');
      },
      refreshToken: (post) async {
        debugPrint('Refreshing token...');
        // Triển khai logic làm mới token nếu cần
      },
      generateAccessToken: () => 'eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJHOXI3Yl9KNDE4MjhEMzZqSzVtdlhta1ZDbnpmdzZ1bDlJamdkb3ZLcGpNIn0.eyJleHAiOjE3NDc1MTkyMTUsImlhdCI6MTc0NzQ5MDQxNSwianRpIjoiZWU4MjFhZGEtOWIwNC00Y2U1LWFmMDEtYjIwZmQ3M2Y2NmIzIiwiaXNzIjoiaHR0cHM6Ly9zc28tZGV2LmF1cm9yYS10ZWNoLmNvbS9yZWFsbXMvZHJ1Y2UiLCJ0eXAiOiJCZWFyZXIiLCJhenAiOiJwdWJsaWMtY2xpZW50Iiwic2lkIjoiNzU1YTRjNDItNzI1YS00NjNkLTgxYjktNjIzMjBkOTkyOThjIiwiYWNyIjoiMSIsInNjb3BlIjoicHJvZmlsZSBncm91cHMgZW1haWwgdXNlcl9kYXRhIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsInVzZXJfaWQiOiIzMiIsIm5hbWUiOiJLaGFuaCBMZSIsImdyb3VwcyI6WyIvYWRtaW4iLCIvZHJ1Y2UiLCIvcGFydG5lciIsIi9zYWxlcyJdLCJwcmVmZXJyZWRfdXNlcm5hbWUiOiJ0ZXN0MTlAZ21haWwuY29tIiwiZ2l2ZW5fbmFtZSI6IktoYW5oIiwiZmFtaWx5X25hbWUiOiJMZSIsImVtYWlsIjoidGVzdDE5QGdtYWlsLmNvbSIsImNoYXRfaWQiOiI2ODEwOTJhZGQ4NTJkZmRhMWMzNGU1YjIifQ.gwLTCPvSHWoicyQtDUuu62PZbVjXZA32PSFEMQqG-faUU9FYdsAHXY1o82VDiZ76ryQXcTG5KkLPtzGkXQL-f1E-TAkvnH2Fv-vHoGoMhom5I68UjOh2PXYortG_i1C2kSgnhydvH6Tg7pmya0YEBfs3Yu-mZI60J2Jy5dF9xUoKWCSo_7s0oxZRxoD7p8_nzqxQXlv4v40tTkRW8jfGLraIBNWcw1JJ8g3liEQogFx0e6ZLElA3wB3BPdBOT9NuQAMv2DivSYDXR1LwYMgg59GFzgy51e4SRBDwM8yMdBM-s2a7BM03nau6vbv65qcoPmhrH6CLFIF9jVxKb1L2-g',
    ),
    apiPath: PackageApiPath(
      uploadListImages: '/api/v1/create_panorama',
      postImagePanorama: '/api/post/panorama',
    ),
  );

  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en', 'US')],
      path: 'assets/lang',
      child: MyApp(cameras: cameras, controller: controller),
    ),
  );
}

class MyApp extends StatefulWidget {
  final List<CameraDescription> cameras;
  final ImagePanoramaController controller;

  const MyApp({super.key, required this.cameras, required this.controller});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    widget.controller.configDI(context);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ControlOverlayCubit()),
        BlocProvider(
          create: (context) => VideoReadyCubit(
            cameraController: widget.cameras.isNotEmpty
                ? CameraController(widget.cameras[0], ResolutionPreset.high)
                : CameraController(
                    const CameraDescription(
                      name: 'dummy',
                      lensDirection: CameraLensDirection.back,
                      sensorOrientation: 0,
                    ),
                    ResolutionPreset.high,
                  ),
            cameras: widget.cameras,
          ),
        ),
      ],
      child: MaterialApp(
        locale: Locale('en', 'US'),
        home: Scaffold(
          body: Camera360(
            onCaptureEnded: (Map<String, dynamic> data) async {
              if (data['success']) {
                debugPrint('Images captured successfully: ${data['images'].length} images');
              } else {
                debugPrint('Failed to capture images');
              }
            },
          ),
        ),
      ),
    );
  }
}