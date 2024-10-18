//
//  ContentView.swift
//  AlarmFireApp
//
//  Created by Ajsa on 16. 9. 2024..
//

import SwiftUI

struct ContentView: View {
    @State private var navigateToHome = false
    var body: some View {
        NavigationView { // Omotajte sve u NavigationView
            VStack {
                Image("gislogo")
                    .resizable()
                    .scaledToFit()
                
                Text("SupportHand")
                    .font(.custom("IrishGrover-Regular", size: 45))
                    .bold()
                    .foregroundColor(Color(hex: "#4A90E2"))
                    .padding(.top, 8)
                    .shadow(color: .gray, radius: 3, x: 0, y: 4)
                
                NavigationLink(destination: Home()) { // NavigationLink za navigaciju
                    Text("Next   -->")
                        .font(.system(size: 25))
                        .foregroundColor(Color.black.opacity(0.25)) // Boja teksta sa 25% opacitetom
                        .padding() // Razmak unutar dugmeta
                        .frame(width: 190, height: 70) // Širina i visina dugmeta
                        .background(Color(hex: "#EBE5F3")) // Pozadina dugmeta
                        .cornerRadius(50) // Zaobljeni uglovi dugmeta
                        .shadow(color: .gray, radius: 4, x: 0, y: 5) // Senka dugmeta
                }
                .padding(.top, 20) // Razmak iznad dugmeta
            }
            .padding()
        }
    }
}

// Prilagodite Color za HEX kodove
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.charactersToBeSkipped = CharacterSet.alphanumerics.inverted
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        let red = Double((rgb >> 16) & 0xFF) / 255.0
        let green = Double((rgb >> 8) & 0xFF) / 255.0
        let blue = Double(rgb & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue)
    }
}

#Preview {
    ContentView()
}
