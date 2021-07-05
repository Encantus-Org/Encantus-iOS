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

/*
We've 2 scenes(players) while playing a song -> 1. Player i.e. situated in PlayerVC
                                                2. MiniPlayer i.e situate in toolbar in HomeVC
*/
class MiniPlayer {
    
    var player: AVPlayer!
    var nowPlayingInfo = [String : Any]()
    
    static let shared = MiniPlayer()
    
//MARK: 👇🏻Functions specific to both PlayerVC & HomeVC
    // configure a track, basically play it
    func configurePlayer(withTracks: Track) {
        // get track data
        let name = withTracks.name
        let artistId = withTracks.artistId[0]
        let artist = ArtistService.shared.getArtist(byId: artistId).name
        let albumId = withTracks.albumId
        let album = ArtistService.shared.getAlbum(byId: albumId).name
        let genre = withTracks.genres
        let urlString = withTracks.urlString
        let cover = UIImage(named: "encantus-logo") // TODO - CODE A LOGIC TO GET THE COVER
        
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
            
            // if there's already a track playing, then stop that and start selected track
            if player.isPlaying {
                player.pause()
            }
            
            // play the track
            player.play()
            
            // to set play icon in playbttn in HomeVC when a track is forwarded when paused from PlayerVC
            if self.playBttnInHome != nil {
                setPlayBttnImage(self.playBttnInHome!)
            }
            
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
        switch TrackService.shared.checkIfPaused() {
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
    
    func forward(inTrackList: [Track], toPosition: Int) {
        player.pause()
        if coverImageView!.image != nil {
            coverImageView!.toIdentity(1.05)
        }
        configurePlayer(withTracks: inTrackList[toPosition])
    }
    
    func backward(inTrackList: [Track], toPosition: Int) {
        player.pause()
        if coverImageView!.image != nil {
            coverImageView!.toIdentity(1.05)
        }
        configurePlayer(withTracks: inTrackList[toPosition])
    }
    
    func setPlayBttnImage(_ playBttn: UIButton) {
        switch TrackService.shared.checkIfPaused() {
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
    
//MARK: 👇🏻references specific to HomeVC only
    var currentSongCoverImageView:UIImageView?
    var currentSongNameLabel: UILabel?
    var currentSongArtistNameLabel: UILabel?
    var playBttnInHome: UIButton?
    
//MARK: 👇🏻references specific to Player only
    var timer: Timer!
    var songNameLabel: UILabel?
    var artistNameLabel: UILabel?
    var currentTimeLabel: UILabel?
    var completeSongLengthLabel: UILabel?
    var songProgressSlider: UISlider?
    var playBttn: UIButton?
    var coverImageView: UIImageView?
    var coverImageView2: UIImageView?
}

// MINIPLAYER ONLY
extension MiniPlayer {
    // update changes in MiniPlayer's UI located in HomeVC
    func configMiniPlayerUI(withTrack: Track) {
        let coverUrl = withTrack.coverUrlString
        let name = withTrack.name
        let artistId = withTrack.artistId[0]
        let artist = ArtistService.shared.getArtist(byId: artistId).name
        
        currentSongCoverImageView!.kf.setImage(with: URL(string: coverUrl), placeholder: UIImage(named: "placeholder"), options: [.transition(.fade(0.5))], progressBlock: nil, completionHandler: nil)
        currentSongNameLabel!.text = name
        currentSongArtistNameLabel!.text = artist
    }
    @objc func miniPlayerBackwardBttnDidTap() {
        let tracksToPlay = tracksToPlay()
        var position = position()
        
        // change the position of track in an array
        if position>0 {
            position = position - 1
        }
        // update current playing value after change the position
        updateCurrentPlaying(withTracksList: tracksToPlay, andPosition: position)
        // update changes in UI of miniPlayer
        configMiniPlayerUI(withTrack: tracksToPlay[position])
        // take user to previous track
        backward(inTrackList: tracksToPlay, toPosition: position)
    }
    @objc func miniPlayerForwardBttnDidTap() {
        let tracksToPlay = tracksToPlay()
        var position = position()
        
        // change the position of track in the playing list
        if position < (tracksToPlay.count - 1) {
            position = position + 1
        }
        // update current playing value after change the position
        updateCurrentPlaying(withTracksList: tracksToPlay, andPosition: position)
        // update changes in UI of miniPlayer
        configMiniPlayerUI(withTrack: tracksToPlay[position])
        // take user to next track
        forward(inTrackList: tracksToPlay, toPosition: position)
    }
    func assignMiniPlayerValues(nameL:UILabel, artistL: UILabel, cover: UIImageView,playBttn: UIButton) {
        currentSongNameLabel = nameL
        currentSongArtistNameLabel = artistL
        currentSongCoverImageView = cover
        playBttnInHome = playBttn
    }
}

// PLAYER ONLY
extension MiniPlayer {
    // update changes in Player's UI located in PlayerVC
    func configPlayerUI(withTrack: Track){
        // get track's data
        let coverUrl = withTrack.coverUrlString
        let name = withTrack.name
        let artistId = withTrack.artistId[0]
        let artist = ArtistService.shared.getArtist(byId: artistId).name
        
        // schedule timer
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(changeSliderValueWithTimer), userInfo: nil, repeats: true)
        setPlayBttnImage(playBttn!)
        
        // update UI
        coverImageView!.kf.setImage(with: URL(string: coverUrl), placeholder: UIImage(named: "placeholder"), options: [.transition(.fade(0.5))], progressBlock: nil, completionHandler: nil)
        coverImageView2!.kf.setImage(with: URL(string: coverUrl), placeholder: UIImage(named: "placeholder"), options: [.transition(.fade(0.5))], progressBlock: nil, completionHandler: nil)
        songNameLabel!.text = name
        artistNameLabel!.text = artist
        
        // track progress slider
        songProgressSlider!.minimumValue = 0.0
        // get track's total duration
        let duration = MiniPlayer.shared.player!.currentItem?.asset.duration
        DispatchQueue.main.async {
            self.completeSongLengthLabel!.text = duration?.minutes
            self.songProgressSlider!.maximumValue = Float(CMTimeGetSeconds(duration!))
        }
    }
    
    func setImageAnimation(_ imageView: UIImageView){
        switch TrackService.shared.checkIfPaused() {
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
    
    // change values of slider and label with timer
    @objc func changeSliderValueWithTimer() {
        currentTimeLabel!.text = player.currentTime().minutes
        UIView.animate(withDuration: 0.1, animations: {
            self.songProgressSlider!.setValue(Float(CMTimeGetSeconds(self.player.currentTime())), animated:true)
        })
    }
    
    // change value of audio's position by dragging
    @objc func changeSliderValueOnDrag() {
        let seconds: Int64 = Int64(songProgressSlider!.value)
        let targetTime: CMTime = CMTimeMake(value: seconds, timescale: 1)
        
        // to update now playing in notification centre
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(MiniPlayer.shared.player!.currentTime())
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 0
        MPNowPlayingInfoCenter.default().nowPlayingInfo=nowPlayingInfo
        
        MiniPlayer.shared.player!.seek(to: targetTime) { (isCompleted) in
            // to update now playing in notification centre
            self.nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(MiniPlayer.shared.player!.currentTime())
            self.nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1
            MPNowPlayingInfoCenter.default().nowPlayingInfo = self.nowPlayingInfo
        }
        self.currentTimeLabel!.text = String(TimeInterval(songProgressSlider!.value).minutes())
    }
    @objc func playerForwardBttnDidTap() {
        miniPlayerForwardBttnDidTap()
        
        let trackToPlay = tracksToPlay()[position()]
        configPlayerUI(withTrack: trackToPlay)
    }
    @objc func playerBackwardBttnDidTap() {
        miniPlayerBackwardBttnDidTap()
        
        let trackToPlay = tracksToPlay()[position()]
        configPlayerUI(withTrack: trackToPlay)
    }
    func assignPlayerValues(nameL:UILabel, artistL: UILabel, currentTimeL: UILabel, completeSongDurationL: UILabel, slider: UISlider, cover1: UIImageView, cover2: UIImageView, playBttn: UIButton) {
        songNameLabel = nameL
        artistNameLabel = artistL
        currentTimeLabel = currentTimeL
        completeSongLengthLabel = completeSongDurationL
        coverImageView = cover1
        coverImageView2 = cover2
        songProgressSlider = slider
        self.playBttn = playBttn
    }
}

// Current Playing list functions
extension MiniPlayer {
    func tracksToPlay() -> [Track]{
        let array = currentPlayingInfo?.playingList
        guard array != nil else { return [Track(uid: "Nan", name: "NaN", albumId: "NaN", artistId: ["NaN"], genres: "", urlString: "Nan", coverUrlString: "NaN")]}
        return array!
    }
    func position() -> Int{
        let position = currentPlayingInfo?.position
        guard position != nil else {return 0}
        return position!
    }
    func updateCurrentPlaying(withTracksList: [Track], andPosition: Int){
        currentPlayingInfo = CurrentPlaying(playingList: withTracksList, position: andPosition)
    }
    func currentPlayingTrack() -> Track {
        return tracksToPlay()[position()]
    }
}
