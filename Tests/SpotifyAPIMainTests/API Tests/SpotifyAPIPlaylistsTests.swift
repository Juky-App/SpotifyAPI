import Foundation
import XCTest
#if canImport(Combine)
import Combine
#else
import OpenCombine
import OpenCombineDispatch
import OpenCombineFoundation
#endif

@testable import SpotifyWebAPI
import SpotifyAPITestUtilities
import SpotifyExampleContent

protocol SpotifyAPIPlaylistsTests: SpotifyAPITests { }

extension SpotifyAPIPlaylistsTests {

    func getCrumbPlaylist() {

        let expectation = XCTestExpectation(
            description: "getCrumbPlaylist"
        )

        let trackNames = [
            "Part III", "Plants", "Locket", "Nina", "Jinx",
            "M.R.", "And It Never Ends", "Thirty-Nine", "Cracking",
            "Recently Played", "Vinta", "Faces", "Ghostride",
            "Bones", "Fall Down"
        ]

        Self.spotify.playlist(URIs.Playlists.crumb)
            .XCTAssertNoFailure()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { playlist in
                    encodeDecode(playlist, areEqual: ==)
                    if let owner = playlist.owner {
                        assertUserIsPeter(owner)
                    }
                    else {
                        XCTFail("playlist owner should not be nil")
                    }

                    XCTAssertEqual(playlist.name, "Crumb")
                    XCTAssertEqual(playlist.uri, "spotify:playlist:33yLOStnp2emkEA76ew1Dz")
                    XCTAssertEqual(playlist.id, "33yLOStnp2emkEA76ew1Dz")
                    guard playlist.items.items.count >= 15 else {
                        XCTFail("Crumb playlist should have at least 15 tracks")
                        return
                    }
                    let tracks = playlist.items.items.map(\.item)
                    for (i, track) in tracks.enumerated() {
                        guard trackNames.count > i else {
                            return
                        }
                        guard case .track(let track) = track else {
                            XCTFail("playlist should only contain tracks")
                            continue
                        }
                        print(i)
                        XCTAssertEqual(track.name, trackNames[i])
                    }

                }
            )
            .store(in: &Self.cancellables)

        self.wait(for: [expectation], timeout: 60)
    }

    func getCrumbPlaylistTracks() {

        let expectation = XCTestExpectation(
            description: "getCrumPlaylistTracks"
        )

        let trackNames = [
            "Nina", "Jinx", "M.R.", "And It Never Ends", "Thirty-Nine",
            "Cracking", "Recently Played", "Vinta", "Faces", "Ghostride"
        ]

        Self.spotify.authorizationManager.setExpirationDate(to: Date())

        let authorizationManagerDidChangeExpectation = XCTestExpectation(
            description: "authorizationManagerDidChange"
        )
        let internalQueue = DispatchQueue(label: "internal")

        var didChangeCount = 0
        var cancellables: Set<AnyCancellable> = []
        Self.spotify.authorizationManagerDidChange
            .receive(on: internalQueue)
            .sink(receiveValue: {
                didChangeCount += 1
                internalQueue.asyncAfter(deadline: .now() + 2) {
                    authorizationManagerDidChangeExpectation.fulfill()
                }
            })
            .store(in: &cancellables)

        Self.spotify.playlistTracks(
            URIs.Playlists.crumb,
            limit: 10,
            offset: 3,
            market: "US"
        )
        .XCTAssertNoFailure()
        .sink(
            receiveCompletion: { _ in expectation.fulfill() },
            receiveValue: { playlistTracks in
                encodeDecode(playlistTracks, areEqual: ==)
                let tracks = playlistTracks.items.map(\.item)
                XCTAssertEqual(playlistTracks.items.count, 10)
                if playlistTracks.items.count < 10 { return }

                for (i, track) in tracks.enumerated() {
                    guard let track = track else {
                        XCTFail("track should not be nil")
                        continue
                    }
                    XCTAssertEqual(track.name, trackNames[i])
                    XCTAssertEqual(track.artists?.first?.name, "Crumb")
                    XCTAssertEqual(
                        track.artists?.first?.uri,
                        "spotify:artist:4kSGbjWGxTchKpIxXPJv0B"
                    )
                    XCTAssertEqual(
                        track.artists?.first?.id,
                        "4kSGbjWGxTchKpIxXPJv0B"
                    )

                }

            }
        )
        .store(in: &Self.cancellables)

        self.wait(
            for: [
                expectation,
                authorizationManagerDidChangeExpectation
            ],
            timeout: 60
        )
        internalQueue.sync {
            XCTAssertEqual(
                didChangeCount, 1,
                "authorizationManagerDidChange should emit exactly once"
            )
        }

    }

    func filteredPlaylist() {

        func reveivePlaylist(_ playlist: FilteredPlaylist) {
            encodeDecode(playlist, areEqual: ==)
            XCTAssertEqual(playlist.name, "Mac DeMarco")
            XCTAssertEqual(playlist.uri, "spotify:playlist:6oyVZ3dZZVCkXJm451Hj5v")
            XCTAssertEqual(playlist.ownerDisplayName, "petervschorn")
            let artists = playlist.tracks.flatMap(\.artists)
            for artist in artists {
                XCTAssertEqual(artist.name, "Mac DeMarco")
                XCTAssertEqual(artist.type, .artist)
                XCTAssertEqual(artist.uri, "spotify:artist:3Sz7ZnJQBIHsXLUSo0OQtM")
            }
        }

        let filters = FilteredPlaylist.filters

        let expectationTrack = XCTestExpectation(
            description: "testFilteredPlaylist [.track]"
        )

        Self.spotify.filteredPlaylist(
            URIs.Playlists.macDeMarco,
            filters: filters,
            additionalTypes: [.track]
        )
        .XCTAssertNoFailure()
        .decodeSpotifyObject(FilteredPlaylist.self)
        .XCTAssertNoFailure()
        .sink(
            receiveCompletion: { _ in expectationTrack.fulfill() },
            receiveValue: reveivePlaylist(_:)
        )
        .store(in: &Self.cancellables)

        let expectationEmpty = XCTestExpectation(
            description: "testFilteredPlaylist []"
        )

        Self.spotify.filteredPlaylist(
            URIs.Playlists.macDeMarco,
            filters: filters,
            additionalTypes: []
        )
        .XCTAssertNoFailure()
        .decodeSpotifyObject(FilteredPlaylist.self)
        .XCTAssertNoFailure()
        .sink(
            receiveCompletion: { _ in expectationEmpty.fulfill() },
            receiveValue: reveivePlaylist(_:)
        )
        .store(in: &Self.cancellables)

        self.wait(for: [expectationTrack, expectationEmpty], timeout: 120)

    }

    func filteredPlaylistItems() {

        func receivePlaylistItems(_ playlistItems: FilteredPlaylistItems) {
            encodeDecode(playlistItems, areEqual: ==)
            for item in playlistItems.items {
                XCTAssertFalse(item.name.isEmpty)
                guard let artist = item.artists.first else {
                    XCTFail("no artists found for \(item.name)")
                    continue
                }
                XCTAssertEqual(artist.name, "Men I Trust")
                XCTAssertEqual(artist.type, .artist)
                XCTAssertEqual(artist.uri, "spotify:artist:3zmfs9cQwzJl575W1ZYXeT")
            }
        }

        let filters = FilteredPlaylistItems.filters

        let expectationEmpty = XCTestExpectation(
            description: "testFilteredPlaylistItems []"
        )

        Self.spotify.filteredPlaylistItems(
            URIs.Playlists.menITrust,
            filters: filters,
            additionalTypes: []
        )
        .XCTAssertNoFailure()
        .decodeSpotifyObject(FilteredPlaylistItems.self)
        .XCTAssertNoFailure()
        .sink(
            receiveCompletion: { _ in expectationEmpty.fulfill() },
            receiveValue: receivePlaylistItems(_:)
        )
        .store(in: &Self.cancellables)

        let expectationTrack = XCTestExpectation(
            description: "testFilteredPlaylistItems [.track]"
        )

        Self.spotify.filteredPlaylistItems(
            URIs.Playlists.menITrust,
            filters: filters,
            additionalTypes: [.track]
        )
        .XCTAssertNoFailure()
        .decodeSpotifyObject(FilteredPlaylistItems.self)
        .XCTAssertNoFailure()
        .sink(
            receiveCompletion: { _ in expectationTrack.fulfill() },
            receiveValue: receivePlaylistItems(_:)
        )
        .store(in: &Self.cancellables)

        self.wait(for: [expectationEmpty, expectationTrack], timeout: 120)

    }

    func playlistWithEpisodesAndLocalTracks() {

        func receivePlaylistItems(
            _ playlistItems: PlaylistItems,
            onlyTracks: Bool
        ) {
            internalQueue.sync {
                receivePlaylistItemsCallCount += 1
            }
            for user in playlistItems.items.map(\.addedBy) {
                guard let user = user else {
                    XCTFail("addedBy should not be nil")
                    continue
                }
                assertUserIsPeter(user)
            }

            let items = playlistItems.items.map(\.item)

            if !onlyTracks {
                encodeDecode(items)
            }

            guard items.count >= 7 else {
                XCTFail("test playlist should contain at least 7 items")
                return
            }

            if case .track(let partIII) = items[0] {
                encodeDecode(partIII)
                XCTAssertFalse(partIII.isLocal)
                XCTAssertEqual(partIII.name, "Part III")
                XCTAssertEqual(partIII.uri, "spotify:track:49ztutPq82dK8AYDO2OkN7")
                XCTAssertEqual(partIII.id, "49ztutPq82dK8AYDO2OkN7")
                XCTAssertEqual(partIII.artists?.first?.name, "Crumb")
                XCTAssertEqual(
                    partIII.artists?.first?.uri,
                    "spotify:artist:4kSGbjWGxTchKpIxXPJv0B"
                )

                XCTAssertEqual(partIII.album?.name, "Jinx")
                XCTAssertEqual(partIII.album?.uri, "spotify:album:3vukTUpiENDHDoYTVrwqtz")
                XCTAssertEqual(partIII.album?.releaseDate, "2019-06-14")
                XCTAssertEqual(partIII.album?.releaseDatePrecision, "day")

            }
            else {
                XCTFail("should be track: \(items[0]?.name ?? "nil")")
            }

            if case .track(let whenIGetHome) = items[1] {
                encodeDecode(whenIGetHome)
                XCTAssertFalse(whenIGetHome.isLocal)
                XCTAssertEqual(whenIGetHome.name, "When I Get Home")
                XCTAssertEqual(whenIGetHome.uri, "spotify:track:2rY4NvZAyYJi8Gvcp0pSI6")
                XCTAssertEqual(whenIGetHome.id, "2rY4NvZAyYJi8Gvcp0pSI6")
                XCTAssertEqual(whenIGetHome.artists?.first?.name, "Post Animal")
                XCTAssertEqual(
                    whenIGetHome.artists?.first?.uri,
                    "spotify:artist:4iaDWP59Z3e62DW7YWDbIE"
                )
                XCTAssertEqual(whenIGetHome.album?.name, "The Garden Series")
                XCTAssertEqual(
                    whenIGetHome.album?.uri,
                    "spotify:album:5p3dhXhw62KlVkf0oPfq1G"
                )
                XCTAssertEqual(whenIGetHome.album?.releaseDate, "2016-07-22")
                XCTAssertEqual(whenIGetHome.album?.releaseDatePrecision, "day")
            }
            else {
                XCTFail("should be track: \(items[1]?.name ?? "nil")")
            }

            if let item = items[2] {
                if onlyTracks {
                    if case .track(let newReligion) = item {
                        XCTAssertEqual(newReligion.name, "#217 — The New Religion of Anti-Racism")
                        XCTAssertEqual(newReligion.uri, "spotify:episode:7nsYz7tSJryO5vVYtkKiot")
                        XCTAssertEqual(newReligion.id, "7nsYz7tSJryO5vVYtkKiot")
                    }
                    else {
                        XCTFail("should be track: \(String(describing: item.name))")
                    }
                }
                else {
                    if case .episode(let newReligion) = item {
                        encodeDecode(newReligion)
                        XCTAssertEqual(newReligion.name, "#217 — The New Religion of Anti-Racism")
                        XCTAssertEqual(newReligion.uri, "spotify:episode:7nsYz7tSJryO5vVYtkKiot")
                        XCTAssertEqual(newReligion.id, "7nsYz7tSJryO5vVYtkKiot")

                        if let show = newReligion.show {
                            XCTAssertEqual(show.name, "Making Sense with Sam Harris")
                            XCTAssertEqual(show.id, "5rgumWEx4FsqIY8e1wJNAk")
                            XCTAssertEqual(show.uri, "spotify:show:5rgumWEx4FsqIY8e1wJNAk")
                            XCTAssertEqual(show.type, .show)
                            XCTAssertEqual(
                                show.href,
                                URL(string: "https://api.spotify.com/v1/shows/5rgumWEx4FsqIY8e1wJNAk")!
                            )
                        }
                        else {
                            XCTFail("episode should contain show")
                        }
                    }
                    else {
                        XCTFail("should be episode: \(String(describing: item.name))")
                    }
                }

            }
            else {
                print("third item should not be nil")
                XCTFail("third item should not be nil")
            }


            if case .track(let bensound) = items[3] {
                encodeDecode(bensound)
                XCTAssertEqual(bensound.name, "bensound-anewbeginning")
                XCTAssertTrue(bensound.isLocal)
                XCTAssertEqual(bensound.durationMS, 154000)
            }
            else {
                XCTFail("should be track: \(items[3]?.name ?? "nil")")
            }

            if case .track(let echoes) = items[4] {
                encodeDecode(echoes)
                XCTAssertEqual(echoes.name, "Echoes - Acoustic Version")
                XCTAssertTrue(echoes.isLocal)
                XCTAssertEqual(echoes.durationMS, 348000)
            }
            else {
                XCTFail("should be track: \(items[4]?.name ?? "nil")")
            }

            if case .track(let oceanBloom) = items[5] {
                encodeDecode(oceanBloom)
                XCTAssertEqual(
                    oceanBloom.name,
                    "Hans Zimmer & Radiohead - Ocean Bloom (full song HQ)"
                )
                XCTAssertTrue(oceanBloom.isLocal)
                XCTAssertEqual(oceanBloom.durationMS, 315000)
            }
            else {
                XCTFail("should be track: \(items[5]?.name ?? "nil")")
            }

            if case .track(let killshot) = items[6] {
                encodeDecode(killshot)
                XCTAssertEqual(killshot.name, "Killshot")
                XCTAssertTrue(killshot.isLocal)
                XCTAssertEqual(killshot.durationMS, 253000)
                if let artist = killshot.artists?.first {
                    XCTAssertEqual(artist.name, "Eminem")
                    XCTAssertEqual(artist.type, .artist)
                }
                else {
                    XCTFail("should have found artist 'Eminiem'")
                }
            }
            else {
                XCTFail("should be track: \(items[6]?.name ?? "nil")")
            }


        }

        let decodeLogLevel = spotifyDecodeLogger.logLevel
        spotifyDecodeLogger.logLevel = .trace

        let internalQueue = DispatchQueue(
            label: "testPlaylistWithEpisodesAndLocalTracks internal"
        )

        var receivePlaylistItemsCallCount = 0

        let playlistExpectation = XCTestExpectation(
            description: "testPlaylistWithEpisodesAndLocalTracks: playlist"
        )

        Self.spotify.playlist(URIs.Playlists.test, market: "us")
            .XCTAssertNoFailure()
            .sink(
                receiveCompletion: { _ in playlistExpectation.fulfill() },
                receiveValue: { playlist in
                    receivePlaylistItems(playlist.items, onlyTracks: false)
                }
            )
            .store(in: &Self.cancellables)

        let playlistItemsExpectation = XCTestExpectation(
            description: "testPlaylistWithEpisodesAndLocalTracks: playlistItems"
        )

        Self.spotify.playlistItems(URIs.Playlists.test, market: "us")
            .XCTAssertNoFailure()
            .sink(
                receiveCompletion: { _ in playlistItemsExpectation.fulfill() },
                receiveValue: { playlistItems in
                    receivePlaylistItems(playlistItems, onlyTracks: false)
                }
            )
            .store(in: &Self.cancellables)

        let playlistTracksExpectation = XCTestExpectation(
            description: "testPlaylistWithEpisodesAndLocalTracks: playlistTracks"
        )

        Self.spotify.playlistTracks(URIs.Playlists.test, market: "us")
            .XCTAssertNoFailure()
            .sink(
                receiveCompletion: { _ in playlistTracksExpectation.fulfill() },
                receiveValue: { playlistTracks in
                    let items = playlistTracks.items.map { container in
                        PlaylistItemContainer(
                            addedAt: container.addedAt,
                            addedBy: container.addedBy,
                            isLocal: container.isLocal,
                            item: container.item.map { PlaylistItem.track($0) }
                        )
                    }
                    let playlistItems = PagingObject(
                        href: playlistTracks.href,
                        items: items,
                        limit: playlistTracks.limit,
                        offset: playlistTracks.offset,
                        total: playlistTracks.total
                    )
                    receivePlaylistItems(playlistItems, onlyTracks: true)
                }
            )
            .store(in: &Self.cancellables)


        self.wait(
            for: [
                playlistExpectation,
                playlistItemsExpectation,
                playlistTracksExpectation
            ],
            timeout: 120
        )
        spotifyDecodeLogger.logLevel = decodeLogLevel
        XCTAssertEqual(receivePlaylistItemsCallCount, 3)

    }

}

extension SpotifyAPIPlaylistsTests where
    AuthorizationManager: _InternalSpotifyScopeAuthorizationManager
{

    func createPlaylistAndAddTracksThenUnfollowIt() {

        let dateString = Date().description(with: .current)
        let itemsToAddToPlaylist = URIs.Tracks.array(
            .jinx, .fearless, .illWind, .nuclearFusion, .theBay
        ) + URIs.Episodes.array(
            .samHarris213, .samHarris214, .samHarris212
        )

        let details = PlaylistDetails(
            name: "createPlaylistAddTracks",
            isPublic: false,
            isCollaborative: false,
            description: dateString
        )
        encodeDecode(details, areEqual: ==)

        let expectation = XCTestExpectation(
            description: "createPlaylistAndAddTracks"
        )

        var createdPlaylistURI = ""

        // get the uri of the current user
        let publisher: AnyPublisher<Playlist<PlaylistItems>, Error> =
            Self.spotify.currentUserProfile()
            .XCTAssertNoFailure()
            .flatMap { user -> AnyPublisher<Playlist<PlaylistItems>, Error> in
                // create a playlist for them
                encodeDecode(user, areEqual: ==)
                return Self.spotify.createPlaylist(for: user.uri, details)
            }
            .XCTAssertNoFailure()
            .flatMap { playlist -> AnyPublisher<String, Error> in

                encodeDecode(playlist, areEqual: ==)
                XCTAssertEqual(playlist.name, "createPlaylistAddTracks")
                XCTAssertEqual(playlist.description, dateString)
                XCTAssertEqual(playlist.isPublic, false)
                XCTAssertFalse(playlist.isCollaborative)
                XCTAssertEqual(playlist.items.items.count, 0)

                createdPlaylistURI = playlist.uri
                XCTAssert(createdPlaylistURI.count > 5)

                // add tracks and episodes to the playlist
                return Self.spotify.addToPlaylist(
                    playlist.uri, uris: itemsToAddToPlaylist
                )
            }
            .XCTAssertNoFailure()
            .flatMap { snapshotId -> AnyPublisher<Playlist<PlaylistItems>, Error> in
                XCTAssert(snapshotId.count > 5)
                // retrieve the playlist
                return Self.spotify.playlist(createdPlaylistURI)
            }
            .XCTAssertNoFailure()
            .eraseToAnyPublisher()

        self.wait(for: [expectation], timeout: 120)

    }

    func createPlaylistAddRemoveReorderItems() {

        let itemsToAddToPlaylist: [SpotifyURIConvertible] = [
            URIs.Tracks.anyColourYouLike,  // 0
            URIs.Tracks.because,           // 1 | rangeStart
            URIs.Tracks.blueBoy,           // 2 |
            URIs.Tracks.breathe,           // 3 | rangeLength = 3
            URIs.Episodes.seanCarroll111,  // 4
            URIs.Episodes.joeRogan1531,    // 5
            URIs.Episodes.samHarris212     // 6  insertBefore
        ]

        let urisDict = URIsDictWithInsertionIndex(
            uris: itemsToAddToPlaylist,
            position: 5
        )

        encodeDecode(urisDict, areEqual: ==)

        XCTAssertEqual(
            urisDict.uris.map(\.uri),
            itemsToAddToPlaylist.map(\.uri)
        )
        XCTAssertEqual(urisDict.position, 5)

        var reorderRequest1 = ReorderPlaylistItems(
            rangeStart: 1,
            rangeLength: 3,
            insertBefore: 6
        )

        /// The expected order of the items after sending `reorderRequest1`.
        let reordered1: [SpotifyURIConvertible] = [
            URIs.Tracks.anyColourYouLike,  //      0
                                           //---->
            URIs.Episodes.seanCarroll111,  //    | 1
            URIs.Episodes.joeRogan1531,    //    | 2
            URIs.Tracks.because,           //  <-| 3
            URIs.Tracks.blueBoy,           //  <-| 4
            URIs.Tracks.breathe,           //  <-| 5
            URIs.Episodes.samHarris212     //      6
        ]

        // will set URI
        var reorderRequest2 = ReorderPlaylistItems(
            rangeStart: 5,
            insertBefore: 2
        )

        let reordered2: [SpotifyURIConvertible] = [
            URIs.Tracks.anyColourYouLike,  // 0
            URIs.Episodes.seanCarroll111,  // 1
            URIs.Tracks.breathe,           // 2  —
            URIs.Episodes.joeRogan1531,    // 3  |
            URIs.Tracks.because,           // 4  |
            URIs.Tracks.blueBoy,           // 5  —
            URIs.Episodes.samHarris212     // 6
        ]

        let dateString = Date().description(with: .current)
        var createdPlaylistURI = ""

        let playlistDetails = PlaylistDetails(
            name: "createPlaylistAddRemoveReorderItems",
            isCollaborative: nil,
            description: dateString
        )

        encodeDecode(playlistDetails, areEqual: ==)

        let expectation = XCTestExpectation(
            description: "testCreatePlaylistAddRemoveReorderItems"
        )

        let publisher: AnyPublisher<String, Error> = Self.spotify
            .currentUserProfile()
            .XCTAssertNoFailure()
            .flatMap { user -> AnyPublisher<Playlist<PlaylistItems>, Error> in
                encodeDecode(user, areEqual: ==)
                // MARK: Create the playlist
                return Self.spotify.createPlaylist(
                    for: user.uri, playlistDetails
                )
            }
            .XCTAssertNoFailure()
            .flatMap { (playlist: Playlist<PlaylistItems>) -> AnyPublisher<String, Error> in

                encodeDecode(playlist, areEqual: ==)
                // MARK: Ensure it has the details we added
                XCTAssertEqual(playlist.name, "createPlaylistAddRemoveReorderItems")
                XCTAssertEqual(playlist.description, dateString)
                if let isPublic = playlist.isPublic {
                    XCTAssertTrue(isPublic)
                }
                else {
                    XCTFail("playlist.isPublic should not be nil")
                }
                XCTAssertFalse(playlist.isCollaborative)
                XCTAssertEqual(playlist.items.items.count, 0)

                createdPlaylistURI = playlist.uri
                XCTAssert(createdPlaylistURI.count > 5)

                // MARK: Add Tracks and episodes to the playlist
                return Self.spotify.addToPlaylist(
                    playlist.uri, uris: itemsToAddToPlaylist
                )

            }
            .XCTAssertNoFailure()
            .receiveOnMain(delay: 2)
            .eraseToAnyPublisher()

        let publisher2: AnyPublisher<PlaylistItems, Error> = publisher
            .flatMap { (snapshotId: String) -> AnyPublisher<PagingObject<Playlist<PlaylistItemsReference>>, Error> in
                // get all of the current user's playlists
                // MARK: Get all of the user's playlists
                Self.spotify.currentUserPlaylists()
            }
            .XCTAssertNoFailure()
            .extendPages(Self.spotify)
            .XCTAssertNoFailure()
            .collect()
            .flatMap { (playlistsArray: [PagingObject<Playlist<PlaylistItemsReference>>]) -> AnyPublisher<PlaylistItems, Error> in

                encodeDecode(playlistsArray, areEqual: ==)
                // MARK: Ensure the user is following the playlist we just created
                let playlists = playlistsArray.flatMap({ $0.items })
                let playlist = playlists.first(where: { playlist in
                    playlist.uri == createdPlaylistURI
                })
                XCTAssertNotNil(
                    playlist,
                    "should've found just-created playlist in currentUserPlaylists"
                )
                reorderRequest1.snapshotId = playlist?.snapshotId

                XCTAssert(createdPlaylistURI.count > 5)
                // MARK: Get all of the tracks and episodes in the playlist
                return Self.spotify.playlistItems(createdPlaylistURI)
            }
            .XCTAssertNoFailure()
            .eraseToAnyPublisher()

        // A single subscription stream takes too long to type-check.
        let publisher3: AnyPublisher<PlaylistItems, Error> = publisher2
            .flatMap { playlistItems -> AnyPublisher<String, Error> in

                encodeDecode(playlistItems, areEqual: ==)
                // assert that the playlist contains all of the items that
                // we just added, in the same order.
                // MARK: Ensure the playlist has the items we added
                XCTAssertEqual(
                    playlistItems.items.compactMap(\.item?.uri),
                    itemsToAddToPlaylist.map(\.uri)
                )

                // MARK: Reorder the items in the playlist 1
                return Self.spotify.reorderPlaylistItems(
                    createdPlaylistURI, body: reorderRequest1
                )
            }
            .XCTAssertNoFailure()
            .receiveOnMain(delay: 1)
            .flatMap { snapshotId -> AnyPublisher<Playlist<PlaylistItems>, Error> in
                // MARK: Get the items in the playlist again
                return Self.spotify.playlist(
                    createdPlaylistURI,
                    market: "US"
                )
            }
            .XCTAssertNoFailure()
            .flatMap { playlist -> AnyPublisher<String, Error> in

                encodeDecode(playlist, areEqual: ==)
                // MARK: Ensure the items in the playlist were reordered as requested 1
                XCTAssertEqual(
                    playlist.items.items.compactMap(\.item?.uri),
                    reordered1.map(\.uri)
                )
                // MARK: Reorder the items in the playlist 2 **WITH snapshot ID**
                reorderRequest2.snapshotId = playlist.snapshotId
                return Self.spotify.reorderPlaylistItems(
                    createdPlaylistURI, body: reorderRequest2
                )
            }
            .XCTAssertNoFailure()
            .receiveOnMain(delay: 1)
            .flatMap { snapshotId -> AnyPublisher<PlaylistItems, Error> in
                // MARK: Get the items in the playlist again
                return Self.spotify.playlistItems(createdPlaylistURI)
            }
            .XCTAssertNoFailure()
            .eraseToAnyPublisher()


        self.wait(for: [expectation], timeout: 300)

    }

    func playlistImage() {

        var cancellables: [AnyCancellable] = []

        var expectations: [XCTestExpectation] = []

        let playlists: [URIs.Playlists] = [
            .thisIsTheBeatles, .all, .bluesClassics
        ]
        for (i, playlist) in playlists.enumerated() {

            let playlistImageExpectation = XCTestExpectation(
                description: "testPlaylistImage \(i)"
            )
            expectations.append(playlistImageExpectation)

            Self.spotify.playlistImage(playlist)
                .receiveOnMain()
                .XCTAssertNoFailure()
                .sink(
                    receiveCompletion: { _ in
                        playlistImageExpectation.fulfill()
                    },
                    receiveValue: { images in
                        XCTAssertImagesExist(images, assertSizeNotNil: false)
                    }
                )
                .store(in: &cancellables)

        }

        self.wait(for: expectations, timeout: 240)
    }

}

// MARK: Authorization and setup methods

extension SpotifyAPIPlaylistsTests where
    AuthorizationManager: _InternalSpotifyScopeAuthorizationManager
{

    /// Only authorize for the playlist scopes. The super implementation
    /// authorizes for all scopes.
    static func _setupAuthorization() {

        Self.spotify.authorizationManager.deauthorize()
        XCTAssertEqual(
            Self.spotify.authorizationManager.scopes , []
        )
        XCTAssertFalse(
            Self.spotify.authorizationManager.isAuthorized(for: [])
        )
        let randomScope = Scope.allCases.randomElement()!
        XCTAssertFalse(
            Self.spotify.authorizationManager.isAuthorized(
                for: [randomScope]
            ),
            "should not be authorized for \(randomScope.rawValue): " +
            "\(Self.spotify.authorizationManager)"
        )
        Self.spotify.authorizationManager.authorizeAndWaitForTokens(
            scopes: Scope.playlistScopes, showDialog: false
        )

    }

    func _setup() {
        // XCTAssertEqual(
        //     Self.spotify.authorizationManager.scopes,
        //     Scope.playlistScopes,
        //     "authorization manager should only have playlist scopes: " +
        //     "\(Self.spotify.authorizationManager)"
        // )
        // XCTAssertTrue(
        //     Self.spotify.authorizationManager.isAuthorized(
        //         for: Scope.playlistScopes
        //     ),
        //     "should only be authorized for playlist scopes: " +
        //     "\(Self.spotify.authorizationManager)"
        // )
        // // the scopes that we shouldn't be authorized for
        // let otherScopes = Scope.allCases.subtracting(Scope.playlistScopes)
        // XCTAssertFalse(
        //     Self.spotify.authorizationManager.isAuthorized(
        //         for: otherScopes
        //     ),
        //     "authorization manager should only be authorized for playlist scopes, " +
        //     "not \(otherScopes.map(\.rawValue)): \(Self.spotify.authorizationManager)"
        // )
    }

}

final class SpotifyAPIClientCredentialsFlowPlaylistsTests:
    SpotifyAPIClientCredentialsFlowTests, SpotifyAPIPlaylistsTests
{

    static let allTests = [
        ("testGetCrumbPlaylist", testGetCrumbPlaylist),
        ("testGetCrumPlaylistTracks", testGetCrumbPlaylistTracks),
        ("testFilteredPlaylist", testFilteredPlaylist),
        ("testFilteredPlaylistItems", testFilteredPlaylistItems),
        (
            "testPlaylistWithEpisodesAndLocalTracks",
            testPlaylistWithEpisodesAndLocalTracks
        )
    ]

    func testGetCrumbPlaylist() { getCrumbPlaylist() }
    func testGetCrumbPlaylistTracks() { getCrumbPlaylistTracks() }
    func testFilteredPlaylist() { filteredPlaylist() }
    func testFilteredPlaylistItems() { filteredPlaylistItems() }

    func testPlaylistWithEpisodesAndLocalTracks() {
        playlistWithEpisodesAndLocalTracks()
    }

}

final class SpotifyAPIAuthorizationCodeFlowPlaylistsTests:
    SpotifyAPIAuthorizationCodeFlowTests, SpotifyAPIPlaylistsTests
{

    static let allTests = [
        ("testGetCrumbPlaylist", testGetCrumbPlaylist),
        ("testGetCrumPlaylistTracks", testGetCrumbPlaylistTracks),
        ("testFilteredPlaylist", testFilteredPlaylist),
        ("testFilteredPlaylistItems", testFilteredPlaylistItems),
        (
            "testPlaylistWithEpisodesAndLocalTracks",
            testPlaylistWithEpisodesAndLocalTracks
        ),
        (
            "testCreatePlaylistAndAddTracksThenUnfollowIt",
            testCreatePlaylistAndAddTracksThenUnfollowIt
        ),
        (
            "testCreatePlaylistAddRemoveReorderItems",
            testCreatePlaylistAddRemoveReorderItems
        ),
        ("testPlaylistImage", testPlaylistImage),
    ]

    /// Only authorize for the playlist scopes. The super implementation
    /// authorizes for all scopes.
    override class func setupAuthorization(
        scopes: Set<Scope> = Scope.allCases,
        showDialog: Bool = true
    ) {
        Self._setupAuthorization()
    }

    override func setUp() {
        self._setup()
    }

    func testGetCrumbPlaylist() { getCrumbPlaylist() }
    func testGetCrumbPlaylistTracks() { getCrumbPlaylistTracks() }
    func testFilteredPlaylist() { filteredPlaylist() }
    func testFilteredPlaylistItems() { filteredPlaylistItems() }
    func testPlaylistWithEpisodesAndLocalTracks() {
        playlistWithEpisodesAndLocalTracks()
    }

    func testCreatePlaylistAndAddTracksThenUnfollowIt() {
        createPlaylistAndAddTracksThenUnfollowIt()
    }
    func testCreatePlaylistAddRemoveReorderItems() {
        createPlaylistAddRemoveReorderItems()
    }
    func testPlaylistImage() { playlistImage() }

}

final class SpotifyAPIAuthorizationCodeFlowPKCEPlaylistsTests:
    SpotifyAPIAuthorizationCodeFlowPKCETests, SpotifyAPIPlaylistsTests
{

    static let allTests = [
        ("testGetCrumbPlaylist", testGetCrumbPlaylist),
        ("testGetCrumPlaylistTracks", testGetCrumbPlaylistTracks),
        ("testFilteredPlaylist", testFilteredPlaylist),
        ("testFilteredPlaylistItems", testFilteredPlaylistItems),
        (
            "testPlaylistWithEpisodesAndLocalTracks",
            testPlaylistWithEpisodesAndLocalTracks
        ),
        (
            "testCreatePlaylistAndAddTracksThenUnfollowIt",
            testCreatePlaylistAndAddTracksThenUnfollowIt
        ),
        (
            "testCreatePlaylistAddRemoveReorderItems",
            testCreatePlaylistAddRemoveReorderItems
        ),
        ("testPlaylistImage", testPlaylistImage),
    ]

    /// Only authorize for the playlist scopes. The super implementation
    /// authorizes for all scopes.
    override class func setupAuthorization(
        scopes: Set<Scope> = Scope.allCases
    ) {
        Self._setupAuthorization()
    }

    override func setUp() {
        self._setup()
    }

    func testGetCrumbPlaylist() { getCrumbPlaylist() }
    func testGetCrumbPlaylistTracks() { getCrumbPlaylistTracks() }
    func testFilteredPlaylist() { filteredPlaylist() }
    func testFilteredPlaylistItems() { filteredPlaylistItems() }
    func testPlaylistWithEpisodesAndLocalTracks() {
        playlistWithEpisodesAndLocalTracks()
    }

    func testCreatePlaylistAndAddTracksThenUnfollowIt() {
        createPlaylistAndAddTracksThenUnfollowIt()
    }
    func testCreatePlaylistAddRemoveReorderItems() {
        createPlaylistAddRemoveReorderItems()
    }
    func testPlaylistImage() { playlistImage() }

}
