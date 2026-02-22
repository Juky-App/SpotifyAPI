import Foundation
#if canImport(Combine)
import Combine
#else
import OpenCombine
import OpenCombineDispatch
import OpenCombineFoundation
#endif

public extension SpotifyAPI {

    // MARK: Shows
    
    /**
     Get a show.
     
     See also:
     
     * ``shows(_:market:)`` - gets multiple shows
     * ``showEpisodes(_:market:offset:limit:)`` - gets all of the episodes for a
       show
     
     Reading the user’s resume points on episode objects requires the
     ``Scope/userReadPlaybackPosition`` scope. Otherwise, no scopes are
     required.
     
     Read more at the [Spotify web API reference][1].
     
     - Parameters:
       - uri: The URI of an episode.
       - market: An [ISO 3166-1 alpha-2 country code][2] or the string
             "from_token". If a country code is specified, the show will only be
             returned if it is available in that market. If the access token was
             granted on behalf of a user (i.e., if you authorized your
             application using the authorization code flow or the authorization
             code flow with proof key for code exchange), the country associated
             with the user account will take priority over this parameter. Users
             can view the country that is associated with their account in the
             [account settings][3]. **Note: If neither market or user country**
             **are provided, the show is considered unavailable for the client**
             **and Spotify will return a 404 error with the message "non**
             **existing id". Therefore, if you authorized your application**
             **using the client credentials flow, you must provide a value for**
             **this parameter.**
     - Returns: The full version of a show object.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/#/operations/get-a-show
     [2]: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
     [3]: https://www.spotify.com/account/overview/
     */
    func show(
        _ uri: SpotifyURIConvertible,
        market: String? = nil
    ) -> AnyPublisher<Show, Error> {
        
        do {
            
            let id = try SpotifyIdentifier(
                uri: uri, ensureCategoryMatches: [.show]
            ).id
            
            return self.getRequest(
                path: "/shows/\(id)",
                queryItems: ["market": market],
                requiredScopes: []
            )
            .decodeSpotifyObject(
                Show.self,
                maxRetryDelay: self.maxRetryDelay
            )
            

        } catch {
            return error.anyFailingPublisher()
        }
        
    }

    /**
     Get a show's episodes.
     
     See also:
     
     * ``shows(_:market:)`` - gets multiple shows
     * ``show(_:market:)`` - gets a single show
     
     Reading the user’s resume points on episode objects requires the
     ``Scope/userReadPlaybackPosition`` scope. Otherwise, no scopes are
     required.
     
     Read more at the [Spotify web API reference][1].
     
     - Parameters:
       - uri: The URI of a show.
       - market: An [ISO 3166-1 alpha-2 country code][2] or the string
             "from_token",. If a country code is specified, only episodes that
             are available in that market will be returned. If the access token
             was granted on behalf of a user (i.e., if you authorized your
             application using the authorization code flow or the authorization
             code flow with proof key for code exchange), the country associated
             with the user account will take priority over this parameter. Users
             can view the country that is associated with their account in the
             [account settings][3]. **Note: If neither market or user country**
             **are provided, the show and all of its episodes are considered**
             **unavailable for the client and Spotify will return a 404 error**
             **with the message "non existing id". Therefore, if you**
             **authorized your application using the client credentials flow,**
             **you must provide a value for this parameter.**
       - limit: The maximum number of episodes to return. Default: 20; Minimum:
             1; Maximum: 50.
       - offset: The index of the first episode to return. Default: 0. Use with
             `limit` to get the next set of episodes.
     - Returns: The simplified versions of episode objects wrapped in a paging
             object.
     
     [1]: https://developer.spotify.com/documentation/web-api/reference/#/operations/get-a-shows-episodes
     [2]: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
     [3]: https://www.spotify.com/account/overview/
     */
    func showEpisodes(
        _ uri: SpotifyURIConvertible,
        market: String? = nil,
        offset: Int? = nil,
        limit: Int? = nil
    ) -> AnyPublisher<PagingObject<Episode>, Error> {
        
        do {
            
            let id = try SpotifyIdentifier(
                uri: uri, ensureCategoryMatches: [.show]
            ).id
            
            return self.getRequest(
                path: "/shows/\(id)/episodes",
                queryItems: [
                    "market": market,
                    "limit": limit,
                    "offset": offset
                ],
                requiredScopes: []
            )
            .decodeSpotifyObject(
                PagingObject<Episode>.self,
                maxRetryDelay: self.maxRetryDelay
            )
            
        } catch {
            return error.anyFailingPublisher()
        }
        
        
    }
    
}
