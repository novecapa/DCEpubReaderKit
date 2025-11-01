//
//  ReaderChapterView.swift
//  DCEpubReaderKit
//
//  Created by Josep Cerdá Penadés on 16/10/25.
//

import SwiftUI

extension Notification.Name {
    static let chapterShouldScrollToLastPage = Notification.Name("chapterShouldScrollToLastPage")
}

struct DCReaderView: View {

    private enum Constants {
        static let frameSize: CGFloat = 32
    }

    @Environment(\.dismiss) var dismiss

    @ObservedObject var viewModel: DCReaderViewModel

    init(viewModel: DCReaderViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            viewModel.backgroundColor
                .ignoresSafeArea(edges: .all)
            TabView(selection: $viewModel.currentSelection) {
                ForEach(0..<viewModel.bookSpines.count, id: \.self) { idx in
                    Group {
                        if let chapterURL = viewModel.chapterURL(for: idx) {
                            VStack {
                                DCChapterWebView(
                                    chapterURL: chapterURL,
                                    readAccessURL: viewModel.opfDirectoryURL,
                                    spineIndex: idx
                                ) { action in
                                    switch action {
                                    case .totalPageCount(let count, let spineIndex):
                                        if spineIndex == viewModel.currentSelection {
                                            viewModel.totalPages = count
                                            if viewModel.currentPage > count {
                                                viewModel.currentPage = count
                                            }
                                        }
                                    case .currentPage(index: let index,
                                                      totalPages: let totalPages,
                                                      spineIndex: let spineIndex):
                                        if spineIndex == viewModel.currentSelection {
                                            viewModel.totalPages = totalPages
                                            viewModel.currentPage = index
                                        }
                                    case .canTouch(let enabled):
                                        viewModel.canTouch = enabled
                                    case .coordsFirstNodeOfPage(orientation: _,
                                                                spineIndex: let spineIndex,
                                                                coords: let coords):
                                        if spineIndex == viewModel.currentSelection {
                                            // TODO: - Save book position
                                            print("chapterFile: \(chapterURL.lastPathComponent) coords: \(coords)")
                                        }
                                    }
                                }
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .id(viewModel.readerConfigId(for: idx))
                                if viewModel.totalPages > 1 {
                                    Text(viewModel.pageInfo)
                                        .font(.system(size: 14))
                                        .foregroundStyle(viewModel.textColor)
                                        .opacity(viewModel.canTouch ? 1 : 0)
                                        .animation(.easeInOut(duration: 0.25),
                                                   value: viewModel.canTouch)
                                }
                            }

                        } else {
                            Text("Unable to resolve chapter at spine index \(idx).")
                                .foregroundStyle(viewModel.textColor)
                                .padding()
                        }
                    }
                    .tag(idx)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .navigationBarBackButtonHidden(true)
            .toolbar {
                toolbarView
            }
            .sheet(isPresented: $viewModel.showSettings) {
                sheetSettingsView
            }
        }
        .onChange(of: viewModel.currentSelection) { _ in
            defer {
                viewModel.previousSelection = viewModel.currentSelection
            }
            NotificationCenter.default.post(
                name: .chapterShouldScrollToLastPage,
                object: nil,
                userInfo: viewModel.currentSelection < viewModel.previousSelection ? ["spineIndex": viewModel.currentSelection] : nil
            )
        }
    }
}

#if DEBUG

 #Preview {
     NavigationStack {
         DCReaderViewBuilderMock().build(.mock, spineIndex: 0)
     }
 }

#endif
