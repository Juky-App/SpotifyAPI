import Foundation
#if canImport(Combine)
import Combine
#else
import OpenCombine
import OpenCombineDispatch
import OpenCombineFoundation
#endif
import XCTest
@testable import SpotifyWebAPI
import SpotifyAPITestUtilities
import SpotifyExampleContent


protocol SpotifyAPIEpisodeTests: SpotifyAPITests { }

extension SpotifyAPIEpisodeTests {

    func receiveSamHarris212(_ episode: Episode) {
        encodeDecode(episode)
        XCTAssertEqual(
            episode.description,
            """
            Sam Harris speaks with Kathryn Paige Harden about public \
            controversy over group differences in traits like intelligence \
            and ongoing research in behavioral genetics. They discuss \
            Harden’s criticism of the Making Sense episode featuring Charles \
            Murray, the mingling of scientific thinking with politics and \
            social activism, cancel culture, environmental and genetic \
            contributions to individual and group differences, intellectual \
            honesty, and other topics. If the Making Sense podcast logo in \
            your player is BLACK, you can SUBSCRIBE to gain access to all \
            full-length episodes at samharris.org/subscribe.
            """
        )
        XCTAssertEqual(episode.durationMS, 2923102)
        XCTAssertFalse(episode.isExplicit)
        XCTAssertEqual(
            episode.href,
            URL(string: "https://api.spotify.com/v1/episodes/3OEdPEYB69pfXoBrhvQYeC")!
        )
        XCTAssertEqual(episode.id, "3OEdPEYB69pfXoBrhvQYeC")
        XCTAssert(episode.isExternallyHosted == false)
        XCTAssert(episode.isPlayable == true)
        XCTAssert(
            episode.languages?.contains("en") == true,
            String(describing: episode.languages)
        )
        XCTAssertEqual(episode.name, "#212 — A Conversation with Kathryn Paige Harden")
        XCTAssertEqual(episode.type, .episode)
        XCTAssertEqual(episode.uri, "spotify:episode:3OEdPEYB69pfXoBrhvQYeC")
        
        if let externalURLs = episode.externalURLs {
            XCTAssertEqual(
                externalURLs["spotify"],
                URL(string: "https://open.spotify.com/episode/3OEdPEYB69pfXoBrhvQYeC")!,
                "\(externalURLs)"
            )
        }
        else {
            XCTFail("externalURLs should not be nil")
        }
        
        XCTAssertEqual(episode.releaseDate, "2020-07-29")
        XCTAssertEqual(episode.releaseDatePrecision, "day")

        XCTAssertImagesExist(episode.images, assertSizeNotNil: true)

        if Self.spotify.authorizationManager.isAuthorized(
            for: [.userReadPlaybackPosition]
        ) {
            XCTAssertNotNil(
                episode.resumePoint,
                "episode resume point was nil: " +
                "\(type(of: Self.spotify.authorizationManager))"
            )
        }
        
        // MARK: Check Show
        guard let show = episode.show else {
            XCTFail("full episode object should contain show")
            return
        }
        
        XCTAssertEqual(
            show.description,
            """
            Join neuroscientist, philosopher, and best-selling author Sam \
            Harris as he explores important and controversial questions about \
            the human mind, society, and current events.  Sam Harris is the \
            author of The End of Faith, Letter to a Christian Nation, The \
            Moral Landscape, Free Will, Lying, Waking Up, and Islam and the \
            Future of Tolerance (with Maajid Nawaz). The End of Faith won the \
            2005 PEN Award for Nonfiction. His writing has been published in \
            more than 20 languages. Mr. Harris and his work have been discussed \
            in The New York Times, Time, Scientific American, Nature, Newsweek, \
            Rolling Stone, and many other journals. His writing has appeared in \
            The New York Times, The Los Angeles Times, The Economist, Newsweek, \
            The Times (London), The Boston Globe, The Atlantic, The Annals of \
            Neurology, and elsewhere.  Mr. Harris received a degree in \
            philosophy from Stanford University and a Ph.D. in neuroscience \
            from UCLA.
            """
        )
        XCTAssertFalse(show.isExplicit)
        XCTAssertEqual(
            show.href,
            URL(string: "https://api.spotify.com/v1/shows/5rgumWEx4FsqIY8e1wJNAk")!
        )
        XCTAssertEqual(show.id, "5rgumWEx4FsqIY8e1wJNAk")
        XCTAssert(show.isExternallyHosted == false)
        XCTAssertEqual(show.mediaType, "audio")
        XCTAssertEqual(show.name, "Making Sense with Sam Harris")
        if let totalEpisodes = show.totalEpisodes {
            XCTAssert(totalEpisodes >= 226, "\(totalEpisodes)")
        }
        else {
            XCTFail("totalEpisodes should not be nil")
        }
        XCTAssertEqual(show.type, .show)
        XCTAssertEqual(show.uri, "spotify:show:5rgumWEx4FsqIY8e1wJNAk")
     
        guard let images = show.images else {
            XCTFail("images should not be nil")
            return
        }
        XCTAssertImagesExist(
            images, assertSizeNotNil: true
        )
        
    }
    
    func episode() {
        
        let expectation = XCTestExpectation(description: "testEpisode")
        
        Self.spotify.episode(URIs.Episodes.samHarris212, market: "US")
            .XCTAssertNoFailure()
            .receiveOnMain()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: receiveSamHarris212(_:)
            )
            .store(in: &Self.cancellables)
        
        self.wait(for: [expectation], timeout: 120)

    }
    
}

final class SpotifyAPIClientCredentialsFlowEpisodeTests:
    SpotifyAPIClientCredentialsFlowTests, SpotifyAPIEpisodeTests
{

    static let allTests = [
        ("testEpisode", testEpisode),
    ]
    
    func testEpisode() { episode() }

}

final class SpotifyAPIAuthorizationCodeFlowEpisodeTests:
    SpotifyAPIAuthorizationCodeFlowTests, SpotifyAPIEpisodeTests
{

    static let allTests = [
        ("testEpisode", testEpisode),
    ]
    
    func testEpisode() { episode() }
    
}

final class SpotifyAPIAuthorizationCodeFlowPKCEEpisodeTests:
    SpotifyAPIAuthorizationCodeFlowPKCETests, SpotifyAPIEpisodeTests
{

    static let allTests = [
        ("testEpisode", testEpisode),
    ]
    
    func testEpisode() { episode() }
    
    
}
