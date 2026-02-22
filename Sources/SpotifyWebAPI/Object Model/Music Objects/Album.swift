import Foundation

/// A Spotify album.
public struct Album: Hashable {
    
    /// The name of the album.
    ///
    /// In case of an album takedown, the value may be an empty string.
    public let name: String
    
    /**
     The tracks of the album.
     
     For certain endpoints, this property may be `nil`, especially if it is
     nested inside a much larger object. For example, it will be `nil` if
     retrieved from the search endpoint or if nested inside a ``Track``. When
     this property is `nil`, use
     ``SpotifyAPI/albumTracks(_:market:limit:offset:)`` instead, passing in the
     URI of this album.
     */
    public let tracks: PagingObject<Track>?
    
    /// The artists of the album. The simplified versions will be returned.
    ///
    /// Each artist object includes a link in href to more detailed information
    /// about the artist.
    public let artists: [Artist]?
    
    /// The date the album was first released. See also
    /// ``releaseDatePrecision``.
    public let releaseDate: String?

    /// The [Spotify URI][1] for the album.
    ///
    /// [1]: https://developer.spotify.com/documentation/web-api/concepts/spotify-uris-ids
    public let uri: String?
    
    /// The [Spotify ID][1] for the album.
    ///
    /// [1]: https://developer.spotify.com/documentation/web-api/concepts/spotify-uris-ids
    public let id: String?
    
    /// The cover art for the album in various sizes, widest first.
    public let images: [SpotifyImage]?
    
    /**
     A list of the genres the artist is associated with.
    
     For example: "Prog Rock" , "Post-Grunge". (If not yet classified, the array
     is empty.)
    
     Only available for the full album object.
     */
    public let genres: [String]?
    
    /// The total number of tracks in the album.
    public let totalTracks: Int?

    /**
     A link to the Spotify web API endpoint providing the full album object.
     
     Use ``SpotifyAPI/getFromHref(_:responseType:)``, passing in ``Album`` as
     the response type to retrieve the results.
     */
    public let href: URL?

    /**
     Known external urls for this artist.

     - key: The type of the URL, for example: "spotify" - The [Spotify URL][1]
           for the object.
     - value: An external, public URL to the object.

     [1]: https://developer.spotify.com/documentation/web-api/concepts/spotify-uris-ids
     */
    public let externalURLs: [String: URL]?

    /// The type of the album: one of ``AlbumType/album``, ``AlbumType/single``,
    /// or ``AlbumType/compilation``. See also ``albumGroup``.
    public let albumType: AlbumType?

    /// The copyrights for the album.
    public let copyrights: [SpotifyCopyright]?

    /// The precision with which ``releaseDate`` is known: "year", "month", or
    /// "day".
    public let releaseDatePrecision: String?

    /**
     Part of the response when a content restriction, such as Track
     Relinking, is applied. Else, `nil`.
     
     The key will be "reason", and the value will be one of the
     following:
     * "market" - The content item is not available in the given market.
     * "product" - The content item is not available for the user’s subscription
       type.
     * "explicit" - The content item is explicit and the user’s account is set
       to not play explicit content.
     
     Additional reasons and additional keys may be added in the future.
     
     Read about [Track Relinking][1].

     [1]: https://developer.spotify.com/documentation/general/guides/track-relinking-guide/
     */
    public let restrictions: [String: String]?
    
    /// The object type. Always ``IDCategory/album``.
    public let type: IDCategory
    
    /**
     Creates a Spotify album.
     
     - Parameters:
       - name: The name of the album.
       - tracks: The tracks of the album.
       - artists:  The artists of the album.
       - releaseDate: The date the album was first released.
       - uri: The [Spotify URI][1] for the album.
       - id: The [Spotify ID][1] for the album.
       - images: The cover art for the album.
       - genres: A list of the genres the artist is associated with.
       - totalTracks: The total number of tracks in the album.
       - href: A link to the Spotify web API endpoint providing the full album
             object.
       - externalURLs: Known external urls for this artist.
             - key: The type of the URL, for example: "spotify" - The [Spotify
                   URL][1] for the object.
             - value: An external, public URL to the object.
       - albumType: The type of the album: one of ``AlbumType/album``,
             ``AlbumType/single``, or ``AlbumType/compilation``.
       - copyrights: The copyrights for the album.
       - releaseDatePrecision: The precision with which ``releaseDate`` is known:
             "year", "month", or "day".
       - restrictions: Part of the response when a content restriction, such as
             [Track Relinking][6], is applied. Else, `nil`. The key will be
             "reason", and the value will be one of the following:
             * "market" - The content item is not available in the given market.
             * "product" - The content item is not available for the user’s
               subscription type.
             * "explicit" - The content item is explicit and the user’s account
               is set to not play explicit content.
             Additional reasons and additional keys may be added in the future.
     
     [1]: https://developer.spotify.com/documentation/web-api/concepts/spotify-uris-ids
     [2]: http://en.wikipedia.org/wiki/International_Standard_Recording_Code
     [3]: http://en.wikipedia.org/wiki/International_Article_Number_%28EAN%29
     [4]: http://en.wikipedia.org/wiki/Universal_Product_Code
     [5]: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
     [6]: https://developer.spotify.com/documentation/general/guides/track-relinking-guide/
     */
    public init(
        name: String,
        tracks: PagingObject<Track>? = nil,
        artists: [Artist]? = nil,
        releaseDate: String? = nil,
        uri: String? = nil,
        id: String? = nil,
        images: [SpotifyImage]? = nil,
        genres: [String]? = nil,
        totalTracks: Int? = nil,
        href: URL? = nil,
        externalURLs: [String: URL]? = nil,
        albumType: AlbumType? = nil,
        copyrights: [SpotifyCopyright]? = nil,
        releaseDatePrecision: String? = nil,
        restrictions: [String: String]? = nil
    ) {
        self.name = name
        self.tracks = tracks
        self.artists = artists
        self.releaseDate = releaseDate
        self.uri = uri
        self.id = id
        self.images = images
        self.genres = genres
        self.totalTracks = totalTracks
        self.href = href
        self.externalURLs = externalURLs
        self.albumType = albumType
        self.copyrights = copyrights
        self.releaseDatePrecision = releaseDatePrecision
        self.restrictions = restrictions
        self.type = .album
    }

}

extension Album: Codable {
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.name = try container.decodeIfPresent(
            String.self, forKey: .name
        ) ?? ""

        self.tracks = try container.decodeIfPresent(
            PagingObject<Track>.self, forKey: .tracks
        )
        self.artists = try container.decodeIfPresent(
            [Artist].self, forKey: .artists
        )
        

        self.releaseDate = try container.decodeIfPresent(
            String.self, forKey: .releaseDate
        )

        self.releaseDatePrecision = try container.decodeIfPresent(
            String.self, forKey: .releaseDatePrecision
        )
        self.uri = try container.decodeIfPresent(
            String.self, forKey: .uri
        )
        self.id = try container.decodeIfPresent(
            String.self, forKey: .id
        )

        self.images = try container.decodeSpotifyImages(forKey: .images)

        self.genres = try container.decodeIfPresent(
            [String].self, forKey: .genres
        )
        self.totalTracks = try container.decodeIfPresent(
            Int.self, forKey: .totalTracks
        )
        self.href = try container.decodeIfPresent(
            URL.self, forKey: .href
        )
        self.externalURLs = try container.decodeIfPresent(
            [String: URL].self, forKey: .externalURLs
        )
        self.albumType = try container.decodeIfPresent(
            AlbumType.self, forKey: .albumType
        )
        
        self.copyrights = try container.decodeIfPresent(
            [SpotifyCopyright].self, forKey: .copyrights
        )
        self.restrictions = try container.decodeIfPresent(
            [String: String].self, forKey: .restrictions
        )

        self.type = (try? container.decodeIfPresent(
            IDCategory.self, forKey: .type
        )) ?? .album

    }
    
    public func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(
            self.name, forKey: .name
        )
        try container.encodeIfPresent(
            self.tracks, forKey: .tracks
        )
        try container.encodeIfPresent(
            self.artists, forKey: .artists
        )
        
        try container.encodeIfPresent(
            self.releaseDate,
            forKey: .releaseDate
        )

        try container.encodeIfPresent(
            self.releaseDatePrecision,
            forKey: .releaseDatePrecision
        )
        try container.encodeIfPresent(
            self.uri, forKey: .uri
        )
        try container.encodeIfPresent(
            self.id, forKey: .id
        )
        try container.encodeIfPresent(
            self.images, forKey: .images
        )
        try container.encodeIfPresent(
            self.genres, forKey: .genres
        )
        try container.encodeIfPresent(
            self.totalTracks, forKey: .totalTracks
        )
        try container.encodeIfPresent(
            self.href, forKey: .href
        )
        try container.encodeIfPresent(
            self.externalURLs, forKey: .externalURLs
        )
        try container.encodeIfPresent(
            self.copyrights, forKey: .copyrights
        )
        try container.encodeIfPresent(
            self.restrictions, forKey: .restrictions
        )
        try container.encode(
            self.type, forKey: .type
        )
        
    }
    
    private enum CodingKeys: String, CodingKey {
        case name
        case tracks
        case artists
        case releaseDate = "release_date"
        case uri
        case id
        case images
        case genres
        case totalTracks = "total_tracks"
        case href
        case externalURLs = "external_urls"
        case albumType = "album_type"
        case copyrights
        case releaseDatePrecision = "release_date_precision"
        case restrictions
        case type
    }
    

}

extension Album: ApproximatelyEquatable {
    
    /**
     Returns `true` if all the `FloatingPoint` properties of `self` are
     approximately equal to those of `other` within an absolute tolerance of
     0.001 and all other properties are equal by the `==` operator. Else,
     returns `false`.
     
     ``Album/releaseDate`` is compared using `timeIntervalSince1970`, so it
     is considered a floating point property for the purposes of this method.
     
     - Parameter other: Another instance of `Self`.
     */
    public func isApproximatelyEqual(to other: Self) -> Bool {
        
        return self.name == other.name &&
                self.tracks == other.tracks &&
                self.artists == other.artists &&
                self.uri == other.uri &&
                self.id == other.id &&
                self.images == other.images &&
                self.genres == other.genres &&
                self.totalTracks == other.totalTracks &&
                self.href == other.href &&
                self.externalURLs == other.externalURLs &&
                self.copyrights == other.copyrights &&
                self.releaseDatePrecision == other.releaseDatePrecision &&
                self.restrictions == other.restrictions &&
                self.type == other.type &&
                self.releaseDate == other.releaseDate

    }

}
