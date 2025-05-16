import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

class Camera360State extends Equatable {
  // Camera status
  final bool isInitialized;
  final bool isReady;
  final List<CameraDescription> cameras;
  final int selectedCameraKey;
  final CameraController? controller;

  // Sensor data
  final Vector3 absoluteOrientation;
  final double? deviceHorizontalDegInitial;

  // Capture status
  final bool takingPicture;
  final bool isWaitingToTakePhoto;
  final bool deviceInCorrectPosition;
  final bool captureComplete;
  final List<XFile> capturedImages;
  final List<XFile> capturedImagesForDeletion;
  final int nrPhotosTaken;
  final int progressPercentage;
  final bool firstPhotoTaken;
  final bool manualCapture;

  // Helper dot positioning
  final double helperDotHorizontalReach;
  final bool helperDotVerticalInPos;
  final bool helperDotIsHorizontalInPos;
  final List rightRanges;
  final double horizontalMovementNeeded;
  final double lastSuccessHorizontalPosition;

  // Options and settings
  final int nrPhotos;
  final double degreesPerPhotos;
  final double degToNextPosition;
  final double deviceVerticalCorrectDeg;
  final int capturedImageWidth;
  final int capturedImageQuality;
  final int timeToWaitBeforeTakingPicture;

  // UI text
  final String loadingText;
  final String helperText;
  final String helperTiltLeftText;
  final String helperTiltRightText;

  // Flags
  final bool imageSaved;
  final bool lastPhoto;
  final bool lastPhotoTaken;

  // Constants
  static const double centeredDotRadius = 45;
  static const double centeredDotBorder = 3;
  static const double helperDotRadius = 30;
  static const double helperDotVerticalTolerance = 3;
  static const double helperDotHorizontalTolerance = 5;
  static const double helperDotRotationTolerance = 8;
  final double targetCenteredDotPosX; // Vị trí mục tiêu X của centered dot
  final double targetCenteredDotPosY; // Vị trí mục tiêu Y của centered dot


  Camera360State({
    this.isInitialized = false,
    this.isReady = false,
    this.cameras = const [],
    this.selectedCameraKey = 0,
    this.controller,
    Vector3? absoluteOrientation,
    this.deviceHorizontalDegInitial,
    this.takingPicture = false,
    this.isWaitingToTakePhoto = false,
    this.deviceInCorrectPosition = false,
    this.captureComplete = false,
    this.capturedImages = const [],
    this.capturedImagesForDeletion = const [],
    this.nrPhotosTaken = 0,
    this.progressPercentage = 0,
    this.helperDotHorizontalReach = 0,
    this.helperDotVerticalInPos = false,
    this.helperDotIsHorizontalInPos = false,
    this.rightRanges = const [],
    this.horizontalMovementNeeded = 0,
    this.lastSuccessHorizontalPosition = 0,
   // this.nrPhotos = 20,
    this.nrPhotos = 3,
    //this.degreesPerPhotos = 18,
    this.degreesPerPhotos = 120,
   // this.degToNextPosition = 18,
    this.degToNextPosition = 120,
    this.deviceVerticalCorrectDeg = 85,
    this.capturedImageWidth = 1000,
    this.capturedImageQuality = 50,
    this.timeToWaitBeforeTakingPicture = 1000,
    this.loadingText = 'Preparing images...',
    this.helperText = 'Point the camera at the dot',
    this.helperTiltLeftText = 'Tilt left',
    this.helperTiltRightText = 'Tilt right',
    this.imageSaved = false,
    this.lastPhoto = false,
    this.lastPhotoTaken = false,
    this.firstPhotoTaken = false,
    this.manualCapture = true,
    this.targetCenteredDotPosX = 0.48, // Tỷ lệ X (0.0 - 1.0) so với containerWidth
    this.targetCenteredDotPosY = 0.5, // Tỷ lệ Y (0.0 - 1.0) so với containerHeight
  }) : absoluteOrientation = absoluteOrientation ?? Vector3.zero();

  Camera360State copyWith({
    bool? isInitialized,
    bool? isReady,
    List<CameraDescription>? cameras,
    int? selectedCameraKey,
    CameraController? controller,
    Vector3? absoluteOrientation,
    double? deviceHorizontalDegInitial,
    bool? takingPicture,
    bool? isWaitingToTakePhoto,
    bool? deviceInCorrectPosition,
    bool? captureComplete,
    List<XFile>? capturedImages,
    List<XFile>? capturedImagesForDeletion,
    int? nrPhotosTaken,
    int? progressPercentage,
    double? helperDotHorizontalReach,
    bool? helperDotVerticalInPos,
    bool? helperDotIsHorizontalInPos,
    List? rightRanges,
    double? horizontalMovementNeeded,
    double? lastSuccessHorizontalPosition,
    int? nrPhotos,
    double? degreesPerPhotos,
    double? degToNextPosition,
    double? deviceVerticalCorrectDeg,
    int? capturedImageWidth,
    int? capturedImageQuality,
    int? timeToWaitBeforeTakingPicture,
    String? loadingText,
    String? helperText,
    String? helperTiltLeftText,
    String? helperTiltRightText,
    bool? imageSaved,
    bool? lastPhoto,
    bool? lastPhotoTaken,
    bool? firstPhotoTaken,
    bool? manualCapture,
    double? targetCenteredDotPosX,
    double? targetCenteredDotPosY,
  }) {
    return Camera360State(
      isInitialized: isInitialized ?? this.isInitialized,
      isReady: isReady ?? this.isReady,
      cameras: cameras ?? this.cameras,
      selectedCameraKey: selectedCameraKey ?? this.selectedCameraKey,
      controller: controller ?? this.controller,
      absoluteOrientation: absoluteOrientation ?? this.absoluteOrientation,
      deviceHorizontalDegInitial: deviceHorizontalDegInitial ?? this.deviceHorizontalDegInitial,
      takingPicture: takingPicture ?? this.takingPicture,
      isWaitingToTakePhoto: isWaitingToTakePhoto ?? this.isWaitingToTakePhoto,
      deviceInCorrectPosition: deviceInCorrectPosition ?? this.deviceInCorrectPosition,
      captureComplete: captureComplete ?? this.captureComplete,
      capturedImages: capturedImages ?? this.capturedImages,
      capturedImagesForDeletion: capturedImagesForDeletion ?? this.capturedImagesForDeletion,
      nrPhotosTaken: nrPhotosTaken ?? this.nrPhotosTaken,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      helperDotHorizontalReach: helperDotHorizontalReach ?? this.helperDotHorizontalReach,
      helperDotVerticalInPos: helperDotVerticalInPos ?? this.helperDotVerticalInPos,
      helperDotIsHorizontalInPos: helperDotIsHorizontalInPos ?? this.helperDotIsHorizontalInPos,
      rightRanges: rightRanges ?? this.rightRanges,
      horizontalMovementNeeded: horizontalMovementNeeded ?? this.horizontalMovementNeeded,
      lastSuccessHorizontalPosition: lastSuccessHorizontalPosition ?? this.lastSuccessHorizontalPosition,
      nrPhotos: nrPhotos ?? this.nrPhotos,
      degreesPerPhotos: degreesPerPhotos ?? this.degreesPerPhotos,
      degToNextPosition: degToNextPosition ?? this.degToNextPosition,
      deviceVerticalCorrectDeg: deviceVerticalCorrectDeg ?? this.deviceVerticalCorrectDeg,
      capturedImageWidth: capturedImageWidth ?? this.capturedImageWidth,
      capturedImageQuality: capturedImageQuality ?? this.capturedImageQuality,
      timeToWaitBeforeTakingPicture: timeToWaitBeforeTakingPicture ?? this.timeToWaitBeforeTakingPicture,
      loadingText: loadingText ?? this.loadingText,
      helperText: helperText ?? this.helperText,
      helperTiltLeftText: helperTiltLeftText ?? this.helperTiltLeftText,
      helperTiltRightText: helperTiltRightText ?? this.helperTiltRightText,
      imageSaved: imageSaved ?? this.imageSaved,
      lastPhoto: lastPhoto ?? this.lastPhoto,
      lastPhotoTaken: lastPhotoTaken ?? this.lastPhotoTaken,
      firstPhotoTaken: firstPhotoTaken ?? this.firstPhotoTaken,
      manualCapture: manualCapture ?? this.manualCapture,
      targetCenteredDotPosX: targetCenteredDotPosX ?? this.targetCenteredDotPosX,
      targetCenteredDotPosY: targetCenteredDotPosY ?? this.targetCenteredDotPosY,
    );
  }

  @override
  List<Object?> get props => [
    isInitialized,
    isReady,
    cameras,
    selectedCameraKey,
    controller,
    absoluteOrientation,
    deviceHorizontalDegInitial,
    takingPicture,
    isWaitingToTakePhoto,
    deviceInCorrectPosition,
    captureComplete,
    capturedImages,
    capturedImagesForDeletion,
    nrPhotosTaken,
    progressPercentage,
    helperDotHorizontalReach,
    helperDotVerticalInPos,
    helperDotIsHorizontalInPos,
    rightRanges,
    horizontalMovementNeeded,
    lastSuccessHorizontalPosition,
    nrPhotos,
    degreesPerPhotos,
    degToNextPosition,
    deviceVerticalCorrectDeg,
    capturedImageWidth,
    capturedImageQuality,
    timeToWaitBeforeTakingPicture,
    loadingText,
    helperText,
    helperTiltLeftText,
    helperTiltRightText,
    imageSaved,
    lastPhoto,
    lastPhotoTaken,
    firstPhotoTaken,
    manualCapture,
    targetCenteredDotPosX,
    targetCenteredDotPosY,
  ];
}