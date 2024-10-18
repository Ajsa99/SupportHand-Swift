import SwiftUI
import CoreLocation

struct Settings: View {
    @State private var isLoggedIn = false
    @State private var userId: Int?
    @State private var userType: String = ""
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var phone: Int?
    @State private var email: String = ""
    @State private var naziv: String = ""
    @State private var latitude: String = ""
    @State private var longitude: String = ""
    @State private var locationAddress: String = ""
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#EBE5F3")
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    if isLoggedIn {
                        // Korisnička sekcija
                        VStack {
                            Image(systemName: "person.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 70, height: 70)
                                .foregroundColor(Color(hex: "#4A90E2"))
                                .padding(30)
                                .background(Circle().fill(Color.white))
                                .shadow(radius: 5)

                            Text(userType == "Admin" ? naziv : "\(firstName) \(lastName)")
                                .font(.headline)
                                .padding(.top, 10)

                            Divider() // Linija ispod korisničkih informacija
                                .padding(.horizontal, 30)
                                .padding(.vertical, 15)

                            // Informacije o korisniku
                            VStack(alignment: .leading, spacing: 10) {
                                if userType == "Admin" {
                                    Text("Naziv: \(naziv)")
                                        .font(.subheadline)
                                    if !latitude.isEmpty && !longitude.isEmpty {
                                        Text("Adresa: \(locationAddress)")
                                            .font(.subheadline)
                                    }
                                } else {
                                    Text("Ime: \(firstName)")
                                        .font(.subheadline)
                                    Text("Prezime: \(lastName)")
                                        .font(.subheadline)
                                    Text("Broj telefona: \(formattedPhoneNumber(phone))")
                                        .font(.subheadline)
                                }
                                Text("Email: \(email)")
                                    .font(.subheadline)

                                // Dugme "Odjavi se"
                                Button(action: {
                                    logoutUser()
                                }) {
                                    Text("Odjavi se")
                                        .font(.system(size: 18))
                                        .foregroundColor(.black)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.white)
                                        .cornerRadius(50)
                                        .shadow(color: .gray, radius: 4, x: 0, y: 5)
                                }
                                .padding(.top)
                            }
                            .padding(.horizontal, 40)
                        }
                        .padding(.bottom, 30)
                    } else {
                        // Prikaz dugmadi za prijavu i registraciju
                        VStack {
                            NavigationLink(destination: Login()) {
                                Text("Prijavi se")
                                    .font(.system(size: 18))
                                    .foregroundColor(Color.black)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color(hex: "#EDEA53"))
                                    .cornerRadius(50)
                                    .shadow(color: .gray, radius: 4, x: 0, y: 5)
                            }
                            .padding(.top)

                            NavigationLink(destination: Registration()) {
                                Text("Registruj se")
                                    .font(.system(size: 18))
                                    .foregroundColor(Color.black)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.white)
                                    .cornerRadius(50)
                                    .shadow(color: .gray, radius: 4, x: 0, y: 5)
                            }
                            .padding(.top)
                        }
                        .padding(.horizontal, 40)
                    }

                    Spacer() // Održavanje prostora ispod
                }
                .padding()
            }
            .onAppear {
                isLoggedIn = UserDefaults.standard.string(forKey: "authToken") != nil
                userId = UserDefaults.standard.integer(forKey: "userId")
                userType = UserDefaults.standard.string(forKey: "userType") ?? ""

                if let userId = userId {
                    fetchUserData(userId: userId)
                }
            }
        }
    }

    private func formattedPhoneNumber(_ number: Int?) -> String {
        guard let number = number, number > 0 else {
            return "" // Ako je broj prazan ili negativan, vraća prazan string
        }
        
        let phoneString = String(number)
        var formatted = "+381 "

        for (index, character) in phoneString.enumerated() {
            if index > 0 && index % 3 == 0 {
                formatted += "-"
            }
            formatted += String(character)
        }

        return formatted
    }

    private func logoutUser() {
        // Logika za odjavu
        UserDefaults.standard.removeObject(forKey: "authToken")
        UserDefaults.standard.removeObject(forKey: "userId")
        UserDefaults.standard.removeObject(forKey: "userType")
        isLoggedIn = false
    }

    private func fetchUserData(userId: Int) {
        // Logika za učitavanje podataka o korisniku
        let urlString: String
        if userType == "Admin" {
            urlString = "http://alarmfire-001-site1.dtempurl.com/User/GetAdminUser\(userId)"
        } else {
            urlString = "http://alarmfire-001-site1.dtempurl.com/User/GetUser\(userId)"
        }

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
                    self.errorMessage = "Error fetching user data: \(error.localizedDescription)"
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "No data received"
                }
                return
            }

            do {
                if self.userType == "Admin" {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        DispatchQueue.main.async {
                            self.naziv = jsonResponse["naziv"] as? String ?? ""
                            self.email = jsonResponse["email"] as? String ?? ""
                            self.latitude = jsonResponse["latitude"] as? String ?? ""
                            self.longitude = jsonResponse["longitude"] as? String ?? ""

                            // Poziv funkcije za dobijanje adrese
                            if let lat = Double(self.latitude), let long = Double(self.longitude) {
                                fetchLocationAddress(latitude: lat, longitude: long)
                            }
                        }
                    }
                } else {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        DispatchQueue.main.async {
                            self.firstName = jsonResponse["firstName"] as? String ?? ""
                            self.lastName = jsonResponse["lastName"] as? String ?? ""
                            self.phone = jsonResponse["number"] as? Int // Promenjeno u Int?
                            self.email = jsonResponse["email"] as? String ?? ""

                            // Poziv funkcije za dobijanje adrese
                            if let lat = Double(self.latitude), let long = Double(self.longitude) {
                                fetchLocationAddress(latitude: lat, longitude: long)
                            }
                        }
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Error parsing user data: \(error.localizedDescription)"
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

#Preview {
    Settings()
}

