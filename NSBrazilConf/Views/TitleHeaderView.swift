
import SwiftUI

struct TitleHeaderView: View {
    var body: some View {
        ZStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Enquanto a NSBrazil não chega")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .lineLimit(2)
                Text("Assista os vídeos das edições anteriores")
                    .font(.body)
                    .foregroundColor(.gray)
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 24)

    }

}

struct TitleHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        TitleHeaderView()
    }
}
