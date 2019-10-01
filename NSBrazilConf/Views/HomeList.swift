
import SwiftUI

struct HomeList: View {
    var schedules = schedulesData
    @State var showContent = false
    
    var body: some View {
        ScrollView {
            EllipseHeaderView()
            VStack(spacing: 24) {
                CocoaHeadsTitleView()
                DayDateCardView()
                MapCardView()
                TitleHeaderView()
                    .padding(.leading, 20)
                    .padding(.bottom, 16)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 30) {
                        ForEach(schedules) { item in
                            Button(action: { self.showContent.toggle() }) {
                                GeometryReader { geometry in
                                    ScheduleCardView(
                                        title: item.title,
                                        speaker: item.speaker,
                                        image: item.image,
                                        color: item.color,
                                        shadowColor: item.shadowColor
                                    )
                                        .rotation3DEffect(Angle(degrees:
                                            Double(geometry.frame(in: .global).minX - 40) / -20
                                        ), axis: (x: 0, y: 10.0, z: 0))
                                        .sheet(isPresented: self.$showContent) { ContentView() }
                                }
                                .frame(width: 246, height: 360)
                            }
                        }
                    }
                    .padding(.leading, 32)
                    Spacer()
                }
                .frame(height: 416)
                SponsorsRow()
            }
            .padding(.top, 56)
        }
    }
}

struct HomeList_Previews: PreviewProvider {
    static var previews: some View {
        HomeList()
    }
}

struct ScheduleCardView: View {
    var title = "Build an app with SwiftUI"
    var speaker = "Fulano de Tal"
    var event = "50º CocoaHeads SP"
    var image = "Illustration1"
    var color = Color.white
    var shadowColor = Color.black
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(Color.white)
                .padding(30)
                .lineLimit(6)
                .frame(width: 240)
            Text(speaker)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(Color.white)
                .padding(.leading, 30)
                .padding(.top, -16)
                .lineLimit(1)
            Spacer()
            Image(image)
                .resizable()
                .renderingMode(.original)
                .aspectRatio(contentMode: .fit)
                .frame(width: 246, height: 140)
                .padding(.bottom, 8)
        }
        .background(color)
        .cornerRadius(30)
        .frame(width: 246, height: 360)
        .shadow(color: shadowColor, radius: 20, x: 0, y: 20)
    }
}

struct Talk : Identifiable {
    var id = UUID()
    var title: String
    var descript: String
    var local: String
    var idioma: String
    var speaker: String
    var image: String
    var color: Color
    var shadowColor: Color
}

let schedulesData = [
    Talk(title: "GraphQL no iOS na Prática",
         descript: "",
         local:"PicPay",
         idioma:"BR",
         speaker: "Felipe Lefèvre Marino",
         image: "Illustration1",
         color: Color("background3"),
         shadowColor: Color("backgroundShadow3")),
    Talk(title: "Migrando seu app para SwiftUI + Combine",
         descript: "50º CocoaHeads SP",
         local:"Nubank",
         idioma:"",
         speaker: "Fernando Nazario Sousa",
         image: "Illustration2",
         color: Color("background4"),
         shadowColor: Color("backgroundShadow4")),
    Talk(title: "The Roots of Metal",
             descript: "CocoaHeads",
             local:"PicPay - SP",
             idioma:"",
             speaker: "Ricardo Rachaus",
             image: "Illustration2",
             color: Color("background5"),
             shadowColor: Color("backgroundShadow4"))

]

