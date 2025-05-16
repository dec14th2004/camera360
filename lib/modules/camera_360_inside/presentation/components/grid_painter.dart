import 'package:flutter/material.dart';

mixin GridPainter {
  Stack gridPainter() {
    return Stack(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(height: double.infinity, color: Color(0xFFFFFFFF), width: 1),
            SizedBox(width: 200),
            Container(height: double.infinity, color: Color(0xFFFFFFFF), width: 1),
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(height: 1, color: Color(0xFFFFFFFF), width: double.infinity),
            SizedBox(height: 200),
            Container(height: 1, color: Color(0xFFFFFFFF), width: double.infinity),
          ],
        ),
      ],
    );
  }
}