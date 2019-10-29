
import SwiftUI
import Combine

struct ImageViewContainer: View {
    @ObservedObject var remoteImage: RemoteImage
    var imageWidth: CGFloat?
    var imageHeight: CGFloat?
    var hasPadding: Bool
    var contentMode: ContentMode
    
    init(imageURL: URL,
         width: CGFloat? = nil,
         height: CGFloat? = nil,
         hasPadding: Bool = true,
         contentMode: ContentMode = .fit) {
        remoteImage = RemoteImage(imageURL: imageURL)
        imageWidth = width
        imageHeight = height
        self.hasPadding = hasPadding
        self.contentMode = contentMode
    }
    
    var body: some View {
        Image(uiImage: remoteImage.image ?? UIImage())
        .resizable()
        .renderingMode(.original)
        .aspectRatio(contentMode: self.contentMode)
        .frame(width: imageWidth, height: imageHeight)
        .padding(hasPadding ? 10 : 0 )
    }

}
