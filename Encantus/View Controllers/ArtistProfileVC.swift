//
//  ProfileVC.swift
//  Encantus
//
//  Created by Ankit Yadav on 02/07/21.
//

import UIKit
import Combine
import Kingfisher

class optionSwitcherInProfileVC: UICollectionViewCell {
    @IBOutlet weak var textLabel: UILabel!
    override var isSelected: Bool {
        didSet {
            textLabel.textColor = UIColor(named: "lightPurpleColor")
        }
    }
}

class ArtistProfileVC: UITableViewController {

    var artistId: String?
    var observers: [AnyCancellable] = []
    var options = [String]()
    
    @IBOutlet weak var verifiedImageView: UIImageView!
    @IBOutlet weak var artistUsernameLabel: UILabel!
    @IBOutlet weak var artistProfileImageView: UIImageView!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var artistOriginLabel: UILabel!
    @IBOutlet weak var tracksLabel: UILabel!
    @IBOutlet weak var albumsLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followBttn: UIButton!
    @IBOutlet weak var tipBttn: UIButton!
    
    @IBOutlet weak var optionsCollectionView: UICollectionView!
    @IBOutlet weak var optionsCollectionViewLayout: UICollectionViewFlowLayout! {
        didSet {
            optionsCollectionViewLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchOptionsData()
        fetchArtistData()
        
        // design
        artistProfileImageView.layer.cornerRadius = artistProfileImageView.layer.bounds.height/2
        
        followBttn.layer.cornerRadius = 10
        tipBttn.layer.borderWidth = 1
        tipBttn.layer.cornerRadius = 10
        tipBttn.layer.borderColor = UIColor(named: "lightPurpleColor")!.cgColor
    }
    
    func fetchArtistData() {
        
        let ArtistService = ArtistService.shared
        let artist = ArtistService.getArtist(byId: artistId!) // take input for id only
            
        let artists = ArtistService.getAllAlbumbs(byArtistId: artistId!)
        print(artists)
        
        let uid = artist.uid
        let profileImageUrl = artist.profileImageUrl
        let followers = artist.followers.modern
        let name = artist.name
        let origin = artist.origin
        let isVerified = artist.isVerified
        
        // If the returned artist by Id is NaN the show alert
        guard name != "NaN" else {
            DispatchQueue.main.async {
                let alert = CheatSheet.shared.simpleAlert(title: "Can't find artist.", message: "Please fuck off!", actionTitle: "Hmm, okay!")
                self.present(alert, animated: true)
            }
            return
        }
        
        if isVerified {
            verifiedImageView.image = UIImage(systemName: "checkmark.seal.fill")
        }
        
        artistUsernameLabel.text = uid
        artistProfileImageView!.kf.setImage(with: URL(string: profileImageUrl), placeholder: UIImage(named: "placeholder"), options: [.transition(.fade(0.5))], progressBlock: nil, completionHandler: nil)
        artistNameLabel.text = name
        artistOriginLabel.text = origin
        followersLabel.attributedText = NSMutableAttributedString()
            .regular("\(followers)\n", 14, .white)
            .regular("Followers", 12, .gray)
        tracksLabel.attributedText = NSMutableAttributedString()
            .regular("54\n", 14, .white)
            .regular("Tracks", 12, .gray)
        albumsLabel.attributedText = NSMutableAttributedString()
            .regular("3\n", 14, .white)
            .regular("Albums", 12, .gray)
    }
    func fetchOptionsData() {
        DataService.shared.getProfileSongOptions()
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
                self!.options = value
                self!.optionsCollectionView.reloadData()
            }).store(in: &observers)
        
        // get songs
        DataService.shared.getSongs()
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
                let allTracks = ArtistService.shared.getAllTracks(byArtistId: self!.artistId!, songs: value)
                print(allTracks)
            }).store(in: &observers)
    }
}

extension ArtistProfileVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return options.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: optionSwitcherInProfileVC = collectionView.dequeueReusableCell(withReuseIdentifier: "optionSwitcherInProfileVC", for: indexPath) as! optionSwitcherInProfileVC
        let option = options[indexPath.row]
        
        // update UI
        cell.textLabel.text = option
        
        // design
        if indexPath.row == 0 {
            cell.textLabel.textColor = UIColor(named: "lightPurpleColor")
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        for section in 0..<self.optionsCollectionView.numberOfSections{
            for row in 0..<self.optionsCollectionView.numberOfItems(inSection: section){
                let cell = self.optionsCollectionView.cellForItem(at: IndexPath(row: row, section: section)) as? optionSwitcherInProfileVC
                cell!.textLabel.textColor = UIColor.white
            }
        }
        // set color of selected cell purple
        if let cell = optionsCollectionView.cellForItem(at: indexPath) as? optionSwitcherInProfileVC {
            cell.isSelected = true
        }
    }
    
}

// Extra
extension ArtistProfileVC {
    // config. table view
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
}