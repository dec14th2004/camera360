import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

part 'video_ready_state.dart';

class VideoReadyCubit extends Cubit<VideoReadyState> {
  final CameraController cameraController;
  final List<CameraDescription> cameras;

  VideoReadyCubit({
    required this.cameraController,
    required this.cameras,
  }) : super(VideoReadyInitial()) {
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    emit(VideoReadyLoading());
    try {
      if (!cameraController.value.isInitialized) {
        await cameraController.initialize();
        await cameraController.setFocusMode(FocusMode.auto);
        await cameraController.setExposureMode(ExposureMode.auto);
        await cameraController.lockCaptureOrientation(DeviceOrientation.portraitUp);
        debugPrint('Camera initialized with auto focus, auto exposure, and portrait orientation');
      }
      emit(VideoReadyInitialized(cameraController, cameras));
    } catch (e) {
      debugPrint("Camera initialization error: $e");
      emit(VideoReadyError(message: "Error initializing camera: $e"));
    }
  }

  @override
  Future<void> close() {
    cameraController.dispose();
    return super.close();
  }
}