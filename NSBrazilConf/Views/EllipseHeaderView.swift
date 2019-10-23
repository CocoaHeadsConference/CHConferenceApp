
import SwiftUI

struct EllipseHeaderView: View {
    var body: some View {
        ZStack(alignment: .topLeading) {
            Ellipse()
                .size(width: 812, height: 600)
                .foregroundColor(Color("chColor"))
                .frame(maxWidth: .infinity, minHeight: 30)
                .padding(.top, -402)
                .padding(.horizontal, -195)
            VStack(alignment: .leading) {
                Text("NSBrazil")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .foregroundColor(Color.white)
                Text("Conference 2019")
                    .foregroundColor(Color.yellow)
            }
            .padding(.leading, 24)
            .padding(.top, 88)
        }
    }
}

struct EllipseView_Previews: PreviewProvider {
    static var previews: some View {
        EllipseHeaderView()
    }
}
