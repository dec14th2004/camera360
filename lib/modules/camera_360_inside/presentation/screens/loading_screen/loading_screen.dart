import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../domain/use_cases/upload_image_usecase.dart';
import '../../../../../helper/image_panorama_controller.dart';
import '../../cubit/video_loading/loading_cubit.dart';
import '../../cubit/video_loading/loading_state.dart';
import '../image_view_screen/image_view_screen.dart';

class LoadingScreen extends StatelessWidget {
  final List<Uint8List> images;
  const LoadingScreen({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    // Hide status bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    return BlocProvider(
      create:
          (context) => LoadingCubit(
            images: images,
            uploadImageUseCase: getIt.get<UploadImageUsecase>(),
          )..uploadImages(images),
      child: BlocListener<LoadingCubit, LoadingState>(
        listener: (context, state) {
          if (state.byteStream.isNotEmpty) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder:
                    (context) => ImageViewScreen(byteStream: state.byteStream),
              ),
            );
          } else if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: Colors.red,
              ),
            );
            // Quay lại màn hình trước (hoặc xử lý theo yêu cầu)
            Future.delayed(Duration(seconds: 2), () {
              Navigator.pop(context);
            });
          }
        },
        child: WillPopScope(
          onWillPop: () async {
            // Restore status bar when leaving the screen
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
            return true;
          },
          child: Scaffold(
            backgroundColor: const Color(0xFFFAFAFA),
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 1,
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              title: const Text(
                '360 ROOM SCAN',
                style: TextStyle(
                  color: Color(0xFF00294D),
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  fontFamily: 'Inter',
                ),
              ),
            ),
            body: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  SizedBox(height: 16),
                                  Text(
                                    '360 Rendering',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF00284B),
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Please wait...',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF00284B),
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                            2,
                                        child: Lottie.asset(
                                          'packages/flutter_plugin_camera360/lib/assets/lotte/TFOYB36zfH.json',
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                      SvgPicture.asset(
                                        'packages/flutter_plugin_camera360/lib/assets/images/Icons.svg',
                                        width:
                                            MediaQuery.of(context).size.width *
                                            0.35,
                                        fit: BoxFit.contain,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Creating 360 Room Image ...',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF688094),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 16,
                            ),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const Text(
                                  "Feel free to return to the homepage. We'll notify you when it's completed.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'Inter',
                                    color: Color(0xFF4E6A82),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF00284B),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 12,
                                    ),
                                    shape: const RoundedRectangleBorder(),
                                    minimumSize: const Size(
                                      double.infinity,
                                      48,
                                    ),
                                  ),
                                  child: const Text(
                                    'BACK TO HOME SCREEN',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
