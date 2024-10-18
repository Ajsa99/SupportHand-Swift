import SwiftUI
import MapKit

struct UserData: Decodable, Identifiable {
    let id: Int
    let firstName: String
    let lastName: String
    let email: String // Dodajte druge relevantne informacije po potrebi
}

struct MessageView: View {
    let notificationId: Int
    @State private var description: String = ""
    @State private var latitude: String = ""
    @State private var longitude: String = ""
    @State private var idUser: Int = 0
    @State private var userFirstName: String = ""
    @State private var userLastName: String = ""
    @State private var userEmail: String = "" // Dodajemo email
    @State private var userType: String = "" // Tip prijavljenog korisnika
    @State private var errorMessage: String?
    @State private var isLoading: Bool = true
    @State private var locationAddress: String = "Učitavanje adrese..."
    @State private var users: [UserData] = [] // Lista korisnika

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#EBE5F3")
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack {
                        Image(systemName: "house.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.red)
                        
                        if isLoading {
                            ProgressView("Učitavanje...")
                                .progressViewStyle(CircularProgressViewStyle())
                                .padding()
                        } else if let errorMessage = errorMessage {
                            Text("Greška: \(errorMessage)")
                                .foregroundColor(.red)
                                .padding()
                        } else {
                            VStack(alignment: .leading, spacing: 10) {
                                Divider()
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Lokacija:")
                                        .font(.headline)
                                        .foregroundColor(.black)
                                    Text(locationAddress)
                                        .font(.subheadline)
                                    
                                    // Prikaz mape sa lokacijom osobe
                                    if let lat = Double(latitude), let lon = Double(longitude) {
                                        MapView(latitude: lat, longitude: lon)
                                            .frame(height: 200) // Prilagodite visinu mape
                                    } else {
                                        Text("Lokacija nije dostupna.")
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Divider().padding(.vertical, 10)
                                    
                                    Text("Opis:")
                                        .font(.headline)
                                        .foregroundColor(.black)
                                    Text(description.isEmpty ? "Nema opisa" : description)
                                        .font(.subheadline)
                                    
                                    // Prikaz dodatnih podataka ako je prijavljen korisnik Admin
                                    if userType == "Admin" {
                                        Divider().padding(.vertical, 10)
                                        Text("Informacije o korisniku:")
                                            .font(.headline)
                                            .foregroundColor(.black)
                                        Text("Ime: \(userFirstName.isEmpty ? "Nepoznato" : userFirstName) \(userLastName.isEmpty ? "" : userLastName)")
                                            .font(.subheadline)
                                        Text("Email: \(userEmail.isEmpty ? "Nepoznato" : userEmail)")
                                            .font(.subheadline)
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                            .padding()
                        }
                    }
                    .navigationBarTitleDisplayMode(.inline)
                }
            }
            .onAppear(perform: fetchNotification)
        }
    }
    
    private func fetchNotification() {
        let urlString = "http://alarmfire-001-site1.dtempurl.com/NotificationHelp/GetNotificationHelp\(notificationId)"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let username = "11196448"
        let password = "60-dayfreetrial"
        let loginString = "\(username):\(password)"
        let loginData = loginString.data(using: .utf8)!
        let base64LoginString = loginData.base64EncodedString()
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Error fetching data: \(error.localizedDescription)"
                    self.isLoading = false
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "No data received"
                    self.isLoading = false
                }
                return
            }

            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    DispatchQueue.main.async {
                        self.description = jsonResponse["description"] as? String ?? ""
                        self.latitude = jsonResponse["latitude"] as? String ?? ""
                        self.longitude = jsonResponse["longitude"] as? String ?? ""
                        self.idUser = jsonResponse["idUser"] as? Int ?? 0
                        self.isLoading = false

                        // Učitaj tip korisnika iz UserDefaults
                        self.userType = UserDefaults.standard.string(forKey: "userType") ?? ""
                        print("Tip korisnika: \(self.userType)") // Ispis tipa korisnika

                        if let lat = Double(self.latitude), let lon = Double(self.longitude) {
                            fetchLocationAddress(latitude: lat, longitude: lon)
                        }

                        // Učitaj podatke o korisniku samo ako je tip Admin
                        if self.userType == "Admin" {
                            fetchUsers()
                        }
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Decoding error: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }.resume()
    }

    private func fetchUsers() {
        print("Fetching users...")
        let urlString = "http://alarmfire-001-site1.dtempurl.com/User/GetUsers"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let username = "11196448"
        let password = "60-dayfreetrial"
        let loginString = "\(username):\(password)"
        let loginData = loginString.data(using: .utf8)!
        let base64LoginString = loginData.base64EncodedString()
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Error fetching users: \(error.localizedDescription)"
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "No user data received"
                }
                return
            }

            do {
                let decodedUsers = try JSONDecoder().decode([UserData].self, from: data)
                DispatchQueue.main.async {
                    self.users = decodedUsers
                    
                    // Pronađi korisnika koji je postavio obaveštenje
                    if let user = users.first(where: { $0.id == self.idUser }) {
                        self.userFirstName = user.firstName
                        self.userLastName = user.lastName
                        self.userEmail = user.email // Dodajemo email korisnika
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "User decoding error: \(error.localizedDescription)"
                }
            }
        }.resume()
    }

    private func fetchLocationAddress(latitude: Double, longitude: Double) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let geocoder = CLGeocoder()

        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.locationAddress = "Greška pri dobijanju adrese: \(error.localizedDescription)"
                } else if let placemark = placemarks?.first {
                    self.locationAddress = placemark.name ?? "Nepoznata lokacija"
                }
            }
        }
    }
}

struct MapView: View {
    var latitude: Double
    var longitude: Double

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
    )

    var body: some View {
        Map(coordinateRegion: $region, showsUserLocation: true)
            .onAppear {
                region.center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            }
            .frame(height: 200) // Prilagodite visinu mape
    }
}


struct LocationModel: Identifiable {
    let id: UUID
    let coordinate: CLLocationCoordinate2D
    let title: String
}

#Preview {
    MessageView(notificationId: 1) // Primer za preview
}
