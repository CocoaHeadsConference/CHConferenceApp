//
//  CallToAction+ButtonStyle.swift
//  CocoaHeadsKit
//
//  Created by Mauricio on 4/28/25.
//

import SwiftUI

struct CallToAction: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    InnerButtonView(configuration: configuration)
  }

  private struct InnerButtonView: View {
    let configuration: ButtonStyle.Configuration
    @Environment(\.isEnabled) private var isEnabled: Bool
    var body: some View {
      configuration
        .label
        .font(.system(size: 20))
        .bold()
        .kerning(-1)
        .foregroundStyle(.white)
        .padding()
        .frame(maxWidth: .infinity)
        .background {
          RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(
              isEnabled
                ? LinearGradient(
                  colors: [
                    Color.buttonTopGradient,
                    Color.buttonBottomGradient
                  ],
                  startPoint: .top,
                  endPoint: .bottom
                )
                : LinearGradient(
                  colors: [
                    .gray.opacity(0.8),
                    .black.opacity(0.25)
                  ],
                  startPoint: .top,
                  endPoint: .bottom)
            )
            .stroke(Color.buttonBottomGradient)
            .overlay {
              if configuration.isPressed {
                Color.black.opacity(0.2)
              }
            }
            .mask {
              RoundedRectangle(
                cornerRadius: 20,
                style: .continuous
              )
            }
            // FIXME: Cascaded shadows are causing HORRIBLE perf
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            .shadow(color: .black.opacity(0.09), radius: 10, x: 0, y: 10)
            .shadow(color: .black.opacity(0.05), radius: 13, x: 0, y: 21)
            .shadow(color: .black.opacity(0.01), radius: 15, x: 0, y: 38)
            .animation(.bouncy, value: isEnabled)
        }
    }
  }
}

#Preview {
  @Previewable @State var isEnabled = true
  VStack {
    Toggle("isEnabled", isOn: $isEnabled)
    Button("Botão") {}
      .buttonStyle(CallToAction())
      .disabled(!isEnabled)
  }
  .padding()
}
