
import SwiftUI

struct TitleHeaderView: View {
    init?(feedItem: FeedItem) {
        guard let item = feedItem as? SubtitleFeedItem else { return nil }
        title = item.text
        subtitle = item.subtext
    }

    init(title: String, subtitle: String) {
        self.title = title
        self.subtitle = subtitle
    }

    var title: String
    var subtitle: String
    
    var body: some View {
        ZStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(minHeight: 0, maxHeight: 90)
                Text(subtitle)
                    .font(.body)
                    .foregroundColor(.gray)
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 10)
    }

}

struct TitleHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        TitleHeaderView(title: "Pra você que chegou até aqui:", subtitle: "Eu vou escrever um texto grande pra ocupar bastante espaço mas eu acho que tá tudo bem porque o texto é bem grande mesmo sabe")
    }
}
