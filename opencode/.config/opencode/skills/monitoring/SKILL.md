---
name: monitoring
description: Use when building observable systems with structured logging, metrics, distributed tracing, and alerting.
---

# Monitoring & Observability

## When to Use This Skill
- Setting up structured logging with correlation IDs
- Building dashboards with Prometheus and Grafana
- Implementing distributed tracing with OpenTelemetry
- Creating alerts that notify without causing fatigue

## Workflow
1. Add structured logging: JSON format with request ID, timestamp, and level
2. Propagate correlation IDs across services for traceability
3. Instrument metrics: request count, latency (p50/p95/p99), error rate
4. Set up Prometheus to scrape metrics endpoints
5. Build Grafana dashboards: service health, latency, error rate, saturation
6. Add distributed tracing: instrument HTTP clients and servers with OpenTelemetry
7. Define alerts: error rate > 1% for 5min, p99 latency > 2s for 10min
8. Test alerts by simulating failures in staging

## Rules
- Use structured logging — JSON, not free-form text
- Include correlation IDs in every log entry and metric label
- Set alerts on symptoms (latency, error rate), not just causes (CPU, memory)
- Use alert routing to send to the right team
- Review and tune alerts monthly — remove noisy or never-firing ones
- Don't log sensitive data — sanitize PII and credentials
