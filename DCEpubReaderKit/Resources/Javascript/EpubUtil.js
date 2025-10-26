/* EpubUtil.js — pagination & helpers */

function applyHorizontalPagination() {
    
    let marginTop = 54;
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
    scrollTo(0, 0)
}

var SEL_LEN = 7;
var orientationStr;
var isASearch = false;
var searchString;

if (window.innerHeight < window.innerWidth) {
    orientationStr = "landscape";
} else {
    orientationStr = "portrait";
}

var viewerWidth = window.innerWidth;
var viewerHeight = window.innerHeight;
var screenHeight = (screen.height - 40);

if (orientationStr == "landscape") {
    screenHeight = (screen.width - 40);
}

function getCoordFromNode(node, offset) {
    var selParents = Array();
    var aux_node = node;
    var entryposition = 0;
    selParents.push(zeroFilling(parseInt(getOffset(node, offset)), SEL_LEN));
    if (aux_node.parentNode.className == 'highlight-yellow' || aux_node.parentNode.className == 'highlight-underline' || aux_node.parentNode.className == 'highlight_search') {
        aux_node = aux_node.parentNode;
    }
    while (aux_node.parentNode) {
        entryposition = getNodePos(aux_node, 'highlight-yellow', 'highlight-underline');
        selParents.push(zeroFilling(parseInt(entryposition), 7));
        aux_node = aux_node.parentNode;
    }
    selParents.reverse();
    var selRangeString = selParents.join('>');
    return selRangeString;
}

function getOffset(n, offsetnode) {
    var node = n;
    var offset = 0;
    var previousignored = false;
    if ((node.nodeType == 3) && (($(node.parentNode).hasClass('highlight-yellow')) || ($(node.parentNode).hasClass('highlight_search')) || (node.parentNode.className == 'highlight-underline'))) {
        node = node.parentNode;
        previousignored = true;
    }
    while (node.previousSibling) {
        node = node.previousSibling;
        if (($(node).hasClass('highlight-yellow')) || ($(node).hasClass('highlight_search')) || (node.className == 'highlight-underline')) {
            offset = offset + $(node).text().length;
            previousignored = true;
        } else {
            if (previousignored && (node.nodeType == 3)) {
                offset = offset + node.length;
                previousignored = false;
            } else {
                break;
            }
        }
    }
    return offset + offsetnode;
}

function getNodePos(node, ignore, ignore2) {
    var re = /(\r\n|\n|\r)/gm;
    var position = 0;
    var aux_node = node.previousSibling;
    var previousignored = ($(node).hasClass('highlight_search') || $(node).hasClass(ignore) || (node.className == ignore2));
    while (aux_node) {
        if ((!$(aux_node).hasClass(ignore)) && (!$(aux_node).hasClass(ignore2)) && (!$(aux_node).hasClass('highlight_search'))) {
            if (!previousignored && (aux_node.nodeType != 10)) {
                position++;
            } else {
                if ((aux_node.nodeType == 1)) {
                    position++;
                } else {
                    if (aux_node.nextSibling.nextSibling && (aux_node.nextSibling.nextSibling.nodeType == 1) && (!$(aux_node.nextSibling.nextSibling).hasClass('highlight-yellow')) && (!$(aux_node.nextSibling.nextSibling).hasClass('highlight_search')) && (!$(aux_node.nextSibling.nextSibling).hasClass('highlight-underline'))) {
                        position++;
                    }
                }
            }
            previousignored = false;
        } else {
            if (($(aux_node).text().trim() == '') && (aux_node.className != ignore2)) {
                position++;
            } else {
                if (!aux_node.previousSibling &&
                    aux_node.nextSibling &&
                    (aux_node.nextSibling.nodeType == 1) &&
                    !$(aux_node.nextSibling).hasClass('highlight_search') &&
                    !$(aux_node.nextSibling).hasClass('highlight-underline') &&
                    !$(aux_node.nextSibling).hasClass('highlight-yellow')) {
                    position++;
                }
                previousignored = true;
            }
        }
        aux_node = aux_node.previousSibling;
    }
    return position;
}

function zeroFilling(number, width) {
    width -= number.toString().length;
    if (width > 0) {
        return new Array(width + (/\./.test(number) ? 2 : 1)).join('0') + number;
    }
    return number;
}

function getNodeFromCoordFix(mark, ifrDoc) {
    var last_valid_node = null;
    var levels = mark.split(',')[0].split('>');
    var current_node = ifrDoc;
    var nodes;
    for (var position = 0; position < (levels.length - 1); position++) {
        level_value = parseInt(levels[position], 10);
        if (current_node == null) break;
        nodes = $(current_node).children().filter(filterByClass);
        current_node = current_node.childNodes[level_value];
    }
    isASearch = false;
    return current_node;
}

function getNodeFromCoord(mark, ifrDoc) {
    var last_valid_node = null;
    var levels = mark.split(',')[0].split('>');
    var current_node = ifrDoc;
    var nodes;
    var nodesEnd;
    for (var position = 0; position < (levels.length - 1); position++) {
        level_value = parseInt(levels[position], 10);
        if (current_node == null || current_node == 'undefined') break;
        nodes = current_node.childNodes.filter(filterByClass);
        nodesEnd = current_node.childNodes;
        current_node = nodes[level_value];
    }
    
    if(nodesEnd !== undefined){
        if(nodesEnd.length > 1 && nodesEnd.length > nodes.length) {
            var offset = 0;
            for(var i = 0; i < nodesEnd.length; i++) {
                current_node = nodesEnd[i];
                offset += getLengthNode(current_node);
                if(offset > parseInt(levels[levels.length -1], 10))
                    break;
            }
        }
    }
    if (current_node)
        isASearch = false;
    return current_node;
}

function getLengthNode(node) {
    var nodes = node.childNodes;
    if(nodes.length > 0) {
        var count = 0;
        for(var i = 0; i<nodes.length; i++)
            count += getLengthNode(nodes[i]);
        return count;
    } else {
        return 0;
    }
}

function filterByClass(element, index, arra) {
    var re = /(\r\n|\n|\r)/gm;
    if (!isASearch)
        return ((element.nodeType != 10) &&
                (element.className != 'highlight-yellow') &&
                (element.className != 'highlight-underline') &&
                (element.className != 'highlight_search'));
    
    return (!re.test(element.nodeValue) &&
            (element.nodeType != 8) &&
            (element.nodeType != 10) &&
            (element.className != 'highlight-yellow') &&
            (element.className != 'highlight-underline') &&
            (element.className != 'highlight_search'));
}

function getFirstNodeVisible(page) {
    var first;
    $(':visible').not('body, html, div').filter(filterByClass).each(function() {
        if (typeof first === 'undefined') {
            first = $(this);
        }
        if ($(this).offset().left >= page * window.innerWidth) {
            first = $(this);
            return false;
        }
    });
    return first[0];
}

function getFirstNodeVisibleVertical(page) {
    var first;
    $(':visible').not('body, html, div').filter(filterByClass).each(function() {
        if (typeof first === 'undefined') {
            first = $(this);
        }
        
        if ($(this).offset().top >= page * window.innerHeight) {
            first = $(this);
            return false;
        }
    });
    return first[0];
}


function getCoordsFirstNodeOfPage(currentPage) {
    var nodeVisible = getFirstNodeVisible(currentPage);
    var coord = getCoordFromNode(nodeVisible, 0);
    return coord;
}

function getCoordsFirstNodeOfPageVertical(currentPage) {
    var nodeVisible = getFirstNodeVisibleVertical(currentPage);
    var coord = getCoordFromNode(nodeVisible, 0);
    return coord;
}

function getCoordsFromSelection() {
    var sel = window.getSelection();
    var anchorCoord = 0,
    focusCoord = 0;
    try {
        anchorCoord = getCoordFromNode(sel.anchorNode, sel.anchorOffset);
        focusCoord = getCoordFromNode(sel.focusNode, sel.focusOffset);
    } catch (err) {
        return err.toString();
    }
    
    if (isSelectionBackwards())
        return focusCoord + "," + anchorCoord;
    
    return anchorCoord + "," + focusCoord;
}

function highlightSelection(mark_type) {
    try {
        var text = window.getSelection().toString();
        var coords = getCoordsFromSelection();
        return coords + '[QL_GAP]' + text;
        return 'error_mark_overlap';
    } catch (err) {
        return err.toString();
    }
}

function highlightCoords(mark, mark_type, guid, text) {
    try {
        var iniCoords = mark.split(',')[0];
        var endCoords = mark.split(',')[1];
        var iniOffset = iniCoords.split('>').pop();
        var endOffset = endCoords.split('>').pop();

        var tempIniNode = getNodeFromCoord(iniCoords, document);
        var iniNode = getNodeFromCoord(iniCoords, document);
        var iniFixNode = getNodeFromCoordFix(iniCoords, document);
        
        var coordsIniNode = getCoordFromNode(iniNode, 0);
        var coordsIniFixNode = getCoordFromNode(iniFixNode, 0);
        
        if (!iniNode || iniNode == 'undefined' || !iniNode.textContent.includes(text) || coordsIniNode > coordsIniFixNode)
            iniNode = getNodeFromCoordFix(iniCoords, document);
        
        var tempEndNode = getNodeFromCoord(endCoords, document);
        var endNode = getNodeFromCoord(endCoords, document);
        var endFixNode = getNodeFromCoordFix(endCoords, document);
        
        var coordsEndNode = getCoordFromNode(endNode, 0);
        var coordsEndFixNode = getCoordFromNode(endFixNode, 0);
        
        if (!endNode || endNode == 'undefined' || !endNode.textContent.includes(text) || coordsEndNode > coordsEndFixNode)
            endNode = getNodeFromCoordFix(endCoords, document);
        
        if (iniNode == null){
            while (!tempIniNode.textContent.includes(text)){
                tempIniNode = tempIniNode.nextSibling
                if (tempIniNode == null){
                    break
                }
            }
        }
        
        if (endNode == null){
            while (!tempEndNode.textContent.includes(text)){
                tempEndNode = tempEndNode.nextSibling
                if (tempEndNode == null){
                    break
                }
            }
        }
        
        iniNode = iniNode != null ? iniNode : tempIniNode;
        endNode = endNode != null ? endNode : tempEndNode;
        
        
        displayRange(document, iniNode, iniOffset, endNode, endOffset, 1, mark_type, mark, guid);
        
    } catch (err) {
        return err.toString();
    }
}

function isSelectionBackwards() {
    var backwards = false;
    if (window.getSelection) {
        var sel = window.getSelection();
        if (!sel.isCollapsed) {
            var range = document.createRange();
            range.setStart(sel.anchorNode, sel.anchorOffset);
            range.setEnd(sel.focusNode, sel.focusOffset);
            backwards = range.collapsed;
            range.detach();
        }
    }
    return backwards;
}

function getNumPages() {
    var pages = parseInt(document.width / window.innerWidth);
    if ((document.width / window.innerWidth) - pages > 0)
        pages++;
    return pages;
}

function getPageFromCoords(mark) {
    var node = getNodeFromCoord(mark, document);
    if (!node){
        node = getNodeFromCoordFix(mark, document);
    }
    if (typeof node === 'undefined')
        return 0;
    if (typeof $(node).offset() === 'undefined')
        return 0;
    
    var leftOffset = $(node).offset().left;
    console.log("leftOffset___ = " + leftOffset);
    if (leftOffset == 0 && node.parentNode !== undefined){
        if(!$(node.parentNode).is(':visible'))
            return -1000;
        leftOffset = $(node.parentNode).offset().left;
        console.log("leftOffset2___ = " + leftOffset);
    }
    
    if(searchString !== undefined && searchString !== ""){
        while (!node.textContent.includes(searchString)){
            node = node.nextSibling;
            leftOffset = $(node).offset().left;
            console.log("sleftOffset3___ = " + leftOffset);
        }
        $(node).highlight(searchString);
    }
    return parseInt((leftOffset / window.innerWidth) );
}

function getPageFromCoordsVertical(mark) {
    var node = getNodeFromCoord(mark, document);
    if (!node){
        node = getNodeFromCoordFix(mark, document);
    }
    if (typeof node === 'undefined')
        return 0;
    if (typeof $(node).offset() === 'undefined')
        return 0;
    
    var topOffset = $(node).offset().top;
    console.log("leftOffset___ = " + topOffset);
    if (topOffset == 0 && node.parentNode !== undefined){
        if(!$(node.parentNode).is(':visible'))
            return -1000;
        topOffset = $(node.parentNode).offset().top;
        console.log("leftOffset2___ = " + topOffset);
    }
    
    if(searchString !== undefined && searchString !== ""){
        while (!node.textContent.includes(searchString)){
            node = node.nextSibling;
            topOffset = $(node).offset().top;
            console.log("sleftOffset3___ = " + topOffset);
        }
        $(node).highlight(searchString);
    }
    
    var page = parseInt((topOffset / window.innerHeight))
    if (page > 0){
        page = page - 1;
    }

    return parseInt(page);
}


function setBookFontSize(fontSize, pageNumber) {
    try {
        var currentVisibleNode = getFirstNodeVisible(pageNumber);
        var currentNodeCoords = getCoordFromNode(currentVisibleNode, $(currentVisibleNode).offset().left);

        $('body,table').css('font-size', fontSize);
        
        var newPageNumber = getPageFromCoords(currentNodeCoords);
        var newNumPages = getNumPages();
        window.scrollTo(window.innerWidth * newPageNumber, 0);
        return newPageNumber + '-' + newNumPages;
    } catch (err) {
        return 0 + '-' + 0;
    }
}

function getBookFontSize() {
    return $('body').css('font-size').split('px')[0];
}

function displayMode(mode) {
    switch (mode) {
        case 0:
            $(document).find('*').removeClass('night').removeClass('sepia').removeClass('grey');
            break;
        case 1:
            $(document).find('*').removeClass('night').removeClass('sepia').removeClass('grey').addClass('night');
            break;
        case 2:
            $(document).find('*').removeClass('night').removeClass('sepia').removeClass('grey').addClass('grey');
            break;
        case 3:
            $(document).find('*').removeClass('night').removeClass('sepia').removeClass('grey').addClass('sepia');
            break;
        default:
            $(document).find('*').removeClass('night').removeClass('sepia').removeClass('grey');
            break;
    };
}

function getElementsBetweenTree(start, end) {
    if ((start == null) || (end == null)) return null;
    var ancestor = getCommonAncestor(start, end);
    var before = [start];
    while (start.parentNode !== ancestor) {
        var el = start;
        while (el.nextSibling)
            before.push(el = el.nextSibling);
        start = start.parentNode;
    }
    var after = [];
    while (end.parentNode !== ancestor) {
        var el = end;
        while (el.previousSibling)
            after.push(el = el.previousSibling);
        end = end.parentNode;
    }
    after.reverse();
    while ((start = start.nextSibling) !== end)
        before.push(start);
    before.push(end);
    var result = before.concat(after);
    return result;
}

function getCommonAncestor(a, b) {
    var parents = $(a).parents().andSelf();
    while (b) {
        var ix = parents.index(b);
        if (ix !== -1)
            return b;
        b = b.parentNode;
    }
    return null;
}

function highlightSearchResult(mark, searchString) {
    isASearch = true;
    var node = getNodeFromCoord(mark, document);
    if (!node)
        node = getNodeFromCoordFix(mark, document);
    
    $(node).highlight(searchString);
}

function displayRange(doc, anchorNode, anchorOffset, focusNode, focusOffset, id, cl, coords, guid) {
    if (checkIfValid(anchorNode, anchorOffset, focusNode, focusOffset)) {
        if (anchorNode == focusNode) {
            displaySelectionText(anchorNode, anchorOffset, focusNode, focusOffset, cl, coords, guid);
        } else {
            var nodes = getElementsBetweenTree(anchorNode, focusNode);
            var str = '';
            try {
                displaySelectionText(anchorNode, anchorOffset, anchorNode, anchorNode.nodeValue.length, cl, coords,guid);
                displaySelectionText(focusNode, 0, focusNode, focusOffset, cl, coords,guid);
            } catch (err) {}
            $.each(nodes, function(index, el) {
                if ((el == anchorNode) || (el == focusNode) || ($(anchorNode).parents().index(el) != -1) || ($(focusNode).parents().index(el) != -1)) {
                    return true;
                }
                if (cl === 'highlight-yellow') {
                    (el.nodeType == 3 ? $(el).wrap('<span class="highlight-yellow"></span>') : $(el).wrapInner('<span class="highlight-yellow"></span>'));
                } else if (cl === 'highlight-underline') {
                    (el.nodeType == 3 ? $(el).wrap('<span class="highlight-underline"></span>') : $(el).wrapInner('<span class="highlight-underline"></span>'));
                } else {
                    (el.nodeType == 3 ? $(el).wrap('<span class="highlight_search"></span>') : $(el).wrapInner('<span class="highlight_search"></span>'));
                }
                
                nodeClickable = getNodeFromCoord(coords);
                
                $(nodeClickable).click(function() {
                    window.location = 'digitalbooks://clicks/' + cl + '/' + coords;
                });
            });
        }
        return true;
    } else {
        return false;
    }
}

function checkIfValid(anchorNode, anchorOffset, focusNode, focusOffset) {
    if (anchorNode.parentNode.className == 'highlight-yellow' || anchorNode.parentNode.className == 'highlight_search' || anchorNode.parentNode.className == 'highlight-underline') {
        return false;
    }
    
    if (focusNode.parentNode.className == 'highlight-yellow' || focusNode.parentNode.className == 'highlight_search' || focusNode.parentNode.className == 'highlight-underline') {
        return false;
    }
    
    return true;
}

function displaySelectionText(iniNode, iniOffset, endNode, endOffset, cl, coords, guid) {
    var selectionRange = document.createRange();
    selectionRange.setStart(iniNode, iniOffset);
    selectionRange.setEnd(endNode, endOffset);
    var highlightNode = document.createElement('span');
    if (cl === 'highlight-yellow')
        highlightNode.className = 'highlight-yellow';
    else if (cl === 'highlight-underline')
        highlightNode.className = 'highlight-underline';
    else
        highlightNode.className = 'highlight_search';
    
    highlightNode.setAttribute("id", guid);
    highlightNode.setAttribute("onclick", "callHighlightURL(this);");
    
    selectionRange.surroundContents(highlightNode);
}

function setFontFace(fontFace, pageNumber) {
    try {
        var currentVisibleNode = getFirstNodeVisible(pageNumber);
        var currentNodeCoords = getCoordFromNode(currentVisibleNode, $(currentVisibleNode).offset().left);
        $('*').css('font-family', fontFace);
        var newPageNumber = getPageFromCoords(currentNodeCoords);
        var newNumPages = getNumPages();
        window.scrollTo(window.innerWidth * newPageNumber, 0);
        return newPageNumber + '-' + newNumPages;
    } catch (err) {
        return 0 + '-' + 0;
    }
}

if (!window.NodeList.prototype.filter) {
    window.NodeList.prototype.filter = function(fun) {
        var len = this.length;
        if (typeof fun != "function")
            throw new TypeError();
        var res = new Array();
        var thisp = arguments[1];
        for (var i = 0; i < len; i++) {
            if (i in this) {
                var val = this[i];
                if (fun.call(thisp, val, i, this))
                    res.push(val);
            }
        }
        return res;
    };
}

function getPageForNodeID(nodeID){
    var nodeSelected = document.getElementById(nodeID);
    var currentNodeCoords = getCoordFromNode(nodeSelected, $(nodeSelected).offset().left);
    var nodeIDPage = getPageFromCoords(currentNodeCoords);
    window.scrollTo(window.innerWidth * nodeIDPage, 0);
    return currentNodeCoords;
}

jQuery.extend({
    highlight: function (node, re, nodeName, className) {
        if (node.nodeType === 3) {
            var match = node.data.match(re);
            if (match) {
                var highlight = document.createElement(nodeName || 'span');
                highlight.className = className || 'highlight_search';
                var wordNode = node.splitText(match.index);
                wordNode.splitText(match[0].length);
                var wordClone = wordNode.cloneNode(true);
                highlight.appendChild(wordClone);
                wordNode.parentNode.replaceChild(highlight, wordNode);
                return 1;
            }
        } else if ((node.nodeType === 1 && node.childNodes) &&
                   !/(script|style)/i.test(node.tagName) &&
                   !(node.tagName === nodeName.toUpperCase() && node.className === className)) {
            for (var i = 0; i < node.childNodes.length; i++) {
                i += jQuery.highlight(node.childNodes[i], re, nodeName, className);
            }
        }
        return 0;
    }
});

jQuery.fn.unhighlight = function (options) {
    var settings = { className: 'highlight_search', element: 'span' };
    jQuery.extend(settings, options);
    
    return this.find(settings.element + "." + settings.className).each(function () {
        var parent = this.parentNode;
        parent.replaceChild(this.firstChild, this);
        parent.normalize();
    }).end();
};

jQuery.fn.highlight = function (words, options) {
    var settings = { className: 'highlight_search', element: 'span', caseSensitive: false, wordsOnly: false };
    jQuery.extend(settings, options);
    
    if (words.constructor === String) {
        words = [words];
    }
    words = jQuery.grep(words, function(word, i){
        return word != '';
    });
    words = jQuery.map(words, function(word, i) {
        return word.replace(/[-[\]{}()*+?.,\\^$|#\s]/g, "\\$&");
    });
    
    if (words.length == 0) { return this; };
    
    var flag = settings.caseSensitive ? "" : "i";
    var pattern = "(" + words.join("|") + ")";
    if (settings.wordsOnly) {
        pattern = "\\b" + pattern + "\\b";
    }
    var re = new RegExp(pattern, flag);
    
    return this.each(function () {
        jQuery.highlight(this, re, settings.element, settings.className);
    });
};

function scrollToFirstPage() {
    scrollTo(0, 0)
}

function rectsForSelection() {
    var i = 0, j = 0;
    var allSelections = window.getSelection();
    var result = [];
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
        if (window.getSelection().empty) {
            window.getSelection().empty();
        } else if (window.getSelection().removeAllRanges) {
            window.getSelection().removeAllRanges();
        }
    } else if (document.selection) {
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
