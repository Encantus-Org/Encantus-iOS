//
//  Player.swift
//  Encantus
//
//  Created by Ankit Yadav on 01/07/21.
//

import Foundation
import UIKit
import AVFoundation
import MediaPlayer

class MusicPlayer {
    
    var player: AVPlayer!
    var songs = [Song]()
    var position: Int = 0
    
    static let shared = MusicPlayer()
    
    func play() {
        player.play()
    }
    func pause() {
        player.pause()
    }
    func forward() {
        if position < (songs.count - 1) {
            position = position + 1
            player.pause()
        }
//        configure()
    }
    func backward() {
        if position>0 {
            position = position - 1
            player.pause()
        }
//        configure()
    }
    
}
