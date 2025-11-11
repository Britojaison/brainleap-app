import 'package:flutter/foundation.dart';

import '../models/ai_hint.dart';
import '../services/api_service.dart';

class AiAssistantState {
  const AiAssistantState({
    this.isLoading = false,
    this.hint,
    this.errorMessage,
  });

  final bool isLoading;
  final AiHint? hint;
  final String? errorMessage;

  AiAssistantState copyWith({
    bool? isLoading,
    AiHint? hint,
    String? errorMessage,
  }) {
    return AiAssistantState(
      isLoading: isLoading ?? this.isLoading,
      hint: hint ?? this.hint,
      errorMessage: errorMessage,
    );
  }
}

class AiAssistantProvider {
  AiAssistantProvider({ApiService? apiService}) : _api = apiService ?? ApiService();

  final ApiService _api;
  final ValueNotifier<AiAssistantState> state = ValueNotifier(const AiAssistantState());

  Future<void> fetchHint({required String questionId, required String canvasState}) async {
    state.value = state.value.copyWith(isLoading: true, errorMessage: null);
    try {
      final payload = await _api.requestAiHint(questionId: questionId, canvasState: canvasState);
      state.value = AiAssistantState(
        isLoading: false,
        hint: AiHint.fromJson(payload),
      );
    } catch (error) {
      state.value = AiAssistantState(
        isLoading: false,
        errorMessage: 'Unable to fetch hint. Please try again.',
      );
      debugPrint('AI hint error: $error');
    }
  }

  Future<void> evaluateAnswer({required String questionId, required String canvasState}) async {
    state.value = state.value.copyWith(isLoading: true, errorMessage: null);
    try {
      final payload = await _api.evaluateCanvasAnswer(questionId: questionId, canvasState: canvasState);
      state.value = AiAssistantState(
        isLoading: false,
        hint: AiHint.fromJson(payload),
      );
    } catch (error) {
      state.value = AiAssistantState(
        isLoading: false,
        errorMessage: 'Evaluation failed. Please retry after saving your work.',
      );
      debugPrint('AI evaluation error: $error');
    }
  }

  void dispose() {
    state.dispose();
  }
}

