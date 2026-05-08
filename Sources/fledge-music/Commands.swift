import Foundation

struct Commands {
    let bridge = MusicBridge()
    let useProtocol: Bool

    func run(_ args: [String]) -> Int32 {
        guard let subcommand = args.first else {
            printHelp()
            return 0
        }

        do {
            switch subcommand {
            case "play":
                let name = args.dropFirst().joined(separator: " ")
                try handlePlay(name.isEmpty ? nil : name)
            case "pause":
                try bridge.pause()
                printDirect("Paused.")
            case "stop":
                try bridge.stop()
                printDirect("Stopped.")
            case "next":
                try bridge.nextTrack()
                if let np = try bridge.nowPlaying() {
                    printDirect("Now playing: \(np.name) — \(np.artist)")
                }
            case "prev":
                try bridge.prevTrack()
                if let np = try bridge.nowPlaying() {
                    printDirect("Now playing: \(np.name) — \(np.artist)")
                }
            case "now":
                try handleNow()
            case "search":
                let query = args.dropFirst().joined(separator: " ")
                guard !query.isEmpty else {
                    printDirect("Usage: fledge am search <query>")
                    return 1
                }
                try handleSearch(query)
            case "playlists":
                try handlePlaylists()
            case "vol", "volume":
                guard args.count > 1 else {
                    let vol = try bridge.getVolume()
                    printDirect("Volume: \(vol)%")
                    return 0
                }
                try handleVolume(args[1])
            case "--help", "-h", "help":
                printHelp()
            default:
                printDirect("Unknown command: \(subcommand)")
                printHelp()
                return 1
            }
        } catch let error as MusicError {
            printDirect("Error: \(error.description)")
            return 1
        } catch {
            printDirect("Error: \(error.localizedDescription)")
            return 1
        }

        return 0
    }

    private func handlePlay(_ name: String?) throws {
        if let name = name {
            let tracks = try bridge.playTrackByName(name)
            if tracks.isEmpty {
                printDirect("No tracks found for '\(name)'")
                return
            }
            if tracks.count == 1 {
                printDirect("Playing: \(tracks[0].name) — \(tracks[0].artist)")
                return
            }
            if useProtocol {
                let options = tracks.map { "\($0.name) — \($0.artist) (\($0.album))" }
                FledgeProtocol.sendSelect(id: "pick-track", message: "Multiple matches for '\(name)'. Pick a track:", options: options)
                if let response = FledgeProtocol.readResponse(),
                   let selected = response.value?.stringValue,
                   let idx = options.firstIndex(of: selected) {
                    try bridge.playTrackById(tracks[idx].id)
                    FledgeProtocol.sendOutput("Playing: \(tracks[idx].name) — \(tracks[idx].artist)")
                }
            } else {
                printDirect("Multiple matches found:")
                for (i, t) in tracks.enumerated() {
                    printDirect("  \(i + 1). \(t.name) — \(t.artist) (\(t.album))")
                }
                printDirect("Tip: install with fledge-v1 protocol for interactive selection.")
                try bridge.playTrackById(tracks[0].id)
                printDirect("Playing first match: \(tracks[0].name)")
            }
        } else {
            try bridge.play()
            if let np = try bridge.nowPlaying() {
                printDirect("Playing: \(np.name) — \(np.artist)")
            } else {
                printDirect("Playback resumed.")
            }
        }
    }

    private func handleNow() throws {
        guard let np = try bridge.nowPlaying() else {
            printDirect("Nothing playing.")
            return
        }
        let pos = formatTime(np.position)
        let dur = formatTime(np.duration)
        printDirect("\(np.state == "playing" ? "▶" : "⏸") \(np.name)")
        printDirect("  \(np.artist) — \(np.album)")
        printDirect("  \(pos) / \(dur)")
    }

    private func handleSearch(_ query: String) throws {
        let tracks = try bridge.searchLibrary(query)
        if tracks.isEmpty {
            printDirect("No tracks found for '\(query)'")
            return
        }

        if useProtocol {
            let options = tracks.map { "\($0.name) — \($0.artist) (\($0.album))" }
            FledgeProtocol.sendSelect(id: "pick-track", message: "Search results for '\(query)':", options: options)
            if let response = FledgeProtocol.readResponse(),
               let selected = response.value?.stringValue,
               let idx = options.firstIndex(of: selected) {
                try bridge.playTrackById(tracks[idx].id)
                FledgeProtocol.sendOutput("Playing: \(tracks[idx].name) — \(tracks[idx].artist)")
            }
        } else {
            printDirect("Search results for '\(query)':")
            for (i, t) in tracks.enumerated() {
                printDirect("  \(i + 1). \(t.name) — \(t.artist) (\(t.album))")
            }
        }
    }

    private func handlePlaylists() throws {
        let playlists = try bridge.getPlaylists()
        if playlists.isEmpty {
            printDirect("No playlists found.")
            return
        }

        if useProtocol {
            let options = playlists.map { "\($0.name) (\($0.trackCount) tracks)" }
            FledgeProtocol.sendSelect(id: "pick-playlist", message: "Your playlists:", options: options)
            if let response = FledgeProtocol.readResponse(),
               let selected = response.value?.stringValue,
               let idx = options.firstIndex(of: selected) {
                try bridge.playPlaylist(playlists[idx].name)
                FledgeProtocol.sendOutput("Playing playlist: \(playlists[idx].name)")
            }
        } else {
            printDirect("Your playlists:")
            for (i, p) in playlists.enumerated() {
                printDirect("  \(i + 1). \(p.name) (\(p.trackCount) tracks)")
            }
        }
    }

    private func handleVolume(_ arg: String) throws {
        switch arg {
        case "up":
            let current = try bridge.getVolume()
            let newVol = min(100, current + 10)
            try bridge.setVolume(newVol)
            printDirect("Volume: \(newVol)%")
        case "down":
            let current = try bridge.getVolume()
            let newVol = max(0, current - 10)
            try bridge.setVolume(newVol)
            printDirect("Volume: \(newVol)%")
        default:
            guard let level = Int(arg), level >= 0, level <= 100 else {
                printDirect("Usage: fledge am vol <up|down|0-100>")
                return
            }
            try bridge.setVolume(level)
            printDirect("Volume: \(level)%")
        }
    }

    private func printDirect(_ message: String) {
        if useProtocol {
            FledgeProtocol.sendOutput(message)
        } else {
            fputs(message + "\n", stdout)
            fflush(stdout)
        }
    }

    private func formatTime(_ seconds: Double) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }

    private func printHelp() {
        let help = """
        fledge apple-music (am) — Control Apple Music from the terminal

        Usage: fledge am <command> [args]

        Commands:
          play [name]       Resume playback, or play a track by name
          pause             Pause playback
          stop              Stop playback
          next              Skip to next track
          prev              Go to previous track
          now               Show current track info
          search <query>    Search library and pick a track to play
          playlists         Browse and play a playlist
          vol <up|down|N>   Adjust volume (up/down by 10, or set 0-100)
          help              Show this help message
        """
        if useProtocol {
            FledgeProtocol.sendOutput(help)
        } else {
            Swift.print(help)
        }
    }
}
