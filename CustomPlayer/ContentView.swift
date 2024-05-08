//
//  ContentView.swift
//  CustomPlayer
//
//  Created by Blotenko on 08.05.2024.
//

import SwiftUI

struct ContentView: View {
    @State private var currentPage = "recommendations" // Variable for tracking the current page
    
    var body: some View {
        VStack {
            // Main content of the page
            switch currentPage {
            case "search":
                SearchPage()
            case "recommendations":
                RecommendationPage()
            case "playlists":
                PlaylistPage()
            default:
                Text("Page not found")
            }
            
            // Buttons for navigation between pages
            HStack {
                Button(action: {
                    self.currentPage = "search"
                }) {
                    Text("Search")
                        .foregroundColor(currentPage == "search" ? Color.red : Color.blue)
                }
                .padding()
                
                Spacer()
                
                Button(action: {
                    self.currentPage = "recommendations"
                }) {
                    Text("Recommendations")
                        .foregroundColor(currentPage == "recommendations" ? Color.red : Color.blue)
                }
                .padding()
                
                Spacer()
                
                Button(action: {
                    self.currentPage = "playlists"
                }) {
                    Text("Playlists")
                        .foregroundColor(currentPage == "playlists" ? Color.red : Color.blue)
                }
                .padding()
            }
            .frame(height: 50)
            .background(Color(.systemGray6))
        }
        .onAppear {
            self.currentPage = "recommendations" // Set the recommendations page at application startup
        }
    }
}

#Preview {
    ContentView()
}
