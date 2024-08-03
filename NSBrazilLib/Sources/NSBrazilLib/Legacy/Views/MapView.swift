
import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    
    let location: CLLocationCoordinate2D
    let annotationTitle: String
    let span: MKCoordinateSpan
    
    func makeUIView(context: Context) -> MKMapView {
        MKMapView(frame: .zero)
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        let region = MKCoordinateRegion(center: location, span: span)
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = annotationTitle
        uiView.isUserInteractionEnabled = false
        uiView.addAnnotation(annotation)
        uiView.setRegion(region, animated: true)
    }

}

//-23.5965911, -46.6867937
struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(location: CLLocationCoordinate2D(), annotationTitle: "", span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
    }
}

