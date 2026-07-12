---
spec: apple-music.spec.md
---

## Context

This macOS-only plugin controls the local Music.app through AppleScript and supports both fledge-v1 JSON-lines messages and direct terminal invocation.

## Related Modules

- fledge-v1 plugin protocol

## Design Decisions

- Use the system AppleScript bridge so no API key or developer account is required.
- Preserve a direct CLI fallback for smoke testing and manual use.
