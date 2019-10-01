
import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    
    func makeUIView(context: Context) -> MKMapView {
        MKMapView(frame: .zero)
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        let cuboCoordinate = CLLocationCoordinate2D(latitude: -23.5965911, longitude:-46.6867937)
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: cuboCoordinate, span: span)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = cuboCoordinate
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

