# fledge-plugin-apple-music

Apple Music controls for fledge — play, pause, skip, search, and browse your library from the terminal.

## Install

```bash
fledge plugins install CorvidLabs/fledge-plugin-apple-music
```

## Usage

```bash
fledge am play              # Resume playback
fledge am play "Song Name"  # Search and play a specific track
fledge am pause             # Pause
fledge am stop              # Stop
fledge am next              # Next track
fledge am prev              # Previous track
fledge am now               # Show current track
fledge am search "query"    # Search library, pick a track
fledge am playlists         # Browse playlists, pick one
fledge am vol up            # Volume up by 10
fledge am vol down          # Volume down by 10
fledge am vol 75            # Set volume to 75%
```

The long form `fledge apple-music` also works for all commands.

## How it works

This plugin runs via the [fledge-v1 plugin protocol](https://corvidlabs.github.io/fledge/). Built in Swift, it uses `NSAppleScript` to communicate directly with Music.app via the macOS scripting bridge. No API keys, no developer account — just needs Music.app running.

Interactive commands (`search`, `playlists`) use the fledge-v1 `select` prompt for picking from results.

## Requirements

- macOS 13+ (Ventura)
- Music.app must be running
- Swift 5.9+ (for building from source)

## Development

```bash
swift build
swift build -c release
.build/debug/fledge-music --help
```

## License

MIT
