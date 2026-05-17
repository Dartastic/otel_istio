// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_istio_suppression.dart';

class IstioResult {
  const IstioResult({
    this.sourceWorkload,
    this.sourceNamespace,
    this.sourcePrincipal,
    this.destinationWorkload,
    this.destinationNamespace,
    this.destinationPrincipal,
    this.destinationService,
    this.protocol,
    this.requestMtls,
    this.statusCode,
    this.errorCode,
    this.errorMessage,
  });

  final String? sourceWorkload;
  final String? sourceNamespace;
  final String? sourcePrincipal;
  final String? destinationWorkload;
  final String? destinationNamespace;
  final String? destinationPrincipal;
  final String? destinationService;
  final String? protocol;
  final bool? requestMtls;
  final int? statusCode;
  final String? errorCode;
  final String? errorMessage;
}

class IstioCallResult<T> {
  const IstioCallResult({required this.value, this.result});
  final T value;
  final IstioResult? result;
}

Future<T> tracedIstio<T>({
  required String operation,
  required Future<IstioCallResult<T>> Function() invoke,
  Tracer? tracer,
}) async {
  if (istioInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTel.tracerProvider().getTracer('otel_istio');
  final span = t.startSpan('istio $operation', kind: SpanKind.internal);
  try {
    span.setStringAttribute('service.mesh', 'istio');
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.sourceWorkload != null) {
        span.setStringAttribute('source.workload', res.sourceWorkload!);
      }
      if (res.sourceNamespace != null) {
        span.setStringAttribute('source.namespace', res.sourceNamespace!);
      }
      if (res.sourcePrincipal != null) {
        span.setStringAttribute('source.principal', res.sourcePrincipal!);
      }
      if (res.destinationWorkload != null) {
        span.setStringAttribute(
          'destination.workload',
          res.destinationWorkload!,
        );
      }
      if (res.destinationNamespace != null) {
        span.setStringAttribute(
          'destination.namespace',
          res.destinationNamespace!,
        );
      }
      if (res.destinationPrincipal != null) {
        span.setStringAttribute(
          'destination.principal',
          res.destinationPrincipal!,
        );
      }
      if (res.destinationService != null) {
        span.setStringAttribute('destination.service', res.destinationService!);
      }
      if (res.protocol != null) {
        span.setStringAttribute('network.protocol.name', res.protocol!);
      }
      if (res.requestMtls != null) {
        span.setBoolAttribute('istio.mtls', res.requestMtls!);
      }
      if (res.statusCode != null) {
        span.setIntAttribute('http.response.status_code', res.statusCode!);
      }
      if (res.errorCode != null) {
        span.setStringAttribute('istio.error.code', res.errorCode!);
      }
      final fail =
          res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.setStringAttribute(
          ErrorResource.errorType.key,
          res.errorCode ?? 'istio.error',
        );
        span.setStatus(SpanStatusCode.Error, res.errorMessage);
      }
    }
    return r.value;
  } catch (e, st) {
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
