
import SwiftUI

struct VideoView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var videoUrl: URL
    
    @State var isPresented = false
    
    var body: some View {
            ZStack(alignment: .topTrailing) {
                VStack(alignment: .trailing) {
                    ZStack(alignment: .topTrailing) {
                        Button(action: { self.presentationMode.wrappedValue.dismiss() }) {
                            Text("Voltar")
                                .fontWeight(.bold)
                                .foregroundStyle(.primary)
                        }
                    }
                    .padding(.trailing, 16)
                    .padding(.top, 12)
                  #if !os(watchOS)
                    WebView(
                        url: videoUrl
                    )
                  #endif
                }
            }

    }
}

struct VideoView_Previews: PreviewProvider {
    static var previews: some View {
        VideoView(videoUrl: URL(string: "https://google.com")!)
    }
}
