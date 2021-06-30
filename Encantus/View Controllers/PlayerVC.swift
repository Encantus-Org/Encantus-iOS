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
    var isDragging: Bool = false
    
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
        
        // design
        self.coverImageView.layer.cornerRadius = self.coverImageView.bounds.height/12
        self.coverImageView2.layer.cornerRadius = self.coverImageView2.bounds.height/12
        self.playBttn.layer.cornerRadius = playBttn.layer.bounds.height/2
        self.songProgressSlider.setThumbImage(UIImage(named: "thumb-icon"), for: .normal)
        self.songProgressSlider.isContinuous = false // to make slider change values when drag finishes
        
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
    override func remoteControlReceived(with event: UIEvent?) {
        if let event = event {
            if event.type == .remoteControl{
                switch event.subtype{
                case .remoteControlPlay:
                    player.play()
                    setPlayBttnImage()
                    break
                case .remoteControlPause:
                    player.pause()
                    setPlayBttnImage()
                    break
                case .remoteControlNextTrack:
                    forwardBttnDidTap()
                    break
                case .remoteControlPreviousTrack:
                    backwardBttnDidTap()
                    break
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
        
        // url of song to play
        let urlString = Bundle.main.path(forResource: name, ofType: "mp3")
        
        do {
            try AVAudioSession.sharedInstance().setMode(.default)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
            
            // to play the music in background
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            } catch {
                let alert = CheatSheet.shared.simpleAlert(title: error.localizedDescription, message: "", actionTitle: "Okay, got it!")
                self.present(alert,animated: true)
            }
            
            guard let urlString = urlString else {return}
            player = try AVAudioPlayer(contentsOf: URL(string: urlString)!)
            
            guard let player = player else {return}
            
            // if there's already a song playing, then stop that and start selected song
            if player.isPlaying {
                player.stop()
            }
            
            // play the somg
            player.play()
            
            // schedule timer
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(changeSliderValueWithTimer), userInfo: nil, repeats: true)
            
            // send info to media player for displaying data in notification center
            MPNowPlayingInfoCenter.default().nowPlayingInfo = [MPMediaItemPropertyTitle: name,
                                                              MPMediaItemPropertyArtist: artist,
                                                              MPMediaItemPropertyPlaybackDuration: player.duration,
                                                              MPMediaItemPropertyArtwork: MPMediaItemArtwork(image: cover!)]
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
        self.completeSongLengthLabel.text = player.duration.minutes()
        
        // song progress slider
        self.songProgressSlider.minimumValue = 0.0
        self.songProgressSlider.maximumValue = Float(player.duration)
        
        // configure context menu for button
        self.optionsBttn.menu = UIMenu(children: [
            UIAction(title: "Share",image: UIImage(systemName: "square.and.arrow.up")) { [self] _ in
            //let message1 = "Download Dinero App to manage your online subscriptions."
            let image = songs[position].cover
//            let myWebsite = NSURL(string:"https://apps.apple.com/us/app/dinero-subscription-manager/id1545370811")
            let shareAll = [image]
            let activityViewController = UIActivityViewController(activityItems: shareAll as [Any], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
            },
            UIAction(title: "Copy link",image: UIImage(systemName: "link")) { _ in
                
            },
            UIAction(title: "Go to artist",image: UIImage(systemName: "music.mic")) { _ in
                
            },
            UIAction(title: "Go to album",image: UIImage(systemName: "square.stack")) { _ in
                
            }
        ])
    }
    
    // change value of audio's poition by sliding
    @objc func changeSliderValueOnDrag() {
        if player.isPlaying {
            player.stop()
            let curTime = songProgressSlider.value
            player.currentTime = TimeInterval(curTime)
            player.play()
        } else {
            let curTime = songProgressSlider.value
            player.currentTime = TimeInterval(curTime)
        }
        self.currentTimeLabel.text = String(TimeInterval(songProgressSlider.value).minutes())
    }
    
    // change values of slider and labe with timer
    @objc func changeSliderValueWithTimer(){
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
            // pause audio
            player.pause()
            // show play button
            playBttn.setImage(UIImage(named: "play-icon"), for: .normal)
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
            playBttn.setImage(UIImage(named: "pause-icon"), for: .normal)
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
            player.stop()
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
