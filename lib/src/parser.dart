import 'package:flutter/material.dart';
import 'package:fpdt/fpdt.dart';
import 'package:fpdt/option.dart' as O;

typedef NavigationStackItemFromKey<T> = Option<T> Function(
  String name,
  String id,
);

class NavigationStackRoute<T> {
  const NavigationStackRoute({
    required this.key,
    required this.fallback,
    this.fromId,
    this.id,
  });

  final T fallback;
  final String key;
  final String Function(T item)? id;
  final T? Function(String id)? fromId;

  Type get type => fallback.runtimeType;

  String itemToId(T item) => id?.call(item) ?? '';
  T idToItem(String id) => fromId?.call(id) ?? fallback;

  Tuple2<String, String> toSegment(T item) => tuple2(key, itemToId(item));
}

class NavigationStackRouter<T> {
  NavigationStackRouter({
    required this.defaultItem,
    required this.routes,
    this.seperator = '/',
    this.seperatorOptional = false,
  });

  final T defaultItem;
  final List<NavigationStackRoute<T>> routes;
  final String seperator;
  final bool seperatorOptional;

  late final Map<String, NavigationStackRoute<T>> _keys = routes.fold(
    {},
    (acc, route) => {
      ...acc,
      route.key: route,
    },
  );

  late final Map<Type, NavigationStackRoute<T>> _types = routes.fold(
    {},
    (acc, route) => {
      ...acc,
      route.type: route,
    },
  );

  late final defaultRoute = routeFromItem(defaultItem).p(O.toNullable)!;
  late final defaultUriSegment =
      defaultRoute.toSegment(defaultItem).p(_segmentToString);

  String _segmentToString(Tuple2<String, String> segment) =>
      seperatorOptional && segment.second.isEmpty
          ? segment.first
          : '${segment.first}$seperator${segment.second}';

  Option<T> itemFromSegment(Tuple2<String, String> segment) => _keys
      .lookup(segment.first)
      .p(O.map((route) => route.idToItem(segment.second)));

  Option<NavigationStackRoute<T>> routeFromItem(T item) =>
      _types.lookup(item.runtimeType);

  Option<String> segmentFromItem(T item) => routeFromItem(item)
      .p(O.map((route) => route.toSegment(item).p(_segmentToString)));

  Option<Tuple2<String, String>> parseSegment(String segment) => segment
      .split(seperator)
      .p(O.fromPredicateK((parts) => parts.length <= 2 && parts.isNotEmpty))
      .p(O.map((parts) => parts.length == 2
          ? tuple2(parts.first, parts.last)
          : tuple2(parts.first, '')));

  NavigationStackRoute<R> parentRoute<R>({
    required String key,
    required T Function(R parent) fromParent,
    required R Function(T item) toParent,
  }) =>
      NavigationStackRoute(
        key: key,
        fallback: toParent(defaultItem),
        id: fromParent
            .c(segmentFromItem)
            .c(O.getOrElse(() => defaultUriSegment)),
        fromId: parseSegment
            .c(O.flatMap(itemFromSegment))
            .c(O.getOrElse(() => defaultItem))
            .c(toParent),
      );

  RouteInformationParser<IList<T>> get parser =>
      NavigationStackParser(router: this);
}

class NavigationStackParser<T> extends RouteInformationParser<IList<T>> {
  NavigationStackParser({
    required this.router,
  });

  final NavigationStackRouter<T> router;

  @override
  Future<IList<T>> parseRouteInformation(
    RouteInformation routeInformation,
  ) {
    final uri =
        Uri.parse(routeInformation.location ?? '/${router.defaultUriSegment}');

    final segments = uri.pathSegments;
    final pairs = Iterable.generate(
      segments.length ~/ 2,
      (i) => tuple2(segments[2 * i], segments[2 * i + 1]),
    );

    final items = pairs.fold<IList<T>>(
      IList(),
      (acc, pair) => router.itemFromSegment(pair).p(O.fold(
            () => acc,
            (item) => acc.add(item),
          )),
    );

    if (items.isEmpty) {
      return Future.value(IList([router.defaultItem]));
    }
    return Future.value(items);
  }

  @override
  RouteInformation restoreRouteInformation(IList<T> configuration) {
    if (configuration.isEmpty) {
      configuration = configuration.add(router.defaultItem);
    }

    final location = configuration
        .expand<String>((item) => router.segmentFromItem(item).p(O.fold(
              () => [],
              (segment) => [segment],
            )))
        .join('/');

    return RouteInformation(location: '/$location');
  }
}
