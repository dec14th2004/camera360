import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:dchs_motion_sensors/dchs_motion_sensors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;
import 'package:wakelock_plus/wakelock_plus.dart';
import 'camera_360_state.dart';

class Camera360Cubit extends Cubit<Camera360State> {
  final Future<void> Function(Map<String, dynamic>) onCaptureEnded;
  final void Function(int)? onCameraChanged;
  final void Function(int)? onProgressChanged;
  final int? userSelectedCameraKey;
  final int? userNrPhotos;
  final int? userCapturedImageWidth;
  final int? userCapturedImageQuality;
  final double? userDeviceVerticalCorrectDeg;
  final String? userLoadingText;
  final String? userHelperText;
  final String? userHelperTiltLeftText;
  final String? userHelperTiltRightText;

  final List<StreamSubscription<dynamic>> _streamSubscriptions = [];
  Timer? _waitingTimer;

  Camera360Cubit({
    required this.onCaptureEnded,
    this.onCameraChanged,
    this.onProgressChanged,
    this.userSelectedCameraKey,
    this.userNrPhotos,
    this.userCapturedImageWidth,
    this.userCapturedImageQuality,
    this.userDeviceVerticalCorrectDeg,
    this.userLoadingText,
    this.userHelperText,
    this.userHelperTiltLeftText,
    this.userHelperTiltRightText,
  }) : super(Camera360State(
    selectedCameraKey: userSelectedCameraKey ?? 0,
    nrPhotos: userNrPhotos ?? 20,
    // nrPhotos: userNrPhotos ?? 3,
    capturedImageWidth: userCapturedImageWidth ?? 1000,
    capturedImageQuality: userCapturedImageQuality ?? 50,
    deviceVerticalCorrectDeg: userDeviceVerticalCorrectDeg ?? 85,
    loadingText: userLoadingText ?? 'Preparing images...',
    helperText: userHelperText ?? 'Point the camera at the dot',
   degreesPerPhotos: (userNrPhotos != null) ? 360 / userNrPhotos : 18,
    // degreesPerPhotos: (userNrPhotos != null) ? 360 / userNrPhotos : 120,
   degToNextPosition: (userNrPhotos != null) ? 360 / userNrPhotos : 18,
    // degToNextPosition: (userNrPhotos != null) ? 360 / userNrPhotos : 120,
  )) {
    _setupSensors();
    _setupCameras();
  }

  void _setupSensors() {
    _disableSensors();
    int interval = Duration.microsecondsPerSecond ~/ 30;
    motionSensors.absoluteOrientationUpdateInterval = interval;
    motionSensors.orientationUpdateInterval = interval;

    _streamSubscriptions.add(motionSensors.absoluteOrientation.listen((AbsoluteOrientationEvent event) {
      emit(state.copyWith(
        absoluteOrientation: Vector3(event.yaw, event.pitch, event.roll),
      ));
    }, onError: (error) {
      debugPrint("'Panorama360': Sensor error: $error");
      Future.delayed(const Duration(seconds: 1), () {
        _setupSensors();
      });
    }));
  }

  void _disableSensors() {
    for (StreamSubscription<dynamic> subscription in _streamSubscriptions) {
      subscription.cancel();
    }
    _streamSubscriptions.clear();
  }

  Future<void> _setupCameras() async {
    if (Platform.isAndroid) {
      var cameraStatus = await Permission.camera.request();
      if (!cameraStatus.isGranted) {
        debugPrint("'Panorama360': Camera permission denied");
        emit(state.copyWith(isReady: false));
        return;
      }

      var storageStatus = await Permission.storage.request();
      if (!storageStatus.isGranted) {
        debugPrint("'Panorama360': Storage permission denied");
      }
    }

    try {
      final cameras = await availableCameras();
      final filteredCameras = cameras
          .where((description) =>
      description.lensDirection == CameraLensDirection.back ||
          description.lensDirection == CameraLensDirection.external)
          .toList();
      emit(state.copyWith(cameras: filteredCameras));
      await _initCamera(state.selectedCameraKey);
    } catch (e) {
      debugPrint("'Panorama360': Error setting up cameras: $e");
      emit(state.copyWith(isReady: false));
    }
  }

  Future<void> _initCamera(int cameraKey) async {
    try {
      if (!state.cameras.asMap().containsKey(cameraKey)) {
        cameraKey = 0;
      }
      CameraDescription description = state.cameras[cameraKey];
      final controller = CameraController(
        description,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await controller.initialize();
      await controller.setFlashMode(FlashMode.off);
      emit(state.copyWith(
        isInitialized: true,
        isReady: true,
        selectedCameraKey: cameraKey,
        controller: controller,
      ));
    } catch (e) {
      debugPrint("'Panorama360': Error initializing camera: $e");
      emit(state.copyWith(isReady: false, isInitialized: false));
    }
  }

  Future<void> deleteCache() async {
    await deletePanoramaImages();
  }

  Future<void> deletePanoramaImages() async {
    final capturedImagesForDeletion = List<XFile>.from(state.capturedImages);
    for (var capturedImage in capturedImagesForDeletion) {
      try {
        if (await File(capturedImage.path).exists()) {
          await File(capturedImage.path).delete();
          debugPrint("'Panorama360': Deleted image: ${capturedImage.path}");
        }
      } catch (e) {
        debugPrint("'Panorama360': Failed Deleting panorama image: ${capturedImage.path}");
      }
    }
    emit(state.copyWith(capturedImages: [], capturedImagesForDeletion: []));
  }

  Future<void> removeLastCapturedImage() async {
    if (state.capturedImages.isNotEmpty) {
      try {
        final lastImage = state.capturedImages.last;
        if (await File(lastImage.path).exists()) {
          await File(lastImage.path).delete();
        }
      } catch (e) {
        debugPrint("'Panorama360': Failed Deleting panorama image");
      }
      final newImages = List<XFile>.from(state.capturedImages)..removeLast();
      emit(state.copyWith(capturedImages: newImages));
    }
  }

  void restartApp({String? reason, bool clearCache = true}) async {
    debugPrint("'Panorama360': Restarting app reason: $reason");
    _waitingTimer?.cancel();
    _disableSensors();

    emit(state.copyWith(
      capturedImages: [],
      capturedImagesForDeletion: [],
      horizontalMovementNeeded: 0,
      lastSuccessHorizontalPosition: 0,
      helperDotIsHorizontalInPos: false,
      helperDotVerticalInPos: false,
      helperDotHorizontalReach: 0,
      rightRanges: [],
      deviceHorizontalDegInitial: null,
      deviceInCorrectPosition: false,
      takingPicture: false,
      isWaitingToTakePhoto: false,
      nrPhotosTaken: 0,
      imageSaved: false,
      lastPhoto: false,
      lastPhotoTaken: false,
      captureComplete: false,
      progressPercentage: 0,
      firstPhotoTaken: false,
      manualCapture: true,
    ));

    onProgressChanged?.call(0);

    if (clearCache) {
      try {
        await deleteCache();
      } catch (e) {
        //  debugPrint("'Panorama360': Error deleting cache: $e");
      }
    }

    _setupSensors();
    try {
      await _initCamera(state.selectedCameraKey);
    } catch (e) {
      //  debugPrint("'Panorama360': Error re-initializing camera: $e");
      emit(state.copyWith(isReady: false));
    }
  }

  void selectCamera(int cameraKey) {
    onCameraChanged?.call(cameraKey);
    _initCamera(cameraKey).then((_) {
      restartApp(reason: "Camera selected");
    });
  }

  Future<XFile?> _takePicture() async {
    // debugPrint("'Panorama360': _takePicture called, nrPhotosTaken: ${state.nrPhotosTaken}, captureComplete: ${state.captureComplete}");
    if (state.nrPhotosTaken >= state.nrPhotos || state.captureComplete) {
      //   debugPrint("'Panorama360': No more photos needed or capture complete");
      return null;
    }

    try {
      emit(state.copyWith(takingPicture: true));
      // debugPrint("'Panorama360': Taking picture...");
      XFile? file = await state.controller?.takePicture();
      if (file == null) {
        //  debugPrint("'Panorama360': Failed to take picture, file is null");
        return null;
      }

      // debugPrint("'Panorama360': Compressing image...");
      // XFile compressedImage = await resizeImage(File(file.path));
      XFile compressedImage = file;
      if (state.nrPhotosTaken < state.nrPhotos) {
        try {
          //    debugPrint("'Panorama360': Attempting to save photo to gallery: ${compressedImage.path}");
          bool? saved = await GallerySaver.saveImage(compressedImage.path, albumName: 'Camera360');
          if (saved == true) {
            //      debugPrint("'Panorama360': Photo saved to gallery successfully");
          } else {
            //      debugPrint("'Panorama360': Failed to save photo to gallery");
          }
        } catch (e) {
          debugPrint("'Panorama360': Error saving photo to gallery: $e");
        }
        final newImages = List<XFile>.from(state.capturedImages)..add(compressedImage);
        debugPrint("'Panorama360': Updating state, nrPhotosTaken: ${state.nrPhotosTaken + 1}, firstPhotoTaken: ${state.nrPhotosTaken == 0}, manualCapture: ${state.nrPhotosTaken == 0 ? false : state.manualCapture}");
        emit(state.copyWith(
          capturedImages: newImages,
          nrPhotosTaken: state.nrPhotosTaken + 1,
          firstPhotoTaken: state.nrPhotosTaken == 0 ? true : state.firstPhotoTaken,
          manualCapture: state.nrPhotosTaken == 0 ? false : state.manualCapture,
        ));
        debugPrint("'Panorama360': Photo taken, total photos: ${state.nrPhotosTaken} / ${state.nrPhotos}");
        prepareForNextImageCapture();
        return compressedImage;
      } else {
        debugPrint("'Panorama360': Deleting excess image: ${compressedImage.path}");
        await File(compressedImage.path).delete();
        return null;
      }
    } catch (e) {
      debugPrint("'Panorama360': Error taking picture: $e");
      return null;
    } finally {
      debugPrint("'Panorama360': _takePicture completed, resetting takingPicture");
      emit(state.copyWith(takingPicture: false));
    }
  }

  Future<XFile> resizeImage(File img) async {
    final filePath = img.absolute.path;
    final lastIndex = filePath.lastIndexOf(RegExp(r'.png|.jp'));
    final splitted = filePath.substring(0, lastIndex);
    final outPath = "${splitted}_compressed${filePath.substring(lastIndex)}";

    XFile? compressedImage;
    if (lastIndex == filePath.lastIndexOf(RegExp(r'.png'))) {
      compressedImage = await FlutterImageCompress.compressAndGetFile(
        filePath,
        outPath,
        format: CompressFormat.png,
        quality: state.capturedImageQuality,
        minWidth: state.capturedImageWidth,
        minHeight: 1,
      );
    } else {
      compressedImage = await FlutterImageCompress.compressAndGetFile(
        filePath,
        outPath,
        quality: state.capturedImageQuality,
        minWidth: state.capturedImageWidth,
        minHeight: 1,
      );
    }

    try {
      if (await File(img.path).exists()) {
        await File(img.path).delete();
      }
    } catch (e) {
      debugPrint("'Panorama360': Failed Deleting panorama image");
    }

    debugPrint("'Panorama360': Image taken: ${compressedImage!.path}");
    return XFile(compressedImage.path);
  }

  void prepareForNextImageCapture([double? degToNextPositionOverwrite]) {
    if (!state.firstPhotoTaken) return;

    degToNextPositionOverwrite ??= state.degToNextPosition;
    _updateSuccessHorizontalPosition(state.helperDotHorizontalReach);
    _moveHelperDotToNextPosition(degToNextPositionOverwrite);
    final newRightRanges = generateRightRanges(state.helperDotHorizontalReach);
    emit(state.copyWith(
      rightRanges: newRightRanges,
      takingPicture: false,
    ));
    if (_morePhotosNeeded()) {
      _updateProgress();
    }
  }

  void _moveHelperDotToNextPosition([double? degToNextPositionOverwrite]) {
    degToNextPositionOverwrite ??= state.degToNextPosition;
    double newHorizontalReach = state.helperDotHorizontalReach + degToNextPositionOverwrite;

    if (newHorizontalReach > 360) {
      newHorizontalReach -= 360;
    } else if (newHorizontalReach < 0) {
      newHorizontalReach = 360 + newHorizontalReach;
    }

    emit(state.copyWith(helperDotHorizontalReach: newHorizontalReach));
  }

  double updateHelperDotVerticalPosition(double deviceVerticalDeg, double containerHeight) {
    double helperDotUpperMax = containerHeight / 2;
    double helperDotBottomMin = containerHeight / 2;
    double helperDotPosY = containerHeight * state.targetCenteredDotPosY - Camera360State.helperDotRadius;

    if (deviceVerticalDeg < state.deviceVerticalCorrectDeg) {
      if (deviceVerticalDeg <= 0) {
        helperDotPosY = 0;
      } else {
        helperDotPosY = deviceVerticalDeg * (helperDotUpperMax - Camera360State.helperDotRadius) / state.deviceVerticalCorrectDeg;
      }
    } else if (deviceVerticalDeg > state.deviceVerticalCorrectDeg) {
      helperDotPosY = deviceVerticalDeg * (helperDotBottomMin - Camera360State.helperDotRadius) / state.deviceVerticalCorrectDeg;
    }

    // Tính toán vị trí tâm của centered dot và helper dot theo trục Y
    double centeredDotCenterY = containerHeight * state.targetCenteredDotPosY;
    double helperDotEffectiveRadius = Camera360State.helperDotRadius * 1.25; // Bán kính thực tế = 30 * 1.25 = 37.5
    double helperDotCenterY = helperDotPosY + helperDotEffectiveRadius;

    // Kiểm tra xem helper dot có nằm trong vùng của centered dot theo trục Y hay không
    double centeredDotRadius = Camera360State.centeredDotRadius + Camera360State.centeredDotBorder; // 45 + 3 = 48
    bool verticalInPos =
        (deviceVerticalDeg >= (state.deviceVerticalCorrectDeg - Camera360State.helperDotVerticalTolerance) &&
            deviceVerticalDeg <= (state.deviceVerticalCorrectDeg + Camera360State.helperDotVerticalTolerance)) &&
            (helperDotCenterY >= (centeredDotCenterY - centeredDotRadius + helperDotEffectiveRadius) &&
                helperDotCenterY <= (centeredDotCenterY + centeredDotRadius - helperDotEffectiveRadius));

    emit(state.copyWith(helperDotVerticalInPos: verticalInPos));
    return helperDotPosY;
  }

  List generateRightRanges(double reachDeg) {
    double right = reachDeg + 180;
    List rightRanges = [];

    if (right > 360) {
      right -= 360;
      rightRanges.add([0, right]);
      rightRanges.add([reachDeg, 360]);
    } else {
      rightRanges.add([reachDeg, right]);
    }
    return rightRanges;
  }

  double updateHelperDotHorizontalPosition(double deviceHorizontalDegManipulated, double containerWidth) {
    double helperDotPosX = containerWidth * state.targetCenteredDotPosX - Camera360State.helperDotRadius;
    bool moveRight = false;

    for (List rightRange in state.rightRanges) {
      if (deviceHorizontalDegManipulated >= rightRange[0] && deviceHorizontalDegManipulated <= rightRange[1]) {
        moveRight = true;
        break;
      }
    }

    double helperDotEffectiveRadius = Camera360State.helperDotRadius * 1.0; // Bán kính thực tế = 37.5
    if (moveRight) {
      final horizontalMovement = deviceHorizontalDegManipulated - (state.helperDotHorizontalReach - Camera360State.helperDotHorizontalTolerance);
      helperDotPosX = containerWidth * state.targetCenteredDotPosX - helperDotEffectiveRadius - horizontalMovement;

      if (state.rightRanges.length == 2 && deviceHorizontalDegManipulated <= state.rightRanges[0][1]) {
        helperDotPosX -= 360;
      }

      if (helperDotPosX < helperDotEffectiveRadius) {
        helperDotPosX = helperDotEffectiveRadius;
      }
    } else {
      final horizontalMovement = (state.helperDotHorizontalReach - Camera360State.helperDotHorizontalTolerance) - deviceHorizontalDegManipulated;
      helperDotPosX = containerWidth * state.targetCenteredDotPosX - helperDotEffectiveRadius + horizontalMovement;

      if (helperDotPosX < 0 && state.rightRanges.length == 1) {
        helperDotPosX += 360;
      }

      if (helperDotPosX > containerWidth - helperDotEffectiveRadius) {
        helperDotPosX = containerWidth - helperDotEffectiveRadius;
      }
    }

    // Tính toán vị trí tâm của centered dot và helper dot theo trục X
    double centeredDotCenterX = containerWidth * state.targetCenteredDotPosX;
    double helperDotCenterX = helperDotPosX + helperDotEffectiveRadius;

    // Kiểm tra xem helper dot có nằm trong vùng của centered dot theo trục X hay không
    double centeredDotRadius = Camera360State.centeredDotRadius + Camera360State.centeredDotBorder + 5; // 45 + 3 + 5 = 53
    bool horizontalInPos =
        (deviceHorizontalDegManipulated >= (state.helperDotHorizontalReach - Camera360State.helperDotHorizontalTolerance) &&
            deviceHorizontalDegManipulated <= (state.helperDotHorizontalReach + Camera360State.helperDotHorizontalTolerance)) &&
            (helperDotCenterX >= (centeredDotCenterX - centeredDotRadius + helperDotEffectiveRadius) &&
                helperDotCenterX <= (centeredDotCenterX + centeredDotRadius - helperDotEffectiveRadius));

    emit(state.copyWith(
      horizontalMovementNeeded: moveRight ? helperDotPosX : -helperDotPosX,
      helperDotIsHorizontalInPos: horizontalInPos,
    ));

    return helperDotPosX;
  }

  bool checkDeviceRotation(double deviceRotationDeg) {
    return checkRightDeviceRotation(deviceRotationDeg) && checkLeftDeviceRotation(deviceRotationDeg);
  }

  bool checkLeftDeviceRotation(double deviceRotationDeg) {
    return deviceRotationDeg >= (Camera360State.helperDotRotationTolerance * -1);
  }

  bool checkRightDeviceRotation(double deviceRotationDeg) {
    return deviceRotationDeg <= Camera360State.helperDotRotationTolerance;
  }

  Future<void> prepareOnCaptureEnded() async {
    try {
      Map<String, dynamic> returnedData = {
        'success': state.capturedImages.isNotEmpty,
        'images': state.capturedImages,
        'options': {
          'selected_camera': state.selectedCameraKey,
          'vertical_camera_angle': state.deviceVerticalCorrectDeg,
        },
      };

      await onCaptureEnded(returnedData);
      emit(state.copyWith(captureComplete: true));

      await Future.delayed(const Duration(seconds: 1));
      restartApp(reason: "Auto-restart after capture completion");
    } catch (e) {
      debugPrint("'Panorama360': Error in prepareOnCaptureEnded: $e");
      restartApp(reason: "Auto-restart after error");
    }
  }

  bool _morePhotosNeeded() {
    return state.nrPhotosTaken < state.nrPhotos;
  }

  bool readyToTakePhoto() {
    return _morePhotosNeeded() && state.deviceInCorrectPosition && !state.takingPicture && !state.captureComplete && !state.manualCapture;
  }

  double _updateSuccessHorizontalPosition(double value) {
    emit(state.copyWith(lastSuccessHorizontalPosition: value));
    return value;
  }

  void _updateProgress() {
    int newProgressPercentage = ((state.nrPhotosTaken / state.nrPhotos) * 100).round();
    if (newProgressPercentage > 100) {
      newProgressPercentage = 100;
    }

    if (newProgressPercentage != state.progressPercentage) {
      emit(state.copyWith(progressPercentage: newProgressPercentage));
      onProgressChanged?.call(newProgressPercentage);
    }
  }

  double calculateDegreesFromZero(double initialDeg, double currentDeg) {
    double calculatedDeg = currentDeg;
    double deviceHorizontalDegReset = 360 - initialDeg;
    if (currentDeg >= 0 && currentDeg < initialDeg) {
      calculatedDeg += deviceHorizontalDegReset;
    } else {
      calculatedDeg -= initialDeg;
    }
    return calculatedDeg;
  }

  void handleAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (!this.state.captureComplete) {
          _setupSensors();
        }
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _disableSensors();
        break;
    }
  }

  void manualTakePicture() {
    debugPrint("'Panorama360': manualTakePicture called, manualCapture: ${state.manualCapture}, takingPicture: ${state.takingPicture}");
    if (state.manualCapture && !state.takingPicture) {
      emit(state.copyWith(takingPicture: true, isWaitingToTakePhoto: true));
      debugPrint("'Panorama360': Starting timer for taking picture");
      _waitingTimer?.cancel();
      _waitingTimer = Timer(Duration(milliseconds: state.timeToWaitBeforeTakingPicture), () {
        if (state.takingPicture && state.isWaitingToTakePhoto) {
          debugPrint("'Panorama360': Timer triggered, capturing photo");
          emit(state.copyWith(isWaitingToTakePhoto: false));
          _takePicture();
        } else {
          debugPrint("'Panorama360': Timer cancelled, resetting state");
          emit(state.copyWith(isWaitingToTakePhoto: false, takingPicture: false));
        }
      });
    } else {
      debugPrint("'Panorama360': manualTakePicture skipped, conditions not met");
    }
  }

  void updateDeviceOrientation({
    required double deviceVerticalDeg,
    required double deviceHorizontalDeg,
    required double deviceRotationDeg,
    required double containerWidth,
    required double containerHeight,
  }) {
    double? newDeviceHorizontalDegInitial = state.firstPhotoTaken ? (state.deviceHorizontalDegInitial ?? deviceHorizontalDeg) : null;
    double deviceHorizontalDegManipulated = state.firstPhotoTaken
        ? calculateDegreesFromZero(newDeviceHorizontalDegInitial!, deviceHorizontalDeg)
        : deviceHorizontalDeg;
    bool isDeviceRotationCorrect = checkDeviceRotation(deviceRotationDeg);

    double helperDotPosX = updateHelperDotHorizontalPosition(deviceHorizontalDegManipulated, containerWidth);
    double helperDotPosY = updateHelperDotVerticalPosition(deviceVerticalDeg, containerHeight);

    // Tính toán vị trí tâm của centered dot
    double centeredDotCenterX = containerWidth * state.targetCenteredDotPosX;
    double centeredDotCenterY = containerHeight * state.targetCenteredDotPosY;

    // Tính toán vị trí tâm của helper dot
    double helperDotEffectiveRadius = Camera360State.helperDotRadius * 1.25; // Bán kính thực tế = 37.5
    double helperDotCenterX = helperDotPosX + helperDotEffectiveRadius;
    double helperDotCenterY = helperDotPosY + helperDotEffectiveRadius;

    // Kiểm tra xem helper dot có nằm hoàn toàn trong vòng centered dot hay không
    double centeredDotRadius = Camera360State.centeredDotRadius + Camera360State.centeredDotBorder + 5; // 45 + 3 + 5 = 53
    bool isCenteredDotInPos =
        (helperDotCenterX >= (centeredDotCenterX - centeredDotRadius + helperDotEffectiveRadius) &&
            helperDotCenterX <= (centeredDotCenterX + centeredDotRadius - helperDotEffectiveRadius)) &&
            (helperDotCenterY >= (centeredDotCenterY - centeredDotRadius + helperDotEffectiveRadius) &&
                helperDotCenterY <= (centeredDotCenterY + centeredDotRadius - helperDotEffectiveRadius));

    bool deviceInCorrectPosition = state.helperDotVerticalInPos &&
        state.helperDotIsHorizontalInPos &&
        isDeviceRotationCorrect &&
        isCenteredDotInPos;

    emit(state.copyWith(
      deviceHorizontalDegInitial: newDeviceHorizontalDegInitial,
      deviceInCorrectPosition: deviceInCorrectPosition,
      rightRanges: state.firstPhotoTaken ? generateRightRanges(state.helperDotHorizontalReach) : [],
    ));

    if (readyToTakePhoto()) {
      if (!state.takingPicture && !state.isWaitingToTakePhoto) {
        emit(state.copyWith(takingPicture: true, isWaitingToTakePhoto: true));
        _waitingTimer?.cancel();
        _waitingTimer = Timer(Duration(milliseconds: state.timeToWaitBeforeTakingPicture), () {
          if (deviceInCorrectPosition && state.takingPicture && state.isWaitingToTakePhoto) {
            emit(state.copyWith(isWaitingToTakePhoto: false));
            _takePicture();
          } else {
            emit(state.copyWith(isWaitingToTakePhoto: false, takingPicture: false));
          }
        });
      }
    } else if ((state.takingPicture || state.isWaitingToTakePhoto) && !deviceInCorrectPosition) {
      _waitingTimer?.cancel();
      emit(state.copyWith(takingPicture: false, isWaitingToTakePhoto: false));
    }

    if (!_morePhotosNeeded() && !state.captureComplete) {
      prepareOnCaptureEnded();
    }
  }

  @override
  Future<void> close() async {
    _waitingTimer?.cancel();
    WakelockPlus.disable();
    state.controller?.dispose();
    _disableSensors();
    if (state.capturedImages.isNotEmpty && !state.captureComplete) {
      await prepareOnCaptureEnded();
    }
    await super.close();
  }

}