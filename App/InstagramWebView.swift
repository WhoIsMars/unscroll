import SwiftUI
import UnscrollCore
import WebKit

/// Sito mobile di Instagram con Reels, Esplora e feed reindirizzati (regole in UnscrollCore).
struct InstagramWebView: UIViewRepresentable {
    /// Pagina chiesta dalla barra nativa: a ogni cambio la si carica.
    let target: URL
    /// Cambia a ogni tocco, così ritoccare "Messaggi" dentro una chat torna alla lista.
    let tapID: Int

    // Le classi di Instagram sono offuscate: si nascondono i link per href.
    private static let hideCSS = """
    a[href="/"], a[href^="/reels/"], a[href="/explore/"] { display: none !important; }
    """

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .default() // cookie persistenti: il login resta sul telefono
        let js = """
        const s = document.createElement('style');
        s.textContent = `\(Self.hideCSS)`;
        document.documentElement.appendChild(s);
        """
        config.userContentController.addUserScript(
            WKUserScript(source: js, injectionTime: .atDocumentStart, forMainFrameOnly: true))

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        // Instagram è una single-page app: i cambi di pagina interni non passano dal
        // navigation delegate, ma aggiornano webView.url.
        context.coordinator.urlObservation = webView.observe(\.url, options: [.new]) { wv, _ in
            guard let url = wv.url, let target = InstagramRules.redirect(for: url) else { return }
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
            if action.targetFrame?.isMainFrame == true, let url = action.request.url,
               let target = InstagramRules.redirect(for: url) {
                decisionHandler(.cancel)
                webView.load(URLRequest(url: target))
                return
            }
            decisionHandler(.allow)
        }
    }
}
