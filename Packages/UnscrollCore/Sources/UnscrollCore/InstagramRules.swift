import Foundation

/// Decide dove mandare una pagina di Instagram che fa scorrere all'infinito.
/// `nil` = pagina permessa.
public enum InstagramRules {
    public static let inbox = URL(string: "https://www.instagram.com/direct/inbox/")!
    // da verificare: che la ricerca del sito mobile stia davvero sotto /explore/search/.
    public static let search = URL(string: "https://www.instagram.com/explore/search/")!

    public static func redirect(for url: URL) -> URL? {
        guard let host = url.host?.lowercased(),
              host == "instagram.com" || host == "www.instagram.com" else { return nil }
        let parts = url.path.split(separator: "/")
        guard let first = parts.first else { return inbox } // "/" = feed principale
        switch first {
        case "reels": return inbox
        case "explore": return parts.count > 1 && parts[1] == "search" ? nil : search
        default: return nil
        }
    }
}
