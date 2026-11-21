# Piano di lavoro: unscroll (iOS)

Obiettivo: app iOS open source che permette di usare i social (DM, profili cercati,
contenuti ricevuti) senza feed infiniti, Reels, Shorts, Esplora e pubblicità. Nessun
abbonamento.

Riferimento di comportamento: SocialLite (App Store id6757661674, Sociallite LLC).
Ne studiamo il **comportamento osservabile** e riscriviamo tutto da zero: niente codice,
script o asset copiati, niente decifratura del binario (FairPlay).

## Ipotesi di funzionamento di SocialLite (da verificare in fase 1)

Fonte: scheda App Store e recensioni (letto il 2026-11-21).

1. I social girano come **siti mobile dentro un browser interno** (WKWebView), con
   CSS/JS iniettati che nascondono Reels, Shorts, Esplora, feed suggerito, pubblicità.
   Indizi: recensioni ("uses the browser version of each platform"), funzioni mancanti
   tipiche del sito web (upload storie, musica).
2. **Screen Time API** (FamilyControls + ManagedSettings + DeviceActivity) per bloccare le
   app native e mostrare una schermata di blocco che rimanda all'app. Indizi: note di
   versione 2.0.0 "App Shielding and full Screen Time Integration", "Post Mode" da 10 min,
   Live Activity con conto alla rovescia.
3. Da chiarire: le recensioni parlano di "proxy Instagram". Se il traffico passa da un
   loro server, le credenziali degli utenti passano da terzi: è la domanda più importante
   della fase 1.

## Fasi

| # | Fase | Output | Stato |
|---|------|--------|-------|
| 0 | Setup: repo, REA, ipatool, mitmproxy | questo piano | fatto 2026-11-21 |
| 1a | Analisi statica dell'IPA: Info.plist, entitlements, estensioni, risorse in chiaro (JS/CSS/HTML), storyboard, framework | `analysis/static.md` | da fare |
| 1b | Analisi a runtime: traffico con mitmproxy (sito diretto o proxy?), cosa nasconde a schermo per ogni social | `analysis/runtime.md` | da fare |
| 2 | Specifica di comportamento scritta da noi (cosa bloccare, cosa tenere, per social) | `docs/SPEC.md` | da fare |
| 3 | MVP: SwiftUI + WKWebView su instagram.com, regole CSS/JS proprie, test | app che compila | da fare |
| 4 | YouTube (niente Shorts, niente home suggerita) | | da fare |
| 5 | Screen Time: blocco app native + schermata di rimando | | da fare |
| 6 | Pubblicazione: README, release, istruzioni di installazione (sideload/TestFlight) | | da fare |

## Cosa serve dall'utente

- **Xcode completo** (Mac App Store, circa 15 GB): sul Mac ci sono solo i Command Line Tools,
  senza SDK iOS non si compila.
- **Login Apple ID per ipatool** (`ipatool auth login -e <email>`), solo per scaricare
  l'IPA di SocialLite (gratuita). Il login lo fa l'utente nel terminale, mai in chat.
- **iPhone** con il certificato di mitmproxy installato per la fase 1b.
- Da verificare: il blocco app (fase 5) richiede la capability Family Controls, che per
  la distribuzione serve un Apple Developer Program a pagamento (99 $/anno) e
  un'approvazione Apple. Per uso personale in sviluppo potrebbe bastare un account gratuito.

## Limiti di distribuzione (da verificare)

Un'app che riscrive Instagram dentro un browser interno rischia il rifiuto in App Store
e viola probabilmente i termini d'uso di Meta. Strada realistica: codice open source da
compilare e installare da sé (Xcode o AltStore/SideStore).
