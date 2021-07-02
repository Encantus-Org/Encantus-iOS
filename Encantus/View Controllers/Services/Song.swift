//
//  Song.swift
//  Encantus
//
//  Created by Ankit Yadav on 29/06/21.
//

import UIKit
import Foundation

struct Song: Equatable {
    var name: String
    var album: String
    var artist: [String]
    var genres: String
    var urlString: String
    var coverUrlString: String
}
