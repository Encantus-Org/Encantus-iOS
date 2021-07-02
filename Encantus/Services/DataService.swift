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
    
    func getProfileSongOptions() -> Future<[String],Error> {
        return Future { promixe in
            promixe(.success(["Tracks","Albums","Singles","Collaborations"]))
        }
    }
    
    func getSongs() -> Future<[Song],Error> {
        return Future { promixe in
            var songsarr = [Song]()
            songsarr.append(Song(uid: "Sidhu1", name: "Sidhu Son", albumId: "moosetape", artistId: ["sidhu"], genres: "Punjabi", urlString: "https://dl.dropboxusercontent.com/s/0qbqiaoxpq4wgrp/SidhuSon.mp3?dl=0", coverUrlString: "https://dl.dropboxusercontent.com/s/a2oylajf4dorafp/Sidhu%20Son.png?dl=0"))
            
            songsarr.append(Song(uid: "Sidhu2", name: "Regret", albumId: "moosetape", artistId: ["sidhu"], genres: "Punjabi", urlString: "https://dl.dropboxusercontent.com/s/xrxp8256xpwiv5o/Regret.mp3?dl=0", coverUrlString: "https://dl.dropboxusercontent.com/s/hif3mf5on1dmyz6/Regret.png?dl=0"))
            
            songsarr.append(Song(uid: "Jubin1", name: "Phir Chala", albumId: "ginnyWedsSunny", artistId: ["jubin","Payal Dev"], genres: "Bollywood", urlString: "https://dl.dropboxusercontent.com/s/ja04bu4fhgjomh6/Phir%20Chala.mp3?dl=0", coverUrlString: "https://dl.dropboxusercontent.com/s/nyoiszqo3fax83s/Phir%20Chala.png?dl=0"))
        
            songsarr.append(Song(uid: "Ramu1", name: "Test Song", albumId: "ginnyWedsSunny", artistId: ["Ramu Sachan"], genres: "BlockChain", urlString: "https://ipfs.io/ipfs/QmeXiBuRpi3xRaCuHuDmPoDnjf3BKDx78jzq383Gm8ASoA", coverUrlString: "https://dl.dropboxusercontent.com/s/nyoiszqo3fax83s/Phir%20Chala.png?dl=0"))
            promixe(.success(songsarr))
        }
    }
    
    func getCoverWith(urls: [String]) -> Future<[UIImage],Error> {
        return Future { promixe in
            var images = [UIImage]()
            
            let asyncGroup = DispatchGroup()
            
            for url in urls {
                asyncGroup.enter()
                Alamofire.request(url, method: .get).responseData(queue: DispatchQueue.main, completionHandler: {
                    (response) in
                    if response.error == nil{
                        if let data = response.data {
                            images.append(UIImage(data: data)!)
                            asyncGroup.leave()
                        }
                    }
                })
            }
            asyncGroup.notify(queue: .main) {
                promixe(.success(images))
            }
        }
    }
}
