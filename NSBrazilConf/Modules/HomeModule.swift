import SwiftUI

struct HomeModule: View {
  @State private var isShowingSheet = false
  @State private var rating = 3

  var body: some View {
    NavigationStack {
      ScrollView {
        Text("62 Cocoaheads São Paulo - OLX")
          .font(.title2)
          .frame(
            maxWidth: .infinity,
            alignment: .leading
          )
          .foregroundStyle(Color.gray)

        Button(
          "Conecte se ao Wifi", systemImage: "wifi",
          action: {
            // MARK: call to NEHotspotConfigurationManager
          }
        )
        .buttonStyle(CustomButton())
        .padding([.top, .bottom], 16)

        // SPEAKERS
        TitleSectionView(title: "Speakers")

        TabView {
          Text("Luis Filipe Alves de Oliveira\nSwift Testing")
            .font(.title3)
            .frame(alignment: .center)

          Text("Vinicius Carvalho\nSwift Testing")
            .font(.title3)
            .frame(alignment: .center)
        }
        .frame(height: 132)
        .background(Color("background"))
        .cornerRadius(16)
        .tabViewStyle(.page)

        // CONHEÇA O COCOAHEADS
        TitleSectionView(title: "Conheça o cocoaheads")

        CustomCardView {
          Image("cocoaheads_logo")
            .resizable()
            .renderingMode(.original)
        }
        .onTapGesture {
          // MARK: call to MFMessageComposeViewController
        }

        // GOSTOU DO EVENTO
        TitleSectionView(title: "Gostou do eventos")

        CustomCardView {
          VStack {
            Text("Sua avaliação é muito importante para nós!")
              .multilineTextAlignment(.center)
              .padding([.leading, .trailing, .bottom], 16)

            RatingView(rating: $rating)
          }
        }
      }
      .navigationTitle("CocoaHeads")
      .padding(16)
    }
  }
}

#Preview {
  HomeModule()
}
