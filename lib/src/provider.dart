import 'package:fpdt/fpdt.dart';
import 'package:fpdt/riverpod.dart';
import 'package:navigation_stack/navigation_stack.dart';
import 'package:riverpod/riverpod.dart';

NavigationStack<T> Function(NavigationStack<T>) navstackProvider<T>(
  ProviderRef<NavigationStack<T>> ref,
) =>
    (stack) => stateMachineProvider(ref, stack);

IList<T> Function(NavigationStack<T>) navstackStateProvider<T>(
  ProviderRef<IList<T>> ref,
) =>
    (stack) => stateMachineStateProvider(ref, stack);
