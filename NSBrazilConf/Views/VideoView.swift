
import SwiftUI

struct VideoView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var videoUrl = URL(string: "https://www.cocoaheads.com.br/videos/detalhes/20")!
    
    @State var isPresented = false
    
    var body: some View {
            ZStack(alignment: .topTrailing) {
                VStack(alignment: .trailing) {
                    ZStack(alignment: .topTrailing) {
                        Button(action: { self.presentationMode.wrappedValue.dismiss() }) {
                            Text("Voltar")
                                .fontWeight(.medium)
                                .foregroundColor(Color.black)
                        }
                    }
                    .padding()
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
        VideoView()
    }
}
#endif

struct CardView: View {
    var body: some View {
        VStack {
            Text("Card back")
        }
        .frame(width: 340, height: 220)
        .background(Color.blue)
        .cornerRadius(10)
        .shadow(radius: 20)
    }
}

struct TitleView: View {
    var body: some View {
        VStack {
            HStack {
                Text("Video")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                Spacer()
            }
            Image("Illustration5")
            Spacer()
        }.padding()
    }
}

