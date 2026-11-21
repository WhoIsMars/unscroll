import SwiftUI
import UnscrollCore
import WebKit

/// Sito mobile di Instagram con Reels, Esplora e feed suggerito reindirizzati (regole in UnscrollCore).
struct InstagramWebView: UIViewRepresentable {
    /// Pagina chiesta dalla barra nativa.
    let target: URL
    /// Cambia a ogni tocco, così ritoccare una scheda torna alla sua pagina iniziale.
    let tapID: Int

    // Le classi di Instagram sono offuscate: si nascondono i link per href.
    private static let hideCSS = """
    a[href="/"], a[href="/reels/"], a[href="/explore/"],
    a[href*="apps.apple.com"], a[href^="instagram://"] { display: none !important; }
    """

    private static let injectedJS = """
    const s = document.createElement('style');
    s.textContent = `\(hideCSS)`;
    document.documentElement.appendChild(s);
    document.addEventListener('DOMContentLoaded', () => {
      let m = document.querySelector('meta[name=viewport]');
      if (!m) { m = document.createElement('meta'); m.name = 'viewport'; document.head.appendChild(m); }
      m.content = 'width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no';
    });
    \(InstagramScripts.reelLock)
    """

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .default() // cookie persistenti: il login resta sul telefono
        // Senza questo, su iPhone video, storie e reel si aprono nel player di sistema a schermo intero.
        config.allowsInlineMediaPlayback = true
        // Ci si presenta come Safari: con lo user agent di WKWebView Instagram può nascondere funzioni.
        let ios = UIDevice.current.systemVersion.split(separator: ".").first ?? "18"
        config.applicationNameForUserAgent = "Version/\(ios).0 Mobile/15E148 Safari/604.1"
        config.userContentController.addUserScript(
            WKUserScript(source: Self.injectedJS, injectionTime: .atDocumentStart, forMainFrameOnly: true))

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true

        let refresh = UIRefreshControl()
        refresh.addAction(UIAction { [weak webView] _ in
            webView?.reload()
            refresh.endRefreshing()
        }, for: .valueChanged)
        webView.scrollView.refreshControl = refresh

        // Instagram è una single-page app: i cambi di pagina interni non passano dal
        // navigation delegate, ma aggiornano webView.url.
        let coordinator = context.coordinator
        coordinator.urlObservation = webView.observe(\.url, options: [.new]) { wv, _ in
            guard let url = wv.url else { return }
            defer { coordinator.lastURL = wv.url }
            if InstagramRules.isReelSwipe(from: coordinator.lastURL, to: url), let back = coordinator.lastURL {
                wv.load(URLRequest(url: back)) // un reel alla volta: si resta su quello aperto
                return
            }
            guard let target = InstagramRules.redirect(for: url) else { return }
            if url.path.isEmpty || url.path == "/" {
                // shortcut: il sito potrebbe togliere ?variant= dall'indirizzo e causare un ciclo di
                // ricaricamenti; al massimo un rimando ogni 5 s. Se cicla, serve una regola sul contenuto.
                guard Date().timeIntervalSince(coordinator.lastHomeRedirect) > 5 else { return }
                coordinator.lastHomeRedirect = Date()
            }
            wv.load(URLRequest(url: target))
        }
        context.coordinator.loadedTap = tapID
        webView.load(URLRequest(url: target))
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        guard context.coordinator.loadedTap != tapID else { return }
        context.coordinator.loadedTap = tapID
        webView.load(URLRequest(url: target))
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        var urlObservation: NSKeyValueObservation?
        var loadedTap = 0
        var lastHomeRedirect = Date.distantPast
        var lastURL: URL?

        func webView(_ webView: WKWebView, decidePolicyFor action: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            guard let url = action.request.url else { return decisionHandler(.allow) }
            // Niente rimandi all'app ufficiale o all'App Store.
            if !["http", "https", "about", "blob", "data"].contains(url.scheme ?? "")
                || url.host == "apps.apple.com" {
                return decisionHandler(.cancel)
            }
            if action.targetFrame?.isMainFrame == true, let target = InstagramRules.redirect(for: url) {
                decisionHandler(.cancel)
                webView.load(URLRequest(url: target))
                return
            }
            decisionHandler(.allow)
        }
    }
}
