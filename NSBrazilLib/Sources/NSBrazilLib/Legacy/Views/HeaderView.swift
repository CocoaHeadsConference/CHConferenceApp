import SwiftUI

struct HeaderView: View {
  var body: some View {
    HStack {
      Image(decorative: "ic_logo_nsbrazil")
        .resizable()
        .frame(width: 70, height: 70)
        .cornerRadius(35)

      Text("NSBrazil")
        .font(Font.largeTitle.weight(.heavy))

      Spacer()
    }
    .padding()
  }
}

struct EllipseView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      HeaderView().previewDevice(PreviewDevice(rawValue: "iPhone 11"))
      HeaderView().previewDevice(PreviewDevice(rawValue: "iPad Pro (11-inch)"))
    }
  }
}
