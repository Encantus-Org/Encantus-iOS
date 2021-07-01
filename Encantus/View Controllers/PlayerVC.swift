//
//  PlayVC.swift
//  Encantus
//
//  Created by Ankit Yadav on 29/06/21.
//

// TO DO - Seek function in media player
// prepare next song to play after current song is player to half

import UIKit
import Combine
import Foundation
import MediaPlayer
import AVFoundation

// keeping the player global to check if audio is already playing or not
var player: AVPlayer!

class PlayerVC: UITableViewController {
    
    var songs = [Song]()
    var position: Int = 0
    var timer: Timer!
    
//    var observers: [AnyCancellable] = []
//    let start = Date() // to be used when we're using combine timer
    
    var nowPlayingInfo = [String : Any]()
    
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
        
        configure()
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
        setPlayBttnImage()
    }
    
    @IBAction func SliderValueDidChanger(_ sender: Any) {
        changeSliderValueOnDrag()
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
        if object is AVPlayer {
            switch player.timeControlStatus {
            case .waitingToPlayAtSpecifiedRate,.paused:
                nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(player.currentTime())
                nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 0
                MPNowPlayingInfoCenter.default ().nowPlayingInfo = nowPlayingInfo
            case .playing:
                nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime ] = CMTimeGetSeconds(player.currentTime())
                nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1
                MPNowPlayingInfoCenter.default ().nowPlayingInfo = nowPlayingInfo
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

extension PlayerVC {
    func configure() {
        let song = songs[position]
        
        // get song data
        let cover = song.cover
        let name = song.name
        let artist = song.artist[0]
        let album = song.album
        let genre = song.genres
        let urlString = song.urlString
        
        do {
            // to support media playing in background
            try AVAudioSession.sharedInstance().setMode(.default)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
            
            // to play the music in background
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            } catch {
                let alert = CheatSheet.shared.simpleAlert(title: error.localizedDescription, message: "", actionTitle: "Okay, got it!")
                self.present(alert,animated: true)
            }
            
            player = AVPlayer(url: URL(string: urlString)!)
            player.play()
            
            guard let player = player else {return}
            
            // if there's already a song playing, then stop that and start selected song
            if player.isPlaying {
                player.pause()
            }
            
            // play the somg
            player.play()
            
            // schedule timer
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(changeSliderValueWithTimer), userInfo: nil, repeats: true)
            
              // timer with combine
//            Timer.publish(every: 1.0, tolerance: 1.0, on: .main, in: .common)
//                .autoconnect() // .autoconnect() allows us to start a timer once we have our song
//                .map({ (output) in
//                    return output.timeIntervalSince(self.start)
//                })
//                .map({ (timeInterval) in
//                    return Int(timeInterval)
//                })
//                .sink { (seconds) in
//                    self.currentTimeLabel.text = player.currentTime().minutes
//                    self.songProgressSlider.value = Float(CMTimeGetSeconds(player.currentTime()))
//                }
//                .store(in: &observers)
            
            // Define Now Playing Info
            nowPlayingInfo[MPMediaItemPropertyTitle] = name
            nowPlayingInfo[MPMediaItemPropertyArtist] = artist
            nowPlayingInfo[MPMediaItemPropertyGenre] = genre
            nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = album
            if let image = cover {
                nowPlayingInfo[MPMediaItemPropertyArtwork] =
                    MPMediaItemArtwork(boundsSize: image.size) { size in
                        return image
                }
            }
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentTime().seconds
            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = player.currentItem?.asset.duration.seconds
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player.rate

            // Set the metadata
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
            
            UIApplication.shared.beginReceivingRemoteControlEvents()
            becomeFirstResponder()
        } catch {
            let alert = CheatSheet.shared.simpleAlert(title: error.localizedDescription, message: "", actionTitle: "Okay, got it!")
            self.present(alert,animated: true)
        }
        
        // update UI
        self.coverImageView.image = cover
        self.coverImageView2.image = cover
        self.songNameLabel.text = name
        self.artistNameLabel.text = artist
        
        // song progress slider
        self.songProgressSlider.minimumValue = 0.0
        // get song's total duration
        let duration = player.currentItem?.asset.duration
        DispatchQueue.main.async {
            self.completeSongLengthLabel.text = duration?.minutes
            self.songProgressSlider.maximumValue = Float(CMTimeGetSeconds(duration!))
        }
        
        // configure context menu for button
        self.optionsBttn.menu = UIMenu(children: [
            UIAction(title: "Share",image: UIImage(systemName: "square.and.arrow.up")) { [self] _ in
            let message = "Hey, I'm listenting to \(artist) on Encantus. Join me in."
            let image = songs[position].cover
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
                
            },
            UIAction(title: "Go to album",image: UIImage(systemName: "square.stack")) { _ in
                
            }
        ])
    }
                                
    // change value of audio's poition by dragging
    @objc func changeSliderValueOnDrag() {
        let seconds: Int64 = Int64(songProgressSlider.value)
        let targetTime: CMTime = CMTimeMake(value: seconds, timescale: 1)
        
        // to update now playing in notification center
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(player.currentTime())
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 0
        MPNowPlayingInfoCenter.default().nowPlayingInfo=nowPlayingInfo
        
        player.seek(to: targetTime) { (isCompleted) in
            // to update now playing in notification center
            self.nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(player.currentTime())
            self.nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1
            MPNowPlayingInfoCenter.default().nowPlayingInfo = self.nowPlayingInfo
        }
        self.currentTimeLabel.text = String(TimeInterval(songProgressSlider.value).minutes())
    }
    
    // change values of slider and labe with timer
    @objc func changeSliderValueWithTimer(){
        self.currentTimeLabel.text = player.currentTime().minutes
        songProgressSlider.value = Float(CMTimeGetSeconds(player.currentTime()))
    }
    
    @objc func backwardBttnDidTap() {
        if position>0 {
            position = position - 1
            player.pause()
        }
        configure()
    }
    @objc func playBttnDidTap() {
        if player.isPlaying {
            // pause audio
            player.pause()
            // show play button
            setPlayBttnImage()
            // shrink image
            UIView.animate(withDuration: 0.6,
                animations: {
                    self.coverImageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                },
                completion: nil)
        } else {
            // play audio
            player.play()
            // show pause button
            setPlayBttnImage()
            // increase image size
            UIView.animate(withDuration: 0.6,
                animations: {
                    self.coverImageView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                },
                completion: { _ in
                    UIView.animate(withDuration: 0.3) {
                        self.coverImageView.transform = CGAffineTransform.identity
                    }
                })
        }
    }
    @objc func forwardBttnDidTap() {
        if position < (songs.count - 1) {
            position = position + 1
            player.pause()
        }
        configure()
    }
    
    func setPlayBttnImage() {
        switch SongService.shared.checkStatus() {
        case .isPausedd:
            self.playBttn.setImage(UIImage(named: "play-icon"), for: .normal)
            break
        case .isPlayingg:
            self.playBttn.setImage(UIImage(named: "pause-icon"), for: .normal)
            break
        }
    }
}
