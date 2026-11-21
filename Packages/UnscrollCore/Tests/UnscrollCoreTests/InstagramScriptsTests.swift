import JavaScriptCore
import UnscrollCore
import XCTest

/// Lo script gira nel WKWebView; qui si prova la sua funzione di decisione con JavaScriptCore.
final class InstagramScriptsTests: XCTestCase {
    private func blocks(_ path: String, inDialog: Bool = false, inVideoSnapScroller: Bool = false) -> Bool {
        let ctx = JSContext()!
        ctx.evaluateScript(InstagramScripts.reelLock)
        XCTAssertNil(ctx.exception, "lo script non deve dare errori fuori dal browser")
        return ctx.evaluateScript("unscrollBlocksSwipe('\(path)', \(inDialog), \(inVideoSnapScroller))").toBool()
    }

    func testSwipeIsBlockedInReelViewer() {
        XCTAssertTrue(blocks("/reels/ABC123/"))
        XCTAssertTrue(blocks("/reel/ABC123/"))
    }

    func testCommentsSheetStillScrolls() {
        XCTAssertFalse(blocks("/reels/ABC123/", inDialog: true))
    }

    // Visto sul telefono il 2026-11-21: un reel aperto da una chat resta su /direct/t/<id>/ e si
    // scorre in un riquadro con scroll-snap verticale che contiene i video.
    func testReelOverlayInChatIsBlocked() {
        XCTAssertTrue(blocks("/direct/t/18094969202076824/", inVideoSnapScroller: true))
        XCTAssertFalse(blocks("/direct/t/18094969202076824/", inDialog: true, inVideoSnapScroller: true))
    }

    func testOtherPagesScrollNormally() {
        XCTAssertFalse(blocks("/"))
        XCTAssertFalse(blocks("/reels/"))
        XCTAssertFalse(blocks("/direct/inbox/"))
        XCTAssertFalse(blocks("/__whoismars__/"))
        XCTAssertFalse(blocks("/p/XYZ/"))
    }
}
