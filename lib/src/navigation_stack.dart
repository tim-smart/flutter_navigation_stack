import 'package:flutter/foundation.dart';
import 'package:fpdt/fpdt.dart';

typedef NavigationStackTransform<T> = IList<T> Function(IList<T> stack);

class NavigationStack<T> extends ValueNotifier<IList<T>> {
  NavigationStack({
    IList<T> initialStack = const IListConst([]),
    required this.transform,
  }) : super(transform(initialStack));

  final NavigationStackTransform<T> transform;

  @override
  set value(IList<T> items) {
    super.value = transform(items);
  }

  void push(T item) {
    value = value.add(item);
  }

  void pop() {
    value = value.removeLast();
  }

  void replace(IList<T> stack) {
    value = stack;
  }

  void replaceWith(T item) => replace(IList([item]));
}
