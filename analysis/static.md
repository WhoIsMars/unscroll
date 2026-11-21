# Analisi statica di SocialLite 3.1.5 (build 979)

Livello di evidenza: `[STATIC]` letto dall'IPA ufficiale (App Store, bundle `social.Social-lite`,
scaricata con ipatool il 2026-11-21). Solo parti in chiaro: Info.plist, entitlements,
testi di interfaccia, elenco risorse. Il binario non è stato decifrato né decompilato.
L'IPA resta fuori dal repo (`analysis/raw/` è in `.gitignore`).

## Fatti verificati

| Cosa | Evidenza |
|---|---|
| Tutti gli eseguibili sono cifrati | `otool -l`: `cryptid 1` sull'app e sulle 6 estensioni |
| Usa Screen Time | entitlement `com.apple.developer.family-controls` su app, DeviceActivityMonitor, ShieldAction, ShieldConfiguration |
| 6 estensioni | DeviceActivityMonitor (orari e limiti), ShieldConfiguration (schermata di blocco personalizzata), ShieldAction (pulsanti della schermata di blocco), Share (riceve un URL da un'altra app), Notification Service (modifica notifiche push), Widget |
| Dati condivisi tra app ed estensioni | App Group comune a tutte le estensioni |
| Notifiche push e chiamate | `aps-environment`, `UIBackgroundModes`: audio, voip, remote-notification |
| Task in background | 2 identificativi BGTask, uno dedicato alle notifiche Instagram |
| Nessuno script di filtro in chiaro | nessun file .js/.css/.html nel bundle fuori dai framework di terze parti |
| SDK di terze parti | RevenueCat (abbonamenti), Firebase Analytics, Facebook SDK, Google App Measurement, Appstack (attribuzione) |
| Testi di interfaccia | 1359 stringhe in `en.lproj/Localizable.strings` |

## Cosa dicono i testi dell'interfaccia (parafrasati)

- **Login**: l'utente entra dal sito ufficiale di ogni social dentro l'app; un cookie di
  sessione salvato sul telefono lo tiene connesso. Quindi: browser interno (WKWebView)
  sui siti mobile.
- **Regole di filtro per Instagram**: rimuovere Reels (tab e riproduzione nel feed), Esplora,
  post suggeriti, sponsorizzati, barra storie, commenti; modalità "solo DM"; feed "solo
  preferiti"; contatore di post, pubblicità e suggeriti visti; timer di sessione.
- **YouTube**: niente Shorts, niente griglia di raccomandazioni (modalità "solo ricerca"),
  niente barra laterale "Up next", niente schermate di fine video, niente autoplay nel feed,
  blocco pubblicità, audio in background e PiP.
- **Altri social**: Snapchat (Spotlight sempre bloccato, snap video via WebCodecs), Facebook
  (modalità solo Marketplace), X (niente Trending), Reddit (niente r/Popular, niente
  suggeriti), TikTok (niente LIVE).
- **Blocco app native**: le app vere vengono bloccate con Screen Time e la schermata di
  blocco rimanda a SocialLite. "Post Mode" sblocca l'app nativa per qualche minuto per
  pubblicare, dato che dal sito web Instagram limita la pubblicazione.
- **Attrito per sbloccare**: per alzare un limite si deve scrivere una frase e aspettare un
  minuto; pressione prolungata di 5 secondi; Sleep Mode notturno.
- **Notifiche**: un "notification service" lato server deve "connettere l'account".

## Ipotesi aperte (da verificare a runtime, fase 1b)

1. **Sessione Instagram sui loro server.** Per inviare notifiche dei DM quando l'app è
   chiusa, un server deve leggere i messaggi, quindi possedere la sessione dell'utente.
   I testi dicono che SocialLite non vede mai il login; le due cose sono compatibili solo
   se viene mandato il cookie e non la password. Verifica: mitmproxy durante l'attivazione
   delle notifiche.
2. **Regole di filtro remote.** Le regole non sono tra le risorse in chiaro: o sono nel
   binario cifrato, o vengono scaricate (Firebase Remote Config o server proprio).
   Verifica: traffico all'avvio dell'app.
3. **User agent.** Quale user agent usa il WKWebView (mobile o desktop) per avere il sito
   più completo. Verifica: header delle richieste a instagram.com.

## Cosa replicheremo senza account sviluppatore a pagamento

Vedi `docs/PLAN.md`, sezione vincoli. In breve: il cuore (browser interno + regole CSS/JS)
non richiede nessun entitlement speciale. Screen Time, notifiche push e chiamate sì.
