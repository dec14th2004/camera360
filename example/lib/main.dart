import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_plugin_camera360/helper/image_panorama_controller.dart';
import 'package:flutter_plugin_camera360/modules/camera_360_inside/domain/use_cases/upload_image_usecase.dart';
import 'package:flutter_plugin_camera360/modules/camera_360_inside/presentation/cubit/control_overlay/control_overlay_cubit.dart';
import 'package:flutter_plugin_camera360/modules/camera_360_inside/presentation/cubit/video_loading/loading_cubit.dart';
import 'package:flutter_plugin_camera360/modules/camera_360_inside/presentation/cubit/video_ready/video_ready_cubit.dart';
import 'package:flutter_plugin_camera360/modules/camera_360_inside/presentation/screens/camera_360_record_screen/camera_360_record_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final cameras = await availableCameras();
  runApp(MyApp(cameras: cameras));
}

class MyApp extends StatefulWidget {
  final List<CameraDescription> cameras;

  const MyApp({super.key, required this.cameras});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ControlOverlayCubit(),
        ),
        BlocProvider(
          create: (context) => VideoReadyCubit(
            cameraController: widget.cameras.isNotEmpty
                ? CameraController(
                    widget.cameras[0],
                    ResolutionPreset.high,
                  )
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
        BlocProvider(
          create: (context) => LoadingCubit(
            images: [],
            uploadImageUseCase: getIt.get<UploadImageUsecase>()
        ))
      ],
      child: Builder(
        builder: (BuildContext context) {
          return MaterialApp(
            home: Scaffold(
              // body: VideoReadyScreen(
              //   controlOverlayCubit: context.read<ControlOverlayCubit>(), onCaptureEnded: (Map<String, dynamic> data) async {
              //   // Thực hiện xử lý gì đó nếu cần
              //   return;
              // },
              // ),
              body: Camera360(onCaptureEnded:  (Map<String, dynamic> data) async {
              return;
            },),
            ),
          );
        },
      ),
    );
  }
}