import XCTest
@testable import UnscrollCore

final class InstagramRulesTests: XCTestCase {
    private func redirect(_ s: String) -> String? {
        InstagramRules.redirect(for: URL(string: s)!)?.absoluteString
    }

    func testReelsFeedGoesToInbox() {
        XCTAssertEqual(redirect("https://www.instagram.com/reels/"), InstagramRules.inbox.absoluteString)
        XCTAssertEqual(redirect("https://www.instagram.com/reels"), InstagramRules.inbox.absoluteString)
    }

    // Instagram riscrive /reel/<id>/ in /reels/<id>/: il reel singolo deve restare permesso.
    func testSingleReelViewerIsAllowed() {
        XCTAssertNil(redirect("https://www.instagram.com/reels/DgAZav0jF60/"))
        XCTAssertNil(redirect("https://instagram.com/reels/C1abc/?igsh=x"))
    }

    // Passare da un reel a un altro nel visualizzatore è lo scorrimento infinito da bloccare.
    func testReelSwipeIsDetected() {
        let a = URL(string: "https://www.instagram.com/reels/AAA/")!
        let b = URL(string: "https://www.instagram.com/reels/BBB/")!
        XCTAssertTrue(InstagramRules.isReelSwipe(from: a, to: b))
        XCTAssertFalse(InstagramRules.isReelSwipe(from: a, to: a))
        XCTAssertFalse(InstagramRules.isReelSwipe(from: URL(string: "https://www.instagram.com/reel/AAA/")!, to: a))
        XCTAssertFalse(InstagramRules.isReelSwipe(from: URL(string: "https://www.instagram.com/direct/t/1/")!, to: b))
        XCTAssertFalse(InstagramRules.isReelSwipe(from: nil, to: b))
    }

    func testExploreGridGoesToSearch() {
        XCTAssertEqual(redirect("https://www.instagram.com/explore/"), InstagramRules.search.absoluteString)
        XCTAssertEqual(redirect("https://www.instagram.com/explore"), InstagramRules.search.absoluteString)
        XCTAssertEqual(redirect("https://www.instagram.com/explore/tags/cats/"), InstagramRules.search.absoluteString)
    }

    func testSearchIsAllowed() {
        XCTAssertNil(redirect("https://www.instagram.com/explore/search/"))
        XCTAssertNil(redirect("https://www.instagram.com/explore/search/?q=x"))
    }

    func testContentFriendsSendIsAllowed() {
        XCTAssertNil(redirect("https://www.instagram.com/reel/C1abc/"))
        XCTAssertNil(redirect("https://www.instagram.com/p/C1abc/"))
        XCTAssertNil(redirect("https://www.instagram.com/direct/inbox/"))
        XCTAssertNil(redirect("https://www.instagram.com/someuser/"))
    }

    func testHomeGoesToFollowingFeed() {
        let following = InstagramRules.followingFeed.absoluteString
        XCTAssertEqual(redirect("https://www.instagram.com/"), following)
        XCTAssertEqual(redirect("https://www.instagram.com"), following)
        XCTAssertEqual(redirect("https://www.instagram.com/?variant=home"), following)
    }

    func testFollowingAndFavoritesFeedsAreAllowed() {
        XCTAssertNil(redirect("https://www.instagram.com/?variant=following"))
        XCTAssertNil(redirect("https://www.instagram.com/?variant=favorites"))
    }

    func testOtherHostsAreUntouched() {
        XCTAssertNil(redirect("https://www.facebook.com/reels/"))
        XCTAssertNil(redirect("https://scontent.cdninstagram.com/explore/x.jpg"))
        XCTAssertNil(redirect("https://notinstagram.com/reels/"))
    }
}

final class InstagramRulesInvariantTests: XCTestCase {
    // Un target che a sua volta reindirizza creerebbe un ciclo infinito di caricamenti.
    func testRedirectTargetsAreAllowed() {
        XCTAssertNil(InstagramRules.redirect(for: InstagramRules.inbox))
        XCTAssertNil(InstagramRules.redirect(for: InstagramRules.search))
        XCTAssertNil(InstagramRules.redirect(for: InstagramRules.followingFeed))
    }
}

final class InstagramProfileTests: XCTestCase {
    func testProfileURLFromTypedUsername() {
        XCTAssertEqual(InstagramRules.profileURL(username: " @__whoismars__ ")?.absoluteString,
                       "https://www.instagram.com/__whoismars__/")
        XCTAssertEqual(InstagramRules.profileURL(username: "a.b/../x?y")?.absoluteString,
                       "https://www.instagram.com/a.b..xy/")
    }

    func testEmptyUsernameGivesNoURL() {
        XCTAssertNil(InstagramRules.profileURL(username: ""))
        XCTAssertNil(InstagramRules.profileURL(username: " @/ "))
    }
}
