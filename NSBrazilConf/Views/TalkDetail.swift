
import SwiftUI

struct TalkDetail: View {
    var talk: TalkModel?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 16) {
                        Image(talk?.speakerImage ?? "ic_logo_nsbrazil")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .background(Color("background"))
                        .cornerRadius(40)
                        VStack(spacing: 8) {
                            Text(talk?.title ?? "")
                                .font(.headline)
                                .lineLimit(4)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            Text(talk?.speaker ?? "")
                                .font(.system(size: 14))
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                .lineLimit(2)
                        }
                    }
                
                Text(talk?.summary ?? "")
                    .font(.body)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    .lineLimit(nil)
                    
                Text("\(talk?.date ?? "")")
                    .font(.body)
                    .foregroundColor(Color.gray)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    .lineLimit(nil)
                    
                Text(talk?.idioma ?? "")
                    .font(.body)
                    .foregroundColor(Color.gray)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    .lineLimit(nil)
                    
                    Spacer()
                    
                }
            .padding(24)
        }
    }
}

struct UpdateDetail_Previews: PreviewProvider {

    static var previews: some View {
        TalkDetail()
    }
}
