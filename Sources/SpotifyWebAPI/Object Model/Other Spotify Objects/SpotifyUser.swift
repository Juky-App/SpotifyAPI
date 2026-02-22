import Foundation

/**
 A Spotify user.
 
 Can represent both the public and private version. When the public version is
 returned, properties that are only available in the private version will be
 `nil`.
 */
public struct SpotifyUser: SpotifyURIConvertible, Hashable {
    
    /// The name displayed on the user’s profile.
    public let displayName: String?

    /// The [Spotify URI][1] for this user.
    ///
    /// [1]: https://developer.spotify.com/documentation/web-api/concepts/spotify-uris-ids
    public let uri: String
    
    /// The [Spotify user ID][1] for this user.
    ///
    /// [1]: https://developer.spotify.com/documentation/web-api/concepts/spotify-uris-ids
    public let id: String
    
    /// The user's profile image in various sizes.
    public let images: [SpotifyImage]?
    
    /**
     A link to the Spotify web API endpoint for this user.
     
     Use ``SpotifyAPI/getFromHref(_:responseType:)``, passing in ``SpotifyUser``
     as the response type to retrieve the results.
     */
    public let href: URL
    
    /**
    Known external urls for this user.

    - key: The type of the URL, for example: "spotify" - The [Spotify URL][1]
          for the object.
    - value: An external, public URL to the object.

    [1]: https://developer.spotify.com/documentation/web-api/concepts/spotify-uris-ids
    */
    public let externalURLs: [String: URL]?
    
    /// The object type. Always ``IDCategory/user``.
    public let type: IDCategory
    
    /**
     Creates a Spotify user.
     
     - Parameters:
       - displayName: The name displayed on the user’s profile.
       - uri: The [Spotify URI][1] for this user.
       - id: The [Spotify user ID][1] for this user.
       - images: The user's profile image in various sizes.
       - href: A link to the Spotify web API endpoint for this user.
       - externalURLs: Known external urls for this artist.
             - key: The type of the URL, for example: "spotify" - The [Spotify
                   URL][1] for the object.
             - value: An external, public URL to the object.
     
     [1]: https://developer.spotify.com/documentation/web-api/concepts/spotify-uris-ids
     [2]: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
     */
    public init(
        displayName: String? = nil,
        uri: String,
        id: String,
        images: [SpotifyImage]? = nil,
        href: URL,
        externalURLs: [String: URL]? = nil
    ) {
        self.displayName = displayName
        self.uri = uri
        self.id = id
        self.images = images
        self.href = href
        self.externalURLs = externalURLs
        self.type = .user
        
    }
    
}

extension SpotifyUser: Codable {
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.displayName = try container.decodeIfPresent(
            String.self, forKey: .displayName
        )
        
        self.uri = try container.decodeUserURI(forKey: .uri)
        
        self.id = try container.decode(
            String.self, forKey: .id
        )

        self.images = try container.decodeSpotifyImages(forKey: .images)
        
        self.href = try container.decode(
            URL.self, forKey: .href
        )
        self.externalURLs = try container.decodeIfPresent(
            [String: URL].self, forKey: .externalURLs
        )

        self.type = (try? container.decodeIfPresent(
            IDCategory.self, forKey: .type
        )) ?? .user

    }

    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(
            self.displayName, forKey: .displayName
        )
        
        try container.encodeUserURI(self.uri, forKey: .uri)
        
        try container.encode(
            self.id, forKey: .id
        )
        try container.encodeIfPresent(
            self.images, forKey: .images
        )
        try container.encode(
            self.href, forKey: .href
        )
        try container.encodeIfPresent(
            self.externalURLs, forKey: .externalURLs
        )
        try container.encode(
            self.type, forKey: .type
        )

    }

    private enum CodingKeys: String, CodingKey {
        case displayName = "display_name"
        case uri
        case id
        case images
        case href
        case externalURLs = "external_urls"
        case type
    }

}
