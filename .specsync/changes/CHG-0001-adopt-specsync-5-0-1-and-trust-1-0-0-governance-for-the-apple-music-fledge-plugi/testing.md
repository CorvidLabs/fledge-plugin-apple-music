---
change: CHG-0001-adopt-specsync-5-0-1-and-trust-1-0-0-governance-for-the-apple-music-fledge-plugi
artifact: testing
---

# Testing

- `fledge lanes run verify`
- `specsync check --strict --require-coverage 100 --force`
- `specsync agents status`
- `fledge trust doctor`
- `fledge trust verify`
- Hosted macOS `Build & Test` and `trust` jobs
