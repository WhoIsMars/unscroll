import XCTest
@testable import UnscrollCore

final class InstagramRulesTests: XCTestCase {
    private func redirect(_ s: String) -> String? {
        InstagramRules.redirect(for: URL(string: s)!)?.absoluteString
    }

    func testReelsFeedGoesToInbox() {
        XCTAssertEqual(redirect("https://www.instagram.com/reels/"), InstagramRules.inbox.absoluteString)
        XCTAssertEqual(redirect("https://www.instagram.com/reels"), InstagramRules.inbox.absoluteString)
        XCTAssertEqual(redirect("https://instagram.com/reels/C1abc/?igsh=x"), InstagramRules.inbox.absoluteString)
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

    func testFeedHomeGoesToInbox() {
        XCTAssertEqual(redirect("https://www.instagram.com/"), InstagramRules.inbox.absoluteString)
        XCTAssertEqual(redirect("https://www.instagram.com"), InstagramRules.inbox.absoluteString)
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
    }
}
