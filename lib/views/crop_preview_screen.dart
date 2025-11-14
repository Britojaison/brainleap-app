import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

class CropPreviewScreen extends StatefulWidget {
  const CropPreviewScreen({
    super.key,
    required this.imageBytes,
  });

  final Uint8List imageBytes;

  static Future<Uint8List?> show(
    BuildContext context, {
    required Uint8List imageBytes,
  }) {
    return Navigator.of(context).push<Uint8List>(
      PageRouteBuilder(
        fullscreenDialog: true,
        pageBuilder: (_, __, ___) => CropPreviewScreen(imageBytes: imageBytes),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  State<CropPreviewScreen> createState() => _CropPreviewScreenState();
}

class _CropPreviewScreenState extends State<CropPreviewScreen> {
  final GlobalKey<_CropCanvasState> _cropKey = GlobalKey<_CropCanvasState>();

  Rect? _normalizedRect;
  bool _isApplying = false;

  Future<void> _handleReset() async {
    _cropKey.currentState?.clearSelection();
    setState(() => _normalizedRect = null);
  }

  Future<void> _handleApply() async {
    if (_isApplying) return;
    setState(() => _isApplying = true);

    try {
      final cropped = await _cropImage(widget.imageBytes, _normalizedRect);
      if (!mounted) return;
      Navigator.of(context).pop(cropped);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to crop image: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isApplying = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _Header(onCancel: () => Navigator.of(context).pop()),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: _CropCanvas(
                  key: _cropKey,
                  imageBytes: widget.imageBytes,
                  onSelectionChanged: (rect) {
                    setState(() => _normalizedRect = rect);
                  },
                ),
              ),
            ),
            _Footer(
              canReset: _normalizedRect != null,
              isApplying: _isApplying,
              onReset: _handleReset,
              onApply: _handleApply,
            ),
          ],
        ),
      ),
    );
  }

  Future<Uint8List> _cropImage(Uint8List bytes, Rect? normalizedRect) async {
    if (normalizedRect == null) {
      return bytes;
    }

    final image = img.decodeImage(bytes);
    if (image == null) return bytes;

    final left = (normalizedRect.left.clamp(0.0, 1.0) * image.width).round();
    final top = (normalizedRect.top.clamp(0.0, 1.0) * image.height).round();
    final right =
        (normalizedRect.right.clamp(0.0, 1.0) * image.width).round();
    final bottom =
        (normalizedRect.bottom.clamp(0.0, 1.0) * image.height).round();

    final width = (right - left).clamp(1, image.width - left);
    final height = (bottom - top).clamp(1, image.height - top);

    if (width < image.width * 0.05 || height < image.height * 0.05) {
      return bytes;
    }

    final cropped = img.copyCrop(
      image,
      x: left,
      y: top,
      width: width.toInt(),
      height: height.toInt(),
    );

    return Uint8List.fromList(img.encodeJpg(cropped, quality: 95));
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onCancel});

  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: onCancel,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: const Icon(Icons.close, color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Adjust your crop',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    required this.onReset,
    required this.onApply,
    required this.canReset,
    required this.isApplying,
  });

  final VoidCallback onReset;
  final VoidCallback onApply;
  final bool canReset;
  final bool isApplying;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: canReset ? onReset : null,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.white.withOpacity(0.4)),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Reset'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: isApplying ? null : onApply,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: isApplying
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Use Photo',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CropCanvas extends StatefulWidget {
  const _CropCanvas({
    super.key,
    required this.imageBytes,
    required this.onSelectionChanged,
  });

  final Uint8List imageBytes;
  final ValueChanged<Rect?> onSelectionChanged;

  @override
  State<_CropCanvas> createState() => _CropCanvasState();
}

class _CropCanvasState extends State<_CropCanvas> {
  Rect? _selection;
  Offset? _dragStart;
  img.Image? _decoded;
  Rect? _imageRect;

  @override
  void initState() {
    super.initState();
    _decoded = img.decodeImage(widget.imageBytes);
  }

  void clearSelection() {
    setState(() {
      _selection = null;
      _dragStart = null;
    });
    widget.onSelectionChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final maxHeight = constraints.maxHeight;
        final imageWidth = (_decoded?.width ?? 1).toDouble();
        final imageHeight = (_decoded?.height ?? 1).toDouble();
        final fitted = applyBoxFit(
          BoxFit.contain,
          Size(imageWidth, imageHeight),
          Size(maxWidth, maxHeight),
        );

        final renderWidth = fitted.destination.width;
        final renderHeight = fitted.destination.height;
        final offsetX = (maxWidth - renderWidth) / 2;
        final offsetY = (maxHeight - renderHeight) / 2;

        final imageRect =
            Rect.fromLTWH(offsetX, offsetY, renderWidth, renderHeight);
        _imageRect = imageRect;

        return Center(
          child: SizedBox(
            width: maxWidth,
            height: maxHeight,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanStart: (details) {
                if (!imageRect.contains(details.localPosition)) {
                  return;
                }
                final start = _clampToImage(details.localPosition);
                setState(() {
                  _dragStart = start;
                  _selection = Rect.fromLTWH(start.dx, start.dy, 0, 0);
                });
                _notifySelection();
              },
              onPanUpdate: (details) {
                if (_dragStart == null) return;
                final current = _clampToImage(details.localPosition);
                setState(() {
                  _selection = Rect.fromPoints(_dragStart!, current);
                });
                _notifySelection();
              },
              onPanEnd: (_) {
                _dragStart = null;
              },
              child: Stack(
                children: [
                  Positioned.fromRect(
                    rect: imageRect,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.memory(
                        widget.imageBytes,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _SelectionPainter(
                        imageRect: imageRect,
                        rect: _selection,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Offset _clampToImage(Offset input) {
    final rect = _imageRect ?? Rect.zero;
    return Offset(
      input.dx.clamp(rect.left, rect.right),
      input.dy.clamp(rect.top, rect.bottom),
    );
  }

  void _notifySelection() {
    if (_selection == null || _imageRect == null) {
      widget.onSelectionChanged(null);
      return;
    }

    final imageRect = _imageRect!;

    final selection = Rect.fromLTRB(
      _selection!.left.clamp(imageRect.left, imageRect.right),
      _selection!.top.clamp(imageRect.top, imageRect.bottom),
      _selection!.right.clamp(imageRect.left, imageRect.right),
      _selection!.bottom.clamp(imageRect.top, imageRect.bottom),
    );

    final normalized = Rect.fromLTRB(
      ((selection.left - imageRect.left) / imageRect.width).clamp(0.0, 1.0),
      ((selection.top - imageRect.top) / imageRect.height).clamp(0.0, 1.0),
      ((selection.right - imageRect.left) / imageRect.width).clamp(0.0, 1.0),
      ((selection.bottom - imageRect.top) / imageRect.height).clamp(0.0, 1.0),
    );

    final width = (normalized.right - normalized.left).abs();
    final height = (normalized.bottom - normalized.top).abs();

    if (width < 0.02 || height < 0.02) {
      widget.onSelectionChanged(null);
      return;
    }

    widget.onSelectionChanged(normalized);
  }
}

class _SelectionPainter extends CustomPainter {
  const _SelectionPainter({
    required this.imageRect,
    required this.rect,
  });

  final Rect imageRect;
  final Rect? rect;

  @override
  void paint(Canvas canvas, Size size) {
    final overlayPaint = Paint()
      ..color = Colors.black.withOpacity(0.55);

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), overlayPaint);

    final imagePath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(imageRect, const Radius.circular(24)),
      );

    canvas.saveLayer(Rect.largest, Paint());
    canvas.drawPath(imagePath, Paint()..blendMode = BlendMode.clear);
    canvas.restore();

    final framePaint = Paint()
      ..color = Colors.white.withOpacity(0.08);
    canvas.drawRRect(
      RRect.fromRectAndRadius(imageRect, const Radius.circular(24)),
      framePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        imageRect,
        const Radius.circular(24),
      ),
      Paint()
        ..color = Colors.white.withOpacity(0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    if (rect == null) {
      return;
    }

    final selection = rect!;

    final selectionPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(selection, const Radius.circular(24)),
      );

    canvas.saveLayer(Rect.largest, Paint());
    canvas.drawPath(selectionPath, Paint()..blendMode = BlendMode.clear);
    canvas.restore();

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawRRect(
      RRect.fromRectAndRadius(selection, const Radius.circular(24)),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _SelectionPainter oldDelegate) {
    return oldDelegate.rect != rect || oldDelegate.imageRect != imageRect;
  }
}

