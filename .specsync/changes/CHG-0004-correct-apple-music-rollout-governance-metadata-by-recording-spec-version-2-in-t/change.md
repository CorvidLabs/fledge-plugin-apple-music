---
id: CHG-0004-correct-apple-music-rollout-governance-metadata-by-recording-spec-version-2-in-t
state: accepted
type: documentation
base_commit: 6885c43f563bee72ac24771a9d56ce92354e33c4
---

# Correct Apple Music rollout governance metadata by recording spec version 2 in the changelog and treating all installed agent integration directories as meaningful lifecycle paths

## Intent

Correct Apple Music rollout governance metadata by recording spec version 2 in the changelog and treating all installed agent integration directories as meaningful lifecycle paths

## Affected Canonical Specs

- `apple-music`

## Acceptance Criteria

- The Apple Music spec changelog records version 2 for CHG-0003; .specsync/sdd.json includes .claude/
- .codex/
- .cursor/
- and .gemini/ as meaningful paths; strict SpecSync coverage remains 100%; native verification passes.

## No-spec Rationale

Not applicable
