import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../cubit/control_overlay/control_overlay_cubit.dart';
import 'package:flutter_plugin_camera360/modules/camera_360_inside/presentation/screens/camera_360_record_screen/camera_360_record_screen.dart';
import '../../cubit/video_ready/video_ready_cubit.dart';

class VideoReadyScreen extends StatelessWidget {
  final ControlOverlayCubit controlOverlayCubit;
  final Future<void> Function(Map<String, dynamic>) onCaptureEnded;

  const VideoReadyScreen({required this.controlOverlayCubit,
     required this.onCaptureEnded
    , super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VideoReadyCubit, VideoReadyState>(
      builder: (context, state) {
        if (state is! VideoReadyInitialized) {
          return const Center(child: CircularProgressIndicator());
        }

        return Stack(
          children: [
            Camera360(onCaptureEnded: onCaptureEnded),
            Container(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              color: Colors.black.withValues(alpha: 0.7),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: SvgPicture.asset(
                            'packages/flutter_plugin_camera360/lib/assets/images/Button.svg',
                            width: 100,
                            height: 50,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      SvgPicture.asset(
                        'packages/flutter_plugin_camera360/lib/assets/images/IconReady.svg',
                        width: 165,
                        height: 165,
                      ),
                      const SizedBox(height: 50),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40.0),
                        child: Text(
                          'Keep the phone in a fixed position and record a video all around.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40.0),
                        child: Text(
                          'Holding your phone steady while rotating helps enhance the image quality during a 360 tour.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Inter'),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 85.0),
                        child: Text(
                          'Move closer to the door to start your first point in the 360 tour',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Inter'),
                        ),
                      ),
                      const SizedBox(height: 25),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Transform.translate(
                          offset: const Offset(0, -30),
                          child: ElevatedButton(
                            onPressed: () {
                              context.read<ControlOverlayCubit>().toggleOverlay();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Scaffold(
                                    body: Camera360(
                                      userLoadingText: "Preparing images...",
                                      userHelperText: "Point the camera at the dot",
                                      userSelectedCameraKey: state.cameras.isNotEmpty ? 0 : null,
                                      cameraSelectorShow: true,
                                      cameraSelectorInfoPopUpShow: true,
                                      cameraSelectorInfoPopUpContent: const Column(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(bottom: 10),
                                            child: Text(
                                              "Notice: This feature only works if your phone has a wide angle camera.",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Color(0xffDB4A3C),
                                              ),
                                            ),
                                          ),
                                          Text(
                                            "Select the camera with the widest viewing angle below.",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Color(0xffEFEFEF),
                                            ),
                                          ),
                                        ],
                                      ),
                                      onCaptureEnded: (data) async {
                                        debugPrint('Capture ended with result: $data');
                                        if (data['success'] == true) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Capture completed successfully!')),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Capture failed!')),
                                          );
                                        }
                                        Navigator.pop(context);
                                        return Future.value();
                                      },
                                      onCameraChanged: (cameraKey) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text("Camera changed to $cameraKey")),
                                        );
                                      },
                                      onProgressChanged: (newProgressPercentage) {
                                        debugPrint("'Camera360': Progress changed: $newProgressPercentage");
                                      },
                                      cameraNotReadyContent: const Center(child: CircularProgressIndicator()),
                                    ),
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFCD9B4B),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(99),
                                side: const BorderSide(color: Colors.white, width: 4),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                            ),
                            child: const Text(
                              'READY TO RECORD',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}