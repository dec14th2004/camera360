import 'package:flutter/material.dart';
import 'dart:math' show pi;
import '../cubit/camera_360_cubit/camera_360_state.dart';
import 'balance_bar_tutorial.dart';

class BalanceBarIndicator extends StatefulWidget {
  final double containerWidth;
  final double containerHeight;
  final double deviceRotationDeg;
  final bool isDeviceRotationCorrect;
  final bool deviceInCorrectPosition;
  final bool firstPhotoTaken;
  final VoidCallback? onTutorialCompleted; // Thêm callback
  final bool readyCapture;

  const BalanceBarIndicator({
    super.key,
    required this.containerWidth,
    required this.containerHeight,
    required this.deviceRotationDeg,
    required this.isDeviceRotationCorrect,
    required this.deviceInCorrectPosition,
    required this.firstPhotoTaken,
    this.onTutorialCompleted,
    this.readyCapture = true,
  });

  @override
  _BalanceBarIndicatorState createState() => _BalanceBarIndicatorState();
}

class _BalanceBarIndicatorState extends State<BalanceBarIndicator> {
  final GlobalKey _circleKey = GlobalKey();
  final GlobalKey _barKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initBalanceBarTutorial(
        context: context,
        circleKey: _circleKey,
        barKey: _barKey,
        showTutorial: !widget.firstPhotoTaken,
        onFinish: () {
          widget.onTutorialCompleted?.call(); // Gọi callback khi hoàn thành
        },
        onSkip: () {
          widget.onTutorialCompleted?.call(); // Gọi callback khi bỏ qua
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.firstPhotoTaken) return const SizedBox.shrink();

    final double circleSize = 100;
    final double bubbleSize = 20;
    final double radius = (circleSize - bubbleSize) / 2;

    const maxTilt = Camera360State.helperDotRotationTolerance;
    final double angleRad = (widget.deviceRotationDeg / maxTilt).clamp(-1.0, 1.0) * (pi / 24);

    final bubbleColor = widget.isDeviceRotationCorrect ? Colors.yellow : Colors.white;

    return Center(
      child: SizedBox(
        width: circleSize,
        height: circleSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              key: _circleKey,
              width: circleSize,
              height: circleSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.3),
                border: Border.all(color: Colors.white, width: 4),
              ),
            ),
            AnimatedBuilder(
              animation: AlwaysStoppedAnimation(widget.deviceRotationDeg),
              builder: (context, child) {
                return Transform.rotate(
                  angle: -angleRad,
                  child: Container(
                    key: _barKey,
                    width: bubbleSize * 5,
                    height: bubbleSize / 4,
                    decoration: BoxDecoration(
                      color: bubbleColor,
                      borderRadius: BorderRadius.circular(0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            // if (!widget.isDeviceRotationCorrect)
            //   Positioned(
            //     bottom: 20,
            //     child: Text(
            //       widget.deviceRotationDeg > 0 ? "Tilt Left" : "Tilt Right",
            //       style: const TextStyle(
            //         color: Colors.white,
            //         fontSize: 14,
            //         fontWeight: FontWeight.bold,
            //       ),
            //     ),
            //   ),
          ],
        ),
      ),
    );
  }
}