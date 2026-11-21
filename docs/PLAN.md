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
| 1a | Analisi statica dell'IPA: Info.plist, entitlements, estensioni, risorse in chiaro (JS/CSS/HTML), storyboard, framework | `analysis/static.md` | fatto 2026-11-21 |
| 1b | Analisi a runtime: traffico con mitmproxy (sito diretto o proxy?), cosa nasconde a schermo per ogni social | `analysis/runtime.md` | da fare |
| 2 | Specifica di comportamento scritta da noi (cosa bloccare, cosa tenere, per social) | `docs/SPEC.md` | da fare |
| 3 | MVP: SwiftUI + WKWebView su instagram.com, regole CSS/JS proprie, test | app che compila | fatto 2026-11-21: 18 test verdi, installata su iPhone XR; provati dall'utente: login, messaggi, ricerca, feed solo Seguiti, video in linea, scheda Profilo, reel bloccati (anche aperti da chat), barra di Instagram nascosta. Istantanee assenti dal sito, fuori scopo |
| 4 | YouTube (niente Shorts, niente home suggerita) | | da fare |
| 5 | Screen Time: blocco app native + schermata di rimando (solo se il Personal Team lo consente) | | da fare |
| 6 | Pubblicazione: README, release, istruzioni di installazione (sideload/TestFlight) | | README fatto 2026-11-21 (installazione con account gratuito); release da fare |
| 3b | Attrito sul feed: 15 min al giorno, attesa di 10 s prima di aprirlo | | fatto 2026-11-21, attesa provata dall'utente; scadenza dei 15 min non provata |

## Cosa serve dall'utente

- **Xcode completo** (Mac App Store, circa 15 GB): sul Mac ci sono solo i Command Line Tools,
  senza SDK iOS non si compila.
- **Login Apple ID per ipatool** (`ipatool auth login -e <email>`), solo per scaricare
  l'IPA di SocialLite (gratuita). Il login lo fa l'utente nel terminale, mai in chat.
- **iPhone** con il certificato di mitmproxy installato per la fase 1b.
## Vincolo: nessun Apple Developer Program a pagamento (deciso 2026-11-21)

Si firma con l'account Apple gratuito ("Personal Team" in Xcode). Conseguenze (da
verificare in Xcode appena installato):

- l'app installata scade dopo 7 giorni e va reinstallata (o rinnovata con SideStore);
- niente notifiche push: le notifiche dei DM con app chiusa sono fuori scopo;
- Family Controls (Screen Time) probabilmente non disponibile: la fase 5 diventa
  "prova una volta, se Xcode rifiuta la capability si salta". Alternativa senza
  entitlement: disinstallare le app native, che è anche il consiglio delle FAQ di SocialLite;
- quindi l'MVP è **una sola app senza estensioni**: WKWebView + regole CSS/JS, che non
  richiede nessun entitlement speciale.

## Limiti di distribuzione (da verificare)

Un'app che riscrive Instagram dentro un browser interno rischia il rifiuto in App Store
e viola probabilmente i termini d'uso di Meta. Strada realistica: codice open source da
compilare e installare da sé (Xcode o AltStore/SideStore).
