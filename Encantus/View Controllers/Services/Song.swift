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
    var artist: String
    var artist2: String
    var cover: UIImage?
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
}
