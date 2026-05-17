# otel_istio

Dartastic OpenTelemetry bridge for Istio (service mesh).

Wraps each call in a CLIENT-kind span with vendor-specific attributes following OpenTelemetry semantic conventions where applicable.

```dart
import 'package:otel_istio/otel_istio.dart';

await tracedIstio<void>(
  operation: 'someOp',
  invoke: () async {
    final r = await client.someOp();
    return IstioCallResult(value: r, result: IstioResult(statusCode: 200));
  },
);
```

Suppress instrumentation within a block:

```dart
await runWithoutIstioInstrumentationAsync(() async {
  await client.someInternalSync();
});
```
