
import SwiftUI

struct TalkDetail: View {
    
    var title = "SwiftUI"
    var text = "@twiiter"
    var image = "Illustration1"
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                    HStack(spacing: 16) {
                      Image(image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .background(Color("background"))
                        .cornerRadius(40)
                        VStack(spacing: 8) {
                            Text(title)
                                .font(.title)
                                .fontWeight(.heavy)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            Text(text)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                .lineLimit(nil)
                        }
                    }
                    
                    Text("Titulo da talk")
                        .font(.headline)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .lineLimit(nil)
                    
                    Text("[Descrição] - The Text view shows read-only text that can be modified in many ways. It wraps automatically. If you want to limit the text wrapping")
                        .font(.body)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .lineLimit(nil)
                    
                    Text("Dia e Hora")
                        .font(.body)
                        .foregroundColor(Color.gray)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .lineLimit(nil)
                    
                    Text("Idioma")
                    .font(.body)
                    .foregroundColor(Color.gray)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    .lineLimit(nil)
                    
                    Spacer()
                    
                }
            .padding(30)
        }
    }
}

struct UpdateDetail_Previews: PreviewProvider {

    static var previews: some View {
        TalkDetail()
    }
}
