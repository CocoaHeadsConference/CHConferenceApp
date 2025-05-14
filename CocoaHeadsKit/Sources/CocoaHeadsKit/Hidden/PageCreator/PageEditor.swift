//
//  PageEditor.swift
//  CocoaHeadsKit
//
//  Created by Mauricio on 5/14/25.
//

import SwiftUI

struct PageEditor: View {

  let slug: String
  @Environment(\.cloudKitService) private var cloudKit
  @State private var identifier = ""
  @State private var ui: [UI] = []
  @State private var originalUI: [UI] = []
  @State private var isEditingContent = false
  @State private var isLoading = false
  @State private var error = ""

  var body: some View {
    Form {
      Section {
        Text("slug: \(slug)")
        Button("Edit UI") {
          isEditingContent = true
        }
        NavigationLink("Preview locally before saving") {
          PageRenderer(ui: ui)
        }
      }
      .onChange(of: ui) {
        // I don't have enough time right now to debug this but
        // if you remove this `onChange` call, the UI does not update
        // and as such, you cannot update the Page.
        print("ui changed")
      }

      if !error.isEmpty {
        Section("Error") {
          Text(error)
        }
      }
    }
    .sheet(isPresented: $isEditingContent) {
      UIOrderingEditor(ui: $ui)
    }
    .toolbar {
      Button {
        Task {
          await saveData()
        }
      } label: {
        if isLoading {
          ProgressView()
        } else {
          Text("Save")
        }
      }
      .disabled(ui == originalUI)
    }
    .task {
      await fetchData()
    }
  }

  func fetchData() async {
    error = ""
    isLoading = true
    do {
      let (identifier, ui) = try await cloudKit.fetchPageAndID(slug: slug)
      self.identifier = identifier
      self.originalUI = ui
      self.ui = ui
    } catch {
      self.error = error.localizedDescription
    }
    isLoading = false
  }

  func saveData() async {
    error = ""
    isLoading = true
    do {
      try await cloudKit.updatePage(id: identifier, slug: slug, ui: ui)
    } catch {
      print(error)
      self.error = error.localizedDescription
    }
    isLoading = false
  }
}
