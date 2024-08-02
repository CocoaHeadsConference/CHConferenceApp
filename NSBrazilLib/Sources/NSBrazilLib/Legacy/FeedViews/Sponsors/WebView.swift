import SwiftUI
import WebKit

#if !os(watchOS)
struct WebView: UIViewRepresentable {
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

#Preview {
  WebView(url: URL(string: "https://www.apple.com")!)
}
#endif
