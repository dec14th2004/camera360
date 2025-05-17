import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_plugin_camera360/modules/camera_360_inside/presentation/screens/loading_screen/loading_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:io';

import '../cubit/video_loading/loading_cubit.dart';
import '../cubit/video_stop_notify/stop_notify_cubit.dart';


Future<String?> showStopNotifyBottomSheet({
  required BuildContext context,
  required File videoFile,
  required List<CameraDescription> cameras,
  required CameraController cameraController,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16.0))),
    builder:
        (context) => BlocProvider(
          create: (context) => StopNotifyCubit(),
          child: Builder(
            builder:
                (newContext) => _StopNotifyBottomSheet(
                  context: newContext,
                  cameras: cameras,
                  cameraController: cameraController,
                ),
          ),
        ),
  );
}

class _StopNotifyBottomSheet extends StatelessWidget {
  final BuildContext context;
  final List<CameraDescription> cameras;
  final CameraController cameraController;

  const _StopNotifyBottomSheet({
    Key? key,
    required this.context,
    required this.cameras,
    required this.cameraController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return BlocListener<StopNotifyCubit, StopNotifyState>(
      listener: (context, state) {
        if (state is StopNotifyActionSelected) {
          Navigator.pop(context, state.action);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(16.0), topRight: Radius.circular(16.0)),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10.0, offset: Offset(0, -5))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset('packages/flutter_plugin_camera360/lib/assets/images/Icon.svg', width: 80, height: 80),
            const SizedBox(height: 16.0),
            const Text(
              'Complete the Video\n Recording',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Intel',
                fontSize: 30.0,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00294D),
              ),
            ),
            const SizedBox(height: 30.0),
            const Text(
              'Confirm your use of this video to create your \nimmersive 360 tour.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.0, color: Color(0xFF00284B)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                       // context.read<StopNotifyCubit>().selectRetry();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF00284B),
                        side: const BorderSide(color: Color(0xFF00284B), width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      ),
                      child: const Text('Retry', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoadingScreen(images: context.read<LoadingCubit>().images),
                          ),
                        );
                        context.read<StopNotifyCubit>().selectComplete();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00284B),
                        padding: const EdgeInsets.symmetric( vertical: 14),
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      ),
                      child: const Text(
                        'Complete',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
