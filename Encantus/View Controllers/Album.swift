//
//  Album.swift
//  Encantus
//
//  Created by Ankit Yadav on 05/07/21.
//

import Foundation

struct Album: Equatable {
    var uid: String
    var name: String
    var albumCoverUrl: String
    var genres: String
    var artistId: [String]
    var trackId: [String]
}
