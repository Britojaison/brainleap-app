import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

import '../services/api_service.dart';
import 'crop_preview_screen.dart';
import 'processing_screen.dart';

class CameraOverlayScreen extends StatefulWidget {
  const CameraOverlayScreen({super.key});

  static const double _focusFrameWidthFraction = 0.84;
  static const double _focusFrameHeightFraction = 0.5;

  static Future<String?> show(BuildContext context) {
    return Navigator.of(context).push<String>(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const CameraOverlayScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        fullscreenDialog: true,
      ),
    );
  }

  @override
  State<CameraOverlayScreen> createState() => _CameraOverlayScreenState();
}

class _CameraOverlayScreenState extends State<CameraOverlayScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  CameraDescription? _currentCamera;
  bool _isControllerReady = false;
  bool _flashEnabled = false;
  bool _isProcessing = false;
  String? _initializationError;
  late final ApiService _apiService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _apiService = ApiService();
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !_isControllerReady) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      controller.dispose();
      _controller = null;
      _isControllerReady = false;
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera(_currentCamera);
    }
  }

  Future<void> _initializeCamera([CameraDescription? description]) async {
    await _controller?.dispose();
    setState(() {
      _isControllerReady = false;
      _initializationError = null;
      _flashEnabled = false;
    });

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw StateError('No available cameras on this device.');
      }
      final selectedCamera = description ??
          cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.back,
            orElse: () => cameras.first,
          );
      final controller = CameraController(
        selectedCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      await controller.initialize();

      if (!mounted) return;

      setState(() {
        _controller = controller;
        _currentCamera = selectedCamera;
        _isControllerReady = true;
      });
    } catch (error) {
      setState(() {
        _initializationError = error.toString();
      });
    }
  }

  Future<void> _toggleFlash() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    final newState = !_flashEnabled;

    try {
      await controller.setFlashMode(
        newState ? FlashMode.torch : FlashMode.off,
      );
      if (!mounted) return;
      setState(() => _flashEnabled = newState);
    } on CameraException catch (error) {
      if (!mounted) return;
      setState(() => _flashEnabled = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to toggle flash: $error')),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _flashEnabled = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unexpected flash error: $error')),
      );
    }
  }

  Future<void> _handleCapture() async {
    final controller = _controller;
    if (!mounted || controller == null || !controller.value.isInitialized) {
      return;
    }
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    late final Uint8List capturedBytes;

    try {
      final file = await controller.takePicture();
      capturedBytes = await File(file.path).readAsBytes();
      unawaited(File(file.path).delete());
    } catch (error) {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to capture photo: $error')),
      );
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() => _isProcessing = false);

    final croppedBytes = await CropPreviewScreen.show(
      context,
      imageBytes: capturedBytes,
    );

    if (!mounted) {
      return;
    }

    final primaryBytes = croppedBytes ?? capturedBytes;
    final navigator = Navigator.of(context);
    setState(() => _isProcessing = true);

    bool processingVisible = false;

    try {
      navigator.push(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => const ProcessingScreen(),
        ),
      );
      processingVisible = true;

      final preparedPrimary = _compressForUpload(primaryBytes);
      var recognizedText = await _apiService.extractQuestion(preparedPrimary);

      if (recognizedText.isEmpty && croppedBytes != null) {
        final preparedFallback = _compressForUpload(capturedBytes);
        recognizedText = await _apiService.extractQuestion(preparedFallback);
      }

      if (processingVisible && navigator.canPop()) {
        navigator.pop();
        processingVisible = false;
      }

      if (recognizedText.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'We couldn\'t detect any text. Try improving lighting, realigning the frame, or adjusting the crop.',
            ),
          ),
        );
        return;
      }

      navigator.pop(recognizedText);
    } catch (error) {
      if (processingVisible && navigator.canPop()) {
        navigator.pop();
      }
      if (!mounted) return;
      final message = error.toString().replaceFirst('Exception:', '').trim();
      final displayMessage = message.split('\n').first;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            displayMessage.isEmpty
                ? 'Text extraction failed. Please try again.'
                : 'Text extraction failed: $displayMessage',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Uint8List _compressForUpload(Uint8List bytes) {
    try {
      final original = img.decodeImage(bytes);
      if (original == null) return bytes;
      final maxDimension = 1280;
      img.Image processed = original;
      if (original.width > maxDimension || original.height > maxDimension) {
        processed = img.copyResize(original, width: maxDimension);
      }
      return Uint8List.fromList(img.encodeJpg(processed, quality: 85));
    } catch (_) {
      return bytes;
    }
  }

  Future<void> _openGallery() async {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gallery import coming soon.')),
    );
  }

  Widget _buildCameraLayer() {
    if (_initializationError != null) {
      return _CameraErrorState(
        message: _initializationError!,
        onRetry: () => _initializeCamera(_currentCamera),
      );
    }

    final controller = _controller;
    if (!_isControllerReady || controller == null) {
      return const _CameraLoadingState();
    }

    return CameraPreview(controller);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(child: _buildCameraLayer()),
          const Positioned.fill(child: _CameraFocusOverlay()),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: SafeArea(
              minimum: const EdgeInsets.only(left: 16, top: 16, right: 16),
              child: Align(
                alignment: Alignment.topLeft,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 22,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_isProcessing)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.35),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),
          _BottomControls(
            flashEnabled: _flashEnabled,
            onFlashToggle: _toggleFlash,
            onGalleryTap: _openGallery,
            onCaptureTap: _handleCapture,
          ),
        ],
      ),
    );
  }
}

class _CameraFocusOverlay extends StatelessWidget {
  const _CameraFocusOverlay();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width =
            constraints.maxWidth * CameraOverlayScreen._focusFrameWidthFraction;
        final height =
            constraints.maxHeight * CameraOverlayScreen._focusFrameHeightFraction;
        final left = (constraints.maxWidth - width) / 2;
        final top = (constraints.maxHeight - height) / 2;
        final focusRect = Rect.fromLTWH(left, top, width, height);

        return Stack(
          fit: StackFit.expand,
          children: [
            ClipPath(
              clipper: _OutsideFocusClipper(focusRect),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
                child: Container(
                  color: Colors.black.withOpacity(0.45),
                ),
              ),
            ),
            Positioned(
              left: focusRect.left,
              top: focusRect.top,
              width: focusRect.width,
              height: focusRect.height,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.85),
                    width: 3,
                  ),
                  color: Colors.white.withOpacity(0.04),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.45),
                      blurRadius: 30,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: focusRect.left,
              width: focusRect.width,
              top: max(focusRect.top - 48, 16.0),
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Text(
                    'Align your question inside the frame',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _OutsideFocusClipper extends CustomClipper<Path> {
  _OutsideFocusClipper(this.focusRect);

  final Rect focusRect;

  @override
  Path getClip(Size size) {
    final outer = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final inner = Path()
      ..addRRect(
        RRect.fromRectAndRadius(focusRect, const Radius.circular(28)),
      );
    return Path.combine(PathOperation.difference, outer, inner);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}

class _CameraLoadingState extends StatelessWidget {
  const _CameraLoadingState();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }
}

class _CameraErrorState extends StatelessWidget {
  const _CameraErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}


class _BottomControls extends StatelessWidget {
  const _BottomControls({
    required this.flashEnabled,
    required this.onFlashToggle,
    required this.onGalleryTap,
    required this.onCaptureTap,
  });

  final bool flashEnabled;
  final VoidCallback onFlashToggle;
  final VoidCallback onGalleryTap;
  final VoidCallback onCaptureTap;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SafeArea(
        minimum: const EdgeInsets.only(bottom: 16),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(120),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
              child: Container(
                width: 260,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(120),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.22),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 24,
                      offset: const Offset(0, -6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 26),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _ControlIconButton(
                      icon: flashEnabled
                          ? Icons.flash_on_rounded
                          : Icons.flash_off_rounded,
                      onTap: onFlashToggle,
                      isActive: flashEnabled,
                    ),
                    _ShutterButton(onTap: onCaptureTap),
                    _ControlIconButton(
                      icon: Icons.photo_library_rounded,
                      onTap: onGalleryTap,
                      isActive: false,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ControlIconButton extends StatelessWidget {
  const _ControlIconButton({
    required this.icon,
    required this.onTap,
    required this.isActive,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(isActive ? 0.36 : 0.22),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(isActive ? 0.7 : 0.35),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.white : Colors.white.withOpacity(0.85),
          size: 26,
        ),
      ),
    );
  }
}

class _ShutterButton extends StatelessWidget {
  const _ShutterButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 86,
        height: 86,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFFECECEC),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          border: Border.all(color: Colors.white.withOpacity(0.85), width: 4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 26,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.9), width: 3),
          ),
        ),
      ),
    );
  }
}

