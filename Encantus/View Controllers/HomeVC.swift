//
//  ViewController.swift
//  Encantus
//
//  Created by Ankit Yadav on 29/06/21.
//

import UIKit
import Combine
import Kingfisher

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
        
        fetchData()
        
        // design
        currentSongCoverImageView.layer.cornerRadius = currentSongCoverImageView.layer.bounds.height/12
        currentSongCoverImageView.layer.masksToBounds = true
        currentSongCoverImageView.clipsToBounds = true
        currentSongCoverImageView.dropShadow(color: .black, opacity: 0.1 , offSet: CGSize(width: 0.4, height: 0.4),radius: 10)
        miniPlayerView.frame = CGRect(x: 0, y: 730, width: 414, height: 140)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(taped(_:)))
        miniPlayerView.addGestureRecognizer(tapGesture)
        miniPlayerView.isUserInteractionEnabled  = true
        view.addSubview(miniPlayerView)
        // set the theme to always dark
        UIApplication.shared.windows.forEach { window in
            window.overrideUserInterfaceStyle = .dark
        }
    }
    @objc func taped(_ sender: UITapGestureRecognizer) {
        if SongService.shared.checkStatus() == .isPlayingg {
            print("Present vc")
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
//                self!.loadImages()
            }).store(in: &observers)
        
    }
    
    func loadImages() {
        // load image
        var urls = [String]()
        for song in sortedSongs {
            urls.append(song.coverUrlString)
        }
        DataService.shared.getCoverWith(urls: urls )
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
                print("values: \(value)")
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
            let artist = song.artist[0]
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
            let buttonTag = indexPath.row
            
            guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "PlayerVC") as? PlayerVC else {return}
            vc.modalPresentationStyle = .popover
            
            if let sheet = vc.popoverPresentationController?.adaptiveSheetPresentationController {
                sheet.detents = [.large()]
                sheet.prefersGrabberVisible = true
                sheet.prefersScrollingExpandsWhenScrolledToEdge = true
                sheet.preferredCornerRadius = 30
            }
            
            vc.songs = sortedSongs
            vc.position = buttonTag
            
            self.present(vc, animated: true)
            
            print(sortedSongs[buttonTag].name)
            configureMiniPlayer(songs: sortedSongs, position: buttonTag)
        }
    }
    
    @objc func playBttnDidTap(sender: UIButton) {
        let buttonTag = sender.tag
        
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "PlayerVC") as? PlayerVC else {return}
        vc.modalPresentationStyle = .popover
        
        if let sheet = vc.popoverPresentationController?.adaptiveSheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = true
            sheet.preferredCornerRadius = 30
        }
        
        vc.songs = sortedSongs
        vc.position = buttonTag
        
        self.present(vc, animated: true)
        
        print(sortedSongs[buttonTag].name)
        configureMiniPlayer(songs: sortedSongs, position: buttonTag)
    }
}

// MiniPlayer
extension HomeVC {
    func configureMiniPlayer(songs: [Song], position: Int) {
        let song = songs[position]
        currentSongNameLabel.text = song.name
        currentSongCoverImageView.kf.setImage(with: URL(string: song.coverUrlString), placeholder: UIImage(named: "placeholder"), options: [.transition(.fade(0.5))], progressBlock: nil, completionHandler: nil)
        currentSongArtistNameLabel.text = song.artist[0]
        playBttn.addTarget(self, action: #selector(playBttnDidTapp), for: .touchUpInside)
        backwardBttn.addTarget(self, action: #selector(backwardBttnDidTap), for: .touchUpInside)
        forwardBttn.addTarget(self, action: #selector(forwardBttnDidTap), for: .touchUpInside)
        playBttn.setImage(UIImage(named: "pause-icon"), for: .normal)
    }
    @objc func backwardBttnDidTap() {
//        if position>0 {
//            position = position - 1
//            player.pause()
//        }
//        configure()
    }
    @objc func playBttnDidTapp() {
        if player.isPlaying {
            // pause audio
            player!.pause()
            // show play button
            self.playBttn.setImage(UIImage(named: "play-icon"), for: .normal)
        } else {
            // play audio
            player.play()
            // show pause button
            self.playBttn.setImage(UIImage(named: "pause-icon"), for: .normal)
        }
    }
    @objc func forwardBttnDidTap() {
//        if position < (songs.count - 1) {
//            position = position + 1
//            player.pause()
//        }
//        configure()
    }
}
