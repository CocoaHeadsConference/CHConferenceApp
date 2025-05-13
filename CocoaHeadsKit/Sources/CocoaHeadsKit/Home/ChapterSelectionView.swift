//
//  ChapterSelectionView.swift
//  CocoaHeadsKit
//
//  Created by Mauricio on 5/2/25.
//

import SwiftUI

struct ChapterSelectionView: View {

  @Binding var selectedChapter: Chapter?
  var availableChapters: [Chapter]

  var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack {
        ForEach(availableChapters) { chapter in
          ChapterSelectionButton(
            title: chapter.title,
            isSelected: selectedChapter == chapter
          )
          .onTapGesture {
            selectedChapter = chapter
          }
        }
      }
      .padding(.horizontal)
    }
  }
}

struct ChapterSelectionButton: View {
  var title: String
  var isSelected: Bool

  var body: some View {
    Text(title)
      .fontWeight(isSelected ? .regular : .thin)
      .kerning(-0.1)
      .opacity(isSelected ? 1 : 0.5)
      .padding(12)
      .background {
        if isSelected {
          RoundedRectangle(cornerRadius: 50, style: .continuous)
            .fill(.background.shadow(.inner(color: .black.opacity(0.1), radius: 3)))
            .stroke(.black.opacity(0.1), lineWidth: 1)
        }
      }
      .animation(.default.speed(1.5), value: isSelected)
  }
}

#Preview {
  @Previewable @State var selectedChapter: Chapter? = .mock("São Paulo")
  ChapterSelectionView(
    selectedChapter: $selectedChapter,
    availableChapters: [
      .mock("Belo-Horizonte"),
      .mock("Fortaleza"),
      .mock("Campinas"),
      .mock("Curitiba"),
      .mock("Rio de Janeiro"),
      selectedChapter!
    ]
  )
}
