//
//  Player.swift
//  Encantus
//
//  Created by Ankit Yadav on 01/07/21.
//

import UIKit
import Foundation
import MediaPlayer
import AVFoundation

class MiniPlayer {
    
    var player: AVPlayer!
    var nowPlayingInfo = [String : Any]()
    
    static let shared = MiniPlayer()
    
    // properties reffered from `PlayerVC`
    var timer: Timer!
    var currentTimeLabel: UILabel?
    var songProgressSlider: UISlider?
    
//MARK: 👇🏻Functions specific to both PlayerVC & HomeVC
    // configure a song, basically play it from starting
    func configure(song: Song) {
        // get song data
        let name = song.name
        let artist = song.artist[0]
        let album = song.album
        let genre = song.genres
        let urlString = song.urlString
        let cover = UIImage(named: "encantus-logo")
        
//        currentPlaying = song
        
        do {
            // to support media playing in background
            try AVAudioSession.sharedInstance().setMode(.default)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
            
            // to play the music in background
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            } catch {
                print("error")
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
            
            let commandCenter = MPRemoteCommandCenter.shared()
                
            // Scrubber
            commandCenter.changePlaybackPositionCommand.addTarget { [weak self](remoteEvent) -> MPRemoteCommandHandlerStatus in
                guard let self = self else {return .commandFailed}
                let playerRate = player.rate
                if let event = remoteEvent as? MPChangePlaybackPositionCommandEvent {
                    player.seek(to: CMTime(seconds: event.positionTime, preferredTimescale: CMTimeScale(1000)), completionHandler: { [weak self](success) in
                        guard self != nil else {return}
                        if success {
                            player.rate = playerRate
                        }
                    })
                    return .success
                 }
                return .commandFailed
            }

            // Register to receive events
            UIApplication.shared.beginReceivingRemoteControlEvents()
        } catch {
            print(error)
        }
    }
    func playOrPause() {
        switch SongService.shared.checkIfPaused() {
        case .isPausedd:
            player.play()
            break
        case .isPlayingg:
            player.pause()
            break
        case .undefined:
            break
        }
    }
    func forward(position: Int, songs: [Song]) {
        player.pause()
        configure(song: songs[position])
    }
    func backward(position: Int, songs: [Song]) {
        player.pause()
        configure(song: songs[position])
    }
    func setPlayBttnImage(_ playBttn: UIButton) {
        switch SongService.shared.checkIfPaused() {
        case .isPausedd:
            playBttn.play()
            break
        case .isPlayingg:
            playBttn.pause()
            break
        case .undefined:
            break
        }
    }
    
//MARK: 👇🏻Functions specific to HomeVC only
    // update chnages in MiniPlayer's UI located in HomeVC
    func configMiniPlayerUI(song: Song, currentSongCoverImageView: UIImageView, currentSongNameLabel: UILabel, currentSongArtistNameLabel: UILabel) {
        let coverUrl = song.coverUrlString
        let name = song.name
        let artist = song.artist[0]
        
        currentSongCoverImageView.kf.setImage(with: URL(string: coverUrl), placeholder: UIImage(named: "placeholder"), options: [.transition(.fade(0.5))], progressBlock: nil, completionHandler: nil)
        currentSongNameLabel.text = name
        currentSongArtistNameLabel.text = artist
    }
    
//MARK: 👇🏻Functions specific to PlayerVC only
    // update chnages in Player's UI located in PlayerVC
    func configPlayerUI(song: Song, playBttn: UIButton,coverImageView: UIImageView, coverImageView2: UIImageView, songNameLabel: UILabel, artistNameLabel: UILabel, songProgressSlider: UISlider, completeSongLengthLabel: UILabel, currentTimeLabel: UILabel){
        // get song data
        let coverUrl = song.coverUrlString
        let name = song.name
        let artist = song.artist[0]
        
        // schedule timer
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(changeSliderValueWithTimer), userInfo: nil, repeats: true)
        setPlayBttnImage(playBttn)
        
        // update UI
        coverImageView.kf.setImage(with: URL(string: coverUrl), placeholder: UIImage(named: "placeholder"), options: [.transition(.fade(0.5))], progressBlock: nil, completionHandler: nil)
        coverImageView2.kf.setImage(with: URL(string: coverUrl), placeholder: UIImage(named: "placeholder"), options: [.transition(.fade(0.5))], progressBlock: nil, completionHandler: nil)
        songNameLabel.text = name
        artistNameLabel.text = artist
        
        // song progress slider
        songProgressSlider.minimumValue = 0.0
        // get song's total duration
        let duration = MiniPlayer.shared.player!.currentItem?.asset.duration
        DispatchQueue.main.async {
            completeSongLengthLabel.text = duration?.minutes
            songProgressSlider.maximumValue = Float(CMTimeGetSeconds(duration!))
        }
    }
    
    func setImageAnimation(_ imageView: UIImageView){
        switch SongService.shared.checkIfPaused() {
        case .isPausedd:
            imageView.shrink(0.8)
            break
        case .isPlayingg:
            imageView.toIdentity(1.02)
            break
        case .undefined:
            break
        }
    }
    
    // change values of slider and labe with timer
    @objc func changeSliderValueWithTimer() {
        currentTimeLabel!.text = player.currentTime().minutes
        songProgressSlider!.value = Float(CMTimeGetSeconds(player.currentTime()))
    }
    
    // change value of audio's poition by dragging
    @objc func changeSliderValueOnDrag() {
        let seconds: Int64 = Int64(songProgressSlider!.value)
        let targetTime: CMTime = CMTimeMake(value: seconds, timescale: 1)
        
        // to update now playing in notification center
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(MiniPlayer.shared.player!.currentTime())
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 0
        MPNowPlayingInfoCenter.default().nowPlayingInfo=nowPlayingInfo
        
        MiniPlayer.shared.player!.seek(to: targetTime) { (isCompleted) in
            // to update now playing in notification center
            self.nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(MiniPlayer.shared.player!.currentTime())
            self.nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1
            MPNowPlayingInfoCenter.default().nowPlayingInfo = self.nowPlayingInfo
        }
        self.currentTimeLabel!.text = String(TimeInterval(songProgressSlider!.value).minutes())
    }
    
    // Current Playing list
    func array() -> [Song]{
        let array = currentPlayingInfo?.array
        guard array != nil else { return [Song(name: "NaN", album: "NaN", artist: ["NaN"], genres: "", urlString: "", coverUrlString: "")]}
        return array!
    }
    func position() -> Int{
        let position = currentPlayingInfo?.position
        guard position != nil else {return 0}
        return position!
    }
    func updateCurrentPlaying(songs: [Song], position: Int){
        currentPlayingInfo = CurrentPlaying(array: songs, position: position)
    }
}
