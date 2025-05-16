import 'package:flutter/material.dart';
import 'device_rotation.dart';

class OrientationHelpers extends StatefulWidget {
  final double helperDotPosX;
  final double helperDotPosY;
  final double helperDotRadius;
  final Color helperDotColor;
  final double centeredDotPosX;
  final double centeredDotPosY;
  final double centeredDotRadius;
  final double centeredDotBorder;
  final Color centeredDotColor;
  final bool deviceInCorrectPosition;
  final bool isDeviceRotationCorrect;
  final double deviceRotationDeg;
  final bool isWaitingToTakePhoto;
  final int timeToWaitBeforeTakingPicture;
  final bool firstPhotoTaken;
  final bool isTutorialCompleted;

  const OrientationHelpers({
    super.key,
    required this.helperDotPosX,
    required this.helperDotPosY,
    required this.helperDotRadius,
    required this.helperDotColor,
    required this.centeredDotPosX,
    required this.centeredDotRadius,
    required this.centeredDotPosY,
    required this.centeredDotBorder,
    required this.centeredDotColor,
    required this.deviceInCorrectPosition,
    required this.isDeviceRotationCorrect,
    required this.deviceRotationDeg,
    required this.isWaitingToTakePhoto,
    required this.timeToWaitBeforeTakingPicture,
    required this.firstPhotoTaken,
    required this.isTutorialCompleted,
  });

  @override
  State<OrientationHelpers> createState() => _OrientationHelpersState();
}

class _OrientationHelpersState extends State<OrientationHelpers>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.timeToWaitBeforeTakingPicture),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void didUpdateWidget(OrientationHelpers oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.deviceInCorrectPosition && oldWidget.deviceInCorrectPosition) {
      _controller.stop();
      _controller.reset();
      return;
    }
    if (widget.isWaitingToTakePhoto &&
        !oldWidget.isWaitingToTakePhoto &&
        widget.deviceInCorrectPosition) {
      _controller.reset();
      _controller.forward();
    } else if (!widget.isWaitingToTakePhoto && oldWidget.isWaitingToTakePhoto) {
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Transform.translate(
          offset: Offset(widget.helperDotPosX, widget.helperDotPosY),
          child: Container(
            width: widget.helperDotRadius * 2.5,
            height: widget.helperDotRadius * 2.5,
            decoration: BoxDecoration(
              color: widget.helperDotColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF00284B).withOpacity(0.5),
                  spreadRadius: 3,
                  blurRadius: 7,
                  offset: Offset(0, 4),
                ),
              ],
            ),
          ),
        ),

        if (widget.firstPhotoTaken)
          Transform.translate(
            offset: Offset(widget.centeredDotPosX, widget.centeredDotPosY),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      width: widget.centeredDotBorder + 1,
                      color: Colors.white,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: widget.centeredDotRadius,
                    backgroundColor: widget.centeredDotColor,
                  ),
                ),
                if (widget.isWaitingToTakePhoto &&
                    widget.isDeviceRotationCorrect &&
                    widget.isTutorialCompleted)
                  SizedBox(
                    width: widget.centeredDotRadius * 2,
                    height: widget.centeredDotRadius * 2,
                    child: AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return CircularProgressIndicator(
                          value: _animation.value,
                          color: Color(0xFF00284B),
                          strokeWidth: 7,
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

        if (!widget.isDeviceRotationCorrect && widget.firstPhotoTaken)
          DeviceRotation(deviceRotation: widget.deviceRotationDeg),
      ],
    );
  }
}