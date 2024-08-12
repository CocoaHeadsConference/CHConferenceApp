import SwiftUI

struct CustomButton: ButtonStyle {
    let color = Color("background10")
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(
                minWidth: 0,
                maxWidth: .infinity
            )
            .foregroundColor(.white)
            .background(RoundedRectangle(cornerRadius: 8.0).fill(color)
            )
    }
}
