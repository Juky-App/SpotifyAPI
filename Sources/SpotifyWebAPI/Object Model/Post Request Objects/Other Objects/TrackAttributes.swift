import Foundation


/**
 The [tunable track attributes][1] used in the
 `SpotifyAPI.recommendations(_:limit:market:)` endpoint for
 [getting recommendations based on seeds][2].
 
 Note that all of the properties are mutable.
 
 For most of the attributes, a minimum, target (ideal), and maximum value can be
 provided. This is represented by `AttributeRange`. The target value should not
 be smaller than the minimum or larger than the maximum.

 The total number of seed artists, seed tracks and seed genres must add up to 5 or
 less
 
 Use `SpotifyAPI.recommendationGenres()` to retrive the available
 seed genres.
 
 [1]: https://developer.spotify.com/documentation/web-api/reference/browse/get-recommendations/#tuneable-track-attributes
 [2]: https://developer.spotify.com/documentation/web-api/reference/browse/get-recommendations/
 */
public struct TrackAttributes: Codable, Hashable {

    /// An array of artists URIs.
    /// The total number of seed artists, seed tracks and seed genres
    /// must add up to 5 or less.
    public var seedArtists: [String]?

    /// An array of track URIs.
    /// The total number of seed artists, seed tracks and seed genres
    /// must add up to 5 or less.
    public var seedTracks: [String]?
    
    /**
     An array of genres.
    
     Use `SpotifyAPI.recommendationGenres()` to retrive the available
     genres.
    
     The total number of seed artists, seed tracks and seed genres
     must add up to 5 or less.
     */
    public var seedGenres: [String]?

    /// A confidence measure from 0.0 to 1.0 of whether the track is acoustic.
    /// 1.0 represents high confidence the track is acoustic.
    public var acousticness: AttributeRange<Double>?
    
    /**
     Danceability describes how suitable a track is for dancing based on a
     combination of musical elements including tempo, rhythm stability,
     beat strength, and overall regularity. A value of 0.0 is least danceable
     and 1.0 is most danceable.
     */
    public var danceability: AttributeRange<Double>?
    
    /// The duration of the track in milliseonds.
    public var durationMS: AttributeRange<Int>?
    
    /**
     Energy is a measure from 0.0 to 1.0 and represents a perceptual measure
     of intensity and activity.
     
     Typically, energetic tracks feel fast, loud, and noisy. For example, death
     metal has high energy, while a Bach prelude scores low on the scale.
     Perceptual features contributing to this attribute include dynamic range,
     perceived loudness, timbre, onset rate, and general entropy.
     */
    public var energy: AttributeRange<Double>?
    
    /**
     Predicts whether a track contains no vocals. "Ooh" and "aah" sounds are
     treated as instrumental in this context.
     
     A range from 0 to 1, inclusive. Rap or spoken word tracks are clearly
     "vocal". The closer the instrumentalness value is to 1.0, the greater
     the likelihood the track contains no vocal content. Values above 0.5 are
     intended to represent instrumental tracks, but confidence is higher as the
     value approaches 1.0.
     */
    public var instrumentalness: AttributeRange<Double>?
    
    /**
     The key the track is in.
     
     Integers map to pitches using standard [Pitch Class notation][1].
     E.g. 0 = C, 1 = C♯/D♭, 2 = D, and so on.
     
     [1]: https://en.wikipedia.org/wiki/Pitch_class
     */
    public var key: AttributeRange<Int>?
    
    /**
     Detects the presence of an audience in the recording.
     
     A range from 0 to 1, inclusive. Higher liveness values represent an
     increased probability that the track was performed live. A value above
     0.8 provides strong likelihood that the track is live.
     */
    public var liveness: AttributeRange<Double>?
    
    /**
     The overall loudness of a track in decibels (dB). Loudness values are
     averaged across the entire track and are useful for comparing relative
     loudness of tracks. Loudness is the quality of a sound that is the primary
     psychological correlate of physical strength (amplitude). Values typical
     range between -60 and 0 db.
     */
    public var loudness: AttributeRange<Double>?
    
    /**
     Mode indicates the modality (major or minor) of a track, the type of
     scale from which its melodic content is derived. Major is represented
     by 1 and minor is 0.
     */
    public var mode: AttributeRange<Int>?
    
    /**
     The popularity of the track.

     The value will be between 0 and 100, with 100 being the most popular.
     The popularity is calculated by algorithm and is based, in the most part,
     on the total number of plays the track has had and how recent those plays are.
     Note: When applying track relinking via the market parameter, it is expected to
     find relinked tracks with popularities that do not match min, max, and target
     popularities. These relinked tracks are accurate replacements for unplayable
     tracks with the expected popularity scores. Original, non-relinked tracks are
     available via the `linkedFrom` attribute of the [relinked track response][1].
     
     [1]: https://developer.spotify.com/documentation/general/guides/track-relinking-guide
     */
    public var popularity: AttributeRange<Int>?
    
    /**
     Speechiness detects the presence of spoken words in a track.
     
     A range from 0 to 1, inclusive. The more exclusively speech-like the recording
     (e.g. talk show, audio book, poetry), the closer to 1.0 the attribute value.
     Values above 0.66 describe tracks that are probably made entirely of spoken
     words. Values between 0.33 and 0.66 describe tracks that may contain both music
     and speech, either in sections or layered, including such cases as rap music.
     Values below 0.33 most likely represent music and other non-speech-like tracks.
     */
    public var speechiness: AttributeRange<Double>?
    
    /**
     The overall estimated tempo of a track in beats per minute (BPM).
     
     In musical terminology, tempo is the speed or pace of a given piece and derives
     directly from the average beat duration.
     */
    public var tempo: AttributeRange<Double>?
    
    /**
     An estimated overall time signature of a track.
     
     The time signature (meter) is a notational convention to specify how many beats
     are in each bar (or measure).
     */
    public var timeSignature: AttributeRange<Int>?
    
    /**
     A measure from 0.0 to 1.0 describing the musical positiveness conveyed by a
     track.
     
     Tracks with high valence sound more positive (e.g. happy, cheerful, euphoric),
     while tracks with low valence sound more negative (e.g. sad, depressed, angry).
     */
    public var valence: AttributeRange<Double>?

    /**
     Creates the [tunable track attributes][1] used in the endpoint for
     [getting recommendations based on seeds][2].
     
     For most of the attributes, a minimum, target (ideal), and maximum value can be
     provided. This is represented by `AttributeRange`. The target value should not
     be smaller than the minimum or larger than the maximum.
     
     The total number of seed artists, seed tracks and seed genres must add up to 5
     or less.
     
     - Parameters:
       - seedArtists: An array of artists URIs.
       - seedGenres: An array of artists genres. Use
             `SpotifyAPI.recommendationGenres()` to retrive the available seed
              genres.
       - seedTracks: An array of track URIs.
       - acousticness: A confidence measure from 0.0 to 1.0 of whether the track
             is acoustic. 1.0 represents high confidence the track is acoustic.
       - danceability: Danceability describes how suitable a track is for dancing
             based on a combination of musical elements including tempo, rhythm
             stability, beat strength, and overall regularity. A value of 0.0 is
             least danceable and 1.0 is most danceable.
       - durationMS: The duration of the track in milliseonds.
       - energy: Energy is a measure from 0.0 to 1.0 and represents a perceptual
             measure of intensity and activity. Typically, energetic tracks feel
             fast, loud, and noisy. For example, death metal has high energy,
             while a Bach prelude scores low on the scale. Perceptual features
             contributing to this attribute include dynamic range, perceived
             loudness, timbre, onset rate, and general entropy.
       - instrumentalness: Predicts whether a track contains no vocals. "Ooh" and
             "aah" sounds are treated as instrumental in this context. A range from
             0 to 1, inclusive. Rap or spoken word tracks are clearly "vocal". The
             closer the instrumentalness value is to 1.0, the greater the likelihood
             the track contains no vocal content. Values above 0.5 are intended
             to represent instrumental tracks, but confidence is higher as the value
             approaches 1.0.
       - key: The key the track is in. Integers map to pitches using standard
             [Pitch Class notation][3]. E.g. 0 = C, 1 = C♯/D♭, 2 = D, and so on.
       - liveness: Detects the presence of an audience in the recording. A range
             from 0 to 1, inclusive. Higher liveness values represent an
             increased probability that the track was performed live. A value
             above 0.8 provides strong likelihood that the track is live.
       - loudness: The overall loudness of a track in decibels (dB). Loudness
             values are averaged across the entire track and are useful for
             comparing relative loudness of tracks. Loudness is the quality of a
             sound that is the primary psychological correlate of physical strength
             (amplitude). Values typically in the range between -60 and 0 db.
       - mode: Mode indicates the modality (major or minor) of a track, the
             type of scale from which its melodic content is derived. Major is
             represented by 1 and minor is 0.
       - popularity: The popularity of the track. The value will be between 0 and
             100, with 100 being the most popular. The popularity is calculated by
             algorithm and is based, in the most part, on the total number of
             plays the track has had and how recent those plays are. Note: When
             applying track relinking via the market parameter, it is expected to
             find relinked tracks with popularities that do not match min, max,
             and target popularities. These relinked tracks are accurate replacements
             for unplayable tracks with the expected popularity scores. Original,
             non-relinked tracks are available via the `linkedFrom` attribute of
             the [relinked track response][4].
       - speechiness: Speechiness detects the presence of spoken words in a track.
             A range from 0 to 1, inclusive. The more exclusively speech-like the
             recording (e.g. talk show, audio book, poetry), the closer to 1.0 the
             attribute value. Values above 0.66 describe tracks that are probably made
             entirely of spoken words. Values between 0.33 and 0.66 describe tracks
             that may contain both music and speech, either in sections or layered,
             including such cases as rap music. Values below 0.33 most likely
             represent music and other non-speech-like tracks.
       - tempo: The overall estimated tempo of a track in beats per minute (BPM).
             In musical terminology, tempo is the speed or pace of a given piece
             and derives directly from the average beat duration.
       - timeSignature: An estimated overall time signature of a track.
             The time signature (meter) is a notational convention to specify how
             many beats are in each bar (or measure).
       - valence: A measure from 0.0 to 1.0 describing the musical positiveness
             conveyed by a track. Tracks with high valence sound more positive
             (e.g. happy, cheerful, euphoric), while tracks with low valence
             sound more negative (e.g. sad, depressed, angry).
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/browse/get-recommendations/#tuneable-track-attributes
     [2]: https://developer.spotify.com/documentation/web-api/reference/browse/get-recommendations/
     [3]: https://en.wikipedia.org/wiki/Pitch_class
     [4]: https://developer.spotify.com/documentation/general/guides/track-relinking-guide
     */
    public init(
        seedArtists: [SpotifyURIConvertible]? = nil,
        seedTracks: [SpotifyURIConvertible]? = nil,
        seedGenres: [String]? = nil,
        acousticness: AttributeRange<Double>? = nil,
        danceability: AttributeRange<Double>? = nil,
        durationMS: AttributeRange<Int>? = nil,
        energy: AttributeRange<Double>? = nil,
        instrumentalness: AttributeRange<Double>? = nil,
        key: AttributeRange<Int>? = nil,
        liveness: AttributeRange<Double>? = nil,
        loudness: AttributeRange<Double>? = nil,
        mode: AttributeRange<Int>? = nil,
        popularity: AttributeRange<Int>? = nil,
        speechiness: AttributeRange<Double>? = nil,
        tempo: AttributeRange<Double>? = nil,
        timeSignature: AttributeRange<Int>? = nil,
        valence: AttributeRange<Double>? = nil
    ) {
        self.seedArtists = seedArtists?.map(\.uri)
        self.seedGenres = seedGenres
        self.seedTracks = seedTracks?.map(\.uri)
        self.acousticness = acousticness
        self.danceability = danceability
        self.durationMS = durationMS
        self.energy = energy
        self.instrumentalness = instrumentalness
        self.key = key
        self.liveness = liveness
        self.loudness = loudness
        self.mode = mode
        self.popularity = popularity
        self.speechiness = speechiness
        self.tempo = tempo
        self.timeSignature = timeSignature
        self.valence = valence
    }

    /**
     Creates the query dictionary that is ultimately used in the
     [endpoint to request track attributes][1].
     
     You shouldn't need to call this directly. It is called by
     `SpotifyAPI.recommendations(_:limit:market:)`.
     
     See also `AttributeRange.queryDictionary(attributeName:)`, which
     is called on each property of this type to create the dictionary.
     
     - Throws: If an id could not be parsed from any of the artist
           or track URIs, or if these URIs do not match the artist
           and track categories, respectively.
     
     [1]: https://developer.spotify.com/console/get-recommendations/?seed_artists=4NHQUGzhtTLFvgF5SZesLK&seed_tracks=0c6xIDDpzE81m2q797ordA&min_energy=0.4&min_popularity=50&market=US
     */
    public func queryDictionary() throws -> [String: String] {

        var seedsCount = 0
        
        var dictionary: [String: String] = [:]
        
        if let seedArtists = self.seedArtists {
            let idsString = try SpotifyIdentifier.commaSeparatedIdsString(
                seedArtists, ensureCategoryMatches: [.artist]
            )
            dictionary += [CodingKeys.seedArtists.rawValue: idsString]
            seedsCount += seedArtists.count
        }
        if let seedGenres = self.seedGenres {
            dictionary += [
                CodingKeys.seedGenres.rawValue: seedGenres.joined(separator: ",")
            ]
            seedsCount += seedGenres.count
        }
        if let seedTracks = self.seedTracks {
            let idsString = try SpotifyIdentifier.commaSeparatedIdsString(
                seedTracks, ensureCategoryMatches: [.track]
            )
            dictionary += [CodingKeys.seedTracks.rawValue: idsString]
            seedsCount += seedTracks.count
        }
        
        if seedsCount > 5 {
            print(
                """
                TrackAttributes: WARNING: the total number of seed artists \
                seed tracks and seed genres must add up to 5 or less \
                (received \(seedsCount). You may recevie an error from \
                the Spotify web API.
                """
            )
        }
        
        if let acousticness = self.acousticness {
            dictionary += acousticness.queryDictionary(
                attributeName: CodingKeys.acousticness.rawValue
            )
        }
        if let danceability = self.danceability {
            dictionary += danceability.queryDictionary(
                attributeName: CodingKeys.danceability.rawValue
            )
        }
        if let durationMS = self.durationMS {
            dictionary += durationMS.queryDictionary(
                attributeName: CodingKeys.durationMS.rawValue
            )
        }
        if let energy = self.energy {
            dictionary += energy.queryDictionary(
                attributeName: CodingKeys.energy.rawValue
            )
        }
        if let instrumentalness = self.instrumentalness {
            dictionary += instrumentalness.queryDictionary(
                attributeName: CodingKeys.instrumentalness.rawValue
            )
        }
        if let key = self.key {
            dictionary += key.queryDictionary(
                attributeName: CodingKeys.key.rawValue
            )
        }
        if let liveness = self.liveness {
            dictionary += liveness.queryDictionary(
                attributeName: CodingKeys.liveness.rawValue
            )
        }
        if let loudness = self.loudness {
            dictionary += loudness.queryDictionary(
                attributeName: CodingKeys.loudness.rawValue
            )
        }
        if let mode = self.mode {
            dictionary += mode.queryDictionary(
                attributeName: CodingKeys.mode.rawValue
            )
        }
        if let popularity = self.popularity {
            dictionary += popularity.queryDictionary(
                attributeName: CodingKeys.popularity.rawValue
            )
        }
        if let speechiness = self.speechiness {
            dictionary += speechiness.queryDictionary(
                attributeName: CodingKeys.speechiness.rawValue
            )
        }
        if let tempo = self.tempo {
            dictionary += tempo.queryDictionary(
                attributeName: CodingKeys.tempo.rawValue
            )
        }
        if let timeSignature = self.timeSignature {
            dictionary += timeSignature.queryDictionary(
                attributeName: CodingKeys.timeSignature.rawValue
            )
        }
        if let valence = self.valence {
            dictionary += valence.queryDictionary(
                attributeName: CodingKeys.valence.rawValue
            )
        }
        
        return dictionary
        
    }
    
    public enum CodingKeys: String, CodingKey {
        case seedArtists = "seed_artists"
        case seedTracks = "seed_tracks"
        case seedGenres = "seed_genres"
        case acousticness
        case danceability
        case durationMS = "duration_ms"
        case energy
        case instrumentalness
        case key
        case liveness
        case loudness
        case mode
        case popularity
        case speechiness
        case tempo
        case timeSignature = "time_signature"
        case valence
    }
    
}
