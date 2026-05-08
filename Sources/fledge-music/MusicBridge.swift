import Foundation

struct NowPlaying {
    let name: String
    let artist: String
    let album: String
    let position: Double
    let duration: Double
    let state: String
}

struct Track {
    let id: String
    let name: String
    let artist: String
    let album: String
}

struct Playlist {
    let name: String
    let trackCount: Int
}

enum MusicError: Error, CustomStringConvertible {
    case notRunning
    case scriptError(String)
    case noResults(String)

    var description: String {
        switch self {
        case .notRunning:
            return "Music.app is not running. Open it first."
        case .scriptError(let msg):
            return "AppleScript error: \(msg)"
        case .noResults(let query):
            return "No results found for '\(query)'"
        }
    }
}

struct MusicBridge {
    private func run(_ source: String) throws -> String {
        let script = NSAppleScript(source: source)!
        var errorInfo: NSDictionary?
        let result = script.executeAndReturnError(&errorInfo)
        if let error = errorInfo {
            let msg = error[NSAppleScript.errorMessage] as? String ?? "Unknown error"
            if msg.contains("not running") || msg.contains("(-600)") {
                throw MusicError.notRunning
            }
            throw MusicError.scriptError(msg)
        }
        return result.stringValue ?? ""
    }

    func isRunning() -> Bool {
        let source = """
        tell application "System Events"
            return (name of processes) contains "Music"
        end tell
        """
        return (try? run(source))?.lowercased() == "true"
    }

    func ensureRunning() throws {
        if !isRunning() {
            throw MusicError.notRunning
        }
    }

    func play() throws {
        try ensureRunning()
        _ = try run("tell application \"Music\" to play")
    }

    func pause() throws {
        try ensureRunning()
        _ = try run("tell application \"Music\" to pause")
    }

    func stop() throws {
        try ensureRunning()
        _ = try run("tell application \"Music\" to stop")
    }

    func nextTrack() throws {
        try ensureRunning()
        _ = try run("tell application \"Music\" to next track")
    }

    func prevTrack() throws {
        try ensureRunning()
        _ = try run("tell application \"Music\" to previous track")
    }

    func nowPlaying() throws -> NowPlaying? {
        try ensureRunning()
        let source = """
        tell application "Music"
            if player state is stopped then
                return "STOPPED"
            end if
            set trackName to name of current track
            set trackArtist to artist of current track
            set trackAlbum to album of current track
            set trackPos to player position
            set trackDur to duration of current track
            set pState to player state as string
            return trackName & "|||" & trackArtist & "|||" & trackAlbum & "|||" & (trackPos as string) & "|||" & (trackDur as string) & "|||" & pState
        end tell
        """
        let result = try run(source)
        if result == "STOPPED" { return nil }
        let parts = result.components(separatedBy: "|||")
        guard parts.count >= 6 else { return nil }
        return NowPlaying(
            name: parts[0],
            artist: parts[1],
            album: parts[2],
            position: Double(parts[3]) ?? 0,
            duration: Double(parts[4]) ?? 0,
            state: parts[5]
        )
    }

    func getVolume() throws -> Int {
        try ensureRunning()
        let result = try run("tell application \"Music\" to get sound volume")
        return Int(result) ?? 50
    }

    func setVolume(_ level: Int) throws {
        try ensureRunning()
        let clamped = max(0, min(100, level))
        _ = try run("tell application \"Music\" to set sound volume to \(clamped)")
    }

    func searchLibrary(_ query: String) throws -> [Track] {
        try ensureRunning()
        let escaped = query.replacingOccurrences(of: "\"", with: "\\\"")
        let source = """
        tell application "Music"
            set results to {}
            set matchedTracks to (search playlist "Library" for "\(escaped)")
            if matchedTracks is {} then return ""
            set maxResults to 20
            if (count of matchedTracks) < maxResults then set maxResults to (count of matchedTracks)
            repeat with i from 1 to maxResults
                set t to item i of matchedTracks
                set tid to persistent ID of t
                set tname to name of t
                set tartist to artist of t
                set talbum to album of t
                set end of results to tid & ":::" & tname & ":::" & tartist & ":::" & talbum
            end repeat
            set AppleScript's text item delimiters to "|||"
            return results as string
        end tell
        """
        let result = try run(source)
        if result.isEmpty { return [] }
        return result.components(separatedBy: "|||").compactMap { entry in
            let parts = entry.components(separatedBy: ":::")
            guard parts.count >= 4 else { return nil }
            return Track(id: parts[0], name: parts[1], artist: parts[2], album: parts[3])
        }
    }

    func getPlaylists() throws -> [Playlist] {
        try ensureRunning()
        let source = """
        tell application "Music"
            set results to {}
            set allPlaylists to user playlists
            repeat with p in allPlaylists
                set pname to name of p
                set pcount to count of tracks of p
                set end of results to pname & ":::" & (pcount as string)
            end repeat
            set AppleScript's text item delimiters to "|||"
            return results as string
        end tell
        """
        let result = try run(source)
        if result.isEmpty { return [] }
        return result.components(separatedBy: "|||").compactMap { entry in
            let parts = entry.components(separatedBy: ":::")
            guard parts.count >= 2 else { return nil }
            return Playlist(name: parts[0], trackCount: Int(parts[1]) ?? 0)
        }
    }

    func playTrackById(_ id: String) throws {
        try ensureRunning()
        let escaped = id.replacingOccurrences(of: "\"", with: "\\\"")
        let source = """
        tell application "Music"
            set matchedTracks to (every track of playlist "Library" whose persistent ID is "\(escaped)")
            if matchedTracks is not {} then
                play item 1 of matchedTracks
            end if
        end tell
        """
        _ = try run(source)
    }

    func playPlaylist(_ name: String) throws {
        try ensureRunning()
        let escaped = name.replacingOccurrences(of: "\"", with: "\\\"")
        _ = try run("tell application \"Music\" to play playlist \"\(escaped)\"")
    }

    func playTrackByName(_ name: String) throws -> [Track] {
        let tracks = try searchLibrary(name)
        if tracks.count == 1 {
            try playTrackById(tracks[0].id)
        }
        return tracks
    }
}
