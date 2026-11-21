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
    // Feed: 15 minuti al giorno, e 10 secondi di attesa prima di entrare.
    @AppStorage("feedBudget") private var budgetData = Data()
    @State private var feedStart: Date?
    @State private var askFeed = false
    @State private var feedOver = false
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        VStack(spacing: 0) {
            InstagramWebView(target: target, tapID: tapID)
            HStack {
                Button {
                    if budget.remaining(at: Date()) > 0 { askFeed = true } else { feedOver = true }
                } label: { tabLabel("Feed", "house") }
                .foregroundStyle(target == InstagramRules.followingFeed ? Color.primary : Color.secondary)
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
        .fullScreenCover(isPresented: $askFeed) {
            FeedGate(remaining: budget.remaining(at: Date())) {
                askFeed = false
                open(InstagramRules.followingFeed)
                feedStart = Date()
            } cancel: { askFeed = false }
        }
        .task(id: feedStart) {
            guard feedStart != nil else { return }
            try? await Task.sleep(for: .seconds(budget.remaining(at: Date())))
            guard !Task.isCancelled else { return }
            open(InstagramRules.inbox)
            feedOver = true
        }
        .onChange(of: scenePhase) { _, phase in
            if phase != .active { stopFeedClock() }
            else if target == InstagramRules.followingFeed, feedStart == nil {
                // Si torna nell'app col feed aperto: si riparte dal conteggio, o si esce se finito.
                if budget.remaining(at: Date()) > 0 { feedStart = Date() } else { open(InstagramRules.inbox); feedOver = true }
            }
        }
        .alert("Feed finito per oggi", isPresented: $feedOver) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Hai usato i \(Int(Self.feedLimit / 60)) minuti di oggi. Messaggi, ricerca e profilo restano aperti.")
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

    private func open(_ url: URL) {
        if url != InstagramRules.followingFeed { stopFeedClock() }
        target = url; tapID += 1
    }

    static let feedLimit: TimeInterval = 15 * 60

    private var budget: FeedBudget {
        (try? JSONDecoder().decode(FeedBudget.self, from: budgetData)) ?? FeedBudget(limit: Self.feedLimit)
    }

    /// Somma al conteggio di oggi il tempo passato sul feed da quando è stato aperto.
    private func stopFeedClock() {
        guard let start = feedStart else { return }
        feedStart = nil
        var b = budget
        b.add(Date().timeIntervalSince(start), at: Date())
        budgetData = (try? JSONEncoder().encode(b)) ?? budgetData
    }

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

/// Attesa prima del feed: 10 secondi per decidere se ne vale la pena.
struct FeedGate: View {
    let remaining: TimeInterval
    let enter: () -> Void
    let cancel: () -> Void
    @State private var wait = 10

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Text("Vuoi davvero aprire il feed?").font(.title2.bold())
            Text("Oggi ti restano \(Int((remaining / 60).rounded(.up))) minuti.")
                .foregroundStyle(.secondary)
            Spacer()
            Button(wait > 0 ? "Apri il feed tra \(wait) s" : "Apri il feed", action: enter)
                .buttonStyle(.borderedProminent).disabled(wait > 0)
            Button("Lascia stare", action: cancel)
        }
        .padding(32)
        .task {
            while wait > 0 {
                try? await Task.sleep(for: .seconds(1))
                wait -= 1
            }
        }
    }
}
