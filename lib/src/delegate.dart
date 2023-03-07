// ignore_for_file: void_checks

import 'dart:async';

import 'package:elemental/elemental.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
    _subscription = stack.stream.listen((_) => notifyListeners());
  }

  final NavigationStack<T> stack;
  final T fallback;
  final NavigationStackBuilder<T> builder;
  late final StreamSubscription<IList<T>> _subscription;

  @override
  final GlobalKey<NavigatorState> navigatorKey;

  @override
  IList<T> get currentConfiguration => stack.unsafeGet();

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  List<Page> _buildPages(BuildContext context) =>
      stack.unsafeGet().map((item) => builder(context, item)).toList();

  @override
  Widget build(BuildContext context) => Navigator(
        key: navigatorKey,
        pages: _buildPages(context),
        onPopPage: (route, result) {
          if (!route.didPop(result)) {
            return false;
          }

          stack.pop.runSync();
          return true;
        },
      );

  @override
  Future<void> setInitialRoutePath(IList<T> configuration) =>
      SynchronousFuture(stack.replaceWith(fallback).runSyncOrThrow());

  @override
  Future<void> setNewRoutePath(IList<T> configuration) =>
      SynchronousFuture(stack.replace(configuration).runSyncOrThrow());
}
