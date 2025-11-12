# Practice Flow - Integration Guide

## ✅ Implementation Complete!

All 16 files have been successfully created and integrated into your Flutter app.

---

## 📦 What Was Created

### **Configuration** (1 file)
- ✅ `lib/config/practice_theme.dart` - Theme colors, text styles, spacing constants

### **Models** (2 files)
- ✅ `lib/models/practice_flow/practice_selection.dart` - Selection data model
- ✅ `lib/models/practice_flow/topic_data.dart` - Static topic/subtopic data

### **Provider** (1 file)
- ✅ `lib/providers/practice_flow_provider.dart` - State management

### **Widgets** (6 files)
- ✅ `lib/widgets/practice_flow/step_progress_indicator.dart` - Progress stepper
- ✅ `lib/widgets/practice_flow/pill_button.dart` - Selectable pill buttons
- ✅ `lib/widgets/practice_flow/practice_flow_header.dart` - App bar header
- ✅ `lib/widgets/practice_flow/topic_accordion.dart` - Expandable accordion
- ✅ `lib/widgets/practice_flow/dotted_grid_canvas.dart` - Drawing canvas
- ✅ `lib/widgets/practice_flow/canvas_toolbar.dart` - Drawing tools

### **Screens** (6 files)
- ✅ `lib/views/practice_flow/class_selection_view.dart` - Step 1/6
- ✅ `lib/views/practice_flow/subject_selection_view.dart` - Step 2/6
- ✅ `lib/views/practice_flow/curriculum_selection_view.dart` - Step 3/6
- ✅ `lib/views/practice_flow/topic_selection_view.dart` - Step 4/6
- ✅ `lib/views/practice_flow/deep_dive_view.dart` - Step 5/6
- ✅ `lib/views/practice_flow/question_input_view.dart` - Step 6/6

### **Updated Files** (2 files)
- ✅ `lib/main.dart` - Registered `PracticeFlowProvider`
- ✅ `lib/views/practice_view.dart` - Wired "Generate Questions" button navigation

---

## 🚀 How to Test

### 1. Run the App
```bash
cd /Users/mugilarasan/88GB\ Tech/brain_leap/brainleap-app
flutter run
```

### 2. Navigate to Practice Flow
1. Open the app
2. Go to the **Home** tab (Practice screen)
3. Tap the **"✨ Generate Questions"** button
4. You should see the **Class Selection** screen (Step 1/6)

### 3. Test the Complete Flow
**Step 1: Choose Class**
- Select any class (8, 9, 10, 11, 12)
- Tap "Next"

**Step 2: Choose Subject**
- Select Mathematics, Physics, or Chemistry
- Tap "Next"

**Step 3: Choose Curriculum**
- Select any curriculum (CBSE, ICSE, etc.)
- Scroll through grid layout
- Tap "Next"

**Step 4: Choose Topic**
- Topics change based on selected subject
- Select any topic (e.g., "Algebra & Functions")
- Tap "Next"

**Step 5: Deep Dive**
- Tap accordion items to expand
- Select a subtopic (radio button)
- Tap "Next"

**Step 6: Question Input**
- Draw on the dotted canvas
- Try different tools (pen, eraser)
- Tap "Submit Question"
- Should return to home with success message

### 4. Test Navigation
- **Back button**: Should go to previous screen
- **Cancel button**: Should return to home (with confirmation on last screen)
- **State persistence**: Going back should preserve selections

---

## 🎨 UI Features

### Progress Indicator
- Black segments for completed steps
- Grey segments for remaining steps
- Updates on each screen (1/6, 2/6, etc.)

### Pill Buttons
- Grey background when normal
- Black background when selected
- Smooth 200ms animation on selection

### Accordion (Deep Dive Screen)
- Single expansion (only one open at a time)
- Smooth expand/collapse animation
- Radio button selection for subtopics

### Canvas (Question Input)
- Dotted grid background (20px spacing)
- Blue border around canvas
- Toolbar with 7 tools
- Submit button at bottom

---

## 🔧 Customization Points

### Change Colors
Edit `lib/config/practice_theme.dart`:
```dart
static const Color accentBlue = Color(0xFF007AFF); // Change canvas border
static const Color primaryBlack = Color(0xFF000000); // Change selected pills
```

### Add More Topics
Edit `lib/models/practice_flow/topic_data.dart`:
```dart
static const List<String> mathematicsTopics = [
  'Algebra & Functions',
  'Your New Topic', // Add here
];
```

### Add More Subtopics
Edit the `subtopicsMap` in `lib/models/practice_flow/topic_data.dart`:
```dart
'Your New Topic': [
  'Subtopic 1',
  'Subtopic 2',
],
```

### Change Animation Speed
Edit `lib/config/practice_theme.dart`:
```dart
static const Duration animationDuration = Duration(milliseconds: 200);
```

---

## 📝 Next Steps (Optional Enhancements)

### 1. Backend Integration
Update `lib/views/practice_flow/question_input_view.dart`:
```dart
// Replace the TODO section around line 52
final imageData = await _drawingController.exportAsImage();
provider.updateQuestionImage(imageData);

// Call your API service
await _practiceService.submitGeneratedQuestion(
  classLevel: selection.classLevel!,
  subject: selection.subject!,
  // ... other fields
  questionImage: imageData,
);
```

### 2. Image Export from Canvas
Add this method to `DrawingController` in `dotted_grid_canvas.dart`:
```dart
import 'dart:ui' as ui;
import 'dart:typed_data';

Future<Uint8List> exportAsImage() async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  
  // Draw your canvas here
  
  final picture = recorder.endRecording();
  final img = await picture.toImage(800, 600);
  final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}
```

### 3. Add Camera Tool
Install `image_picker` package:
```bash
flutter pub add image_picker
```

Then implement in `canvas_toolbar.dart`:
```dart
import 'package:image_picker/image_picker.dart';

// In toolbar button onTap:
if (tool == DrawingTool.camera) {
  final picker = ImagePicker();
  final image = await picker.pickImage(source: ImageSource.camera);
  // Handle image
}
```

### 4. Add Undo/Redo Buttons
The `DrawingController` already has `undo()` and `redo()` methods.
Just add buttons to the toolbar or canvas.

### 5. Save Draft
Add a "Save Draft" button that stores the current state:
```dart
await prefs.setString('draft', jsonEncode(provider.toJson()));
```

---

## ⚠️ Known Limitations

1. **Canvas Export**: Image export not fully implemented (marked as TODO)
2. **Tool Icons**: Text, Rectangle, Arrow, Camera, Magic Wand tools don't have functionality yet (only pen and eraser work)
3. **Validation**: No error handling for network failures during submission
4. **Persistence**: Selections are lost if app is killed (not saved to local storage)

---

## 🐛 Troubleshooting

### "Provider not found" error
- Make sure you registered `PracticeFlowProvider` in `main.dart` (already done)
- Restart the app completely

### Back button not working
- Check that you're using `Navigator.pop(context)` not `Navigator.of(context).pop()`
- Make sure screens are pushed with `MaterialPageRoute`

### Canvas not drawing
- Check that `DrawingController` is properly initialized in `initState`
- Make sure `GestureDetector` has `behavior: HitTestBehavior.opaque`

### Accordion not expanding
- Verify `_expandedIndex` state is being updated in `setState`
- Check that `AnimatedCrossFade` duration is set

### Styles not matching design
- All styles are in `lib/config/practice_theme.dart`
- Make sure imports are correct: `import '../../config/practice_theme.dart'`

---

## 📊 File Structure Summary

```
lib/
├── config/
│   └── practice_theme.dart (NEW)
├── models/
│   └── practice_flow/ (NEW FOLDER)
│       ├── practice_selection.dart
│       └── topic_data.dart
├── providers/
│   └── practice_flow_provider.dart (NEW)
├── views/
│   ├── practice_flow/ (NEW FOLDER)
│   │   ├── class_selection_view.dart
│   │   ├── subject_selection_view.dart
│   │   ├── curriculum_selection_view.dart
│   │   ├── topic_selection_view.dart
│   │   ├── deep_dive_view.dart
│   │   └── question_input_view.dart
│   └── practice_view.dart (UPDATED)
├── widgets/
│   └── practice_flow/ (NEW FOLDER)
│       ├── step_progress_indicator.dart
│       ├── pill_button.dart
│       ├── practice_flow_header.dart
│       ├── topic_accordion.dart
│       ├── dotted_grid_canvas.dart
│       └── canvas_toolbar.dart
└── main.dart (UPDATED)
```

---

## ✅ Testing Checklist

- [ ] App compiles without errors
- [ ] "Generate Questions" button navigates to flow
- [ ] All 6 screens load correctly
- [ ] Progress indicator updates on each screen
- [ ] Pill buttons highlight on selection
- [ ] "Next" button only enabled when selection made
- [ ] Back button returns to previous screen
- [ ] Cancel button returns to home
- [ ] Accordion expands/collapses smoothly
- [ ] Only one accordion item open at a time
- [ ] Subtopic selection with radio buttons works
- [ ] Canvas allows drawing
- [ ] Pen tool draws black strokes
- [ ] Eraser tool erases strokes
- [ ] Submit button shows loading spinner
- [ ] Success message appears after submission
- [ ] Returns to home after submission

---

## 🎉 You're All Set!

The complete Practice Flow is now integrated into your app. Users can:
1. Select their class, subject, and curriculum
2. Choose a topic and dive into specific subtopics
3. Draw their question on a canvas
4. Submit for AI-powered assistance

**Enjoy building with BrainLeap!** 🚀

---

**Need Help?**
- Check the detailed workflow: `PRACTICE_FLOW_WORKFLOW.md`
- Review code comments in each file
- Test on iOS simulator for best experience

