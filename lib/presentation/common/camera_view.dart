import 'dart:developer' as dev;
import 'dart:io';

import 'package:ahealth/common/spring_button_widget.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});
  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  Future<void>? _initFuture;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
  final status = await Permission.camera.request();
  if (!status.isGranted) {
    if (mounted) Navigator.pop(context);
    return;
  }
  final cameras = await availableCameras();
  _controller = CameraController(cameras.first, ResolutionPreset.high);
  _initFuture = _controller!.initialize();
  if (mounted) setState(() {});
}

  Future<void> _capture() async {
    try {
      final file = await _controller!.takePicture();
      if (mounted) Navigator.pop(context, File(file.path));
    } catch (e, s) {
      dev.log('Exception', error: e, stackTrace: s);
    }
  }

  Future<void> _pickFromGallery() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null && mounted) Navigator.pop(context, File(picked.path));
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _initFuture == null
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder(
              future: _initFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    CameraPreview(_controller!),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        height: 170,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            Colors.black,
                            Colors.transparent,
                          ],begin: AlignmentGeometry.bottomCenter,end: AlignmentGeometry.topCenter)
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 32,
                      left: 24,
                      child: IconButton(
                        icon: const Icon(Icons.photo_library, color: Colors.white, size: 32),
                        onPressed: _pickFromGallery,
                      ),
                    ),
                    Positioned(
                      bottom: 24,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: SpringButton(
                          SpringButtonType.withOpacity,
                          onTap: () => _capture(),
                          uiChild: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: CircleAvatar(backgroundColor: Colors.white,),
                            ),

                          ),
                        ),
                      ),
                    ),
                    
                  ],
                );
              },
            ),
    );
  }
}