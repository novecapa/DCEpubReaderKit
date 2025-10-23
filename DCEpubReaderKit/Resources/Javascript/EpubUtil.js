/* EpubUtil.js — pagination & helpers */

function applyHorizontalPagination() {
    
    let marginTop = 0;
    let columnGap = 20;
    let columnGapTop = 0;
    let stylemargin = 0;

    var d = document.getElementsByTagName('body')[0];

    var ourH = window.innerHeight;
    var ourW = window.innerWidth;
    var fullH = d.offsetHeight;
    var pageCount = Math.max(1, Math.ceil(fullH / ourH));

    var newW = (ourW * pageCount);
    d.style.height = `${(ourH - ((columnGapTop + marginTop) / 2)) + stylemargin}px`;
    d.style.width = `${newW}px`;
    d.style.webkitColumnGap = `${columnGap}px`;
    d.style.columnGap = `${columnGap}px`;
    
    d.style.margin = `${stylemargin}px`;
    d.style.marginLeft = `${stylemargin}px`;
    
    d.style.webkitColumnCount = pageCount;
    d.style.textAlign = 'justify'
    d.style.overflow = 'visible';

    return `${pageCount}`
}

function scrollToLastHorizontalPage() {

    let columnGap = 0;
    let stylemargin = 0;

    var d = document.scrollingElement || document.documentElement || document.body;

    let pageWidth = window.innerWidth;
    // Derive pageCount from scrollWidth to avoid counting an extra blank column
    let pageCount = Math.max(1, Math.ceil(d.scrollWidth / pageWidth));

    let totalscroll = (pageCount - 1) * pageWidth + stylemargin;

    d.scrollLeft = totalscroll;

    return totalscroll;
}

function scrollToFirstHorizontalPage() {
    var d = document.scrollingElement || document.documentElement || document.body;
    d.scrollLeft = 0;
}

function rectsForSelection() {
    var i = 0, j = 0;
    var allSelections = window.getSelection();
    var result = []; // An empty array right now
    // Generally, there is only one selection, but the spec allows multiple
    for (i=0; i < allSelections.rangeCount; i++) {
        var aRange = allSelections.getRangeAt(i);
        var rects = aRange.getClientRects();
        for (j=0; j<rects.length; j++) {
            result.push(rects[j]);
        }
    }
    return JSON.stringify(result);
}

function clearTextSelection() {
    if (window.getSelection) {
        if (window.getSelection().empty) {  // Chrome
            window.getSelection().empty();
        } else if (window.getSelection().removeAllRanges) {  // Firefox
            window.getSelection().removeAllRanges();
        }
    } else if (document.selection) {  // IE?
        document.selection.empty();
    }
}

(function(){
    const HANDLER = "selectionChanged";
    
    function installSelectionBridge() {
        if (window.__dc_selection_listener) {
            document.removeEventListener("selectionchange", window.__dc_selection_listener, true);
        }
        
        let lastKey = "";
        let lastSentAt = 0;
        let to = null;
        
        function buildKey(sel){
            if (!sel || !sel.rangeCount) return "";
            return sel.toString();
        }
        
        function notify(){
            try{
                const sel = window.getSelection();
                const text = sel ? sel.toString() : "";
                const now = Date.now();
                
                if (!text){
                    const key = "";
                    if (lastKey !== key || (now - lastSentAt) > 250){
                        if (window.webkit?.messageHandlers?.[HANDLER]) {
                            window.webkit.messageHandlers[HANDLER].postMessage({ text: "" });
                        }
                        lastKey = key; lastSentAt = now;
                    }
                    return;
                }
                
                const key = buildKey(sel);
                if (key === lastKey && (now - lastSentAt) < 250) return;
                
                if (window.webkit?.messageHandlers?.[HANDLER]) {
                    window.webkit.messageHandlers[HANDLER].postMessage({ text });
                }
                lastKey = key; lastSentAt = now;
            } catch (e) {}
        }
        
        function debounced(){
            if (to) clearTimeout(to);
            to = setTimeout(notify, 120);
        }
        
        document.addEventListener("selectionchange", debounced, true);
        window.__dc_selection_listener = debounced;
    }

    if (document.readyState === "loading"){
        document.addEventListener("DOMContentLoaded", installSelectionBridge, { once: true });
    } else {
        installSelectionBridge();
    }

    window.EpubUtil = window.EpubUtil || {};
    window.EpubUtil.installSelectionBridge = installSelectionBridge;
})();
