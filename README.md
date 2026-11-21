# unscroll

Open source iOS app to use Instagram without the endless scroll. No subscription, no
server: the app shows Instagram's own mobile website and hides what keeps you scrolling.

Not affiliated with Instagram or Meta.

## What it does

| Kept | Removed or limited |
|---|---|
| Direct messages | Reels tab and the swipe from one reel to the next |
| Search, profiles, your own profile and story | Explore grid |
| Feed of accounts you follow only | "For you" feed |
| Posts, reels and stories friends send you | Instagram's bottom bar and "open the app" prompts |
| Posting | Feed: 15 minutes a day, with a 10 second pause before opening it |

Your login stays on the phone (cookies of the built-in browser). Nothing is sent anywhere
else.

Known limits: features that exist only in the official app (for example Instants) are not
available, because the website does not have them. Notifications are not supported.

## Install (free Apple account, needs a Mac)

1. Install Xcode from the Mac App Store and open it once.
2. `brew install xcodegen`
3. Clone this repo, then create `Config/Local.xcconfig` with your team id
   (Xcode, Settings, Accounts, your Apple ID, "Personal Team"):
   ```
   DEVELOPMENT_TEAM = ABCDE12345
   ```
4. `xcodegen` in the repo folder, then open `Unscroll.xcodeproj`.
5. Connect the iPhone, select it as destination, press Run.
6. On the iPhone: Settings, General, VPN & Device Management, trust your developer
   certificate. Developer Mode must be on (Settings, Privacy & Security).

With a free Apple account the app expires after 7 days: connect the phone and press Run
again. A free account can have at most 3 sideloaded apps on a device.

## Development

- Navigation rules and injected scripts live in `Packages/UnscrollCore`, tested with
  `cd Packages/UnscrollCore && swift test` (scripts are run through JavaScriptCore).
- The app (`App/`) is SwiftUI plus a `WKWebView`.
- Plan and status (Italian): [docs/PLAN.md](docs/PLAN.md).

## License

MIT.
