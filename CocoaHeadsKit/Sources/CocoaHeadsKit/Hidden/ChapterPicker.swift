//
//  ChapterPicker.swift
//  CocoaHeadsKit
//
//  Created by Mauricio on 5/13/25.
//

import SwiftUI

struct ChapterPicker: View {

  @Binding var chapter: Chapter?
  @State private var chapterList: [Chapter] = []
  @State private var isLoading = false

  @Environment(\.cloudKitService) var cloudKit
  @Environment(\.dismiss) var dismiss

  var body: some View {
    List(chapterList) { chapter in
      Button(chapter.title) {
        self.chapter = chapter
        dismiss()
      }
    }
    .task {
      isLoading = true
      do {
        chapterList = try await cloudKit.fetchData()
        isLoading = false
      } catch {
        // TODO: ?
      }
    }
  }
}
