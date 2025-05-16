import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

void initBalanceBarTutorial({
  required BuildContext context,
  required GlobalKey circleKey,
  required GlobalKey barKey,
  required bool showTutorial,
  VoidCallback? onFinish,
  Function(TargetFocus)? onClickTarget,
  VoidCallback? onSkip,
}) {
  if (!showTutorial) return;

  final tutorial = TutorialCoachMark(
    targets: [
      TargetFocus(
        identify: "circle",
        keyTarget: circleKey,
        shape: ShapeLightFocus.Circle,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "This is the photo alignment ring!",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Text(
                      "Align the blue circle to the center of this ring to take a photo.",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: ElevatedButton(
                      onPressed: () {
                        controller.next();
                      },
                      style: ElevatedButton.styleFrom(

                        foregroundColor: Colors.white,
                        backgroundColor: Color(0xFF00284B),
                      ),
                      child: const Text("Next"),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: "balance_bar",
        keyTarget: barKey,
        shape: ShapeLightFocus.RRect,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "This is the alignment bar!",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Text(
                      "The bar tilts according to your phone's angle. Adjust it to make it level.",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: ElevatedButton(
                      onPressed: () {
                        controller.next();
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Color(0xFF00284B),
                      ),
                      child: const Text("Finish"),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    ],
    onFinish: () {
      print("Tutorial completed");
      onFinish?.call();
    },
    onClickTarget: (target) {
      print("Clicked on: ${target.identify}");
      onClickTarget?.call(target);
    },
    onSkip: () {
      print("Tutorial skipped");
      onSkip?.call();
      return true;
    },
  );

  tutorial.show(context: context);
}