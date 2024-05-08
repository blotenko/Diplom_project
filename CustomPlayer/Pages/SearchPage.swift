//
//  SearchPage.swift
//  CustomPlayer
//
//  Created by Blotenko on 08.05.2024.
//
import SwiftUI

struct SearchPage: View {
    @State private var searchText: String = ""
    @State private var searchResults: [Song] = []
    @State private var selectedSong: Song?
    @State private var isPlayerSheetPresented = false

    var body: some View {
        NavigationView {
        VStack {
            TextField("Search", text: $searchText)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal)
            
            Button(action: {
                searchResults = [
                    Song(title: "Song 1", cover: "cover1", duration: "3:45"),
                    Song(title: "Song 2", cover: "cover2", duration: "4:20"),
                ]
                selectedSong = searchResults.first
            }) {
                Text("Search")
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(8)
                    .padding(.horizontal)
            }
            
            List(searchResults, id: \.title) { song in
                Button(action: {
                    self.selectedSong = song
                    self.isPlayerSheetPresented = true
                }) {
                    HStack {
                        Image(song.cover)
                            .resizable()
                            .frame(width: 50, height: 50)
                            .cornerRadius(8)
                        Text(song.title)
                            .font(.headline)
                    }
                }
                .buttonStyle(PlainButtonStyle()) 
            }
            .padding(.top)
        }
        .onAppear {
            selectedSong = searchResults.first
        }
        .padding(.horizontal)
        .sheet(isPresented: $isPlayerSheetPresented) {
            if let selectedSong = self.selectedSong {
                SongPlayerPage(song: selectedSong)
            }
        }
        .onTapGesture {
            
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        .navigationTitle("Search")
    }
    }
}

#Preview {
    SearchPage()
}
