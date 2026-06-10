import 'package:chatweaver/di/global_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tests del provider de preferencia "mostrar reasoning"
/// (spec 05 T-28). Persistido en `shared_preferences` con clave
/// `show_reasoning_for_thinking_models`. Default: `true`.
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('default es true cuando prefs esta vacia', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    // El provider depende de sharedPreferencesProvider (FutureProvider).
    // Esperamos a que se resuelva.
    await container.read(sharedPreferencesProvider.future);
    expect(container.read(showReasoningProvider), isTrue);
  });

  test('default es true cuando prefs existe sin la clave', () async {
    SharedPreferences.setMockInitialValues({'otra_clave': 'valor'});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(sharedPreferencesProvider.future);
    expect(container.read(showReasoningProvider), isTrue);
  });

  test('lee el valor persistido si existe', () async {
    SharedPreferences.setMockInitialValues({
      'show_reasoning_for_thinking_models': false,
    });
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(sharedPreferencesProvider.future);
    expect(container.read(showReasoningProvider), isFalse);
  });

  test('set(false) actualiza el state y persiste en prefs', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(sharedPreferencesProvider.future);

    // Antes: true (default).
    expect(container.read(showReasoningProvider), isTrue);

    // Set false.
    await container.read(showReasoningProvider.notifier).set(false);
    expect(container.read(showReasoningProvider), isFalse);

    // Persistio en prefs.
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('show_reasoning_for_thinking_models'), isFalse);
  });

  test('set(true) cuando ya estaba en true es idempotente', () async {
    SharedPreferences.setMockInitialValues({
      'show_reasoning_for_thinking_models': true,
    });
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(sharedPreferencesProvider.future);

    await container.read(showReasoningProvider.notifier).set(true);
    expect(container.read(showReasoningProvider), isTrue);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('show_reasoning_for_thinking_models'), isTrue);
  });
}
