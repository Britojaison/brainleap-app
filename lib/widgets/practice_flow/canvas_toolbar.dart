import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'dotted_grid_canvas.dart';

/// Toolbar with drawing tools for the canvas
class CanvasToolbar extends StatelessWidget {
  const CanvasToolbar({
    super.key,
    required this.selectedTool,
    required this.onToolSelected,
  });

  final DrawingTool selectedTool;
  final Function(DrawingTool) onToolSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ToolButton(
            icon: CupertinoIcons.pencil,
            tool: DrawingTool.pen,
            isSelected: selectedTool == DrawingTool.pen,
            onTap: () => onToolSelected(DrawingTool.pen),
          ),
          const SizedBox(width: 8),
          _ToolButton(
            icon: CupertinoIcons.delete_left,
            tool: DrawingTool.eraser,
            isSelected: selectedTool == DrawingTool.eraser,
            onTap: () => onToolSelected(DrawingTool.eraser),
          ),
          const SizedBox(width: 8),
          _ToolButton(
            icon: CupertinoIcons.textformat,
            tool: DrawingTool.text,
            isSelected: selectedTool == DrawingTool.text,
            onTap: () => onToolSelected(DrawingTool.text),
          ),
          const SizedBox(width: 8),
          _ToolButton(
            icon: CupertinoIcons.square,
            tool: DrawingTool.rectangle,
            isSelected: selectedTool == DrawingTool.rectangle,
            onTap: () => onToolSelected(DrawingTool.rectangle),
          ),
          const SizedBox(width: 8),
          _ToolButton(
            icon: CupertinoIcons.arrow_right,
            tool: DrawingTool.arrow,
            isSelected: selectedTool == DrawingTool.arrow,
            onTap: () => onToolSelected(DrawingTool.arrow),
          ),
          const SizedBox(width: 8),
          _ToolButton(
            icon: CupertinoIcons.camera,
            tool: DrawingTool.camera,
            isSelected: selectedTool == DrawingTool.camera,
            onTap: () => onToolSelected(DrawingTool.camera),
          ),
          const SizedBox(width: 8),
          _ToolButton(
            icon: CupertinoIcons.sparkles,
            tool: DrawingTool.magicWand,
            isSelected: selectedTool == DrawingTool.magicWand,
            onTap: () => onToolSelected(DrawingTool.magicWand),
          ),
        ],
      ),
    );
  }
}

/// Individual tool button
class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.icon,
    required this.tool,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final DrawingTool tool;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.black.withOpacity(0.1) : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.black : Colors.black54,
            size: 22,
          ),
        ),
      ),
    );
  }
}

