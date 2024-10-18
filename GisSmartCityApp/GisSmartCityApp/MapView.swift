/*import SwiftUI
import MapKit

struct MapView: View {
    var latitude: Double
    var longitude: Double

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    
    @State private var routes: [MKRoute] = [] // Za čuvanje ruta
    @State private var travelTimeSocijalna: String = "" // Za čuvanje vremena putovanja

    private let socijalnaSluza = LocationModel(id: UUID(), coordinate: CLLocationCoordinate2D(latitude: 43.14782925402162, longitude: 20.52160149521595), title: "Socijalna služba")

    var body: some View {
        ZStack {
            Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: [socijalnaSluza]) { location in
                MapAnnotation(coordinate: location.coordinate) {
                    VStack {
                        Image(systemName: "house.fill") // Ikona kućice
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.blue)
                        Text(location.title)
                            .font(.caption)
                            .foregroundColor(.black)
                    }
                }
            }
            .onAppear {
                region.center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            }
            .mapControls {
                MapCompass()
                MapPitchToggle()
                MapUserLocationButton()
            }
            
            // Dugme za povezivanje sa osobe
            VStack {
                HStack(spacing: 15) {
                    Spacer()

                    Button(action: {
                        fetchRoute(to: socijalnaSluza.coordinate)
                    }) {
                        VStack {
                            Image(systemName: "person.fill")
                                .font(.system(size: 20))
                                .foregroundColor(Color.blue)
                            Text("Socijalna")
                                .font(.caption)
                                .foregroundColor(Color.blue)
                            Text(travelTimeSocijalna)
                                .font(.caption)
                                .foregroundColor(Color.blue)
                        }
                        .padding(.horizontal)
                        .padding(.top)
                        .background(Color.white.opacity(0.8))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }

                    Spacer()
                }
                .padding()
                Spacer()
            }
        }
    }

    private func fetchRoute(to destinationCoordinate: CLLocationCoordinate2D) {
        let request = MKDirections.Request()
        let userLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        request.source = MKMapItem(placemark: .init(coordinate: userLocation))
        request.destination = MKMapItem(placemark: .init(coordinate: destinationCoordinate))

        Task {
            if let result = try? await MKDirections(request: request).calculate() {
                routes = result.routes
                
                // Pomeranje kamere na putanju
                if let rect = result.routes.first?.polyline.boundingMapRect {
                    region.center = CLLocationCoordinate2D(latitude: rect.midY, longitude: rect.midX)
                    region.span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                }
                
                // Izračunavanje vremena putovanja
                if let travelTimeInSeconds = result.routes.first?.expectedTravelTime {
                    let travelTimeInMinutes = Int(travelTimeInSeconds / 60)
                    travelTimeSocijalna = "\(travelTimeInMinutes) min"
                }
            }
        }
    }
}

struct LocationModel: Identifiable {
    let id: UUID
    let coordinate: CLLocationCoordinate2D
    let title: String
}
*/



