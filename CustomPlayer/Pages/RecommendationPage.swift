//
//  RecommendationPage.swift
//  CustomPlayer
//
//  Created by Blotenko on 08.05.2024.
//
import SwiftUI

struct RecommendationPage: View {
    @StateObject var songManager = SongManager.shared
    @State private var recommendedSongs: [Song] = []
    @State private var selectedSong: Song?
    @State private var isPlayerSheetPresented = false
    
    var body: some View {
        NavigationView {
            VStack {
                List(recommendedSongs, id: \.title) { song in
                    Button(action: {
                        self.selectedSong = song
                        self.isPlayerSheetPresented = true
                    }) {
                        HStack {
                            Image(song.cover)
                                .resizable()
                                .frame(width: 50, height: 50)
                                .cornerRadius(8)
                                .padding(.trailing, 8)
                            
                            Text(song.title)
                                .font(.body)
                        }
                    }
                    .padding(.vertical, 8)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .onAppear {
                recommendedSongs = songManager.recommendSongs()
                selectedSong = recommendedSongs.first
            }
            .sheet(isPresented: $isPlayerSheetPresented) {
                if let selectedSong = self.selectedSong {
                    SongPlayerPage(song: selectedSong, playlistManager: PlaylistManager())
                }
            }
            .navigationTitle("Recommendations")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    RecommendationPage()
}

