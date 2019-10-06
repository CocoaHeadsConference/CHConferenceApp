
import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    
    var location: LocationModel?
    
    func makeUIView(context: Context) -> MKMapView {
        MKMapView(frame: .zero)
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        guard let coordinate = location?.coordinate else  { return }
        let placeCoordinate = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: placeCoordinate, span: span)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = placeCoordinate
        annotation.title = "Cubo Itaú, São Paulo"
        
        uiView.addAnnotation(annotation)
        uiView.setRegion(region, animated: true)
    }

}

//-23.5965911, -46.6867937
struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}

