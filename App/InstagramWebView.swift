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
    a[href="/"], a[href^="/reels/"], a[href="/explore/"],
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
    """

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .default() // cookie persistenti: il login resta sul telefono
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
        context.coordinator.urlObservation = webView.observe(\.url, options: [.new]) { wv, _ in
            // shortcut: "/" si controlla solo nei caricamenti completi, perché il sito potrebbe
            // togliere ?variant= dall'indirizzo e causare un ciclo; il link Home è comunque nascosto.
            guard let url = wv.url, url.path != "/", !url.path.isEmpty,
                  let target = InstagramRules.redirect(for: url) else { return }
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
