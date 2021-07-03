//
//  ViewController.swift
//  Encantus
//
//  Created by Ankit Yadav on 29/06/21.
//

import UIKit
import Combine
import Kingfisher
import MediaPlayer
import AVFoundation

class CategoryCell: UICollectionViewCell {
    @IBOutlet weak var textLabel: UILabel!
    override var isSelected: Bool {
        didSet {
            textLabel.textColor = UIColor(named: "lightPurpleColor")
        }
    }
}
class SongsCell: UICollectionViewCell {
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var playBttn: UIButton!
}

class HomeVC: UITableViewController {
    
    var observers: [AnyCancellable] = []
    private var categories = [String]()
    private var songs = [Song]()
    private var sortedSongs = [Song]()
    
    // MiniPlayer config.
    @IBOutlet var miniPlayerView: UIView!
    @IBOutlet weak var currentSongCoverImageView: UIImageView!
    @IBOutlet weak var currentSongNameLabel: UILabel!
    @IBOutlet weak var currentSongArtistNameLabel: UILabel!
    @IBOutlet weak var playBttn: UIButton!
    @IBOutlet weak var backwardBttn: UIButton!
    @IBOutlet weak var forwardBttn: UIButton!
    
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var categoriesCollectionViewLayout: UICollectionViewFlowLayout! {
        didSet {
            categoriesCollectionViewLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }
    }
    @IBOutlet weak var songCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // set the theme to always dark
        UIApplication.shared.windows.forEach { window in
            window.overrideUserInterfaceStyle = .dark
        }
        
        fetchData()
        assignValuesToMiniPlayer()
        
        // design
        let miniPlayerHeight = 120
        currentSongCoverImageView.layer.cornerRadius = currentSongCoverImageView.layer.bounds.height/4
        miniPlayerView.frame = CGRect(x: 0, y: 0, width: 414, height: miniPlayerHeight)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(miniPlayerDidTap(_:)))
        miniPlayerView.addGestureRecognizer(tapGesture)
        miniPlayerView.isUserInteractionEnabled  = true
        
        // add toolbar
        let toolBar = UIToolbar()
        toolBar.addSubview(miniPlayerView)
        view.addSubview(toolBar)
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        toolBar.layer.maskedCorners = [.layerMaxXMinYCorner,.layerMinXMinYCorner]
        toolBar.layer.cornerRadius = 15
        toolBar.layer.masksToBounds = true
        toolBar.clipsToBounds = true
        // add constrainsts to toolbar
        let guide = self.view.safeAreaLayoutGuide
        toolBar.trailingAnchor.constraint(equalTo: guide.trailingAnchor).isActive = true
        toolBar.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
        toolBar.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: 35).isActive = true
        toolBar.heightAnchor.constraint(equalToConstant: CGFloat(miniPlayerHeight)).isActive = true
    }
    
    @objc func miniPlayerDidTap(_ sender: UITapGestureRecognizer) {
        if SongService.shared.checkStatus() == .isPlayingg {
            print("Player Preseted using miniPlayer")
            guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "PlayerVC") as? PlayerVC else {return}
            vc.modalPresentationStyle = .popover
            
            if let sheet = vc.popoverPresentationController?.adaptiveSheetPresentationController {
                sheet.detents = [.large()]
                sheet.prefersGrabberVisible = true
                sheet.prefersScrollingExpandsWhenScrolledToEdge = true
                sheet.preferredCornerRadius = 30
            }
            vc.isComingFromMiniPlayer = true
            self.present(vc, animated: true)
        } else {
            print("error")
        }
    }
    
    // config. table view
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
}

//MARK: Functions

extension HomeVC {
    func fetchData() {
        // get categories
        DataService.shared.getCategories()
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
                self!.categories = value
                self!.categoryCollectionView.reloadData()
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
                self!.songs = value
                self!.sortedSongs = value
                self!.songCollectionView.reloadData()
            }).store(in: &observers)
    }
}

//MARK: CollectionView
extension HomeVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == categoryCollectionView {
            return categories.count
        } else {
            return sortedSongs.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == categoryCollectionView {
            let cell: CategoryCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
            
            // update UI
            cell.textLabel.text = categories[indexPath.row]
            
            // design
            if indexPath.row == 0 {
                cell.textLabel.textColor = UIColor(named: "lightPurpleColor")
            }
            return cell
        } else {
            let cell: SongsCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SongsCell", for: indexPath) as! SongsCell
            
            // get data
            let song = sortedSongs[indexPath.row]
            let name = song.name
            let artistId = song.artistId[0]
            let artist = ArtistService.shared.getArtist(byId: artistId).name
            let coverUrl = song.coverUrlString
            
            // update UI
            cell.songNameLabel.text = name
            cell.artistNameLabel.text = artist
            cell.coverImageView.kf.setImage(with: URL(string: coverUrl), placeholder: UIImage(named: "placeholder"), options: [.transition(.fade(0.5))], progressBlock: nil, completionHandler: nil)
            
            // design
            cell.blurView.layer.masksToBounds = true
            cell.blurView.layer.cornerRadius = cell.blurView.bounds.height/4
            cell.coverImageView.layer.cornerRadius = cell.coverImageView.bounds.height/7.5
            
            // config.
            cell.playBttn.tag = indexPath.row
            cell.playBttn.addTarget(self, action: #selector(playBttnDidTap(sender:)), for: .touchUpInside)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == categoryCollectionView {
            let genres = categories[indexPath.row]
            // if generes is selected to all then sort the array to all songs
            if genres == "All"{
                sortedSongs = songs
            } else {
                // if generes is selected to `any specific calue` then sort the array accordingly
                sortedSongs = SongService.shared.sortBy(genres: genres, arrayToSort: self.songs)
            }
            // reload the collection view to see the updated
            UIView.transition(with: songCollectionView, duration: 0.5, options: .transitionCrossDissolve, animations: {self.songCollectionView.reloadData()}, completion: nil)
            // set color of all cells white
            for section in 0..<self.categoryCollectionView.numberOfSections{
                for row in 0..<self.categoryCollectionView.numberOfItems(inSection: section){
                    let cell = self.categoryCollectionView.cellForItem(at: IndexPath(row: row, section: section)) as? CategoryCell
                    cell!.textLabel.textColor = UIColor.white
                }
            }
            // set color of selected cell purple
            if let cell = collectionView.cellForItem(at: indexPath) as? CategoryCell {
                cell.isSelected = true
            }
        } else {
            let MiniPlayer = MiniPlayer.shared
            let buttonTag = indexPath.row
            
            guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "PlayerVC") as? PlayerVC else {return}
            vc.modalPresentationStyle = .popover
            
            if let sheet = vc.popoverPresentationController?.adaptiveSheetPresentationController {
                sheet.detents = [.large()]
                sheet.prefersGrabberVisible = true
                sheet.prefersScrollingExpandsWhenScrolledToEdge = true
                sheet.preferredCornerRadius = 30
            }
            
            MiniPlayer.updateCurrentPlaying(songs: sortedSongs, position: buttonTag)
            
            self.present(vc, animated: true)
            
            // check if any song is already playing in player, if so then remover the player and initiater a new one
            if SongService.shared.checkStatus() == .isPlayingg {
                MiniPlayer.player.pause()
                MiniPlayer.player = nil
            }
            configureMiniPlayer(songs: sortedSongs, position: buttonTag)
        }
    }
    
    @objc func playBttnDidTap(sender: UIButton) {
        let MiniPlayer = MiniPlayer.shared
        let indexPath = sender.tag
        
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "PlayerVC") as? PlayerVC else {return}
        vc.modalPresentationStyle = .popover
        
        if let sheet = vc.popoverPresentationController?.adaptiveSheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = true
            sheet.preferredCornerRadius = 30
        }
        
        MiniPlayer.updateCurrentPlaying(songs: sortedSongs, position: indexPath)
        
        self.present(vc, animated: true)
        
        // check if any song is already playing in player, if so then remover the player and initiater a new one
        if SongService.shared.checkStatus() == .isPlayingg {
            MiniPlayer.player.pause()
            MiniPlayer.player = nil
        }
        configureMiniPlayer(songs: sortedSongs, position: indexPath)
    }
}

// MiniPlayer
extension HomeVC {
    func configureMiniPlayer(songs: [Song], position: Int) {
        let MiniPlayer = MiniPlayer.shared
        let song = songs[position]
        MiniPlayer.configMiniPlayerUI(song: song)
        // set music control button actions
        playBttn.addTarget(self, action: #selector(playBttnDidTapp), for: .touchUpInside)
        backwardBttn.addTarget(self, action: #selector(backwardBttnDidTap), for: .touchUpInside)
        forwardBttn.addTarget(self, action: #selector(forwardBttnDidTap), for: .touchUpInside)
        playBttn.setImage(UIImage(named: "pause-icon"), for: .normal)
        // set current playing song's info
        currentPlayingInfo = CurrentPlaying(array: songs, position: position)
        // configure player finally
        MiniPlayer.configure(song: song)
    }
    @objc func forwardBttnDidTap() {
        let MiniPlayer = MiniPlayer.shared
        MiniPlayer.forwardBttnDidTap()
    }
    @objc func backwardBttnDidTap() {
        let MiniPlayer = MiniPlayer.shared
        MiniPlayer.backwardBttnDidTap()
    }
    @objc func playBttnDidTapp() {
        let MiniPlayer = MiniPlayer.shared
        MiniPlayer.playOrPause()
        // show play/pause button
        MiniPlayer.setPlayBttnImage(playBttn)
    }
    // Assign these values to adjacent values in MiniPlayer and see the magic
    func assignValuesToMiniPlayer() {
        let MiniPlayer = MiniPlayer.shared
        MiniPlayer.currentSongNameLabel = self.currentSongNameLabel
        MiniPlayer.currentSongArtistNameLabel = self.currentSongArtistNameLabel
        MiniPlayer.currentSongCoverImageView = self.currentSongCoverImageView
        MiniPlayer.playBttnInHome = self.playBttn
    }
}
