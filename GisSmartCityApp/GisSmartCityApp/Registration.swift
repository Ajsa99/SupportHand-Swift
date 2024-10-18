import SwiftUI

struct Registration: View {
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var number: Int? = nil
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?
    @State private var showSuccessAlert = false
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Spacer()

                VStack(alignment: .leading, spacing: 16) {
                    Text("Lični podaci:")
                        .font(.headline)
                        .padding(.horizontal)

                    Group {
                        TextField("Ime", text: $firstName)
                        TextField("Prezime", text: $lastName)
                        TextField("Broj telefona", value: $number, formatter: NumberFormatter())
                    }
                    .padding()
                    .background(Color(hex: "#EBE5F3"))
                    .cornerRadius(10)
                    .padding(.horizontal)

                    Text("Podaci za nalog:")
                        .font(.headline)
                        .padding(.horizontal)

                    Group {
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                        SecureField("Lozinka", text: $password)
                    }
                    .padding()
                    .background(Color(hex: "#EBE5F3"))
                    .cornerRadius(10)
                    .padding(.horizontal)

                    Button(action: {
                        registerUser()
                    }) {
                        Text("Registruj se")
                            .font(.system(size: 18))
                            .foregroundColor(Color.black)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(hex: "#EDEA53"))
                            .cornerRadius(50)
                            .shadow(color: .gray, radius: 4, x: 0, y: 5)
                    }
                    .padding()
                }
                .padding()

                // Prikazivanje poruke greške ispod dugmeta
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
                
                HStack {
                    Text("Već ste registrovani? ")
                        .font(.footnote)
                        .foregroundColor(.gray)
                    NavigationLink(destination: Login()) {
                        Text("Prijavi se")
                            .font(.footnote)
                            .foregroundColor(Color.blue)
                            .underline()
                    }
                }

                Spacer()
            }
            .navigationTitle("Registracija")
            .navigationBarTitleDisplayMode(.inline)
            .alert(isPresented: $showSuccessAlert) {
                Alert(
                    title: Text("Uspešna registracija"),
                    message: Text("Uspešno ste se registrovali!"),
                    dismissButton: .default(Text("U redu")) {
                    }
                )
            }
            .background()
            
        }
    }

    private func registerUser() {
        guard isValidInput() else {
            return
        }

        guard let url = URL(string: "http://alarmfire-001-site1.dtempurl.com/User/register") else {
            print("Invalid URL")
            return
        }

        let parameters: [String: Any] = [
            "firstName": firstName,
            "lastName": lastName,
            "number": number ?? 0,
            "email": email,
            "password": password
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let username = "11196448"
        let password = "60-dayfreetrial"
        let loginString = "\(username):\(password)"
        let loginData = loginString.data(using: .utf8)!
        let base64LoginString = loginData.base64EncodedString()
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            print("Error in JSON serialization: \(error)")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Greška tokom registracije: \(error.localizedDescription)"
                }
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    DispatchQueue.main.async {
                        showSuccessAlert = true // Prikazati alert za uspešnu registraciju
                        dismiss()
                        
                    }
                } else if httpResponse.statusCode == 400 {
                    DispatchQueue.main.async {
                        self.errorMessage = "Korisnik sa tim email-om je već registrovan."
                    }
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Greška sa serverom: \(httpResponse.statusCode)"
                    }
                }
            }
        }.resume()
    }

    private func isValidInput() -> Bool {
        if firstName.count < 3 {
            errorMessage = "Ime mora imati najmanje 3 karaktera."
            return false
        }
        if lastName.count < 3 {
            errorMessage = "Prezime mora imati najmanje 3 karaktera."
            return false
        }
        if !isValidEmail(email) {
            errorMessage = "Unesite validan email."
            return false
        }
        if password.count < 3 {
            errorMessage = "Lozinka mora imati najmanje 3 karaktera."
            return false
        }
        return true
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@gmail\\.com"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }

}

#Preview {
    Registration()
}

