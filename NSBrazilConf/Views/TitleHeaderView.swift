
import SwiftUI

struct TitleHeaderView: View {
    var body: some View {
        ZStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Enquanto a NSBrazil não chega")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .lineLimit(4)
                Text("Assista os vídeos das edições anteriores")
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, minHeight: 160)
        }
    }
}

struct TitleHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        TitleHeaderView()
    }
}
