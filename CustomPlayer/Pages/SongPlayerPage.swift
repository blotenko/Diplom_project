//
//  SongPlayerPage.swift
//  CustomPlayer
//
//  Created by Blotenko on 08.05.2024.
//

import SwiftUI
import AVFoundation

struct Song {
    var title: String
    var cover: String
    var duration: String
    var artist: String
    var id: Int
    var kind: String
    var audioFileUrl: URL
}

class SongManager: ObservableObject {
    static let shared = SongManager()
    
    @Published var songs: [Song]

    private init() {
        songs = [
                   Song(title: "Song 1", cover: "cover1", duration: "3:45", artist: "Artist 1", id: 1, kind: "classic", audioFileUrl: Bundle.main.url(forResource: "song1", withExtension: "mp3")!),
                   Song(title: "Song 2", cover: "cover2", duration: "2:45", artist: "Artist 2", id: 2, kind: "classic", audioFileUrl: Bundle.main.url(forResource: "song2", withExtension: "mp3")!),
                   
               ]
    }
    
    func getById(id: Int) -> Song? {
            return songs.first { $0.id == id }
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
    @StateObject var songManager = SongManager.shared // Добавлен SongManager
    @State private var player: AVAudioPlayer?
    
    init(song: Song, playlistManager: PlaylistManager) {
        self.song = song
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
                
            }) {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .foregroundColor(.blue)
            }

            
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
    SongPlayerPage(song: Song(title: "Test",cover: "Test", duration: "Test", artist: "artist 1", id: 1, kind: "classic", audioFileUrl: Bundle.main.url(forResource: "song1", withExtension: "mp3")!), playlistManager: PlaylistManager())
}
