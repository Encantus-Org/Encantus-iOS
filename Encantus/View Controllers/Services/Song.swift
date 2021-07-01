//
//  Song.swift
//  Encantus
//
//  Created by Ankit Yadav on 29/06/21.
//

import UIKit
import Foundation

struct Song {
    var name: String
    var album: String
    var artist: [String]
    var cover: UIImage?
    var genres: String
    var urlString: String
}

enum SongStatus {
    case isPlayingg
    case isPausedd
}

class SongService {
    static let shared = SongService()
    
    func checkStatus() -> SongStatus {
        if player.isPlaying {
            return .isPlayingg
        } else {
            return .isPausedd
        }
    }
    
    func sortBy(genres: String, arrayToSort: [Song]) -> [Song] {
        var sorted = [Song]()
        for song in arrayToSort {
            if song.genres == genres{
                sorted.append(song)
            }
        }
        return sorted
    }
}
