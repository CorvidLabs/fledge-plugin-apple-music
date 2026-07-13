---
spec: apple-music.spec.md
---

## User Stories

- As a macOS user, I want to control Music.app from fledge.
- As an agent, I want structured prompts and output for interactive music commands.

## Acceptance Criteria

### REQ-apple-music-001

The plugin SHALL expose play, pause, stop, next, prev, now, search, playlists, and volume commands.

### REQ-apple-music-002

The plugin SHALL emit fledge-v1 structured output when initialized by fledge and readable terminal output in direct CLI mode.

### REQ-apple-music-003

The plugin SHALL reject Music operations when Music.app is not running and surface a descriptive error.

### REQ-apple-music-004

The plugin SHALL constrain applied volume settings to the inclusive range 0 through 100; an invalid explicit value prints usage and returns without applying a volume change.

Acceptance Criteria
- `up` and `down` remain bounded to 0 through 100.
- Numeric values in range are applied.
- Invalid explicit values print volume usage and preserve playback state.

## Constraints

- macOS 13 or later, Music.app, and Swift 5.9 or later.

## Out of Scope

- Remote music services and non-macOS playback backends.
