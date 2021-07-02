//
//  SongService.swift
//  Encantus
//
//  Created by Ankit Yadav on 02/07/21.
//

import Foundation

enum SongStatus {
    case isPlayingg
    case isPausedd
    case undefined
}

class SongService {
    
    static let shared = SongService()
    
    func checkStatus() -> SongStatus {
        //using miniplayer to test player capabilities
        let player = MiniPlayer.shared.player
        guard player != nil else {
            return .isPausedd
        }
        return .isPlayingg
    }
    
    func checkIfPaused() -> SongStatus {
        let player = MiniPlayer.shared.player
        guard player?.isPlaying != false else { return .isPausedd }
        return .isPlayingg
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
    
    func checkIfAleradyPlaying() -> SongStatus {
        let position = currentPlayingInfo?.position
        let currentPlaying = currentPlayingInfo?.array[position!]
        guard currentPlaying != nil else {
            return .undefined
        }
        if currentPlaying == nil {
            return .isPausedd
        }else {
            return .isPlayingg
        }
    }
}
