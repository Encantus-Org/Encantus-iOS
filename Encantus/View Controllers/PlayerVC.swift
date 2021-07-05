//
//  PlayVC.swift
//  Encantus
//
//  Created by Ankit Yadav on 29/06/21.
//

import UIKit
import Combine
import Foundation
import Kingfisher
import MediaPlayer
import AVFoundation

class PlayerVC: UITableViewController {
    
    var isComingFromMiniPlayer: Bool = false
    
    @IBOutlet weak var coverImageView2: UIImageView!
    @IBOutlet weak var coverImageView: UIImageView!
    
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var optionsBttn: UIButton!
    
    @IBOutlet weak var songProgressSlider: UISlider!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var completeSongLengthLabel: UILabel!
    
    @IBOutlet weak var backwardBttn: UIButton!
    @IBOutlet weak var playBttn: UIButton!
    @IBOutlet weak var forwardBttn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMediaPlayerNoticationView()
        
        // design
        self.coverImageView.layer.cornerRadius = self.coverImageView.bounds.height/12
        self.coverImageView2.layer.cornerRadius = self.coverImageView2.bounds.height/12
        self.playBttn.layer.cornerRadius = playBttn.layer.bounds.height/2
        self.songProgressSlider.setThumbImage(UIImage(named: "thumb-icon"), for: .normal)
        
        // actions
        self.playBttn.addTarget(self, action: #selector(playBttnDidTap), for: .touchUpInside)
        self.backwardBttn.addTarget(self, action: #selector(backwardBttnDidTap), for: .touchUpInside)
        self.forwardBttn.addTarget(self, action: #selector(forwardBttnDidTap), for: .touchUpInside)
        self.optionsBttn.showsMenuAsPrimaryAction = true
        self.optionsBttn.changesSelectionAsPrimaryAction = false
    }
    override func viewWillAppear(_ animated: Bool) {
        assignValuesToMiniPlayer()
        configure()
        if isComingFromMiniPlayer {
            let MiniPlayer = MiniPlayer.shared
            MiniPlayer.setPlayBttnImage(playBttn)
            MiniPlayer.setImageAnimation(coverImageView)
        }
    }
    @IBAction func SliderValueDidChanger(_ sender: Any) {
        MiniPlayer.shared.changeSliderValueOnDrag()
    }
    
    // for the controls from notification center media player
    func setupMediaPlayerNoticationView(){
        let commandCenter = MPRemoteCommandCenter.shared()
        // Add handler for Play Command
        commandCenter.playCommand.addTarget{ event in
            self.playBttnDidTap()
            return .success
        }
        // Add handler for Pause Command
        commandCenter.pauseCommand.addTarget{event in
            self.playBttnDidTap()
            return .success
        }
        commandCenter.previousTrackCommand.addTarget{ event in
            self.backwardBttnDidTap()
            return .success
        }
        commandCenter.nextTrackCommand.addTarget { event in
            self.forwardBttnDidTap()
            return .success
        }
    }
    
    // to update now playing in notification center
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        let MiniPlayer = MiniPlayer.shared
        var nowPlayingInfo = MiniPlayer.nowPlayingInfo
        if object is AVPlayer {
            switch MiniPlayer.player!.timeControlStatus {
            case .waitingToPlayAtSpecifiedRate,.paused:
                nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(MiniPlayer.player!.currentTime())
                nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 0
                MPNowPlayingInfoCenter.default ().nowPlayingInfo = nowPlayingInfo
            case .playing:
                nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime ] = CMTimeGetSeconds(MiniPlayer.player!.currentTime())
                nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1
                MPNowPlayingInfoCenter.default ().nowPlayingInfo = nowPlayingInfo
            @unknown default:
                break
            }
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

// configured player here
extension PlayerVC {
    func configure() {
        // check if user is coming from mini player of by tapping the main cell
        if isComingFromMiniPlayer {
            // We're not configuring the player again here because song is already playing and we don't want to have 2 songs playing at the same time
            let MiniPlayer = MiniPlayer.shared
            let songs = MiniPlayer.tracksToPlay()
            let position = MiniPlayer.position()
            let song = songs[position]
            
            configureOptionsBttn(forSong: song)
            // display a song's info if coming from miniPlayerView
            MiniPlayer.currentTimeLabel = self.currentTimeLabel
            MiniPlayer.songProgressSlider = self.songProgressSlider
            
            MiniPlayer.configPlayerUI(withTrack: song)
        } else {
            let MiniPlayer = MiniPlayer.shared
            let songs = MiniPlayer.tracksToPlay()
            let position = MiniPlayer.position()
            let song = songs[position]
            
            configureOptionsBttn(forSong: song)
            DispatchQueue.main.async {
                MiniPlayer.currentTimeLabel = self.currentTimeLabel
                MiniPlayer.songProgressSlider = self.songProgressSlider
                
                MiniPlayer.configPlayerUI(withTrack: song)
            }
        }
    }
    func configureOptionsBttn(forSong: Track) {
        let track = forSong
        // get song data
        let artistId = track.artistId[0]
        let artist = ArtistService.shared.getArtist(byId: artistId).name
        let urlString = track.urlString
        let cover = UIImage(named: "encantus-logo")
        let albumId = track.albumId
        
        // configure context menu for button
        self.optionsBttn.menu = UIMenu(children: [
            UIAction(title: "Share",image: UIImage(systemName: "square.and.arrow.up")) { [self] _ in
                let message = "Hey, I'm listenting to \(artist) on Encantus App. Join me in."
                let image = cover
                let myWebsite = NSURL(string: urlString)
                let shareAll = [image! ,message, myWebsite!] as [Any]
                let activityViewController = UIActivityViewController(activityItems: shareAll as [Any], applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = self.view
                self.present(activityViewController, animated: true, completion: nil)
            },
            UIAction(title: "Copy link",image: UIImage(systemName: "link")) { _ in
                let clipBoard = UIPasteboard.general
                clipBoard.string = urlString
            },
            UIAction(title: "Go to artist",image: UIImage(systemName: "music.mic")) { _ in
                weak var pvc = self.presentingViewController
                self.dismiss(animated: true) {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ArtistProfileVC") as! ArtistProfileVC
                    vc.artistId = artistId
                    let navigationController = UINavigationController()
                    navigationController.viewControllers = [vc]
                    navigationController.modalPresentationStyle = .fullScreen
                    pvc?.present(navigationController, animated: true)
                }
            },
            UIAction(title: "Go to album",image: UIImage(systemName: "square.stack")) { _ in
                weak var pvc = self.presentingViewController
                self.dismiss(animated: true) {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "AlbumDetailVC") as! AlbumDetailVC
                    vc.albumId = albumId
                    let navigationController = UINavigationController()
                    navigationController.viewControllers = [vc]
                    navigationController.modalPresentationStyle = .fullScreen
                    pvc?.present(navigationController, animated: true)
                }
            }
        ])
    }
    @objc func backwardBttnDidTap() {
        let MiniPlayer = MiniPlayer.shared
        MiniPlayer.miniPlayerBackwardBttnDidTap()
        
        let currentPlayingTrack = MiniPlayer.currentPlayingTrack()
        // configure option's menu button when song changes
        configureOptionsBttn(forSong: currentPlayingTrack)
    }
    @objc func playBttnDidTap() {
        let MiniPlayer = MiniPlayer.shared
        
        MiniPlayer.playOrPause()
        // show play/pause button
        MiniPlayer.setPlayBttnImage(playBttn)
        // show play/pause for MiniPlayer button
        MiniPlayer.setPlayBttnImage(MiniPlayer.playBttnInHome!)
        // shrink image and send back to normal
        MiniPlayer.setImageAnimation(coverImageView)
    }
    @objc func forwardBttnDidTap() {
        let MiniPlayer = MiniPlayer.shared
        MiniPlayer.playerForwardBttnDidTap()
        
        let currentPlayingTrack = MiniPlayer.currentPlayingTrack()
        // configure option's menu button when song changes
        configureOptionsBttn(forSong: currentPlayingTrack)
    }
    // Assign these values to adjacent values in MiniPlayer and see the magic
    func assignValuesToMiniPlayer() {
        let MiniPlayer = MiniPlayer.shared
        MiniPlayer.assignPlayerValues(nameL: songNameLabel, artistL: artistNameLabel, currentTimeL: currentTimeLabel, completeSongDurationL: completeSongLengthLabel, slider: songProgressSlider, cover1: coverImageView, cover2: coverImageView2, playBttn: playBttn)
    }
}

