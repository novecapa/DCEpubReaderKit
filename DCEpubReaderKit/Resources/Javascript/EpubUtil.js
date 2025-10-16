/* EpubUtil.js — pagination & helpers */

function applyHorizontalPagination() {
    
    let margin_top = 40;
    let margin_bottom = 30;
    let columnGap = 20;
    let columnGapTop = 40;
    let stylemargin = 10;

    var d = document.getElementsByTagName('body')[0];

    var ourH = window.innerHeight;
    var ourW = window.innerWidth;
    var fullH = d.offsetHeight;
    var pageCount = Math.ceil((fullH/ourW) == 1 ? 1 : (fullH/ourH));

    var newW = (ourW * pageCount) - columnGap;
    d.style.height = `${(ourH - ((columnGapTop + margin_top) / 2)) + stylemargin}px`;
    d.style.width = `${newW}px`;
    
    d.style.margin = `${stylemargin}px`;
    
    d.style.webkitColumnCount = pageCount;
    d.style.textAlign = 'justify'
    d.style.overflow = 'visible';

    let totalPages = newW / (ourW-columnGapTop-stylemargin)
    
    return Math.round(totalPages);
}
