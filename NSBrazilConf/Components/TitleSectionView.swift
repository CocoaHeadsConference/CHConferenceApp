import SwiftUI

struct TitleSectionView: View {
    private let title: String
    
    init(title: String) {
        self.title = title
    }
    
    var body: some View {
        Text(title)
            .font(.title3)
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
            .padding([.top, .bottom], 16)
    }
}

#Preview {
    TitleSectionView(title: "Speakers")
}
