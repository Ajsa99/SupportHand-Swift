import SwiftUI

struct Information: View {
    var body: some View {
        ZStack {
            Color(hex: "#EBE5F3")
                .edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack {
                    Image(systemName: "info.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 70, maxHeight: 70)
                        .clipped()
                    
                    Text("Informacije")
                        .font(.title2)
                        .padding(.bottom, 20)
                    
                    Divider()
                        .padding(.horizontal, 30)
                        .padding(.vertical, 15)
                    
                    Image("copy")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .clipped()
                    
                    Text("Ova aplikacija je osmišljena da pomogne osobama u opasnosti. Sadrži funkcionalnosti kao što su:")
                        .font(.body)
                        .padding(.vertical)
                    
                    VStack(alignment: .leading) {
                        Text("• Hitna obaveštenja za pomoć")
                        Text("• Geolokacija za bržu identifikaciju mesta")
                        Text("• Uputstva za bezbednu evakuaciju")
                        Text("• Direktno povezivanje sa lokalnim službama")
                    }
                    
                    Text("Kako se koristi?")
                        .font(.headline)
                        .padding()
                    
                    Text("Jednostavno je! Preuzmite aplikaciju, kreirajte nalog i omogućite geolokaciju.")
                        .font(.body)
                        .padding(.bottom)
                   
                    Text("Kada primite upozorenje, pratite uputstva na ekranu i pridržavajte se svih preporuka za sigurnost.")
                        .font(.body)
                    
                    Spacer()
                }
                .padding()
            }
        }
    }
}

#Preview {
    Information()
}
