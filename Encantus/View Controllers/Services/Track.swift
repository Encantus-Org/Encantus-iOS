//
//  Song.swift
//  Encantus
//
//  Created by Ankit Yadav on 29/06/21.
//

import Foundation

struct Track: Equatable {
    var uid: String
    var name: String
    var albumId: String
    var artistId: [String]
    var genres: String
    var urlString: String
    var coverUrlString: String
}
