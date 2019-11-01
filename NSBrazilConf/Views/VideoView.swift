
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
                                .foregroundColor(Color(UIColor.label))
                        }
                    }
                    .padding(.trailing, 16)
                    .padding(.top, 12)
                    SponsorWebView(
                        url: videoUrl
                    )
                }
            }

    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        VideoView(videoUrl: URL(string: "https://google.com")!)
    }
}
#endif
