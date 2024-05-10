//
//  PlaylistPage.swift
//  CustomPlayer
//
//  Created by Blotenko on 08.05.2024.
//
import SwiftUI

struct Playlist: Codable, Hashable {
    var name: String
    var songs: [Int]
    
    func hash(into hasher: inout Hasher) {
            hasher.combine(name)
        }
}

struct PlaylistPage: View {
    @State private var playlists: [Playlist] = []
    @State private var newPlaylistName: String = ""
    @StateObject var playlistManager = PlaylistManager()
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(playlists, id: \.self) { playlist in
                        NavigationLink(destination: PlaylistDetailView(playlistName: playlist.name, playlistManager: playlistManager)) {
                            Text(playlist.name)
                                .padding(.vertical, 4)
                        }
                    }
                    //.onDelete(perform: deletePlaylist)
                }
                .padding(.horizontal)
                
                HStack {
                    TextField("Enter new playlist name", text: $newPlaylistName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button("Create") {
                        if !newPlaylistName.isEmpty {
                            playlistManager.addPlaylist(newPlaylistName)
                            newPlaylistName = ""
                            playlistManager.loadPlaylists()
                            playlists = playlistManager.playlists
                        }
                    }
                }
                .padding()
                
                Spacer()
            }
            .onAppear {
                playlists = playlistManager.playlists
            }
            .navigationTitle("Playlists")
        }
    }
    
    private func deletePlaylist(_ playlistName: String) {
        playlistManager.deletePlaylist(playlistName)
    }
}

struct PlaylistDetailView: View {
    var playlistName: String
    @State private var songIds: [Int] = []
    @State private var songs: [Song] = []
    @State private var selectedSong: Song?
    @State private var isPlayerSheetPresented = false
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var playlistManager: PlaylistManager
    var songManager = SongManager.shared // Добавлен экземпляр SongManager

    var body: some View {
        VStack {
            Text(playlistName)
                .font(.title)
                .padding()
            
            List(songs, id: \.id) { song in
                Button(action: {
                    self.selectedSong = song
                    self.isPlayerSheetPresented = true
                }) {
                    HStack {
                        Image(systemName: "music.note")
                        Text(song.title)
                    }
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .onAppear {
            songIds = playlistManager.songIds(forPlaylist: playlistName)
            songs = songIds.compactMap { songManager.getById(id: $0) } // Получаем песни по их id
            selectedSong = songs.first
        }
        .sheet(isPresented: $isPlayerSheetPresented) {
            if let selectedSong = self.selectedSong {
                SongPlayerPage(song: selectedSong, playlistManager: playlistManager)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "arrow.left")
                .foregroundColor(.blue)
                .imageScale(.large)
        }, trailing: Button(action: {
            playlistManager.deletePlaylist(playlistName)
            presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "trash")
                .foregroundColor(.red)
                .imageScale(.large)
        })
    }
}




class PlaylistManager: ObservableObject {
        
    init() {
        loadPlaylists()
    }
    @Published var playlists: [Playlist] = UserDefaults.standard.data(forKey: "playlists").flatMap {
        try? JSONDecoder().decode([Playlist].self, from: $0)
    } ?? []
    
    private func savePlaylists() {
        if let encoded = try? JSONEncoder().encode(playlists) {
            UserDefaults.standard.set(encoded, forKey: "playlists")
        }
    }
    
    func addPlaylist(_ playlistName: String) {
        let newPlaylist = Playlist(name: playlistName, songs: [])
        playlists.append(newPlaylist)
        savePlaylists() // Сохраняем изменения
    }
    
    func songs(forPlaylist playlistName: String) -> [Song] {
        return []
    }
    
    func addSongToPlaylist(playlistName: String, song: Song) {
        if let index = playlists.firstIndex(where: { $0.name == playlistName }) {
            playlists[index].songs.append(song.id)
            savePlaylists()
        }
    }
    
    func deletePlaylist(_ playlistName: String) {
        if let index = playlists.firstIndex(where: { $0.name == playlistName }) {
            playlists.remove(at: index)
            savePlaylists()
        }
    }
    
    func loadPlaylists() {
            if let data = UserDefaults.standard.data(forKey: "playlists") {
                if let loadedPlaylists = try? JSONDecoder().decode([Playlist].self, from: data) {
                    playlists = loadedPlaylists
                }
            }
        }
    
    func songIds(forPlaylist playlistName: String) -> [Int] {
            if let playlist = playlists.first(where: { $0.name == playlistName }) {
                return playlist.songs
            } else {
                return []
            }
        }
    
}


struct PlaylistPage_Preview: PreviewProvider {
    static var previews: some View {
        let playlistManager = PlaylistManager()
        playlistManager.addPlaylist("My Test Playlist")
        playlistManager.addSongToPlaylist(playlistName: "My Test Playlist", song: Song(title: "song 1", cover: "Cover 1", duration: "3:30", artist: "ar1", id: 1, kind: "classic", audioFileUrl: Bundle.main.url(forResource: "song1", withExtension: "mp3")!))
        playlistManager.addSongToPlaylist(playlistName: "My Test Playlist", song: Song(title: "song 2", cover: "Cover 2", duration: "4:00", artist: "ar2", id: 2, kind: "classic", audioFileUrl: Bundle.main.url(forResource: "song1", withExtension: "mp3")!))
        
        return PlaylistPage()
            .environmentObject(playlistManager)
    }
}


