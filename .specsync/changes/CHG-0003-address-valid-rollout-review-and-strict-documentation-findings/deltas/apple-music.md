## MODIFIED

### SPEC SECTION Invariants

1. Music commands fail with a descriptive error when Music.app is not running.
2. Volume writes are clamped to the inclusive range 0 through 100.
3. Interactive selection uses fledge-v1 protocol messages; direct CLI mode never waits for a protocol response.
4. Search results are limited to 20 tracks and preserve persistent IDs for playback.
5. Unknown commands and missing search queries return a non-zero exit status; an invalid volume value prints usage, preserves playback state, and currently returns zero.

### REQUIREMENT REQ-apple-music-004

The plugin SHALL constrain applied volume settings to the inclusive range 0 through 100; an invalid explicit value prints usage and returns without applying a volume change.

Acceptance Criteria
- `up` and `down` remain bounded to 0 through 100.
- Numeric values in range are applied.
- Invalid explicit values print volume usage and preserve playback state.
