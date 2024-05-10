//
//  PlaylistPageTests.swift
//  CustomPlayerTests
//
//  Created by Blotenko on 10.05.2024.
//

import XCTest
import SwiftUI

@testable import CustomPlayer

class PlaylistPageTests: XCTestCase {

    func testPlaylistPage() throws {
        let playlists: [Playlist] = [Playlist(name: "Test Playlist 1", songs: [2]), Playlist(name: "Test Playlist 2", songs: [1])]

        let playlistManager = PlaylistManager()
        playlistManager.playlists = playlists

        let contentView = PlaylistPage()
                    .environmentObject(playlistManager)
                
        let view = UIHostingController(rootView: contentView)
                
        view.loadView()
                
        XCTAssertEqual(playlistManager.playlists.count, 2)
        XCTAssertEqual(playlistManager.playlists[0].name, "Test Playlist 1")
        XCTAssertEqual(playlistManager.playlists[1].name, "Test Playlist 2")
    }
}

