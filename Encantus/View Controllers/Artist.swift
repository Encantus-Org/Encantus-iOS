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
