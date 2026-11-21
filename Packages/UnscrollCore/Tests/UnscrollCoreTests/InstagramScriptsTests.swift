import JavaScriptCore
import UnscrollCore
import XCTest

/// Lo script gira nel WKWebView; qui si prova la sua funzione di decisione con JavaScriptCore.
final class InstagramScriptsTests: XCTestCase {
    private func blocks(_ path: String, inDialog: Bool = false) -> Bool {
        let ctx = JSContext()!
        ctx.evaluateScript(InstagramScripts.reelLock)
        XCTAssertNil(ctx.exception, "lo script non deve dare errori fuori dal browser")
        return ctx.evaluateScript("unscrollBlocksSwipe('\(path)', \(inDialog))").toBool()
    }

    func testSwipeIsBlockedInReelViewer() {
        XCTAssertTrue(blocks("/reels/ABC123/"))
        XCTAssertTrue(blocks("/reel/ABC123/"))
    }

    func testCommentsSheetStillScrolls() {
        XCTAssertFalse(blocks("/reels/ABC123/", inDialog: true))
    }

    func testOtherPagesScrollNormally() {
        XCTAssertFalse(blocks("/"))
        XCTAssertFalse(blocks("/reels/"))
        XCTAssertFalse(blocks("/direct/inbox/"))
        XCTAssertFalse(blocks("/__whoismars__/"))
        XCTAssertFalse(blocks("/p/XYZ/"))
    }
}
