
import SwiftUI

struct NSBrazilTitleView: View {
    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(alignment: .leading) {
                Text("NSBrazil")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .foregroundColor(Color.black)
                Text("Conference 2019")
                    .foregroundColor(Color.yellow)

            }
        }
    }
}

struct NSBrazilTitleView_Previews: PreviewProvider {
    static var previews: some View {
        NSBrazilTitleView()
    }
}
