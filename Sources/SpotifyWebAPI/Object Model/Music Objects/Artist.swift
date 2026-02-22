import Foundation

/// A Spotify artist.
public struct Artist: Hashable {
    
    /// The name of the artist.
    public let name: String
    
    /// The [Spotify URI][1] for the artist.
    ///
    /// [1]: https://developer.spotify.com/documentation/web-api/concepts/spotify-uris-ids
    public let uri: String?

    /// The [Spotify ID][1] for the artist.
    ///
    /// [1]: https://developer.spotify.com/documentation/web-api/concepts/spotify-uris-ids
    public let id: String?
    
    /// Images of the artist in various sizes, widest first.
    ///
    /// Only available for the full artist object.
    public let images: [SpotifyImage]?
    
    /**
     Known external urls for this artist.
    
     - key: The type of the URL, for example: "spotify" - The [Spotify URL][1]
           for the object.
     - value: An external, public URL to the object.
    
     [1]: https://developer.spotify.com/documentation/web-api/concepts/spotify-uris-ids
     */
    public let externalURLs: [String: URL]?
    
    /**
     A list of the genres the artist is associated with.
    
     For example: "Prog Rock" , "Post-Grunge". (If not yet classified, the array
     is empty.)
    
     Only available for the full artist object.
     */
    public let genres: [String]?

    /**
     A link to the Spotify web API endpoint providing the full artist object.
     
     Use ``SpotifyAPI/getFromHref(_:responseType:)``, passing in ``Artist`` as
     the response type to retrieve the results.
     */
    public let href: URL?
    
    /// The object type. Always ``IDCategory/artist``.
    public let type: IDCategory
    
    /**
     A Spotify artist.
     
     - Parameters:
       - name: The name of the artist.
       - uri: The [Spotify URI][1] for the artist.
       - id: The [Spotify ID][1] for the artist.
       - images: Images of the artist.
       - externalURLs: Known external urls for this artist.
             - key: The type of the URL, for example: "spotify" - The [Spotify
                   URL][1] for the object.
             - value: An external, public URL to the object.
       - genres: A list of the genres the artist is associated with.
       - href: A link to the Spotify web API endpoint providing the full
             artist object.
     
     [1]: https://developer.spotify.com/documentation/web-api/concepts/spotify-uris-ids
     */
    public init(
        name: String,
        uri: String? = nil,
        id: String? = nil,
        images: [SpotifyImage]? = nil,
        externalURLs: [String: URL]? = nil,
        genres: [String]? = nil,
        href: URL? = nil
    ) {
        self.name = name
        self.uri = uri
        self.id = id
        self.images = images
        self.externalURLs = externalURLs
        self.genres = genres
        self.href = href
        self.type = .artist
    }

}

extension Artist: Codable {

    public init(from decoder: any Decoder) throws {

        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.name = try container.decodeIfPresent(
            String.self, forKey: .name
        ) ?? ""
        
        self.uri =  try container.decodeIfPresent(
            String.self, forKey: .uri
        )
        
        self.id =  try container.decodeIfPresent(
            String.self, forKey: .id
        )

        self.images = try container.decodeSpotifyImages(forKey: .images)

        self.externalURLs =  try container.decodeIfPresent(
            [String: URL].self, forKey: .externalURLs
        )

        self.genres = try container.decodeAndUnwrapArray(forKey: .genres)

        self.href =  try container.decodeIfPresent(
            URL.self, forKey: .href
        )

        self.type = (try? container.decodeIfPresent(
            IDCategory.self, forKey: .type
        )) ?? .artist

    }

    private enum CodingKeys: String, CodingKey {
        case name
        case uri
        case id
        case images
        case externalURLs = "external_urls"
        case genres
        case href
        case type
    }
    
}
