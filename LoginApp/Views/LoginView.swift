import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isLoggedIn = false // Estado para rastrear si el usuario ha iniciado sesión correctamente

    var body: some View {
        VStack {
            Spacer()
            Text("Inicio de sesión")
                    .font(.title)

            TextField("Correo electrónico", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            SecureField("Contraseña", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Iniciar sesión") {
                signIn()
            }
            .padding()
            
            Spacer()
        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .fullScreenCover(isPresented: $isLoggedIn) {
            ProfileView() // Presentar la vista del perfil cuando isLoggedIn es true
        }
    }
    
    func signIn() {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                alertMessage = error.localizedDescription
                showAlert = true
            } else {
                isLoggedIn = true // Marcar como verdadero cuando el inicio de sesión es exitoso
                // Limpiar los campos de correo electrónico y contraseña
                email = ""
                password = ""
            }
        }
    }
}

#Preview {
    LoginView()
}
