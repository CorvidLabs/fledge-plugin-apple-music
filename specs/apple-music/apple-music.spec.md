---
module: apple-music
version: 1
status: active
files:
  - Sources/fledge-music/Commands.swift
  - Sources/fledge-music/MusicBridge.swift
  - Sources/fledge-music/Protocol.swift
  - Sources/fledge-music/main.swift

db_tables: []
depends_on: []
---

# Apple Music Plugin

## Purpose

Provide macOS Apple Music playback, search, playlist, now-playing, and volume controls through the fledge-v1 plugin protocol and a direct command-line fallback.

## Public API

| Type | Responsibility |
|------|----------------|
| `Commands` | Parse plugin arguments and dispatch playback, search, playlist, now-playing, and volume commands. |
| `MusicBridge` | Validate Music.app availability and execute bounded AppleScript operations. |
| `NowPlaying`, `Track`, `Playlist` | Carry Music.app results into command and protocol output. |
| `MusicError` | Represent Music.app availability, script, and empty-result failures. |
| `InitMessage`, `ProtocolResponse`, `ResponseValue` | Decode fledge-v1 initialization and interactive responses. |
| `FledgeProtocol` | Read initialization, request selections, and emit structured log/output messages. |

## Invariants

1. Music commands fail with a descriptive error when Music.app is not running.
2. Volume writes are clamped to the inclusive range 0 through 100.
3. Interactive selection uses fledge-v1 protocol messages; direct CLI mode never waits for a protocol response.
4. Search results are limited to 20 tracks and preserve persistent IDs for playback.
5. Unknown commands and invalid required arguments return a non-zero exit status.

## Behavioral Examples

```
Given Music.app is running and a fledge init message requests `now`
When the plugin reads the current track
Then it emits structured output containing the track, artist, album, and playback position
```

## Error Cases

| Error | When | Behavior |
|-------|------|----------|
| Music.app unavailable | Any bridge command is requested while Music.app is stopped | Return `MusicError.notRunning` and exit non-zero. |
| AppleScript failure | Music.app rejects or cannot execute an operation | Return the AppleScript message as `MusicError.scriptError`. |
| Invalid command input | A required query is missing or volume is outside 0 through 100 | Print usage guidance without changing playback state. |
| Empty or malformed result | Search has no matches or now-playing fields are incomplete | Return an empty result or report that nothing is playing. |

## Dependencies

- macOS 13 or later
- Music.app and the system AppleScript bridge
- Swift 5.9 or later
- fledge-v1 JSON-lines plugin protocol

## Change Log

| Version | Date | Changes |
|---------|------|---------|
| 1 | 2026-07-12 | Document existing Apple Music plugin behavior for SpecSync 5 adoption. |
