
import SwiftUI

struct ContentView: View {
    
    @State var show = false
    @State var viewState = CGSize.zero
    
    var body: some View {
        ZStack {
            Spacer()
            BlurView(style: .extraLight)
            TitleView()
                .blur(radius: show ? 20 : 0)
                .animation(.default)
            
            Text("CocoaHeads é um grupo mundial de desenvolvedores iOS (e outras tecnologias Apple). No Brasil somos o maior grupo de desenvolvedores iOS do país (com mais de 2500 participantes). \n\nOrganizamos encontros mensais (em torno de 20 até 150 participantes) em cerca de 20 cidades diferentes.\n\nA NSBrazil é a terceira edição - agora com nova marca - da CocoaHeads Conference, conferência organizada pela comunidade CocoaHeads Brasil")
                .font(.system(size: 20))
                .lineLimit(nil)
                .padding(.leading, 20)
                .padding(.trailing, 20)
                .padding(.top, 40)
            Spacer()

        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
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

