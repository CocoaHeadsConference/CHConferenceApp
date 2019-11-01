
import SwiftUI

struct HeaderView: View {
        var body: some View {
            HStack(spacing: -15) {
                Image(decorative: "ic_logo_nsbrazil")
                .resizable()
                .frame(width: 70, height: 70)
                .cornerRadius(35)

                VStack(alignment: .leading) {
                    Text("NSBrazil")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                    Text("Conference 2019")
                }
                .padding(.leading, 24)
            }.frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 10)
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
