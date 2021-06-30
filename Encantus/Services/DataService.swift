//
//  DataService.swift
//  Encantus
//
//  Created by Ankit Yadav on 29/06/21.
//

import Foundation
import Combine
import UIKit

class DataService {
    static let shared = DataService()
    
    func getCategories() -> Future<[String],Error> {
        return Future { promixe in
            promixe(.success(["Punjabi","Bollywood"]))
        }
    }
    
    func getSongs() -> Future<[Song],Error> {
        return Future { promixe in
            var songsarr = [Song]()
            songsarr.append(Song(name: "SidhuSon", album: "Moosetape", artist: "Sidhu Moosewala", artist2: "NaN", cover: UIImage(named: "sample-cover")))
            songsarr.append(Song(name: "Regret", album: "Moosetape", artist: "Sidhu Moosewala", artist2: "NaN", cover: UIImage(named: "regret-cover")))
            promixe(.success(songsarr))
        }
    }
}
