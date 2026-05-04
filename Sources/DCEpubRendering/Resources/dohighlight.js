//
//  dohighlight.js
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 4/11/25.
//

(function(){
    'use strict';
    
    /**
     * Highlight matches under a DOM node.
     * @param {HTMLElement|string} node - Element or element id string.
     * @param {string} className - CSS class applied to each highlighted span.
     * @param {string|RegExp} searchFor - String (escaped) or RegExp to search. If RegExp, will be forced global.
     * @param {number} which - Capture group to highlight (0 = whole match). Defaults to 0.
     */
    function doHighlight(node, className, searchFor, which){
        const doc = document;
        
        // Normalize node
        if (typeof node === 'string') node = doc.getElementById(node);
        if (!node) return; // nothing to do
        
        // Normalize search
        let rx;
        if (typeof searchFor === 'string') {
            // Escape special regex chars, then build case-insensitive global regex
            // https://stackoverflow.com/a/6969486
            const escaped = searchFor.replace(/[.*+?|()\[\]{}\\$^]/g, '\\$&');
            rx = new RegExp(escaped, 'ig');
        } else if (searchFor instanceof RegExp) {
            // Ensure global flag so we can iterate with exec(...)
            const flags = searchFor.flags.includes('g') ? searchFor.flags : (searchFor.flags + 'g');
            rx = new RegExp(searchFor.source, flags);
        } else {
            return; // unsupported search token
        }
        which = which || 0;
        
        // Collect text and index-node pairs using a non-recursive DFS
        // indices: [{ i: absoluteOffsetInText, n: TextNode }]
        const indices = [];
        const textChunks = [];
        let textLength = 0;
        
        // Elements considered inline: do NOT insert extra space before/after
        const INLINE_TAG_RE = /^(a|b|basefont|bdo|big|em|font|i|s|small|span|strike|strong|su[bp]|tt|u)$/i;
        const SKIP_TAG_RE = /^(script|style)$/i;
        
        let cur = node;
        let iNode = 0;
        let nNodes = node.childNodes.length;
        const stack = [];
        
        // Iterative tree walk
        for(;;){
            while (iNode < nNodes) {
                const child = cur.childNodes[iNode++];
                if (!child) continue;
                
                if (child.nodeType === 3) { // TEXT_NODE
                    indices.push({ i: textLength, n: child });
                    const t = child.nodeValue || '';
                    textChunks.push(t);
                    textLength += t.length;
                } else if (child.nodeType === 1) { // ELEMENT_NODE
                    if (SKIP_TAG_RE.test(child.tagName)) {
                        continue; // skip script/style
                    }
                    // Add a natural word boundary when leaving non-inline elements
                    if (!INLINE_TAG_RE.test(child.tagName)) {
                        textChunks.push(' ');
                        textLength += 1;
                    }
                    const kids = child.childNodes.length;
                    if (kids) {
                        // save parent state
                        stack.push({ node: cur, len: nNodes, idx: iNode });
                        // descend
                        cur = child;
                        nNodes = kids;
                        iNode = 0;
                    }
                }
            }
            if (!stack.length) break;
            const state = stack.pop();
            cur = state.node;
            nNodes = state.len;
            iNode = state.idx;
        }
        
        if (!indices.length) return; // no text to highlight
        
        // Build the full text and append sentinel in indices
        const fullText = textChunks.join('');
        indices.push({ i: fullText.length }); // sentinel (no node)
        
        // Helper: binary search to find entry covering absolute position
        function findEntry(pos){
            let lo = 0, hi = indices.length - 1; // last entry is sentinel; safe bounds
            while (lo < hi) {
                const mid = (lo + hi) >> 1;
                if (pos < indices[mid].i) hi = mid;
                else if (pos >= indices[mid + 1].i) lo = mid + 1;
                else return mid;
            }
            return lo;
        }
        
        // Iterate regex matches
        let m;
        while ((m = rx.exec(fullText))) {
            if (m.length <= which || !m[which]) continue;
            
            // Compute absolute start/end for the chosen group
            let start = m.index;
            for (let g = 1; g < which; g++) start += (m[g] || '').length;
            const end = start + m[which].length;
            
            // Walk through affected text nodes and wrap ranges
            let entryIdx = findEntry(start);
            while (entryIdx < indices.length - 1) { // stop before sentinel
                const entry = indices[entryIdx];
                const nextI = indices[entryIdx + 1].i;
                const textNode = entry.n;
                // Safety: if the text node was removed by a previous wrap (extremely rare), skip
                if (!textNode || !textNode.parentNode) { entryIdx++; continue; }
                
                const localStart = Math.max(0, start - entry.i);
                const localEnd = Math.min(end, nextI) - entry.i;
                if (localEnd <= 0) break; // current entry is before match
                
                const nodeText = textNode.nodeValue || '';
                const before = localStart > 0 ? nodeText.slice(0, localStart) : '';
                const middle = nodeText.slice(localStart, localEnd);
                const after  = localEnd < nodeText.length ? nodeText.slice(localEnd) : '';
                
                const parent = textNode.parentNode;
                const nextSibling = textNode.nextSibling;
                
                // Replace current text node with optional before + <span class=...>middle</span> + optional after
                if (before) {
                    textNode.nodeValue = before;
                } else {
                    parent.removeChild(textNode);
                }
                
                const mark = doc.createElement('span');
                mark.className = className;
                mark.appendChild(doc.createTextNode(middle));
                parent.insertBefore(mark, nextSibling);
                
                if (after) {
                    const tail = doc.createTextNode(after);
                    parent.insertBefore(tail, nextSibling);
                    // Maintain indices for subsequent intersections within this same match
                    indices[entryIdx] = { n: tail, i: end };
                }
                
                entryIdx++;
                if (end <= nextI) break; // this match segment is complete in current entry
            }
        }
    }
    
    // Expose globally (backward compatibility with original file)
    window.doHighlight = doHighlight;
})();
