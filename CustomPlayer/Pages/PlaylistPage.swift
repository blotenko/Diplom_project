//
//  PlaylistPage.swift
//  CustomPlayer
//
//  Created by Blotenko on 08.05.2024.
//
import SwiftUI

struct PlaylistPage: View {
    @State private var playlists: [String] = []
    
    var body: some View {
        NavigationView {
            VStack {
                List(playlists, id: \.self) { playlist in
                    NavigationLink(destination: PlaylistDetailView(playlistName: playlist)) {
                        Text(playlist)
                            .padding(.vertical, 4)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .onAppear {
                
                playlists = (1...5).map { "Playlist \($0)" }
            }
            .navigationTitle("Playlists")
        }
    }
}

struct PlaylistDetailView: View {
    var playlistName: String
    @State private var songs: [Song] = []
    @State private var selectedSong: Song?
    @State private var isPlayerSheetPresented = false
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        VStack {
            Text(playlistName)
                .font(.title)
                .padding()
            
            List(songs, id: \.title) { song in
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
            
            songs = (1...5).map { Song(title: "Song \($0)", cover: "cover\($0)", duration: "\(3 + $0):\(30 - $0)") }
            
            selectedSong = songs.first
        }
        .sheet(isPresented: $isPlayerSheetPresented) {
            
            if let selectedSong = self.selectedSong {
                SongPlayerPage(song: selectedSong)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            
            presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "arrow.left")
                .foregroundColor(.blue)
                .imageScale(.large)
        })
    }
}


#Preview {
    PlaylistPage()
}
