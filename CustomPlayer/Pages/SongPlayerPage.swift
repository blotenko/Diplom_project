//
//  SongPlayerPage.swift
//  CustomPlayer
//
//  Created by Blotenko on 08.05.2024.
//

import SwiftUI
import AVFoundation

class Song: Identifiable, ObservableObject {
    var title: String
    var cover: String
    var duration: String
    var artist: String
    var id: Int
    var kind: String
    var audioFileUrl: URL
    @Published var isLiked: Bool
    var listensCount: Int
    
    init(title: String, cover: String, duration: String, artist: String, id: Int, kind: String, audioFileUrl: URL, isLiked: Bool = false, listensCount: Int) {
            self.title = title
            self.cover = cover
            self.duration = duration
            self.artist = artist
            self.id = id
            self.kind = kind
            self.audioFileUrl = audioFileUrl
            self.isLiked = isLiked
            self.listensCount = listensCount
        }
}

class SongManager: ObservableObject {
    static let shared = SongManager()
    
    @Published var songs: [Song]

    private init() {
        songs = [
            Song(title: "Song 1", cover: "cover1", duration: "3:45", artist: "Artist 1", id: 1, kind: "classic", audioFileUrl: Bundle.main.url(forResource: "song1", withExtension: "mp3")!, isLiked: false, listensCount: 0),
                Song(title: "Song 2", cover: "cover2", duration: "2:45", artist: "Artist 2", id: 2, kind: "classic", audioFileUrl: Bundle.main.url(forResource: "song2", withExtension: "mp3")!, isLiked: false, listensCount: 0),
                Song(title: "Song 3", cover: "cover3", duration: "2:45", artist: "Artist 3", id: 3, kind: "classic", audioFileUrl: Bundle.main.url(forResource: "song3", withExtension: "mp3")!, isLiked: false, listensCount: 0),
                Song(title: "Song 4", cover: "cover4", duration: "4:20", artist: "Artist 4", id: 4, kind: "classic", audioFileUrl: Bundle.main.url(forResource: "song4", withExtension: "mp3")!, isLiked: false, listensCount: 0),
                Song(title: "Song 5", cover: "cover5", duration: "3:15", artist: "Artist 5", id: 5, kind: "classic", audioFileUrl: Bundle.main.url(forResource: "song5", withExtension: "mp3")!, isLiked: false, listensCount: 0),
                Song(title: "Song 6", cover: "cover6", duration: "3:30", artist: "Artist 6", id: 6, kind: "classic", audioFileUrl: Bundle.main.url(forResource: "song6", withExtension: "mp3")!, isLiked: false, listensCount: 0),
                Song(title: "Song 7", cover: "cover7", duration: "3:00", artist: "Artist 7", id: 7, kind: "classic", audioFileUrl: Bundle.main.url(forResource: "song7", withExtension: "mp3")!, isLiked: false, listensCount: 0),
                Song(title: "Song 8", cover: "cover8", duration: "2:55", artist: "Artist 8", id: 8, kind: "classic", audioFileUrl: Bundle.main.url(forResource: "song8", withExtension: "mp3")!, isLiked: false, listensCount: 0),
                Song(title: "Song 9", cover: "cover9", duration: "3:10", artist: "Artist 9", id: 9, kind: "classic", audioFileUrl: Bundle.main.url(forResource: "song9", withExtension: "mp3")!, isLiked: false, listensCount: 0),
                Song(title: "Song 10", cover: "cover10", duration: "4:00", artist: "Artist 10", id: 10, kind: "classic", audioFileUrl: Bundle.main.url(forResource: "song10", withExtension: "mp3")!, isLiked: false, listensCount: 0)
               ]
    }
    
    func getById(id: Int) -> Song? {
            return songs.first { $0.id == id }
        }
    
    struct AudioFeatures {
        var valence: Float
        var energy: Float
        
        init(valence: Float, energy: Float) {
            self.valence = valence
            self.energy = energy
        }
    }

    
    func recommendSongs() -> [Song] {
        
        guard let mostListenedSong = songs.max(by: { $0.listensCount < $1.listensCount }) else {
               print("Error")
               return []
           }
        
        guard let trackFeatures = getAudioFeatures(from: getById(id: mostListenedSong.id)!.audioFileUrl) else {
            return []
        }
        
        struct Recommendation {
            var song: Song
            var similarity: Double
        }
        
        var recommendations: [Recommendation] = []
        for song in songs {
            if let songFeatures = getAudioFeatures(from: getById(id: mostListenedSong.id)!.audioFileUrl) {
                let similarity = calculateSimilarity(trackFeatures, songFeatures)
                recommendations.append(Recommendation(song: song, similarity: similarity))
            }
        }
        
       
        recommendations.sort { $0.similarity < $1.similarity }
        return recommendations.prefix(5).map { $0.song }
    }

    func getAudioFeatures(from fileURL: URL) -> AudioFeatures? {
        let asset = AVURLAsset(url: fileURL)
            
        let audioTracks = asset.tracks(withMediaType: .audio)
            
         let audioTrack = audioTracks.first!

         let formatDescription = audioTrack.formatDescriptions.first
            
        let audioStreamBasicDescription = CMAudioFormatDescriptionGetStreamBasicDescription(formatDescription as! CMAudioFormatDescription)?.pointee
        let audioBitrate = audioStreamBasicDescription?.mBitsPerChannel ?? 0
            
        let format = audioTrack.mediaType.hashValue
            
        let audioFeatures = AudioFeatures(valence: Float(format), energy: Float(audioBitrate))
        
        return audioFeatures
    }

    func calculateSimilarity(_ trackFeatures: AudioFeatures, _ songFeatures: AudioFeatures) -> Double {
        let energyDifference = abs(trackFeatures.energy - songFeatures.energy)
        let valenceDifference = abs(trackFeatures.valence - songFeatures.valence)
        
        let totalDifference = energyDifference +  valenceDifference
        
        let maxDifference = Double(2)
        
        let similarity = 1.0 - (Double(totalDifference) / maxDifference)
        
        return similarity
    }

}

struct SongPlayerPage: View {
    var song: Song
    @State private var isPlaying: Bool = false
    @State private var isPlaylistSelectionPresented = false
    @State private var newPlaylistName: String = ""
    @State private var isCreatingNewPlaylist = false
    @State private var existingPlaylists: [Playlist] = []
    @StateObject var playlistManager: PlaylistManager
    @StateObject var songManager = SongManager.shared
    @State private var player: AVAudioPlayer?
    @State private var isLiked: Bool = false
    
    init(song: Song, playlistManager: PlaylistManager) {
        self.song = song
        self.isLiked = song.isLiked
        self._playlistManager = StateObject(wrappedValue: playlistManager)
    }

    var body: some View {
        VStack {
            Image(song.cover)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200)
                .padding()
            
            Text(song.title)
                .font(.title)
                .padding()
            
            Text("Duration: \(song.duration)")
                .padding()
            
            Button(action: {
                 var audioFileUrl = song.audioFileUrl 
                    if isPlaying {
                        player?.pause()
                    } else {
                        do {
                            player = try AVAudioPlayer(contentsOf: audioFileUrl)
                            player?.play()
                        } catch {
                            print("Ошибка при воспроизведении аудио: \(error.localizedDescription)")
                        }
                    }
                    self.isPlaying.toggle()
                song.listensCount += 1
                
            }) {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .foregroundColor(.blue)
            }
            Button(action: {
                            self.isLiked.toggle()
                            song.isLiked = self.isLiked
                
                        }) {
                            Image(systemName: isLiked ? "heart.fill" : "heart")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30)
                                .foregroundColor(isLiked ? .red : .gray)
                        }
                        .padding(.top, 20)

            
            HStack {
                Button(action: {
                    self.isPlaylistSelectionPresented = true
                }) {
                    Text("Add to playlist")
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                
                Button(action: {
                    self.isCreatingNewPlaylist = true
                }) {
                    Text("Add to new playlist")
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
            }
            .padding(.top)
            .sheet(isPresented: $isPlaylistSelectionPresented) {
                NavigationView {
                    List {
                        ForEach(existingPlaylists, id: \.self) { playlist in
                            Button(action: {
                                playlistManager.addSongToPlaylist(playlistName: playlist.name, song: song)
                                print("Added to playlist: \(playlist)")
                                self.isPlaylistSelectionPresented = false
                            }) {
                                Text(playlist.name)
                            }
                        }
                    }
                    .navigationBarTitle("Select a playlist")
                }
                .onAppear {
                    playlistManager.loadPlaylists()
                    existingPlaylists = playlistManager.playlists
                }
            }
            Spacer()
        }
        .navigationBarTitle(Text("Playback"), displayMode: .inline)
        .sheet(isPresented: $isCreatingNewPlaylist) {
            VStack {
                TextField("Playlist name", text: $newPlaylistName)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                
                Button("Create") {
                    playlistManager.addPlaylist(newPlaylistName)
                    playlistManager.addSongToPlaylist(playlistName: newPlaylistName, song: song)
                    print("New playlist: \(newPlaylistName)")
                    existingPlaylists.append(Playlist(name: newPlaylistName, songs: []))
                    self.isPlaylistSelectionPresented = false
                    self.isCreatingNewPlaylist = false
                }
                .padding()
            }
            .padding(.vertical)
            .navigationBarTitle("New playlist", displayMode: .inline)
        }
        .onAppear {
            existingPlaylists = playlistManager.playlists
        }
    }
}

#Preview {
    SongPlayerPage(song: Song(title: "Test",cover: "Test", duration: "Test", artist: "artist 1", id: 1, kind: "classic", audioFileUrl: Bundle.main.url(forResource: "song1", withExtension: "mp3")!, isLiked: false, listensCount: 0), playlistManager: PlaylistManager())
}
