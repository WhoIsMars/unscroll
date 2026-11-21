/// JavaScript iniettato nel sito di Instagram.
public enum InstagramScripts {
    /// Nei reel blocca il trascinamento, così non si passa al reel successivo. Due casi:
    /// - visore dei reel (/reel/<id>/, /reels/<id>/);
    /// - riquadro aperto da una chat: l'indirizzo resta /direct/t/<id>/ e i reel scorrono in un
    ///   contenitore con scroll-snap verticale che contiene video (visto sul telefono il 2026-11-21).
    /// I fogli sopra il reel (commenti, condivisione) sono [role=dialog] e restano scorrevoli.
    public static let reelLock = """
    function unscrollBlocksSwipe(path, inDialog, inVideoSnapScroller) {
      if (inDialog) return false;
      return inVideoSnapScroller || /^\\/reels?\\/[^\\/]+/.test(path);
    }
    function unscrollInVideoSnapScroller(el) {
      for (let n = el; n && n !== document.body; n = n.parentElement) {
        if (getComputedStyle(n).scrollSnapType.includes('y') && n.querySelector('video')) return true;
      }
      return false;
    }
    if (typeof document !== 'undefined') {
      let block = false; // deciso a ogni inizio tocco, non a ogni movimento
      document.addEventListener('touchstart', (e) => {
        const t = e.target;
        const inDialog = !!(t.closest && t.closest('[role="dialog"]'));
        block = unscrollBlocksSwipe(location.pathname, inDialog, !inDialog && unscrollInVideoSnapScroller(t));
      }, { passive: true, capture: true });
      document.addEventListener('touchmove', (e) => { if (block) e.preventDefault(); },
        { passive: false, capture: true });
    }
    """
}
