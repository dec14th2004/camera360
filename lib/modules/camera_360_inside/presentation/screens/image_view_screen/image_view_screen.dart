import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:panorama_viewer/panorama_viewer.dart';

class ImageViewScreen extends StatefulWidget {
  final Uint8List byteStream;

  const ImageViewScreen({super.key, required this.byteStream});

  @override
  State<ImageViewScreen> createState() => _ImageViewScreenState();
}

class _ImageViewScreenState extends State<ImageViewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(title: const Text("Processed Image")),
      body: Stack(
        children: [
          PanoramaViewer(
            minLatitude: 0,
            maxLatitude: 0,
            sensorControl: SensorControl.none,
            child: Image.memory(widget.byteStream),
          ),
          Container(height: 100, color: Colors.white),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(height: 100, color: Colors.white),
          ),
        ],
      ),
    );
  }
}