
import SwiftUI
import WebKit

struct SponsorWebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView  {
        return WKWebView()
    }
        
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.load(urlRequest(url))
    }
    
    func urlRequest(_ url: URL) -> URLRequest {
        return URLRequest(url: url)
    }
}

struct SponsorWebView_Previews: PreviewProvider {
    
    static var previews: some View {
        SponsorWebView(url: URL(string: "https://www.apple.com")!)

    }
}
