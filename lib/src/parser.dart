import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:fpdt/fpdt.dart';
import 'package:fpdt/option.dart' as O;
import 'package:navigation_stack/src/item.dart';

typedef NavigationStackItemFromKey<T> = Option<T> Function(
  String name,
  String id,
);

String _itemToPath(NavigationStackItemBase item) =>
    '${item.key.first}/${item.key.second}';

class NavigationStackParser<T extends NavigationStackItemBase>
    extends RouteInformationParser<IList<T>> {
  NavigationStackParser({
    required this.defaultItem,
    required this.fromKey,
  });

  final T defaultItem;
  final NavigationStackItemFromKey<T> fromKey;

  @override
  Future<IList<T>> parseRouteInformation(
    RouteInformation routeInformation,
  ) {
    final uri =
        Uri.parse(routeInformation.location ?? '/${_itemToPath(defaultItem)}');
    final segments = uri.pathSegments;
    final pairs = Iterable.generate(
      segments.length ~/ 2,
      (i) => [segments[2 * i], segments[2 * i + 1]],
    );

    final items = pairs.fold<IList<T>>(
      IList(),
      (acc, pair) => fromKey(pair[0], pair[1]).p(O.fold(
        () => acc,
        (item) => acc.add(item),
      )),
    );

    if (items.isEmpty) {
      return Future.value(IList([defaultItem]));
    }
    return Future.value(items);
  }

  @override
  RouteInformation restoreRouteInformation(IList<T> configuration) {
    if (configuration.isEmpty) {
      configuration = configuration.add(defaultItem);
    }

    final location = configuration.map(_itemToPath).join('/');
    return RouteInformation(location: '/$location');
  }
}
