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
    @AppStorage("instagramUsername") private var username = ""
    @State private var askUsername = false
    @State private var draft = ""

    var body: some View {
        VStack(spacing: 0) {
            InstagramWebView(target: target, tapID: tapID)
            HStack {
                tab("Feed", "house", InstagramRules.followingFeed)
                tab("Messaggi", "paperplane", InstagramRules.inbox)
                tab("Cerca", "magnifyingglass", InstagramRules.search)
                Button {
                    if let url = profileURL { open(url) } else { draft = ""; askUsername = true }
                } label: { tabLabel("Profilo", "person.crop.circle") }
                .foregroundStyle(target == profileURL ? Color.primary : Color.secondary)
                .contextMenu { Button("Cambia nome utente") { draft = username; askUsername = true } }
            }
            .padding(.top, 8)
            .background(.bar)
        }
        .alert("Il tuo nome utente Instagram", isPresented: $askUsername) {
            TextField("nome_utente", text: $draft)
                .textInputAutocapitalization(.never).autocorrectionDisabled()
            Button("Salva") {
                username = draft
                if let url = profileURL { open(url) }
            }
            Button("Annulla", role: .cancel) {}
        } message: {
            Text("Serve per aprire il tuo profilo e la tua storia.")
        }
    }

    private var profileURL: URL? {
        InstagramRules.profileURL(username: username)
    }

    private func open(_ url: URL) { target = url; tapID += 1 }

    private func tabLabel(_ title: String, _ icon: String) -> some View {
        VStack(spacing: 2) {
            Image(systemName: icon)
            Text(title).font(.caption2)
        }.frame(maxWidth: .infinity)
    }

    private func tab(_ title: String, _ icon: String, _ url: URL) -> some View {
        Button { open(url) } label: { tabLabel(title, icon) }
            .foregroundStyle(target == url ? Color.primary : Color.secondary)
    }
}
