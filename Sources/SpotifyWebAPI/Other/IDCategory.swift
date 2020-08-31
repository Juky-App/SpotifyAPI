import Foundation

/**
 The Spotify ID Category, which is the identifier that appears
 near the beginning of a Spotify URI.
 
 In this URI:
 ```
 "spotify:track:6rqhFgbbKwnb9MLmUQDhG6"
 ```
 "track" is the id category.
 
 Read more at the [Spotify web API reference][1].
 
 [1]: https://developer.spotify.com/documentation/web-api/#spotify-uris-and-ids
 - tag: IDCategory
 */
public enum IDCategory: String, CaseIterable, Codable, Hashable {

    case artist
    case album
    case track
    case playlist
    case show
    case episode
    
    /// See [Identifying Local Files][1].
    ///
    /// [1]: https://developer.spotify.com/documentation/general/guides/local-files-spotify-playlists/
    case local
    
    /// A Spotify user.
    case user
    case unknown
    
}