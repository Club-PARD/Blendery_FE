//
//  RecipeSearchOverlayView.swift
//  Blendery
//
//  Created by 박성준 on 1/6/26.
//

import SwiftUI
import UIKit

struct RecipeSearchOverlayView: View {

    @ObservedObject var searchVM: SearchBarViewModel
    var focus: FocusState<Bool>.Binding

    // ✅ 검색 결과 눌렀을 때 recipeId 넘겨주기
    var onSelect: (UUID) -> Void

    var body: some View {
        let results = searchVM.results
        let q = searchVM.text.trimmingCharacters(in: .whitespacesAndNewlines)

        return ZStack(alignment: .top) {
            Color.white
                .ignoresSafeArea()
                .onTapGesture { closeSearch() }

            if searchVM.isLoading {
                VStack { Spacer(); ProgressView(); Spacer() }
                    .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 74) }

            } else if !q.isEmpty && results.isEmpty {
                VStack {
                    Spacer()
                    Text("검색 결과가 없어요")
                        .foregroundColor(.gray)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 74) }

            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(results, id: \.recipeId) { r in
                            Button {
                                onSelect(r.recipeId)
                                closeSearch()
                            } label: {
                                SearchResultRow(title: r.title, subtitle: r.category)
                            }
                            .buttonStyle(SearchRowButtonStyle())
                            
                            Divider()
                                .padding(.leading, 16)      // ✅ 텍스트 시작점과 정확히 일치
                        }
                    }
                    .padding(.bottom, 74)
                }
            }
        }
    }

    // MARK: - Close
    private func closeSearch() {
        searchVM.close()
        focus.wrappedValue = false
        hideKeyboard()
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil, from: nil, for: nil
        )
    }
}

private struct SearchResultRow: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.headline)
            Text(subtitle).font(.subheadline).foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
