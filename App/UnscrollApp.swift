import SwiftUI
import UnscrollCore

@main
struct UnscrollApp: App {
    var body: some Scene {
        WindowGroup { RootView() }
    }
}

/// Barra nativa: dai messaggi il sito mobile non offre altra uscita che la Home (bloccata).
struct RootView: View {
    @State private var target = InstagramRules.inbox
    @State private var tapID = 0

    var body: some View {
        VStack(spacing: 0) {
            InstagramWebView(target: target, tapID: tapID)
            HStack {
                tab("Messaggi", "paperplane", InstagramRules.inbox)
                tab("Cerca", "magnifyingglass", InstagramRules.search)
            }
            .padding(.top, 8)
            .background(.bar)
        }
    }

    private func tab(_ title: String, _ icon: String, _ url: URL) -> some View {
        Button { target = url; tapID += 1 } label: {
            Label(title, systemImage: icon).labelStyle(.titleAndIcon).frame(maxWidth: .infinity)
        }
        .foregroundStyle(target == url ? Color.primary : Color.secondary)
    }
}
