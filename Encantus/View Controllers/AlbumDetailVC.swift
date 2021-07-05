//
//  AlbumDetailVC.swift
//  Encantus
//
//  Created by Ankit Yadav on 03/07/21.
//

import UIKit
import Combine

class AllSongsInAlbumCell: UITableViewCell {
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
}
class AlbumDetailVC: UITableViewController {

    var albumId: String?
    var album: Album? = nil
    var allSongsInAlbum = [Track]()
    var observers = [AnyCancellable]()
    
    let header = StretchyTableHeaderView(frame: CGRect(x: 0, y: 0, width: CheatSheet.screenWidth, height: CheatSheet.screenWidth))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard albumId != nil else {
            DispatchQueue.main.async {
                let alert = CheatSheet.shared.simpleAlert(title: "The album doesn't exist.", message: "Please try again later", actionTitle: "Okay, got it.")
                self.present(alert, animated: true)
            }
            return
        }
        album = ArtistService.shared.getAlbum(byId: self.albumId!)
        fetchAllSongs()
        
        // load cover image
        let coverUrl = album?.albumCoverUrl
        header.imageView.layer.cornerRadius = 25
        header.imageView.layer.maskedCorners = [.layerMaxXMaxYCorner,.layerMinXMaxYCorner] // [.layerMaxXMinYCorner,.layerMinXMinYCorner]
        header.imageView.kf.setImage(with: URL(string: coverUrl!), placeholder: nil, options: [.transition(.fade(0.5))], progressBlock: nil, completionHandler: nil)
        tableView.tableHeaderView = header
    }
    func fetchAllSongs(){
        // get songs
        DataService.shared.getTracks()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error)
                    break
                }
            }, receiveValue: { [weak self] value in
                let albumId = self?.album?.uid
                let allSongsInAlbum = ArtistService.shared.getAllSongs(byAlbumId: albumId!, songs: value)
                self?.allSongsInAlbum = allSongsInAlbum
                self?.tableView.reloadData()
                print(value)
            }).store(in: &observers)
    }
    /// to add `stretch` animation to header
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let header = tableView.tableHeaderView as? StretchyTableHeaderView else {
            return
        }
        header.scrollViewDidScroll(scrollView: tableView)
    }
}

extension AlbumDetailVC {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allSongsInAlbum.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: AllSongsInAlbumCell = tableView.dequeueReusableCell(withIdentifier: "AllSongsInAlbumCell") as! AllSongsInAlbumCell
        
        let song = allSongsInAlbum[indexPath.row]
        let name = song.name
        let artistId = song.artistId[0]
        let artist = ArtistService.shared.getArtist(byId: artistId).name
        let coverUrl = song.coverUrlString
        
        cell.nameLabel.text = name
        cell.artistNameLabel.text = artist
        cell.coverImageView.kf.setImage(with: URL(string: coverUrl), placeholder: UIImage(named: "placeholder"), options: [.transition(.fade(0.5))], progressBlock: nil, completionHandler: nil)
        
        //design
        cell.coverImageView.layer.cornerRadius = cell.coverImageView.layer.bounds.height/4
        return cell
    }
}
