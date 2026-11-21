/// JavaScript iniettato nel sito di Instagram.
public enum InstagramScripts {
    /// Nel visore dei reel blocca il trascinamento, così non si passa al reel successivo.
    /// L'indirizzo non cambia sempre allo scorrimento, quindi il controllo nativo sull'URL non basta.
    /// I fogli sopra il reel (commenti, condivisione) sono [role=dialog] e restano scorrevoli.
    public static let reelLock = """
    function unscrollBlocksSwipe(path, inDialog) {
      return /^\\/reels?\\/[^\\/]+/.test(path) && !inDialog;
    }
    if (typeof document !== 'undefined') {
      document.addEventListener('touchmove', (e) => {
        const inDialog = !!(e.target.closest && e.target.closest('[role="dialog"]'));
        if (unscrollBlocksSwipe(location.pathname, inDialog)) e.preventDefault();
      }, { passive: false, capture: true });
    }
    """
}
