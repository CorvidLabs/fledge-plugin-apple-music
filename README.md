# fledge-plugin-apple-music

A [fledge](https://github.com/CorvidLabs/fledge) plugin to control Apple Music from the terminal.

**macOS only** — uses the macOS scripting bridge to communicate with Music.app.

## Install

```bash
fledge plugins install CorvidLabs/fledge-plugin-apple-music
```

## Usage

```bash
# Playback
fledge am play              # Resume playback
fledge am play "Song Name"  # Search and play a specific track
fledge am pause             # Pause
fledge am stop              # Stop
fledge am next              # Next track
fledge am prev              # Previous track

# Info
fledge am now               # Show current track

# Browse
fledge am search "query"    # Search library, pick a track
fledge am playlists         # Browse playlists, pick one

# Volume
fledge am vol up            # Volume up by 10
fledge am vol down          # Volume down by 10
fledge am vol 75            # Set volume to 75%
```

The long form `fledge apple-music` also works for all commands.

## Requirements

- macOS 13+ (Ventura)
- Music.app must be running
- Swift 5.9+

## Development

```bash
swift build
swift build -c release
```

## License

MIT
