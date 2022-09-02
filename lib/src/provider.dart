import 'package:fpdt/fpdt.dart';
import 'package:navigation_stack/navigation_stack.dart';
import 'package:riverpod/riverpod.dart';

NavigationStack<T> Function(NavigationStack<T>) navstackProvider<T>(
  ProviderRef<NavigationStack<T>> ref,
) =>
    (stack) {
      ref.onDispose(stack.close);
      return stack;
    };

IList<T> Function(NavigationStack<T>) navstackStateProvider<T>(
  ProviderRef<IList<T>> ref,
) =>
    (stack) {
      ref.onDispose(stack.stream.listen((s) => ref.state = s).cancel);
      return stack.state;
    };
