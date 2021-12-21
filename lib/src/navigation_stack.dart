import 'package:bloc_stream/bloc_stream.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:fpdt/fpdt.dart';
import 'package:fpdt/option.dart' as O;

typedef NavigationStackAction<T> = BlocStreamAction<IList<T>>;

NavigationStackAction<T> push<T>(T item) =>
    (value, add) => _add(value.add(item))(value, add);

NavigationStackAction<T> pop<T>() => (value, add) => add(value.removeLast());

NavigationStackAction<T> replace<T>(IList<T> stack) => _add(stack);

NavigationStackAction<T> _add<T>(IList<T> newStack) =>
    (_, add) => add(newStack);

typedef NavigationStackTransform<T> = IList<T> Function(IList<T> stack);

class NavigationStack<T> extends BlocStream<IList<T>> {
  NavigationStack({
    required NavigationStackTransform<T> transform,
    this.initialStack = const None(),
  }) : super(
          initialStack.p(O.getOrElse(IList.new)),
          transform: transform,
        );

  final Option<IList<T>> initialStack;
}
