//
//  SongPlayerPage.swift
//  CustomPlayer
//
//  Created by Blotenko on 08.05.2024.
//

import SwiftUI

struct Song {
    var title: String
    var cover: String
    var duration: String
}

struct SongPlayerPage: View {
    var song: Song
    @State private var isPlaying: Bool = false
    @State private var isPlaylistSelectionPresented = false
    @State private var newPlaylistName: String = ""
    @State private var isCreatingNewPlaylist = false
    @State private var existingPlaylists: [String] = ["My Playlist 1", "My Playlist 2"]

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
                    Text("Select a playlist")
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                
                Button(action: {
                    
                    self.isCreatingNewPlaylist = true
                }) {
                    Text("Create a new playlist")
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
                                
                                print("Added to playlist: \(playlist)")
                                self.isPlaylistSelectionPresented = false
                            }) {
                                Text(playlist)
                            }
                        }
                    }
                    .navigationBarTitle("Select a playlist")
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
                    
                    print("New playlist: \(newPlaylistName)")
                    existingPlaylists.append(newPlaylistName);
                    self.isPlaylistSelectionPresented = false
                    self.isCreatingNewPlaylist = false
                }
                .padding()
            }
            .padding(.vertical)
            .navigationBarTitle("New playlist", displayMode: .inline)
        }
    }
}


#Preview {
    SongPlayerPage(song: Song(title: "Test",cover: "Test", duration: "Test"))
}
