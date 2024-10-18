import SwiftUI

struct Login: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?
    @State private var navigateToHome = false
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 16) {
                    Image("login")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .clipped()
                    
                    VStack(spacing: 0) {
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .padding()
                            .background(Color(hex: "#EBE5F3"))
                            .cornerRadius(10)
                        
                        Divider()
                            .background(Color.white)
                            .frame(height: 10)
                        
                        SecureField("Lozinka", text: $password)
                            .padding()
                            .background(Color(hex: "#EBE5F3"))
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        Spacer()
                        Button(action: {
                            loginUser()
                        }) {
                            Text("Prijavi se")
                                .font(.system(size: 18))
                                .foregroundColor(Color.black)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(hex: "#EDEA53"))
                                .cornerRadius(50)
                                .shadow(color: .gray, radius: 4, x: 0, y: 5)
                        }
                        Spacer()
                    }
                    .padding()
                }
                .padding()
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
                
                HStack {
                    Text("Nemate nalog? ")
                        .font(.footnote)
                        .foregroundColor(.gray)
                    NavigationLink(destination: Registration()) {
                        Text("Registruj se")
                            .font(.footnote)
                            .foregroundColor(Color.blue)
                            .underline()
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Prijava")
            .navigationBarTitleDisplayMode(.inline)
            .background(
                NavigationLink(destination: Settings(), isActive: $navigateToHome) {
                    EmptyView()
                }
            )
        }
    }
    
    private func loginUser() {
        guard isValidInput() else {
            return
        }

        guard let url = URL(string: "http://alarmfire-001-site1.dtempurl.com/User/login") else {
            print("Invalid URL")
            return
        }

        let parameters: [String: Any] = [
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
                    self.errorMessage = "Error during login: \(error.localizedDescription)"
                }
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200:
                    DispatchQueue.main.async {
                        do {
                            if let data = data,
                               let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                               let token = jsonResponse["token"] as? String,
                               let userId = jsonResponse["id"] as? Int,
                               let userType = jsonResponse["role"] as? String { // Uloga korisnika

                                UserDefaults.standard.set(token, forKey: "authToken")
                                UserDefaults.standard.set(userId, forKey: "userId")
                                UserDefaults.standard.set(userType, forKey: "userType")
                                navigateToHome = true
                                dismiss()
                            }
                        } catch {
                            self.errorMessage = "Error parsing response: \(error.localizedDescription)"
                        }
                    }
                    
                case 401:
                    DispatchQueue.main.async {
                        self.errorMessage = "Niste uneli ispravno email ili lozinku."
                    }
                default:
                    DispatchQueue.main.async {
                        self.errorMessage = "Login failed: \(httpResponse.statusCode)"
                    }
                }
            }
        }.resume()
    }
    
    private func isValidInput() -> Bool {
        if email.isEmpty {
            errorMessage = "Unesite email."
            return false
        }
        if password.isEmpty {
            errorMessage = "Unesite lozinku."
            return false
        }
        return true
    }
}

#Preview {
    Login()
}
