// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:otel_istio/otel_istio.dart';
import 'package:test/test.dart';

void main() {
  group('otel_istio', () {
    test('suppression toggles in zone', () async {
      expect(istioInstrumentationSuppressed(), isFalse);
      await runWithoutIstioInstrumentationAsync(() async {
        expect(istioInstrumentationSuppressed(), isTrue);
      });
      expect(istioInstrumentationSuppressed(), isFalse);
    });

    test('IstioResult fields default null', () {
      const r = IstioResult();
      expect(r.statusCode, isNull);
    });
  });
}
