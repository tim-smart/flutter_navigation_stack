import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fpdt/fpdt.dart';

import 'navigation_stack.dart';

typedef NavigationStackBuilder<T> = Page Function(
  BuildContext context,
  T item,
);

class NavigationStackDelegate<T> extends RouterDelegate<IList<T>>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin {
  NavigationStackDelegate({
    required this.navigatorKey,
    required this.stack,
    required this.builder,
    required this.fallback,
  }) : super() {
    stack.addListener(notifyListeners);
  }

  final NavigationStack<T> stack;
  final T fallback;
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

  List<Page> _buildPages(BuildContext context) =>
      stack.value.map((item) => builder(context, item)).toList();

  @override
  Widget build(BuildContext context) => Navigator(
        key: navigatorKey,
        pages: _buildPages(context),
        onPopPage: (route, result) {
          if (!route.didPop(result)) {
            return false;
          }

          stack.pop();
          return true;
        },
      );

  @override
  Future<void> setInitialRoutePath(IList<T> configuration) =>
      SynchronousFuture(stack.replaceWith(fallback));

  @override
  Future<void> setNewRoutePath(IList<T> configuration) =>
      SynchronousFuture(stack.replace(configuration));
}
