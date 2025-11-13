# Practice Flow - Generate Questions Workflow

## 📋 Overview
This document outlines the complete implementation plan for the **"✨ Generate Questions"** multi-step flow in the BrainLeap iOS app using **Flutter + Dart**.

The flow will be triggered from the existing "Generate Questions" button in `PracticeView` and will navigate through 6 screens to collect user preferences before reaching the question input canvas.

---

## 🗂️ Folder Structure

```
lib/
├── views/
│   └── practice_flow/
│       ├── class_selection_view.dart          # Step 1: Choose Class
│       ├── subject_selection_view.dart        # Step 2: Choose Subject  
│       ├── curriculum_selection_view.dart     # Step 3: Choose Curriculum
│       ├── topic_selection_view.dart          # Step 4: Choose Topic
│       ├── deep_dive_view.dart                # Step 5: Deep Dive (Accordion)
│       └── question_input_view.dart           # Step 6: Question Canvas
│
├── widgets/
│   └── practice_flow/
│       ├── step_progress_indicator.dart       # Progress stepper (1/6, 2/6, etc.)
│       ├── pill_button.dart                   # Selectable pill-shaped button
│       ├── practice_flow_header.dart          # Back + Cancel header bar
│       ├── topic_accordion.dart               # Expandable accordion widget
│       ├── dotted_grid_canvas.dart            # Drawing canvas with dotted grid
│       └── canvas_toolbar.dart                # Drawing tools toolbar
│
├── models/
│   └── practice_flow/
│       ├── practice_selection.dart            # Main selection data model
│       ├── topic_data.dart                    # Topic/Subtopic definitions
│       └── drawing_data.dart                  # Canvas drawing data
│
├── providers/
│   └── practice_flow_provider.dart            # State management provider
│
└── config/
    └── practice_theme.dart                    # Theme constants & styles
```

---

## 🎨 Design System

### Color Palette

```dart
// lib/config/practice_theme.dart

class PracticeTheme {
  // Primary Colors
  static const Color primaryBlack = Color(0xFF000000);
  static const Color primaryWhite = Color(0xFFFFFFFF);
  
  // Greys
  static const Color grey50 = Color(0xFFF5F5F5);    // Normal pill background
  static const Color grey100 = Color(0xFFEDEDED);   // Pill border
  static const Color grey300 = Color(0xFFD9D9D9);   // Inactive stepper
  static const Color grey600 = Color(0xFF7A7A7A);   // Subtext
  
  // Accent
  static const Color accentBlue = Color(0xFF007AFF); // Active canvas border
  
  // Spacing
  static const double pagePadding = 24.0;
  static const double verticalSpacing = 16.0;
  static const double pillSpacing = 12.0;
  
  // Border Radius
  static const double pillRadius = 100.0;
  static const double cardRadius = 16.0;
}
```

### Typography

```dart
class PracticeTextStyles {
  // Heading - Screen titles
  static const TextStyle heading = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: PracticeTheme.primaryBlack,
    letterSpacing: -0.3,
  );
  
  // Subtext - Helper text below titles
  static const TextStyle subtext = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: PracticeTheme.grey600,
    height: 1.4,
  );
  
  // Pill button (normal state)
  static const TextStyle pillText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: PracticeTheme.primaryBlack,
  );
  
  // Pill button (selected state)
  static const TextStyle pillTextSelected = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: PracticeTheme.primaryWhite,
  );
  
  // Cancel button
  static const TextStyle cancelButton = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: PracticeTheme.primaryBlack,
  );
}
```

### Component Specs

#### Pill Button
```dart
Container(
  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(100),
    border: Border.all(
      color: PracticeTheme.grey100,
      width: 1,
    ),
    color: isSelected ? PracticeTheme.primaryBlack : PracticeTheme.grey50,
  ),
  child: Text(
    label,
    style: isSelected 
      ? PracticeTextStyles.pillTextSelected 
      : PracticeTextStyles.pillText,
  ),
)
```

#### Progress Stepper
```dart
// Height: 4px
// Active segment: primaryBlack (#000000)
// Inactive segment: grey300 (#D9D9D9)
// Rounded ends: BorderRadius.circular(2)
// Gap between segments: 4px
```

---

## 🧭 Navigation Flow

### Current Navigation Structure
Your app uses a **bottom tab navigation** (Home, History, Settings) defined in `MainNavigationView`. The Practice Flow will use **Navigator.push** to create a modal stack on top of the Home tab.

### Practice Flow Navigation
```dart
// From PracticeView -> ClassSelectionView (new stack)
// Navigation will be handled via MaterialPageRoute with slide transitions

Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ClassSelectionView(),
  ),
);

// Each screen pushes to the next
// Back button: Navigator.pop(context)
// Cancel button: Navigator.popUntil(context, (route) => route.isFirst)
```

### Screen Flow Sequence
```
PracticeView (existing)
    ↓ Tap "✨ Generate Questions"
ClassSelectionView (1/6)
    ↓ Select class
SubjectSelectionView (2/6)
    ↓ Select subject
CurriculumSelectionView (3/6)
    ↓ Select curriculum
TopicSelectionView (4/6)
    ↓ Select topic
DeepDiveView (5/6)
    ↓ Select subtopic
QuestionInputView (6/6)
    ↓ Draw & Submit
[Results/Loading Screen]
```

---

## 📱 Screen Specifications

### 1️⃣ ClassSelectionView (Step 1/6)

**File**: `lib/views/practice_flow/class_selection_view.dart`

**Purpose**: Select student's class level

**UI Layout**:
```dart
Scaffold(
  backgroundColor: Colors.white,
  appBar: PracticeFlowHeader(
    title: 'Choose Class',
    onCancel: () => Navigator.popUntil(context, (route) => route.isFirst),
  ),
  body: SafeArea(
    child: Padding(
      padding: EdgeInsets.all(PracticeTheme.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StepProgressIndicator(currentStep: 1, totalSteps: 6),
          SizedBox(height: 32),
          Text('Select Your Class', style: PracticeTextStyles.heading),
          SizedBox(height: 8),
          Text('Choose the class you\'re currently studying in', 
               style: PracticeTextStyles.subtext),
          SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              PillButton(label: 'Class 8', isSelected: false, onTap: () {}),
              PillButton(label: 'Class 9', isSelected: false, onTap: () {}),
              PillButton(label: 'Class 10', isSelected: true, onTap: () {}),
              PillButton(label: 'Class 11', isSelected: false, onTap: () {}),
              PillButton(label: 'Class 12', isSelected: false, onTap: () {}),
            ],
          ),
          Spacer(),
          _buildNextButton(),
        ],
      ),
    ),
  ),
  bottomNavigationBar: // Keep existing bottom nav visible
)
```

**State Management**:
```dart
class _ClassSelectionViewState extends State<ClassSelectionView> {
  String? _selectedClass;
  
  void _handleClassSelection(String className) {
    setState(() => _selectedClass = className);
    
    // Update provider
    final provider = context.read<PracticeFlowProvider>();
    provider.updateClass(className);
  }
  
  void _handleNext() {
    if (_selectedClass == null) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SubjectSelectionView()),
    );
  }
}
```

**Options**: `['Class 8', 'Class 9', 'Class 10', 'Class 11', 'Class 12']`

---

### 2️⃣ SubjectSelectionView (Step 2/6)

**File**: `lib/views/practice_flow/subject_selection_view.dart`

**Purpose**: Select academic subject

**UI Elements**:
- Header: Back | "Choose Subject" | Cancel
- Progress: 2/6 active
- Title: "Select Your Subject"
- Subtext: "Which subject would you like to practice?"
- Pills (vertical list):
  - Mathematics
  - Physics  
  - Chemistry

**State**:
```dart
String? _selectedSubject;
final List<String> subjects = ['Mathematics', 'Physics', 'Chemistry'];
```

**Navigation**:
```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => CurriculumSelectionView()),
);
```

---

### 3️⃣ CurriculumSelectionView (Step 3/6)

**File**: `lib/views/practice_flow/curriculum_selection_view.dart`

**Purpose**: Select educational curriculum/board

**UI Elements**:
- Header: Back | "Choose Curriculum" | Cancel
- Progress: 3/6 active
- Title: "Select Your Curriculum"
- Subtext: "Choose your educational board or examination"
- Pills (2-column grid with GridView or Wrap):

```dart
final List<String> curriculums = [
  'CBSE',
  'ICSE',
  'Cambridge IGCSE',
  'IB',
  'SAT',
  'GRE',
  'GMAT',
  'JEE',
  'NEET',
];
```

**Layout**:
```dart
GridView.builder(
  shrinkWrap: true,
  physics: NeverScrollableScrollPhysics(),
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    childAspectRatio: 2.5,
    crossAxisSpacing: 12,
    mainAxisSpacing: 12,
  ),
  itemCount: curriculums.length,
  itemBuilder: (context, index) {
    return PillButton(
      label: curriculums[index],
      isSelected: _selectedCurriculum == curriculums[index],
      onTap: () => _handleSelection(curriculums[index]),
    );
  },
)
```

---

### 4️⃣ TopicSelectionView (Step 4/6)

**File**: `lib/views/practice_flow/topic_selection_view.dart`

**Purpose**: Select main topic area

**UI Elements**:
- Header: Back | "Choose Topic" | Cancel
- Progress: 4/6 active
- Title: "Select Topic"
- Subtext: "Pick the main topic you want to practice"
- Pills (scrollable list):

```dart
final List<String> topics = [
  'Algebra & Functions',
  'Probability & Statistics',
  'Geometry & Trigonometry',
  'Coordinate Geometry',
  'Calculus',
  'Vectors',
];
```

**Implementation**:
```dart
ListView.separated(
  shrinkWrap: true,
  physics: NeverScrollableScrollPhysics(),
  itemCount: topics.length,
  separatorBuilder: (_, __) => SizedBox(height: 12),
  itemBuilder: (context, index) {
    return PillButton(
      label: topics[index],
      isSelected: _selectedTopic == topics[index],
      onTap: () => _handleTopicSelection(topics[index]),
    );
  },
)
```

---

### 5️⃣ DeepDiveView (Step 5/6)

**File**: `lib/views/practice_flow/deep_dive_view.dart`

**Purpose**: Select specific subtopic using expandable accordion

**UI Elements**:
- Header: Back | "Deep Dive" | Cancel
- Progress: 5/6 active
- Title: "Deep Dive Into [Topic Name]"
- Subtext: "Select a specific subtopic to focus on"
- Accordion list (single expansion):

```dart
final Map<String, List<String>> topics = {
  'Algebraic Expressions & Identities': [
    'Simplifying Expressions',
    'Using Standard Identities',
    'Factorisation',
  ],
  'Linear Equations & Inequalities': [],
  'Quadratic Equations': [],
  'Exponents & Powers': [],
  'Polynomials': [],
  'Word Problems': [],
};
```

**Accordion Widget** (`lib/widgets/practice_flow/topic_accordion.dart`):
```dart
class TopicAccordion extends StatefulWidget {
  final String title;
  final List<String> subtopics;
  final bool isExpanded;
  final String? selectedSubtopic;
  final VoidCallback onToggle;
  final Function(String) onSubtopicSelected;
  
  // ...
}
```

**State Management**:
```dart
class _DeepDiveViewState extends State<DeepDiveView> {
  int? _expandedIndex;
  String? _selectedSubtopic;
  
  void _toggleAccordion(int index) {
    setState(() {
      _expandedIndex = _expandedIndex == index ? null : index;
    });
  }
  
  void _selectSubtopic(String subtopic) {
    setState(() => _selectedSubtopic = subtopic);
    
    // Update provider
    context.read<PracticeFlowProvider>().updateSubtopic(subtopic);
  }
}
```

**Animation**:
```dart
AnimatedContainer(
  duration: Duration(milliseconds: 200),
  curve: Curves.easeInOut,
  height: isExpanded ? null : 0,
  // ...
)
```

---

### 6️⃣ QuestionInputView (Step 6/6)

**File**: `lib/views/practice_flow/question_input_view.dart`

**Purpose**: Draw or write question on canvas

**UI Elements**:
- Header: Back | "Question Input" | Cancel
- Progress: 6/6 complete
- Title: "Draw or Write Your Question"
- Subtext: "Use the tools below to input your question"
- **Canvas**: Large dotted grid with drawing capability
- **Toolbar**: Tool selector (pen, eraser, text, shapes, camera, AI)
- **Submit Button**: Black button at bottom

**Canvas Implementation** (reuse existing drawing code):
```dart
// Similar to LocalDrawingCanvas from practice_view.dart
// But with custom dotted grid painter

class DottedGridCanvas extends StatefulWidget {
  final DrawingController controller;
  
  // ...
}

class _DottedGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Draw dotted grid
    final dotPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    const spacing = 20.0;
    const dotRadius = 1.0;
    
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, dotPaint);
      }
    }
  }
  
  // ...
}
```

**Toolbar** (`lib/widgets/practice_flow/canvas_toolbar.dart`):
```dart
class CanvasToolbar extends StatelessWidget {
  final DrawingTool selectedTool;
  final Function(DrawingTool) onToolSelected;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToolButton(icon: CupertinoIcons.pencil, tool: DrawingTool.pen),
          _ToolButton(icon: CupertinoIcons.delete_left, tool: DrawingTool.eraser),
          _ToolButton(icon: CupertinoIcons.textformat, tool: DrawingTool.text),
          _ToolButton(icon: CupertinoIcons.square, tool: DrawingTool.rectangle),
          _ToolButton(icon: CupertinoIcons.arrow_right, tool: DrawingTool.arrow),
          _ToolButton(icon: CupertinoIcons.camera, tool: DrawingTool.camera),
          _ToolButton(icon: CupertinoIcons.sparkles, tool: DrawingTool.magicWand),
        ],
      ),
    );
  }
}

enum DrawingTool {
  pen,
  eraser,
  text,
  rectangle,
  arrow,
  camera,
  magicWand,
}
```

**Submit Logic**:
```dart
Future<void> _handleSubmit() async {
  if (!_canvasHasContent()) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please draw or write your question first')),
    );
    return;
  }
  
  setState(() => _isSubmitting = true);
  
  try {
    // Get all selections from provider
    final provider = context.read<PracticeFlowProvider>();
    final selection = provider.selection;
    
    // Serialize canvas
    final canvasData = await _controller.exportAsImage();
    
    // Submit to backend
    await _practiceService.submitGeneratedQuestion(
      classLevel: selection.classLevel!,
      subject: selection.subject!,
      curriculum: selection.curriculum!,
      topic: selection.topic!,
      subtopic: selection.subtopic!,
      questionImage: canvasData,
    );
    
    // Success - navigate back to home or show results
    if (!mounted) return;
    Navigator.popUntil(context, (route) => route.isFirst);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Question submitted successfully!')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Submission failed: $e')),
    );
  } finally {
    if (mounted) setState(() => _isSubmitting = false);
  }
}
```

---

## 🧩 Reusable Components

### 1. StepProgressIndicator Widget

**File**: `lib/widgets/practice_flow/step_progress_indicator.dart`

**Purpose**: Visual progress bar showing current step

**Props**:
```dart
class StepProgressIndicator extends StatelessWidget {
  const StepProgressIndicator({
    super.key,
    required this.currentStep,
    this.totalSteps = 6,
  });
  
  final int currentStep;
  final int totalSteps;
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (index) {
        final isActive = index < currentStep;
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: index < totalSteps - 1 ? 4 : 0),
            decoration: BoxDecoration(
              color: isActive 
                ? PracticeTheme.primaryBlack 
                : PracticeTheme.grey300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}
```

**Usage**:
```dart
StepProgressIndicator(currentStep: 3) // Shows 3 of 6 bars active
```

---

### 2. PillButton Widget

**File**: `lib/widgets/practice_flow/pill_button.dart`

**Purpose**: Selectable pill-shaped button

**Implementation**:
```dart
class PillButton extends StatelessWidget {
  const PillButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });
  
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          border: isSelected 
            ? null 
            : Border.all(color: PracticeTheme.grey100, width: 1),
          color: isSelected 
            ? PracticeTheme.primaryBlack 
            : PracticeTheme.grey50,
        ),
        child: Text(
          label,
          style: isSelected 
            ? PracticeTextStyles.pillTextSelected 
            : PracticeTextStyles.pillText,
        ),
      ),
    );
  }
}
```

**States**:
- Normal: Grey background, black text, grey border
- Selected: Black background, white text, no border
- Animation: 200ms duration on state change

---

### 3. PracticeFlowHeader Widget

**File**: `lib/widgets/practice_flow/practice_flow_header.dart`

**Purpose**: Consistent app bar for all flow screens

**Implementation**:
```dart
class PracticeFlowHeader extends StatelessWidget implements PreferredSizeWidget {
  const PracticeFlowHeader({
    super.key,
    required this.title,
    required this.onCancel,
  });
  
  final String title;
  final VoidCallback onCancel;
  
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: Text(
            'Cancel',
            style: PracticeTextStyles.cancelButton,
          ),
        ),
        SizedBox(width: 8),
      ],
    );
  }
  
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
```

---

### 4. TopicAccordion Widget

**File**: `lib/widgets/practice_flow/topic_accordion.dart`

**Purpose**: Expandable accordion for subtopic selection

**Implementation**:
```dart
class TopicAccordion extends StatelessWidget {
  const TopicAccordion({
    super.key,
    required this.title,
    required this.subtopics,
    required this.isExpanded,
    required this.onToggle,
    this.selectedSubtopic,
    required this.onSubtopicSelected,
  });
  
  final String title;
  final List<String> subtopics;
  final bool isExpanded;
  final VoidCallback onToggle;
  final String? selectedSubtopic;
  final Function(String) onSubtopicSelected;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PracticeTheme.grey100),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: subtopics.isEmpty ? null : onToggle,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (subtopics.isNotEmpty)
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.black54,
                      ),
                    ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: SizedBox.shrink(),
            secondChild: Column(
              children: subtopics.map((subtopic) {
                final isSelected = selectedSubtopic == subtopic;
                return InkWell(
                  onTap: () => onSubtopicSelected(subtopic),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected 
                        ? PracticeTheme.grey50 
                        : Colors.transparent,
                      border: Border(
                        top: BorderSide(color: PracticeTheme.grey100),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected 
                            ? Icons.radio_button_checked 
                            : Icons.radio_button_unchecked,
                          size: 20,
                          color: isSelected 
                            ? PracticeTheme.primaryBlack 
                            : PracticeTheme.grey600,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            subtopic,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected 
                                ? FontWeight.w600 
                                : FontWeight.w400,
                              color: isSelected 
                                ? PracticeTheme.primaryBlack 
                                : PracticeTheme.grey600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            crossFadeState: isExpanded 
              ? CrossFadeState.showSecond 
              : CrossFadeState.showFirst,
            duration: Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}
```

---

## 🔄 State Management

### Data Model

**File**: `lib/models/practice_flow/practice_selection.dart`

```dart
class PracticeSelection {
  String? classLevel;
  String? subject;
  String? curriculum;
  String? topic;
  String? subtopic;
  Uint8List? questionImage;
  
  PracticeSelection({
    this.classLevel,
    this.subject,
    this.curriculum,
    this.topic,
    this.subtopic,
    this.questionImage,
  });
  
  bool get isComplete {
    return classLevel != null &&
           subject != null &&
           curriculum != null &&
           topic != null &&
           subtopic != null &&
           questionImage != null;
  }
  
  Map<String, dynamic> toJson() {
    return {
      'classLevel': classLevel,
      'subject': subject,
      'curriculum': curriculum,
      'topic': topic,
      'subtopic': subtopic,
    };
  }
}
```

### Provider

**File**: `lib/providers/practice_flow_provider.dart`

```dart
import 'package:flutter/foundation.dart';
import '../models/practice_flow/practice_selection.dart';

class PracticeFlowProvider extends ChangeNotifier {
  PracticeSelection _selection = PracticeSelection();
  
  PracticeSelection get selection => _selection;
  
  void updateClass(String classLevel) {
    _selection.classLevel = classLevel;
    notifyListeners();
  }
  
  void updateSubject(String subject) {
    _selection.subject = subject;
    notifyListeners();
  }
  
  void updateCurriculum(String curriculum) {
    _selection.curriculum = curriculum;
    notifyListeners();
  }
  
  void updateTopic(String topic) {
    _selection.topic = topic;
    notifyListeners();
  }
  
  void updateSubtopic(String subtopic) {
    _selection.subtopic = subtopic;
    notifyListeners();
  }
  
  void updateQuestionImage(Uint8List image) {
    _selection.questionImage = image;
    notifyListeners();
  }
  
  void reset() {
    _selection = PracticeSelection();
    notifyListeners();
  }
}
```

### Provider Registration

**Update**: `lib/main.dart`

```dart
// Add to MultiProvider
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    ChangeNotifierProvider(create: (_) => AiAssistantProvider()),
    ChangeNotifierProvider(create: (_) => PracticeFlowProvider()), // NEW
  ],
  // ...
)
```

---

## 🎯 Integration Points

### 1. Update PracticeView

**File**: `lib/views/practice_view.dart`

**Change**: Update the "Generate Questions" button handler:

```dart
// Line 102-108
Container(
  decoration: BoxDecoration(
    color: Colors.grey.shade300,
    borderRadius: BorderRadius.circular(24),
  ),
  child: CupertinoButton(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    onPressed: () {
      // NEW: Navigate to practice flow
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ClassSelectionView(),
        ),
      );
    },
    // ...
  ),
)
```

### 2. Add Import

```dart
// At top of practice_view.dart
import 'practice_flow/class_selection_view.dart';
```

---

## 📦 Dependencies

Check if these are already in `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.1              # ✅ Already installed
  cupertino_icons: ^1.0.6       # ✅ Already installed
  
  # Additional (if needed):
  image_picker: ^1.0.0          # For camera tool
  path_provider: ^2.1.0         # For file storage
```

---

## ✅ Implementation Checklist

### Phase 1: Setup & Theme (Day 1)
- [ ] Create folder structure (`lib/views/practice_flow/`, `lib/widgets/practice_flow/`)
- [ ] Create `practice_theme.dart` with colors and text styles
- [ ] Create `PracticeSelection` model
- [ ] Create `PracticeFlowProvider` 
- [ ] Register provider in `main.dart`

### Phase 2: Core Widgets (Day 1-2)
- [ ] Build `StepProgressIndicator` widget
- [ ] Build `PillButton` widget with animations
- [ ] Build `PracticeFlowHeader` widget
- [ ] Test widgets in isolation (optional test file)

### Phase 3: Selection Screens (Day 2-3)
- [ ] Build `ClassSelectionView` (step 1/6)
- [ ] Build `SubjectSelectionView` (step 2/6)
- [ ] Build `CurriculumSelectionView` (step 3/6) with GridView
- [ ] Build `TopicSelectionView` (step 4/6)
- [ ] Wire up navigation between screens
- [ ] Test selection flow with provider

### Phase 4: Accordion Screen (Day 3-4)
- [ ] Build `TopicAccordion` widget with animations
- [ ] Build `DeepDiveView` (step 5/6)
- [ ] Implement single-expansion accordion logic
- [ ] Add subtopic selection with radio buttons
- [ ] Test accordion expand/collapse

### Phase 5: Canvas Screen (Day 4-5)
- [ ] Create `DrawingController` (can reuse `LocalCanvasController` logic)
- [ ] Build `DottedGridCanvas` widget with custom painter
- [ ] Build `CanvasToolbar` with 7 tools
- [ ] Build `QuestionInputView` (step 6/6)
- [ ] Implement drawing functionality (pen, eraser)
- [ ] Add image export capability
- [ ] Wire up submit button with provider data

### Phase 6: Integration & Polish (Day 5-6)
- [ ] Update `PracticeView` to navigate to flow
- [ ] Test complete flow end-to-end (1→2→3→4→5→6)
- [ ] Test back button navigation
- [ ] Test cancel button (returns to home)
- [ ] Add loading states during submission
- [ ] Add error handling and user feedback
- [ ] Test on iOS device/simulator
- [ ] Fix any layout issues or animations
- [ ] Add haptic feedback (optional)

---

## 🎨 Design Notes

### iOS Design Principles
- ✅ Use `SafeArea` on all screens
- ✅ Support swipe-back gesture (default in MaterialPageRoute)
- ✅ Keep bottom tab bar visible (persistent navigation)
- ✅ Use Cupertino icons where appropriate
- ✅ Smooth animations (200-300ms)
- ✅ White backgrounds (matches existing app)
- ✅ Consistent spacing (24px margins)

### Layout Patterns
```dart
// Standard screen layout
Scaffold(
  backgroundColor: Colors.white,
  appBar: PracticeFlowHeader(...),
  body: SafeArea(
    child: Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StepProgressIndicator(...),
          SizedBox(height: 32),
          Text('Title', style: heading),
          SizedBox(height: 8),
          Text('Subtext', style: subtext),
          SizedBox(height: 24),
          // Content here
          Spacer(),
          // Next button
        ],
      ),
    ),
  ),
)
```

---

## 🧪 Testing Strategy

### Manual Testing Flow
1. **Navigation Test**:
   - Tap "Generate Questions" → Should show ClassSelectionView
   - Select class → Should enable Next button
   - Tap Next → Should navigate to SubjectSelectionView
   - Tap Back → Should return to ClassSelectionView with selection preserved
   - Tap Cancel → Should return to PracticeView (home)

2. **Selection Test**:
   - Test each screen's selection (pill buttons should highlight)
   - Verify provider stores selections correctly
   - Test that Next button is disabled when no selection

3. **Accordion Test**:
   - Tap accordion item → Should expand/collapse
   - Verify only one accordion open at a time
   - Test subtopic selection (radio buttons)
   - Verify smooth animations

4. **Canvas Test**:
   - Test drawing with pen tool
   - Test eraser tool
   - Verify dotted grid renders correctly
   - Test Submit button (enabled only with content)

### Widget Testing (Optional)
```dart
// test/widgets/practice_flow/pill_button_test.dart
testWidgets('PillButton changes style when selected', (tester) async {
  bool tapped = false;
  
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: PillButton(
          label: 'Test',
          isSelected: true,
          onTap: () => tapped = true,
        ),
      ),
    ),
  );
  
  // Verify selected styling
  final container = tester.widget<Container>(find.byType(Container).first);
  expect((container.decoration as BoxDecoration).color, PracticeTheme.primaryBlack);
  
  // Verify tap works
  await tester.tap(find.text('Test'));
  expect(tapped, true);
});
```

---

## 📝 Code Quality Guidelines

### Naming Conventions
- Files: `snake_case.dart` (e.g., `class_selection_view.dart`)
- Classes: `PascalCase` (e.g., `ClassSelectionView`)
- Private classes: `_PascalCase` (e.g., `_ClassSelectionViewState`)
- Variables: `camelCase` (e.g., `selectedClass`)
- Constants: `camelCase` (e.g., `static const pagePadding`)

### Code Style (matching your existing code)
```dart
// ✅ Good - matches your style
class PracticeView extends StatefulWidget {
  const PracticeView({super.key});

  @override
  State<PracticeView> createState() => _PracticeViewState();
}

// Private widgets within same file
class _PracticeHeader extends StatelessWidget {
  const _PracticeHeader({required this.onTap});
  
  final VoidCallback onTap;
  // ...
}
```

### Comments
```dart
// Brief comments for complex logic
// Longer documentation for public APIs
/// Displays the class selection screen (step 1 of 6).
///
/// Users select their current class level before proceeding
/// to subject selection.
class ClassSelectionView extends StatefulWidget {
  // ...
}
```

---

## 🚀 Getting Started

### Step 1: Create Folders
```bash
cd lib
mkdir -p views/practice_flow
mkdir -p widgets/practice_flow
mkdir -p models/practice_flow
mkdir -p config
```

### Step 2: Create Theme File
Start with `lib/config/practice_theme.dart` - this centralizes all styling.

### Step 3: Build Components First
Create reusable widgets before screens:
1. `StepProgressIndicator`
2. `PillButton`
3. `PracticeFlowHeader`

### Step 4: Build Screens in Order
Follow the 1→6 sequence, testing navigation as you go.

### Step 5: Wire Up Provider
Connect all screens to `PracticeFlowProvider` for state management.

---

## 📞 Support & Questions

### Common Issues

**Q: Bottom navigation bar disappears?**
A: Make sure you're using `Navigator.push` and not replacing the root navigator. The bottom bar is in `MainNavigationView` and should stay visible.

**Q: State not persisting on back navigation?**
A: Use Provider to store selections. Don't rely on widget state alone.

**Q: Animations not smooth?**
A: Use `AnimatedContainer`, `AnimatedCrossFade`, or explicit `AnimationController` with `Curves.easeInOut`.

**Q: Canvas drawing laggy?**
A: Wrap `CustomPaint` in `RepaintBoundary` and optimize painter's `shouldRepaint` logic.

---

## 📸 UI Reference Summary

### Screen Flow Visual
```
┌─────────────────────────────────────┐
│ ← Back  Choose Class      Cancel ✕  │  <- Header
├─────────────────────────────────────┤
│ ████████░░░░░░░░░░░░░░░░             │  <- Progress (1/6)
│                                     │
│ Select Your Class                   │  <- Title (20px, semibold)
│ Choose the class you're currently   │  <- Subtext (13px, grey)
│ studying in                         │
│                                     │
│  ┌──────────┐  ┌──────────┐         │  <- Pill Buttons
│  │ Class 8  │  │ Class 9  │         │
│  └──────────┘  └──────────┘         │
│  ┌──────────┐  ┌──────────┐         │
│  │ Class 10 │  │ Class 11 │         │
│  └──────────┘  └──────────┘         │
│  ┌──────────┐                       │
│  │ Class 12 │                       │
│  └──────────┘                       │
│                                     │
│                                     │
│  ┌─────────────────────────────┐   │  <- Next Button
│  │          Next →              │   │
│  └─────────────────────────────┘   │
├─────────────────────────────────────┤
│ 🏠 Home    📜 History    ⚙️ Settings│  <- Bottom Tab (persistent)
└─────────────────────────────────────┘
```

---

**Document Version**: 2.0 (Flutter/Dart)  
**Last Updated**: November 12, 2025  
**Framework**: Flutter 3.3+  
**Status**: ✅ Ready for Implementation

---

## 🎯 Next Steps

Once you approve this workflow, I will generate:

1. ✅ **All 6 screen files** (complete implementation)
2. ✅ **All 6 widget files** (reusable components)
3. ✅ **Theme configuration** (colors, text styles, constants)
4. ✅ **Models** (PracticeSelection, TopicData)
5. ✅ **Provider** (PracticeFlowProvider)
6. ✅ **Integration code** (update PracticeView)
7. ✅ **pubspec.yaml updates** (if needed)

**Ready to build?** Let me know and I'll start generating all the code! 🚀
