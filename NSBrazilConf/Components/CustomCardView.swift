import SwiftUI

struct CustomCardView<Content: View>: View {
    var height: CGFloat = 132
    var content: () -> Content
    
    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .stroke(Color.gray, lineWidth: 2)
            .frame(height: height)
            .overlay(content())
    }
}
