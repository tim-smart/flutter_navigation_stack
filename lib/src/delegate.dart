import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fpdt/fpdt.dart';
import 'package:fpdt/option.dart' as O;

import 'item.dart';
import 'navigation_stack.dart' as navstack;

typedef NavigationStackBuilder<T> = List<Page> Function(
  BuildContext context,
  IList<T> stack,
);

class NavigationStackDelegate<T extends NavigationStackItemBase>
    extends RouterDelegate<IList<T>>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin {
  NavigationStackDelegate({
    required this.navigatorKey,
    required this.stack,
    required this.builder,
  }) : super() {
    _subscription = stack.withCurrentValue.listen((_) {
      notifyListeners();
    });
  }

  final navstack.NavigationStack<T> stack;
  final NavigationStackBuilder<T> builder;
  late final StreamSubscription<IList<T>> _subscription;

  @override
  final GlobalKey<NavigatorState> navigatorKey;

  @override
  IList<T> get currentConfiguration => stack.value;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Navigator(
        key: navigatorKey,
        pages: builder(context, stack.value),
        onPopPage: (route, result) {
          if (!route.didPop(result)) {
            return false;
          }

          stack.add(navstack.pop<T>());
          return true;
        },
      );

  @override
  Future<void> setInitialRoutePath(IList<T> configuration) =>
      setNewRoutePath(stack.initialStack.p(O.getOrElse(() => configuration)));

  @override
  Future<void> setNewRoutePath(IList<T> configuration) async =>
      stack.add(navstack.replace(configuration));
}
