import 'package:flutter/foundation.dart';

import '../models/ai_hint.dart';
import '../services/api_service.dart';

class AiAssistantProvider extends ChangeNotifier {
  AiAssistantProvider({ApiService? apiService}) : _api = apiService ?? ApiService();

  final ApiService _api;
  
  bool _isLoading = false;
  AiHint? _hint;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  AiHint? get hint => _hint;
  String? get errorMessage => _errorMessage;

  Future<void> fetchHint({required String questionId, required String canvasState}) async {
    _setLoading(true);
    _errorMessage = null;
    notifyListeners();

    try {
      final payload = await _api.requestAiHint(questionId: questionId, canvasState: canvasState);
      _hint = AiHint.fromJson(payload);
      _errorMessage = null;
    } catch (error) {
      _errorMessage = 'Unable to fetch hint. Please try again.';
      _hint = null;
      debugPrint('AI hint error: $error');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> evaluateAnswer({required String questionId, required String canvasState}) async {
    _setLoading(true);
    _errorMessage = null;
    notifyListeners();

    try {
      final payload = await _api.evaluateCanvasAnswer(questionId: questionId, canvasState: canvasState);
      _hint = AiHint.fromJson(payload);
      _errorMessage = null;
    } catch (error) {
      _errorMessage = 'Evaluation failed. Please retry after saving your work.';
      _hint = null;
      debugPrint('AI evaluation error: $error');
    } finally {
      _setLoading(false);
    }
  }

  void clearHint() {
    _hint = null;
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}


