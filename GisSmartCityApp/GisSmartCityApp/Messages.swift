import SwiftUI
import MapKit

struct NotificationData: Decodable, Identifiable {
    let id: Int
    let description: String
    let latitude: String
    let longitude: String
    let idUser: Int
    let user: String?
}

struct Messages: View {
    @State private var notifications: [NotificationData] = []
    @State private var errorMessage: String?
    @State private var locationNames: [Int: String] = [:]
    @State private var isLoggedIn: Bool = false
    @State private var userType: String = ""

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#EBE5F3")
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Image(systemName: "house.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .foregroundColor(Color(hex: "#4A90E2"))
                        .padding()

                    Divider()
                        .background(Color.gray)
                        .padding(10)
                    
                    if isLoggedIn {
                        if let errorMessage = errorMessage {
                            Text("Error: \(errorMessage)")
                                .foregroundColor(.red)
                                .padding()
                        } else {
                            List(notifications) { notification in
                                NavigationLink(destination: MessageView(notificationId: notification.id)) {
                                    HStack {
                                        if let locationName = locationNames[notification.id] {
                                            Text(locationName)
                                                .font(.headline)
                                                .foregroundColor(.black)
                                            
                                            Spacer()
                                            // Prikaz zvonaca u zavisnosti od vrste usluge
                                            HStack {
                                                Image(systemName: "bell.fill")
                                                    .foregroundColor(.red) // Uvek crveno zvono
                                                
                                            }
                                            .padding(.leading, 5)

                                        } else {
                                            Text("Pribavljanje lokacije...")
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(20)
                                    .background(Color(hex: "#F0F0F0"))
                                    .cornerRadius(10)
                                    .shadow(color: .gray, radius: 4, x: 0, y: 2)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.vertical, 5)
                                .onAppear {
                                    fetchLocation(for: notification)
                                }
                            }
                            .listStyle(PlainListStyle())
                            .cornerRadius(10)
                        }
                    } else {
                        Text("Niste prijavljeni.")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding()
                    }
                }
                .padding()
            }
            .onAppear {
                checkLoginStatus()
                fetchNotifications()
            }
        }
    }

    private func checkLoginStatus() {
        isLoggedIn = UserDefaults.standard.string(forKey: "authToken") != nil
        
        if isLoggedIn {
            userType = UserDefaults.standard.string(forKey: "userType") ?? ""
        }
    }

    private func fetchNotifications() {
        guard isLoggedIn else { return }

        guard let userId = UserDefaults.standard.value(forKey: "userId") as? Int else {
            errorMessage = "User ID not found."
            return
        }

        guard let url = URL(string: "http://alarmfire-001-site1.dtempurl.com/NotificationHelp/GetNotificationsHelp") else {
            errorMessage = "Invalid URL"
            return
        }

        let username = "11196448"
        let password = "60-dayfreetrial"
        let loginString = "\(username):\(password)"
        let loginData = loginString.data(using: .utf8)!
        let base64LoginString = loginData.base64EncodedString()

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Error during request: \(error.localizedDescription)"
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    self.errorMessage = "Invalid response received"
                }
                return
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                DispatchQueue.main.async {
                    self.errorMessage = "Server error: \(httpResponse.statusCode)"
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
                let decodedNotifications = try JSONDecoder().decode([NotificationData].self, from: data)
                
                // Filtriramo notifikacije
                let filteredNotifications: [NotificationData]
                if userType == "Admin" {
                    // Ako je admin, uzimamo sve notifikacije
                    filteredNotifications = decodedNotifications
                } else {
                    // Ako je običan korisnik, uzimamo samo njegove notifikacije
                    filteredNotifications = decodedNotifications.filter { $0.idUser == userId }
                }
                
                DispatchQueue.main.async {
                    self.notifications = filteredNotifications.reversed() // Obrni redosled
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Decoding error: \(error.localizedDescription)"
                }
            }
        }.resume()
    }

    private func fetchLocation(for notification: NotificationData) {
        let latitude = Double(notification.latitude) ?? 0.0
        let longitude = Double(notification.longitude) ?? 0.0
        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                return
            }
            
            if let placemark = placemarks?.first, let name = placemark.name {
                DispatchQueue.main.async {
                    locationNames[notification.id] = name
                }
            }
        }
    }
}

#Preview {
    Messages()
}

