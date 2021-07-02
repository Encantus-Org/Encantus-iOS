//
//  Artist.swift
//  Encantus
//
//  Created by Ankit Yadav on 02/07/21.
//

import Foundation

struct Artist: Equatable {
    var uid: String // = userName
    var name: String
    var profileImageUrl: String
    var albumsId: [String]
    var tracksId: [String]
    var isVerified: Bool
    var followers: Int
    var origin: String
}

struct Album: Equatable {
    var uid: String
    var name: String
    var albumCoverUrl: String
    var genres: String
    var artistId: [String]
    var trackId: [String]
}
