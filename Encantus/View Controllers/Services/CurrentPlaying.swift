//
//  CurrentPlayingModel.swift
//  Encantus
//
//  Created by Ankit Yadav on 02/07/21.
//

import Foundation

var currentPlayingInfo: CurrentPlaying?

struct CurrentPlaying {
    var playingList: [Track]
    var position: Int
}
