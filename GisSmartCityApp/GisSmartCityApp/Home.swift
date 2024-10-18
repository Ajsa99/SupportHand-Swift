import SwiftUI

struct Home: View {
    @State private var isLoggedIn: Bool = false
    @State private var userId: Int = 0
    @State private var userType: String = ""

    var body: some View {
        TabView {
            Settings()
                .tabItem {
                    Label("Podesavanja", systemImage: "gearshape.fill")
                }
            
            Messages() // Novi tab za Poruke
                .tabItem {
                    Label("Poruke", systemImage: "message.fill") // Ikona za poruke
                }

            // Uslov za prikazivanje notifikacija
            if userType != "Admin" {
                Notification()
                    .tabItem {
                        Label("Obaveštenje", systemImage: "bell.fill")
                    }
            }

            GoogleMap()
                .tabItem {
                    Label("Mapa", systemImage: "map.fill")
                }

            Information()
                .tabItem {
                    Label("Informacije", systemImage: "info.circle.fill")
                }
        }
        .onAppear {
            // Učitaj informacije o korisniku
            isLoggedIn = UserDefaults.standard.string(forKey: "authToken") != nil
            userId = UserDefaults.standard.integer(forKey: "userId")
            userType = UserDefaults.standard.string(forKey: "userType") ?? ""
            
            // Customize Tab Bar Appearance
            let appearance = UITabBarAppearance()
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
        .accentColor(Color(hex: "#4A90E2"))
    }
}

#Preview {
    Home()
}

