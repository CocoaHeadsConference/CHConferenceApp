
import SwiftUI
import Combine

struct ImageViewContainer: View {
    @ObservedObject var remoteImage: RemoteImage
    var imageWidth: CGFloat?
    var imageHeight: CGFloat?
    
    init(imageURL: URL, width: CGFloat, height: CGFloat) {
        remoteImage = RemoteImage(imageURL: imageURL)
        imageWidth = width
        imageHeight = height
    }
    
    var body: some View {
        Image(
            uiImage: remoteImage.image ?? UIImage()
        )
        .resizable()
        .renderingMode(.original)
        .aspectRatio(contentMode: .fit)
        .frame(width: imageWidth, height: imageHeight)
        .padding()
    }
}



