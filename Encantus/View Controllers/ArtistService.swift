//
//  ArtistService.swift
//  Encantus
//
//  Created by Ankit Yadav on 02/07/21.
//

import Foundation

class ArtistService {
    
    static let shared = ArtistService()
    
    let artistArray = [Artist(uid: "sidhu",
                              name: "Sidhu Moosewala",
                              profileImageUrl: "https://siachenstudios.com/wp-content/uploads/2020/05/sidhu-moose-wala-siachen-studios.jpg",
                              albumsId: ["moosetape"],
                              tracksId: ["Sidhu1", "Sidhu2"],
                              isVerified: true,
                              followers: 19866910,
                              origin: "Punjab, India"),
                       Artist(uid: "jubin",
                              name: "Jubin Nautiyal",
                              profileImageUrl: "https://pbs.twimg.com/profile_images/789829943072989185/7MrhCADz_400x400.jpg",
                              albumsId: ["ginnyWedsSunny"],
                              tracksId: ["Jubin1"],
                              isVerified: true,
                              followers: 213400,
                              origin: "Jaunsar, Uttrakhand")]
    
    let albumArray = [Album(uid: "moosetape",
                            name: "MooseTape",
                            albumCoverUrl: "https://pbs.twimg.com/media/E1grV6kXIAEYKEi?format=jpg&name=medium",
                            genres: "Punjabi",
                            artistId: ["sidhu"],
                            trackId: ["Sidhu1","Sidhu2"]),
                      Album(uid: "ginnyWedsSunny",
                            name: "Ginny Weds Sunny",
                            albumCoverUrl: "https://dl.dropboxusercontent.com/s/nyoiszqo3fax83s/Phir%20Chala.png?dl=0",
                            genres: "Bollywood",
                            artistId: ["jubin"],
                            trackId: ["Jubin1"])]
    
    
    func getArtist(byId: String) -> Artist {
        var myArtist: Artist?
        for artist in artistArray {
            if artist.uid == byId {
                myArtist = artist
            }
        }
        guard myArtist != nil else {
            return Artist(uid: "NaN", name: "NaN", profileImageUrl: "NaN", albumsId: ["NaN"], tracksId: ["NaN"], isVerified: false, followers: 0, origin: "NaN")
        }
        return myArtist!
    }
    func getAlbum(byId: String) -> Album {
        var myAlbum: Album?
        for album in albumArray {
            if album.uid == byId {
                myAlbum = album
            }
        }
        guard myAlbum != nil else {
            return Album(uid: "NaN", name: "NaN", albumCoverUrl: "NaN", genres: "NaN", artistId: ["NaN"], trackId: ["NaN"])
        }
        return myAlbum!
    }
    
    // get all albums of an artist by their id
    func getAllAlbumbs(byArtistId: String) -> [Album] {
        let artist = getArtist(byId: byArtistId)
        var myAlbums = [Album]()
        for album in albumArray {
            if artist.albumsId.contains(album.uid){
                myAlbums.append(album)
            }
        }
        return myAlbums
    }
    // get all tracks of an Artist by Id
    func getAllTracks(byArtistId: String, amongTracks: [Track]) -> [Track] {
        let artist = getArtist(byId: byArtistId)
        var myTracks = [Track]()
        for track in amongTracks {
            if artist.tracksId.contains(track.uid){
                myTracks.append(track)
            }
        }
        return myTracks
    }
    func getAllTracks(byAlbumId: String, amongTracks: [Track]) -> [Track] {
        let album = getAlbum(byId: byAlbumId)
        var myTracks = [Track]()
        for track in amongTracks {
            if album.trackId.contains(track.uid){
                myTracks.append(track)
            }
        }
        return myTracks
    }
}
