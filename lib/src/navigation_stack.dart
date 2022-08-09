import 'package:fpdt/fpdt.dart';
import 'package:fpdt/state_reader.dart' as SR;
import 'package:fpdt/state_reader_machine.dart';

typedef NavigationStack<T>
    = StateReaderMachine<IList<T>, NavigationStackContext<T>>;

NavigationStack<T> createNavigationStack<T>({
  required NavigationStackTransform<T> transform,
  IList<T> initialStack = const IListConst([]),
}) =>
    StateReaderMachine(
      NavigationStackContext(
        defaultStack: initialStack,
        transform: transform,
      ),
      initialStack,
    );

typedef NavigationStackTransform<T> = IList<T> Function(IList<T> stack);

class NavigationStackContext<T> {
  NavigationStackContext({
    required IList<T> defaultStack,
    required this.transform,
  }) {
    this.defaultStack = transform(defaultStack);
  }

  late final IList<T> defaultStack;
  final NavigationStackTransform<T> transform;
}

typedef NavigationStackOp<T, A>
    = StateReader<IList<T>, NavigationStackContext<T>, A>;

NavigationStackOp<T, Unit> _transform<T>(NavigationStackOp<T, dynamic> fa) =>
    (s) => (c) {
          final next = fa(s)(c);
          return tuple2(unit, c.transform(next.second));
        };

NavigationStackOp<T, Unit> _modifyAndTransform<T>(
        IList<T> Function(IList<T> s) f) =>
    SR.modify(f).p(_transform);

NavigationStackOp<T, Unit> navStackPush<T>(T item) =>
    _modifyAndTransform((s) => s.add(item));

NavigationStackOp<T, Unit> navStackPop<T>() =>
    _modifyAndTransform((s) => s.removeLast());

NavigationStackOp<T, Unit> navStackReplace<T>(IList<T> stack) =>
    SR.put(stack).p(_transform);
