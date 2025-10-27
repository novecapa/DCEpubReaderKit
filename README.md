# 📚 DCEpubReaderKit

> ⚠️ **Project status:** under active development.  
> As of now, there isn’t a fully functional version — the codebase is currently in the design, testing, and EPUB rendering engine construction phase.

**DCEpubReaderKit** is a modular Swift library designed to build digital book readers compatible with **EPUB 2 and EPUB 3**.  
It’s fully customizable, supporting highlights, annotations, bookmarks, and flexible reading themes.

Built for seamless integration into **SwiftUI** or **UIKit** projects, DCEpubReaderKit provides a solid foundation for creating professional or educational readers — without heavy dependencies or external service lock-ins.

---

## 🚀 Main Features

- ✅ **Full EPUB 2 and EPUB 3 compatibility**
  - Reads `container.xml`, `content.opf`, `toc.ncx`, and `nav.xhtml`.
  - Supports metadata, manifest, spine, and internal resources.
- 🧭 **Smooth navigation**
  - Automatically generates a table of contents and chapter structure.
  - Supports both vertical and horizontal pagination.
- 🖍️ **Highlights and annotations**
  - Select text directly within the book.
  - Persistent highlights, notes, and precise reading positions.
  - Automatic restoration of highlights and bookmarks.
- 🔖 **Bookmarks**
  - Add and manage bookmarks by chapter or page.
- ✍️ **Notes**
  - Attach custom notes or comments to selected text fragments.
- 🧩 **Visual customization**
  - Change **font family** and text size.
  - Control **text and background colors** (dark mode, sepia, night mode).
  - Includes predefined and dynamic reading themes.
- 📄 **Reading position tracking**
  - Save and restore the exact position inside the book.
- ⚡ **Full-text search**
  - Search for words or phrases across the entire book.
  - Contextual results with direct navigation.

---

## 🧱 Architecture

- 100% **Swift**
- Compatible with **SwiftUI** and **UIKit**
- Built on top of `WKWebView`
- Modular and extensible (usable as a submodule or Swift Package)

---

## 🧩 Installation

### Swift Package Manager

In Xcode:
1. Open **File → Add Packages...**
2. Add the repository URL:

```
https://github.com/novecapa/DCEpubReaderKit.git
```

or add it to your `Package.swift`:

```swift
.package(url: "https://github.com/novecapa/DCEpubReaderKit.git", from: "0.0.1")
```

---

## 🛠️ Roadmap

- [x] EPUB2 file parsing
- [ ] EPUB3 file parsing
- [ ] Vertical pagination
- [x] Horizontal pagination  
- [x] Highlights and bookmarks
- [ ] Save book states
- [ ] Cloud synchronization  
- [ ] Collaborative notes  
- [ ] Audio and interactive multimedia support (EPUB3 extended)

---

## 🤝 Contributing

Contributions are welcome — from bug reports to feature improvements or documentation updates.

1. Fork the repository  
2. Create a branch (`feature/your-feature`)  
3. Commit with clear messages  
4. Open a pull request  

---

## 💖 Donations

If this project has been helpful or you’d like to support its development, you can make a donation.

Your support helps fuel the time (and coffee ☕️) needed to keep improving **DCEpubReaderKit** 🚀

- **PayPal:** [https://paypal.me/novecapa](https://paypal.me/novecapa)

---

## ⚖️ License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

© 2025 Josep Cerdá Penadés.  
If you use this library, please acknowledge its origin:

> “This project uses DCEpubReaderKit, developed by Josep Cerdá Penadés (github.com/novecapa).”

Redistribution under a different name or without attribution is not allowed.

---

## 🧠 Inspiration

> “Reading is not just consuming text — it’s navigating another person’s mind.  
>  This framework aims to make that journey elegant and free.”

---

## 🧩 Author

**Josep Cerdá Penadés**  
Senior iOS Developer / Electronic Engineer  
📫 [github.com/novecapa](https://github.com/novecapa)
