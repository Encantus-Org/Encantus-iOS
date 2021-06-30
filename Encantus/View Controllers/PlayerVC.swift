//
//  PlayVC.swift
//  Encantus
//
//  Created by Ankit Yadav on 29/06/21.
//

import UIKit
import Foundation
import AVFoundation
import MediaPlayer

// keeping the player global to check if audio is already playing or not
var player: AVAudioPlayer!

class PlayerVC: UITableViewController {
    
    var songs = [Song]()
    var position: Int = 0
    var timer: Timer!
    
    @IBOutlet weak var coverImageView: UIImageView!
    
    @IBOutlet weak var songNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    
    @IBOutlet weak var songProgressSlider: UISlider!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var completeSongLengthLabel: UILabel!
    
    @IBOutlet weak var backwardBttn: UIButton!
    @IBOutlet weak var playBttn: UIButton!
    @IBOutlet weak var forwardBttn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        
        // design
        self.coverImageView.layer.cornerRadius = self.coverImageView.bounds.height/12
        self.playBttn.layer.cornerRadius = playBttn.layer.bounds.height/2
        self.playBttn.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        self.songProgressSlider.setThumbImage(UIImage(named: "thumb-icon"), for: .normal)
        
        // actions
        self.playBttn.addTarget(self, action: #selector(playBttnDidTap), for: .touchUpInside)
        self.backwardBttn.addTarget(self, action: #selector(backwardBttnDidTap), for: .touchUpInside)
        self.forwardBttn.addTarget(self, action: #selector(forwardBttnDidTap), for: .touchUpInside)
    }
    
    // change value of audio's poition
    @IBAction func SliderValueDidChanger(_ sender: Any) {
        playBttnDidTap()
        let curTime = songProgressSlider.value
        player.currentTime = TimeInterval(curTime)
        playBttnDidTap()
    }
    
    // for the controls from notification center media player
    override func remoteControlReceived(with event: UIEvent?) {
        if let event = event {
            if event.type == .remoteControl{
                switch event.subtype{
                case .remoteControlPlay:
                    player.play()
                case .remoteControlPause:
                    player.pause()
                case .remoteControlNextTrack:
                    forwardBttnDidTap()
                case .remoteControlPreviousTrack:
                    backwardBttnDidTap()
                @unknown default:
                    break
                }
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
        let artist = song.artist
        
        let urlString = Bundle.main.path(forResource: name, ofType: "mp3")
        
        do {
            try AVAudioSession.sharedInstance().setMode(.default)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
            
            // to play the music in background
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            } catch {
                print(error)
            }
            
            guard let urlString = urlString else {return}
            player = try AVAudioPlayer(contentsOf: URL(string: urlString)!)
            
            guard let player = player else {return}
            
            // if there's already a song playing, then stop that and start selected song
            if player.isPlaying {
                player.stop()
            } else {
                print("No song playing")
            }
            
            player.play()
            
            // schedule timer
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(changeSliderValueFollowPlayerCurTime), userInfo: nil, repeats: true)
            
            // send info to media player for displaying data in notification center
            MPNowPlayingInfoCenter.default().nowPlayingInfo = [MPMediaItemPropertyTitle: name,
                                                              MPMediaItemPropertyArtist: artist,
                                                              MPMediaItemPropertyPlaybackDuration: player.duration,
                                                              MPMediaItemPropertyArtwork: MPMediaItemArtwork(image: cover!)]
            UIApplication.shared.beginReceivingRemoteControlEvents()
            becomeFirstResponder()
        } catch {
            print("Error")
        }
        
        // update UI
        self.coverImageView.image = cover
        self.songNameLabel.text = name
        self.artistNameLabel.text = artist
        self.completeSongLengthLabel.text = player.duration.minutes()
        
        // song progress slider
        self.songProgressSlider.minimumValue = 0.0
        self.songProgressSlider.maximumValue = Float(player.duration)
    }
    
    @objc func changeSliderValueFollowPlayerCurTime(){
        let curValue = Float(player.currentTime)
        self.currentTimeLabel.text = player.currentTime.minutes()
        songProgressSlider.value = curValue
    }
    
    
    @objc func backwardBttnDidTap() {
        if position>0 {
            position = position - 1
            player.stop()
        }
        configure()
    }
    @objc func playBttnDidTap() {
        if player.isPlaying {
//            pause audio
            player.pause()
//            show play button
            playBttn.setImage(UIImage(systemName: "play.fill"), for: .normal)
//            shrink image
//            UIView.animate(withDuration: 0.2, animations: {
//                self.coverImageView.frame = CGRect(x: 0, y: 0, width: 250, height: 250)
//            }, completion: nil)
        } else {
//            play audio
            player.play()
//            show pause button
            playBttn.setImage(UIImage(systemName: "pause.fill"), for: .normal)
//            increase image size
//            UIView.animate(withDuration: 0.2, animations: {
//                self.coverImageView.frame = CGRect(x: 0, y: 0, width: 344, height: 344)
//            }, completion: nil)
        }
    }
    @objc func forwardBttnDidTap() {
        if position < (songs.count - 1) {
            position = position + 1
            player.stop()
        }
        configure()
    }
}
