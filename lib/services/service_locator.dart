import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_app/services/api_service.dart';
import 'package:flutter_app/services/fake_api_service.dart';
import 'package:flutter_app/services/firebase_api_service.dart';

// Global service locator instance.
final GetIt locator = GetIt.instance;

/// Controls whether to use Firebase services even in debug mode.
/// Set this to true to test Firebase integration during development.
/// Default: false (uses fake service in debug mode for faster development)
bool useFirebaseInDebug = false;

/// Controls whether to enable LLM calls in development mode.
/// When true, the fake service will call real LLM APIs for authentic match analysis.
/// Requires GEMINI_API_KEY to be set.
/// Default: false (uses traditional algorithm for faster development)
bool useLLMInDebug = false;

/// Registers the services with the service locator.
///
/// This function should be called once at app startup.
/// In debug mode, it uses the fast local fake service by default for rapid development.
/// In release mode, it always uses the Firebase service.
/// Set `useFirebaseInDebug = true` to test Firebase integration during development.
Future<void> setupLocator() async {
  // Use a factory for the ApiService, so a new instance is created on each request if needed,
  // or use a singleton if the service should persist throughout the app's lifecycle.
  locator.registerSingletonAsync<ApiService>(() async {
    final shouldUseFirebase = !kDebugMode || useFirebaseInDebug;

    if (shouldUseFirebase) {
      print('🔥 Using Firebase API Service (with AI capabilities)');
      return FirebaseApiService();
    } else {
      // Get Gemini API key from environment if LLM is enabled
      String? geminiApiKey;
      if (useLLMInDebug) {
        geminiApiKey = const String.fromEnvironment('GEMINI_API_KEY',
            defaultValue: '');
        if (geminiApiKey.isEmpty) {
          geminiApiKey = null;
          print('⚠️ Warning: GEMINI_API_KEY not found in environment variables');
          print('   LLM calls will fallback to traditional algorithm');
        }
      }

      if (useLLMInDebug && geminiApiKey != null) {
        print('🤖 Using Fake API Service with LLM integration');
        return await FakeApiService.create(
          useLLM: true,
          geminiApiKey: geminiApiKey,
        );
      } else {
        print('🎭 Using Fake API Service (fast development mode)');
        return await FakeApiService.create();
      }
    }
  });

  // You can register other services here as well, e.g.:
  // locator.registerLazySingleton<AnalyticsService>(() => AnalyticsService());
}

/// Utility function to switch between fake and Firebase services during development.
/// Call this function to toggle the service without restarting the app.
/// Note: This only affects the next time the service is requested.
void switchToFirebaseService() {
  useFirebaseInDebug = true;
  useLLMInDebug = false; // Reset LLM flag when switching to Firebase
  print('🔄 Switching to Firebase service for next requests...');
  // Force re-registration of the service
  locator.unregister<ApiService>();
  setupLocator();
}

void switchToFakeService() {
  useFirebaseInDebug = false;
  print('🔄 Switching to Fake service for next requests...');
  // Force re-registration of the service
  locator.unregister<ApiService>();
  setupLocator();
}

/// Utility function to enable LLM calls in development mode.
/// Call this function to toggle LLM integration without restarting the app.
/// Requires GEMINI_API_KEY environment variable to be set.
/// Note: This only affects the next time the service is requested.
void enableLLMInDebug() {
  useLLMInDebug = true;
  useFirebaseInDebug = false; // Ensure we're not using Firebase
  print('🤖 Enabling LLM integration in debug mode for next requests...');
  print('   Make sure GEMINI_API_KEY is set in environment variables');
  // Force re-registration of the service
  locator.unregister<ApiService>();
  setupLocator();
}

void disableLLMInDebug() {
  useLLMInDebug = false;
  print('🎭 Disabling LLM integration in debug mode for next requests...');
  // Force re-registration of the service
  locator.unregister<ApiService>();
  setupLocator();
}

