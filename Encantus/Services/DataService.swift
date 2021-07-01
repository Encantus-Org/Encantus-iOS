//
//  DataService.swift
//  Encantus
//
//  Created by Ankit Yadav on 29/06/21.
//

import Foundation
import Combine
import UIKit
import Alamofire
import AlamofireImage

class DataService {
    static let shared = DataService()
    
    func getCategories() -> Future<[String],Error> {
        return Future { promixe in
            promixe(.success(["All","Punjabi","Bollywood"]))
        }
    }
    
    func getSongs() -> Future<[Song],Error> {
        return Future { promixe in
            var songsarr = [Song]()
            songsarr.append(Song(name: "Sidhu Son", album: "Moosetape", artist: ["Sidhu Moosewala"], cover: UIImage(named: "sample-cover"), genres: "Punjabi", urlString: "https://dl.dropboxusercontent.com/s/0qbqiaoxpq4wgrp/SidhuSon.mp3?dl=0"))
            songsarr.append(Song(name: "Regret", album: "Moosetape", artist: ["Sidhu Moosewala"], cover: UIImage(named: "regret-cover"), genres: "Punjabi", urlString: "https://dl.dropboxusercontent.com/s/xrxp8256xpwiv5o/Regret.mp3?dl=0"))
            songsarr.append(Song(name: "Phir Chala", album: "Single", artist: ["Jubin Nautiyal","Payal Dev"], cover: UIImage(named: "phir-chala-cover"), genres: "Bollywood", urlString: "https://dl.dropboxusercontent.com/s/ja04bu4fhgjomh6/Phir%20Chala.mp3?dl=0"))
            promixe(.success(songsarr))
        }
    }
    
    func getCoverWith(url: String) -> Future<UIImage,Error> {
        return Future { promixe in
            var image = UIImage(named: "nil")
            Alamofire.request(url, method: .get).responseData(queue: DispatchQueue.main, completionHandler: {
                (response) in
                if response.error == nil{
                    if let data = response.data {
                        image = UIImage(data: data)
                        promixe(.success(image!))
                    }
                }
            })
        }
    }
}
