/* EpubUtil.js — pagination & helpers */

function applyHorizontalPagination() {
    
    let marginTop = 20;
    let columnGap = 0;
    let columnGapTop = 20;
    let stylemargin = 0;

    var d = document.getElementsByTagName('body')[0];

    var ourH = window.innerHeight;
    var ourW = window.innerWidth;
    var fullH = d.offsetHeight;
    var pageCount = Math.ceil((fullH/ourW) == 1 ? 1 : (fullH/ourH));

    var newW = (ourW * pageCount) - columnGap;
    d.style.height = `${(ourH - ((columnGapTop + marginTop) / 2)) + stylemargin}px`;
    d.style.width = `${newW}px`;
    
    d.style.margin = `${stylemargin}px`;
    d.style.marginLeft = `${stylemargin}px`;
    
    d.style.webkitColumnCount = pageCount;
    d.style.textAlign = 'justify'
    d.style.overflow = 'visible';

    let totalPages = newW / (ourW-columnGapTop-stylemargin)
    
    return Math.round(totalPages);
}
