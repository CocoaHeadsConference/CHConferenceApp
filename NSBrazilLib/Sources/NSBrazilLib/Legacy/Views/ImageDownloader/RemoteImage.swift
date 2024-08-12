
import Foundation
import SwiftUI
import Combine
import UIKit

// TODO: Remove this in favor of AsyncImage

class RemoteImage: ObservableObject {
    
    let imageCache = NSCache<NSString, NSData>()
    
    @Published var image: UIImage?

    convenience init(imageURL: String, placeholder: String = "ic_logo_nsbrazil") {
        self.init(imageURL: URL(string: imageURL), placeholder: placeholder)
    }
    
    init(imageURL: URL?, placeholder: String = "ic_logo_nsbrazil") {
        self.image = UIImage(named: placeholder)
        load(imageUrl: imageURL)
    }

    init(imageURL: URL) {
        load(imageUrl: imageURL)
    }
    
    func load(imageUrl: URL?) {
        guard let imageUrl = imageUrl else { return }
        let key = imageUrl.absoluteString as NSString
        // check cached image
        if let cachedData = imageCache.object(forKey: key) {
            apply(data: cachedData)
            return
        } else {
            // if not, download image from url
            loadUrl(url: imageUrl)
        }
    }
    
    private func apply(data: NSData) {
        if let image = UIImage(data: (data as Data)) {
            self.image = image
        }
    }
    
    func loadUrl(url: URL) {
        let key = url.absoluteString as NSString
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print(error)
                return
            }
            DispatchQueue.main.async {
                if let imageData = data {
                    self.imageCache.setObject(imageData as NSData, forKey: key)
                    self.apply(data: imageData as NSData)
                }
            }
        }.resume()
    }

}


