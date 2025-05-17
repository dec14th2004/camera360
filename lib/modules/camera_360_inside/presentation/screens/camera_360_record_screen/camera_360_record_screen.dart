import 'dart:math';
import 'dart:typed_data'; // Thêm để xử lý Uint8List
import 'package:flutter_plugin_camera360/modules/camera_360_inside/presentation/cubit/camera_360_cubit/camera_360_state.dart';
import 'package:flutter_plugin_camera360/modules/camera_360_inside/presentation/components/stop_notify_bottom_sheet.dart';
import 'package:flutter_plugin_camera360/modules/camera_360_inside/presentation/components/grid_painter.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_plugin_camera360/modules/camera_360_inside/presentation/cubit/camera_360_cubit/camera_360_cubit.dart';
import 'package:flutter_plugin_camera360/modules/camera_360_inside/presentation/components/balance_bar_indicator.dart';
import 'package:flutter_plugin_camera360/modules/camera_360_inside/presentation/components/helper_text.dart';
import 'package:flutter_plugin_camera360/modules/camera_360_inside/presentation/components/orientation_helpers.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';
import 'dart:io';

double degrees(double radians) => radians * 180 / pi;

class Camera360 extends StatefulWidget {
  final Future<void> Function(Map<String, dynamic>) onCaptureEnded;
  final void Function(int)? onCameraChanged;
  final void Function(int)? onProgressChanged;
  final int? userSelectedCameraKey;
  final int? userNrPhotos;
  final int? userCapturedImageWidth;
  final int? userCapturedImageQuality;
  final String? userLoadingText;
  final String? userHelperText;
  final String? userHelperTiltLeftText;
  final String? userHelperTiltRightText;
  final double? userDeviceVerticalCorrectDeg;
  final bool cameraSelectorInfoPopUpShow;
  final bool cameraSelectorShow;
  final Widget? cameraSelectorInfoPopUpContent;
  final Widget? cameraNotReadyContent;
  final double? targetCenteredDotPosX;
  final double? targetCenteredDotPosY;

  const Camera360({
    super.key,
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
    this.cameraSelectorShow = true,
    this.cameraSelectorInfoPopUpShow = true,
    this.cameraSelectorInfoPopUpContent,
    this.cameraNotReadyContent,
    this.targetCenteredDotPosX,
    this.targetCenteredDotPosY,
  });

  @override
  State<Camera360> createState() => _Camera360State();
}

class _Camera360State extends State<Camera360> with WidgetsBindingObserver, GridPainter {
  Camera360Cubit? _cubit;
  bool isTutorialCompleted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    _cubit?.handleAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ẩn thanh trạng thái và điều hướng
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    return BlocProvider(
      create: (context) {
        _cubit = Camera360Cubit(
          onCaptureEnded: widget.onCaptureEnded,
          onCameraChanged: widget.onCameraChanged,
          onProgressChanged: widget.onProgressChanged,
          userSelectedCameraKey: widget.userSelectedCameraKey,
          userNrPhotos: widget.userNrPhotos,
          userCapturedImageWidth: widget.userCapturedImageWidth,
          userCapturedImageQuality: widget.userCapturedImageQuality,
          userDeviceVerticalCorrectDeg: widget.userDeviceVerticalCorrectDeg,
          userLoadingText: widget.userLoadingText,
          userHelperText: widget.userHelperText,
          userHelperTiltLeftText: widget.userHelperTiltLeftText,
          userHelperTiltRightText: widget.userHelperTiltRightText,
        );
        return _cubit!;
      },
      child: BlocConsumer<Camera360Cubit, Camera360State>(
        listener: (context, state) async {
    if (state.captureComplete && !state.hasShownBottomSheet && ModalRoute.of(context)?.isCurrent == true) {
      // Đặt hasShownBottomSheet = true ngay lập tức
      context.read<Camera360Cubit>().emit(state.copyWith(hasShownBottomSheet: true));

      showStopNotifyBottomSheet(
        context: context,
        images: state.capturedImages.map((image) => File(image.path).readAsBytesSync()).toList(), // Chuyển đổi đồng bộ để nhanh hơn
        cameras: state.cameras,
        cameraController: state.controller!,
      ).then((result) {
        if (result == 'Retry') {
          context.read<Camera360Cubit>().restartApp(reason: "Retry được chọn từ bottom sheet");
        } else if (result == 'Complete') {
          // Không cần làm gì, LoadingScreen sẽ xử lý
        }
      });
    }
  },
        builder: (context, state) {
          // Hiển thị loading nếu camera chưa sẵn sàng
          if (!state.isReady || !state.isInitialized || state.controller == null) {
            return widget.cameraNotReadyContent ?? const Center(child: CircularProgressIndicator());
          }

          return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              double containerWidth = constraints.maxWidth;
              double containerHeight = constraints.maxHeight;

              // Tính toán góc xoay thiết bị
              double deviceVerticalDeg = double.parse(degrees(state.absoluteOrientation.y).toStringAsFixed(1));
              double deviceHorizontalDeg = double.parse(
                  (360 - degrees(state.absoluteOrientation.x + state.absoluteOrientation.z) % 360).toStringAsFixed(1));
              double deviceRotationDeg = double.parse(degrees(state.absoluteOrientation.z).toStringAsFixed(1));

              if (state.firstPhotoTaken) {
                context.read<Camera360Cubit>().updateDeviceOrientation(
                      deviceVerticalDeg: deviceVerticalDeg,
                      deviceHorizontalDeg: deviceHorizontalDeg,
                      deviceRotationDeg: deviceRotationDeg,
                      containerWidth: containerWidth,
                      containerHeight: containerHeight,
                    );
              }

              bool isDeviceRotationCorrect = context.read<Camera360Cubit>().checkDeviceRotation(deviceRotationDeg);
              double centeredDotPosX =
                  (containerWidth * state.targetCenteredDotPosX) - Camera360State.centeredDotRadius - Camera360State.centeredDotBorder;
              double centeredDotPosY =
                  (containerHeight * state.targetCenteredDotPosY) - Camera360State.centeredDotRadius - Camera360State.centeredDotBorder;
              double helperDotPosX = state.firstPhotoTaken
                  ? (state.horizontalMovementNeeded >= 0 ? state.horizontalMovementNeeded : -state.horizontalMovementNeeded)
                  : containerWidth * state.targetCenteredDotPosX - Camera360State.helperDotRadius;
              double helperDotPosY = context
                  .read<Camera360Cubit>()
                  .updateHelperDotVerticalPosition(deviceVerticalDeg, containerHeight);

              var centeredDotColor = state.deviceInCorrectPosition ? Colors.white.withOpacity(0.7) : Colors.transparent;
              var helperDotColor = state.deviceInCorrectPosition ? Colors.white : const Color(0xFF00284B);

              return Scaffold(
                backgroundColor: Colors.black,
                body: state.nrPhotosTaken < state.nrPhotos || state.captureComplete
                    ? Stack(
                        children: [
                          Center(
                            child: GestureDetector(
                              onTapDown: (details) async {
                                try {
                                  final tapPosition = details.localPosition;
                                  final x = tapPosition.dx / containerWidth;
                                  final y = tapPosition.dy / containerHeight;

                                  await state.controller!.setFocusPoint(Offset(x, y));
                                  await state.controller!.setFocusMode(FocusMode.auto);
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Lỗi khi đặt điểm lấy nét')),
                                  );
                                }
                              },
                              child: Stack(
                                children: [
                                  CameraPreview(state.controller!),
                                  gridPainter(),
                                ],
                              ),
                            ),
                          ),

                          // Thanh cân bằng khi chụp thủ công
                          if (state.manualCapture && !state.firstPhotoTaken)
                            BalanceBarIndicator(
                              containerWidth: containerWidth,
                              containerHeight: containerHeight,
                              deviceRotationDeg: deviceRotationDeg,
                              isDeviceRotationCorrect: isDeviceRotationCorrect,
                              deviceInCorrectPosition: state.deviceInCorrectPosition,
                              firstPhotoTaken: state.firstPhotoTaken,
                              onTutorialCompleted: () {
                                setState(() {
                                  isTutorialCompleted = true;
                                });
                              },
                            ),

                          // Nút chụp ảnh thủ công
                          if (state.manualCapture && !state.firstPhotoTaken)
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: GestureDetector(
                                  onTap: () {
                                    context.read<Camera360Cubit>().manualTakePicture();
                                  },
                                  child: SvgPicture.asset(
                                    'packages/flutter_plugin_camera360/lib/assets/images/Oval.svg',
                                    width: 75,
                                    height: 75,
                                  ),
                                ),
                              ),
                            ),

                          // Thanh trên cùng (nút quay lại, chọn camera, loading)
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.only(
                                top: MediaQuery.of(context).padding.top + 5,
                              ),
                              color: Colors.black.withOpacity(0.4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 12),
                                    child: GestureDetector(
                                      onTap: () async {
                                        await context.read<Camera360Cubit>().deletePanoramaImages();
                                        context.read<Camera360Cubit>().restartApp(
                                              reason: "Nút quay lại được nhấn",
                                              clearCache: true,
                                            );
                                      },
                                      child: const Icon(
                                        Icons.arrow_back,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                    ),
                                  ),
                                  if (state.takingPicture || state.isWaitingToTakePhoto)
                                    Padding(
                                      padding: EdgeInsets.only(right: 10),
                                      child: Lottie.asset(
                                        'packages/flutter_plugin_camera360/lib/assets/lotte/Animation-1747120515158.json',
                                        width: 75,
                                        height: 75,
                                      ),
                                    ),
                                  // Bỏ comment nếu muốn bật chọn camera
                                  // if (widget.cameraSelectorShow)
                                  //   CameraSelector(
                                  //     cameras: state.cameras,
                                  //     selectedCameraKey: state.selectedCameraKey,
                                  //     infoPopUpContent: widget.cameraSelectorInfoPopUpContent,
                                  //     infoPopUpShow: widget.cameraSelectorInfoPopUpShow,
                                  //     onCameraChanged: (cameraKey) {
                                  //       context.read<Camera360Cubit>().selectCamera(cameraKey);
                                  //     },
                                  //   ),
                                ],
                              ),
                            ),
                          ),

                          // Thanh dưới cùng (hiển thị tiến trình và nút dừng)
                          if (state.firstPhotoTaken)
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Container(
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: 80,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Flexible(
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const SizedBox(width: 16),
                                              Text(
                                                "${state.progressPercentage}%",
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () async {
                                            if (state.capturedImages.isNotEmpty &&
                                                ModalRoute.of(context)?.isCurrent == true) {
                                              // Chuyển XFile thành Uint8List
                                              List<Uint8List> imageBytes = [];
                                              for (var image in state.capturedImages) {
                                                final bytes = await File(image.path).readAsBytes();
                                                imageBytes.add(bytes);
                                              }

                                              showStopNotifyBottomSheet(
                                                context: context,
                                                images: imageBytes,
                                                cameras: state.cameras,
                                                cameraController: state.controller!,
                                              ).then((result) {
                                                if (result == 'Retry') {
                                                  context
                                                      .read<Camera360Cubit>()
                                                      .restartApp(reason: "Retry được chọn từ bottom sheet");
                                                } else if (result == 'Complete') {
                                                  // Không gọi restartApp, để LoadingScreen xử lý
                                                }
                                              });
                                            }
                                          },
                                          highlightColor: Colors.blue.withOpacity(0.3),
                                          splashColor: Colors.blue.withOpacity(0.3),
                                          child: SvgPicture.asset(
                                            'packages/flutter_plugin_camera360/lib/assets/images/Oval.svg',
                                            width: 75,
                                            height: 75,
                                          ),
                                        ),
                                        Flexible(
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: 16,
                                                height: 16,
                                                margin: const EdgeInsets.only(right: 6),
                                              ),
                                              Text(
                                                "${state.nrPhotosTaken}/${state.nrPhotos}",
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          // Văn bản hướng dẫn khi chưa chụp ảnh đầu tiên
                          if (state.firstPhotoTaken)
                            HelperText(
                              shown: state.capturedImages.isEmpty &&
                                  (!state.helperDotVerticalInPos || !state.helperDotIsHorizontalInPos),
                              helperText: state.helperText,
                            ),

                          // Văn bản hướng dẫn khi cần điều chỉnh góc xoay
                          if (state.firstPhotoTaken)
                            HelperText(
                              shown: state.helperDotVerticalInPos &&
                                  state.helperDotIsHorizontalInPos &&
                                  !isDeviceRotationCorrect,
                              helperText: context.read<Camera360Cubit>().checkLeftDeviceRotation(deviceRotationDeg)
                                  ? state.helperTiltLeftText
                                  : state.helperTiltRightText,
                            ),

                          // Hiển thị điểm định hướng và trợ giúp
                          if (state.firstPhotoTaken || isTutorialCompleted)
                            OrientationHelpers(
                              helperDotPosX: helperDotPosX,
                              helperDotPosY: helperDotPosY,
                              helperDotRadius: Camera360State.helperDotRadius,
                              helperDotColor: helperDotColor,
                              centeredDotPosX: centeredDotPosX,
                              centeredDotRadius: Camera360State.centeredDotRadius,
                              centeredDotPosY: centeredDotPosY,
                              centeredDotBorder: Camera360State.centeredDotBorder,
                              centeredDotColor: centeredDotColor,
                              deviceInCorrectPosition: state.deviceInCorrectPosition,
                              isDeviceRotationCorrect: isDeviceRotationCorrect,
                              deviceRotationDeg: deviceRotationDeg,
                              isWaitingToTakePhoto: state.isWaitingToTakePhoto,
                              timeToWaitBeforeTakingPicture: state.timeToWaitBeforeTakingPicture,
                              firstPhotoTaken: state.firstPhotoTaken,
                              isTutorialCompleted: isTutorialCompleted,
                            ),
                        ],
                      )
                    : Center(
                        child: Text(
                          state.loadingText,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
              );
            },
          );
        },
      ),
    );
  }
}