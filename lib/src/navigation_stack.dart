import 'package:elemental/elemental.dart';

typedef NavigationStackTransform<T> = IList<T> Function(IList<T> stack);

class NavigationStack<T> extends Ref<IList<T>> {
  NavigationStack({
    IList<T> initialStack = const IListConst([]),
    required this.transform,
  }) : super.unsafeMake(initialStack);

  final NavigationStackTransform<T> transform;

  @override
  void unsafeValueDidChange(IList<T> value) {
    super.unsafeValueDidChange(transform(value));
  }

  IO<Unit> push(T item) => update((_) => _.add(item));

  IO<Unit> get pop => update((_) => _.removeLast());

  IO<Unit> replace(IList<T> stack) => set(stack);

  IO<Unit> replaceWith(T item) => replace(IList([item]));
}
