import Foundation
import CoreLocation
import Combine
import SwiftUI
import MapKit

enum MapStyle: String {
    case standard = "Standard"
    case hybrid = "Satelit"
}

struct GoogleMap: View {
    @StateObject private var locationManager = LocationManager()
    @State private var cameraPosition: MapCameraPosition = .region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), latitudinalMeters: 1000, longitudinalMeters: 1000))
    @State private var routes: [MKRoute] = []
    @State private var selectedMarker: String? // Track the selected marker
    @State private var mapType: MapStyle = .standard
    @State private var travelTimeSocijalna: String = "" // String for Socijalna
    private let socijalna = CLLocationCoordinate2D(latitude: 43.14779794333782, longitude: 20.52162295288741) // Koordinate za Socijalnu

    var body: some View {
        VStack {
            Picker("Map Style", selection: $mapType) {
                Text("Standard").tag(MapStyle.standard)
                Text("Satelit").tag(MapStyle.hybrid)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            ZStack {
                // Mapa
                Map(position: $cameraPosition) {
                    UserAnnotation()
                    
                    Annotation("My location", coordinate: locationManager.location?.coordinate ?? .init()) {
                        ZStack {
                            Circle()
                                .frame(width: 32, height: 32)
                                .foregroundColor(.blue.opacity(0.25))
                            Circle()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.white)
                            Circle()
                                .frame(width: 12, height: 12)
                                .foregroundColor(.blue)
                        }
                    }

                    // Custom annotations
                    Annotation("Centar za socijalni rad Novi Pazar", coordinate: socijalna) {
                        VStack {
                            Image(systemName: "house.fill") // Promenjen simbol
                                .font(.system(size: selectedMarker == "Socijalna" ? 40 : 20))
                                .foregroundColor(Color(hex: "#4A90E2"))
                            Text("Socijalna")
                                .font(.caption)
                                .foregroundColor(Color(hex: "#4A90E2"))
                        }
                        .onTapGesture {
                            selectedMarker = "Socijalna"
                        }
                    }

                    ForEach(routes, id: \.self) { route in
                        MapPolyline(route.polyline)
                            .stroke(.blue, lineWidth: 6)
                    }
                }
                .mapStyle(mapType == .standard ? .standard : .hybrid)
                .onAppear {
                    if let userLocation = locationManager.location {
                        cameraPosition = .region(MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000))
                    }
                }
                .mapControls {
                    MapCompass()
                    MapPitchToggle()
                    MapUserLocationButton()
                }
                
                // VStack sa dugmadima na vrhu
                VStack {
                    HStack(spacing: 15) {
                        Spacer()

                        Button(action: {
                            fetchRoute(to: socijalna, for: "Socijalna")
                        }) {
                            VStack {
                                Image(systemName: "house.fill") // Promenjen simbol
                                    .font(.system(size: 20))
                                    .foregroundColor(Color(hex: "#4A90E2"))
                                Text("Socijalna")
                                    .font(.caption)
                                    .foregroundColor(Color(hex: "#4A90E2"))
                                Text(travelTimeSocijalna)
                                    .font(.caption)
                                    .foregroundColor(Color(hex: "#4A90E2"))
                            }
                            .padding(.horizontal)
                            .padding(.top)
                            .background(Color.white.opacity(0.8))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }

                        Spacer()
                    }
                    .padding()
                    Spacer() // Ovo omogućava da dugmad budu na vrhu
                }
            }
        }
    }
    
    func fetchRoute(to destinationCoordinate: CLLocationCoordinate2D, for location: String) {
        guard let userLocation = locationManager.location else { return }

        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: .init(coordinate: userLocation.coordinate))
        request.destination = MKMapItem(placemark: .init(coordinate: destinationCoordinate))

        Task {
            if let result = try? await MKDirections(request: request).calculate() {
                routes = result.routes
                if let rect = result.routes.first?.polyline.boundingMapRect {
                  // cameraPosition = .rect(rect)
                }
                
                // Get travel time in minutes
                if let travelTimeInSeconds = result.routes.first?.expectedTravelTime {
                    let travelTimeInMinutes = Int(travelTimeInSeconds / 60)
                    let travelTimeString = "\(travelTimeInMinutes) min"

                    // Update specific travel time based on location
                    switch location {
                    case "Socijalna":
                        travelTimeSocijalna = travelTimeString
                    default:
                        break
                    }
                }
            }
        }
    }
}

#Preview {
    GoogleMap()
}
