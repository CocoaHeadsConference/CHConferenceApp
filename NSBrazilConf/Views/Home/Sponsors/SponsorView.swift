
import SwiftUI

struct SponsorView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var sponsorUrl: URL
    
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
                        url: sponsorUrl
                    )
                }
            }

    }
}

