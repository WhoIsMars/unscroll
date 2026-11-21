import Foundation

/// Decide dove mandare una pagina di Instagram che fa scorrere all'infinito.
/// `nil` = pagina permessa.
public enum InstagramRules {
    public static let inbox = URL(string: "https://www.instagram.com/direct/inbox/")!
    // da verificare: che la ricerca del sito mobile stia davvero sotto /explore/search/.
    public static let search = URL(string: "https://www.instagram.com/explore/search/")!

    // da verificare: che Instagram mantenga ancora le varianti ?variant=following/favorites.
    public static let followingFeed = URL(string: "https://www.instagram.com/?variant=following")!

    public static func redirect(for url: URL) -> URL? {
        guard let host = url.host?.lowercased(),
              host == "instagram.com" || host == "www.instagram.com" else { return nil }
        let parts = url.path.split(separator: "/")
        guard let first = parts.first else {
            // "/" è il feed con i suggeriti; le varianti "seguiti" e "preferiti" mostrano solo chi segui.
            let variant = URLComponents(url: url, resolvingAgainstBaseURL: false)?
                .queryItems?.first { $0.name == "variant" }?.value
            return variant == "following" || variant == "favorites" ? nil : followingFeed
        }
        switch first {
        case "reels": return parts.count > 1 ? nil : inbox // /reels/<id>/ = un reel solo
        case "explore": return parts.count > 1 && parts[1] == "search" ? nil : search
        default: return nil
        }
    }

    /// Vero se si è passati da un reel a un altro reel (scorrimento nel visualizzatore).
    public static func isReelSwipe(from old: URL?, to new: URL) -> Bool {
        guard let oldID = reelID(old), let newID = reelID(new) else { return false }
        return oldID != newID
    }

    private static func reelID(_ url: URL?) -> Substring? {
        guard let parts = url?.path.split(separator: "/"), parts.count > 1, parts[0] == "reels" else { return nil }
        return parts[1]
    }

    /// Profilo dal nome utente scritto dall'utente; nil se non resta nessun carattere valido.
    public static func profileURL(username: String) -> URL? {
        // I nomi utente Instagram usano solo lettere, cifre, punto e trattino basso (max 30).
        let clean = String(username.filter { $0.isASCII && ($0.isLetter || $0.isNumber || $0 == "." || $0 == "_") }
            .prefix(30))
        return clean.isEmpty ? nil : URL(string: "https://www.instagram.com/\(clean)/")
    }
}
