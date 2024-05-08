//
//  RecommendationPage.swift
//  CustomPlayer
//
//  Created by Blotenko on 08.05.2024.
//
import SwiftUI

struct RecommendationPage: View {
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
                            Image(systemName: "music.note")
                            Text(song.title)
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .onAppear {
                
                recommendedSongs = (1...5).map { Song(title: "Song \($0)", cover: "cover\($0)", duration: "\(3 + $0):\(30 - $0)") }
                
                selectedSong = recommendedSongs.first
            }
            .sheet(isPresented: $isPlayerSheetPresented) {
                
                if let selectedSong = self.selectedSong {
                    SongPlayerPage(song: selectedSong)
                }
            }
            .navigationTitle("Recommendations")
        }
    }
}

#Preview {
    RecommendationPage()
}

