
import SwiftUI

struct Home: View {
    var menu = menuData
    var feedViewModel: FeedViewModel
    @State var show = false
    @State var showProfile = false
    
    var body: some View {
        ZStack {
            
            HomeList(feedViewModel: feedViewModel)
                .blur(radius: show ? 20 : 0)
                .scaleEffect(showProfile ? 0.95 : 1)
                .animation(.default)
            
            ContentView()
                .background(Color.white)
                .cornerRadius(30)
                .shadow(radius: 20)
                .animation(.spring())
                .offset(y: showProfile ? 0 : UIScreen.main.bounds.height)

        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home(feedViewModel: FeedViewModel())
    }
}

struct MenuRow: View {
    var image = "creditcard"
    var text = "My Account"
    var body: some View {
        HStack {
            Image(systemName: image)
                .imageScale(.large)
                .foregroundColor(Color("icons"))
                .frame(width: 32, height: 32)
            Text(text)
                .font(.headline)
            Spacer()
        }
    }
}

struct Menu : Identifiable {
    var id = UUID()
    var title: String
    var icon: String
}

let menuData = [
    Menu(title: "My Account", icon: "person.crop.circle"),
    Menu(title: "Billing", icon: "creditcard"),
    Menu(title: "Team", icon: "person.2"),
    Menu(title: "Sign out", icon: "arrow.uturn.down")
]

struct MenuView: View {
    var menu = menuData
    @Binding var show: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(menu) { item in
                MenuRow(image: item.icon, text: item.title)
            }
            Spacer()
        }
        .padding(.top, 20)
        .padding(30)
        .frame(minWidth: 0, maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(30)
        .padding(.trailing, 60)
        .rotation3DEffect(Angle(degrees: show ? 0 : 60), axis: (x: 0, y: 10, z: 0))
        .shadow(radius: 20)
        .animation(.default)
        .offset(x: show ? 0 : -UIScreen.main.bounds.width)
        .onTapGesture {
            self.show.toggle()
        }
    }
}

struct CircleButton: View {
    var icon: String = "person.crop.circle"
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Color.black)
        }
        .frame(width: 44, height: 44)
        .background(Color.white)
        .cornerRadius(30)
        .shadow(color: Color("buttonShadow"), radius: 10, y: 10)
    }
}

struct MenuButton: View {
    @Binding var show: Bool
    var body: some View {
        ZStack(alignment: .topLeading) {
            Button(action: { self.show.toggle() }) {
                HStack {
                    Spacer()
                    Image(systemName: "list.dash")
                        .foregroundColor(Color.black)
                }
                .padding(.trailing, 20)
                .frame(width: 90, height: 60)
                .background(Color.white)
                .cornerRadius(30)
                .shadow(color: Color("buttonShadow"), radius: 10, x: 0, y: 10)
            }
            Spacer()
        }
        
    }
}

struct MenuRight: View {
    @Binding var show: Bool
    var body: some View {
        ZStack(alignment: .topTrailing) {
            HStack(spacing: 12) {
                Button(action: { self.show.toggle() }) {
                    CircleButton(icon: "text.quote")
                }
                Button(action: { }) {
                    CircleButton(icon: "bell")
                }
            }
            Spacer()
        }
    }
}
