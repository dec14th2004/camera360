import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CameraSelector extends StatefulWidget {
  final List<CameraDescription> cameras;
  final int selectedCameraKey;
  final bool infoPopUpShow;
  final Widget? infoPopUpContent;
  final void Function(int)? onCameraChanged;

  const CameraSelector({
    super.key,
    required this.cameras,
    required this.selectedCameraKey,
    this.infoPopUpShow = true,
    this.infoPopUpContent,
    this.onCameraChanged,
  });

  @override
  State<CameraSelector> createState() => _CameraSelectorState();
}

class _CameraSelectorState extends State<CameraSelector> {
  late List<String> cameraKeys;
  bool infoPopUpShowValue = false;
  Widget? infoPopUpContentValue;
  late SharedPreferences prefs;

  void cameraChanged(int cameraKey) {
    widget.onCameraChanged?.call(cameraKey);
  }

  void hideHelperPopUp() {
    setState(() {
      infoPopUpShowValue = false;
    });
    prefs.setBool('infoPopUpShowValue', false);
  }

  Future<void> initSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      infoPopUpShowValue = prefs.getBool('infoPopUpShowValue') ?? widget.infoPopUpShow;
    });
  }

  @override
  void initState() {
    super.initState();
    // Validate selectedCameraKey
    int validCameraKey = widget.selectedCameraKey;
    if (validCameraKey < 0 || validCameraKey >= widget.cameras.length) {
      validCameraKey = 0;
    }

    // Populate cameraKeys based on available cameras
    cameraKeys = List.generate(widget.cameras.length, (index) => index.toString());

    infoPopUpContentValue = widget.infoPopUpContent ??
        const Column(
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
        );

    initSharedPreferences();
  }

  @override
  Widget build(BuildContext context) {
    // Ensure selectedCameraKey is valid
    String selectedValue = (widget.selectedCameraKey < widget.cameras.length && widget.selectedCameraKey >= 0)
        ? widget.selectedCameraKey.toString()
        : '0';

    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Helper Popup
            if (infoPopUpShowValue)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Container(
                      constraints: const BoxConstraints(maxWidth: 400),
                      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: infoPopUpContentValue,
                    ),
                    // ClipPath(
                    //   clipper: TriangleClipper(),
                    //   child: Container(
                    //     color: Colors.black.withOpacity(0.8),
                    //     height: 10,
                    //     width: 20,
                    //   ),
                    // ),
                  ],
                ),
              ),

            // Dropdown Button
            Container(
              padding: const EdgeInsets.only(left: 10, right: 20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: DropdownButton<String>(
                onTap: hideHelperPopUp,
                dropdownColor: Colors.black.withOpacity(0.8),
                underline: const SizedBox(),
                // icon: const ImageIcon(
                //   AssetImage(
                //     "images/arrow-down.png",
                //     package: 'camera_360',
                //   ),
                //   size: 10,
                // ),
                onChanged: (String? value) {
                  if (value != null) {
                    cameraChanged(int.parse(value));
                  }
                },
                value: selectedValue,
                items: cameraKeys.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    alignment: AlignmentDirectional.center,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        'Camera $value',
                        style: const TextStyle(color: Color(0xff999999)),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}