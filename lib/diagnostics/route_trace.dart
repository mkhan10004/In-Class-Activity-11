import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Off in the normal app. These flags support the Ghost Hunt experiment only.
const showRouteTrace = bool.fromEnvironment('SHOW_ROUTE_TRACE');
const experimentUsesPush = bool.fromEnvironment('GHOST_USE_PUSH');
final routeTrace = RouteTrace();

class RouteTrace extends NavigatorObserver {
  final List<Route<dynamic>> _routes = [];
  final ValueNotifier<String> label = ValueNotifier('Foyer');
  List<String> get names => _routes.map((r) {
        final name = r.settings.name;
        return name == '/' ? 'Foyer' : (name ?? 'Dialog');
      }).toList(growable: false);

  void _publish() {
    final snapshot = names.join(' > ');
    if (showRouteTrace) debugPrint('ROUTE STACK: $snapshot');
    // Observer callbacks occur during navigation/build; notify after the frame.
    WidgetsBinding.instance.addPostFrameCallback((_) => label.value = snapshot);
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _routes.add(route);
    _publish();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _routes.remove(route);
    _publish();
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _routes.remove(route);
    _publish();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    final index = oldRoute == null ? -1 : _routes.indexOf(oldRoute);
    if (index >= 0 && newRoute != null) {
      _routes[index] = newRoute;
    } else {
      if (oldRoute != null) _routes.remove(oldRoute);
      if (newRoute != null) _routes.add(newRoute);
    }
    _publish();
  }

  // Used between independent widget tests, never as app navigation.
  void resetForTest() {
    _routes.clear();
    label.value = 'Foyer';
  }
}

class RouteTracePanel extends StatelessWidget {
  const RouteTracePanel({super.key});

  @override
  Widget build(BuildContext context) {
    if (!showRouteTrace) return const SizedBox.shrink();
    return SafeArea(
      top: false,
      child: Container(
        color: const Color(0xFFFFE8C7),
        padding: const EdgeInsets.all(12),
        child: ValueListenableBuilder<String>(
          valueListenable: routeTrace.label,
          builder: (_, value, __) => Text(
            'EXPERIMENT: ${experimentUsesPush ? "push" : "pushReplacement"}\n'
            'Bottom > top: $value',
            key: const Key('route-trace'),
            style: const TextStyle(color: Color(0xFF39200A)),
          ),
        ),
      ),
    );
  }
}
