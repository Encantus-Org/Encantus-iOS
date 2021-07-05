//
//  TrackService.swift
//  Encantus
//
//  Created by Ankit Yadav on 02/07/21.
//

import Foundation

enum TrackStatus {
    case isPlayingg
    case isPausedd
    case undefined
}

class TrackService {
    
    static let shared = TrackService()
    
    func checkStatus() -> TrackStatus {
        //using miniplayer to test player capabilities
        let player = MiniPlayer.shared.player
        guard player != nil else {
            return .isPausedd
        }
        return .isPlayingg
    }
    
    func checkIfPaused() -> TrackStatus {
        let player = MiniPlayer.shared.player
        guard player?.isPlaying != false else { return .isPausedd }
        return .isPlayingg
    }
    
    func sortBy(genres: String, arrayToSort: [Track]) -> [Track] {
        var sorted = [Track]()
        for track in arrayToSort {
            if track.genres == genres{
                sorted.append(track)
            }
        }
        return sorted
    }
    
    func checkIfAleradyPlaying() -> TrackStatus {
        let position = currentPlayingInfo?.position
        let currentPlaying = currentPlayingInfo?.playingList[position!]
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
