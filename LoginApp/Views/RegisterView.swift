import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct RegisterView: View {
    @Binding var isRegistrationSuccess: Bool
    @State private var registrationData = Registro(email: "", password: "", confirmPassword: "")
    @State private var showAlertError = false // Estado para mostrar la alerta de error
    @State private var showAlertSuccess = false // Estado para mostrar la alerta de éxito
    @State private var alertMessage = ""
    @State private var isCheckingEmail = false
    

    init(isRegistrationSuccess: Binding<Bool>) {
            _isRegistrationSuccess = isRegistrationSuccess
        }
    
    var body: some View {
        VStack {
            Spacer()
            Text("Registro")
                .font(.title)
                .padding()
            
            TextField("Correo electrónico", text: $registrationData.email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .disabled(isCheckingEmail)
            
            SecureField("Contraseña", text: $registrationData.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            SecureField("Confirmar contraseña", text: $registrationData.confirmPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button(action: {
                isCheckingEmail = true
                checkIfEmailExists()
            }) {
                Text("Verificar correo electrónico")
            }
            .padding()
            .disabled(isCheckingEmail)
            
            Button("Registrarse") {
                register()
                saveUserData(email: registrationData.email)
            }
            .padding()
            .disabled(isCheckingEmail || registrationData.email.isEmpty || registrationData.password.isEmpty)
            
            Spacer()
        }
        .padding()
        .alert(isPresented: .init(get: {
            self.showAlertError || self.showAlertSuccess
        }, set: { _ in
            // No es necesario implementar el setter en este caso
        })) {
            if showAlertError {
                return Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            } else {
                return Alert(title: Text("Registro exitoso"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    func checkIfEmailExists() {
        let db = Firestore.firestore()
        let email = registrationData.email.lowercased()
        
        db.collection("users").whereField("email", isEqualTo: email).getDocuments { snapshot, error in
            if let error = error {
                self.alertMessage = "Error al verificar el correo electrónico: \(error.localizedDescription)"
                self.showAlertError = true
                self.isCheckingEmail = false
                return
            }
            
            if let documents = snapshot?.documents, !documents.isEmpty {
                // Mostrar una alerta cuando el correo electrónico ya está registrado
                self.alertMessage = "Este correo electrónico ya está registrado por otra persona"
                self.showAlertError = true
                self.isCheckingEmail = false
            } else {
                self.alertMessage = "Correo electrónico disponible"
                self.showAlertSuccess = true
                self.isCheckingEmail = false
            }
        }
    }
    
    func register() {
        guard registrationData.password == registrationData.confirmPassword else {
            self.alertMessage = "Las contraseñas no coinciden"
            self.showAlertError = true
            return
        }
        
        Auth.auth().createUser(withEmail: registrationData.email, password: registrationData.password) { (result, error) in
            if let error = error {
                self.alertMessage = "Error al registrar el usuario: \(error.localizedDescription)"
                self.showAlertError = true
                print("Error al registrar el usuario:", error.localizedDescription)
            } else {
                self.alertMessage = "Registro exitoso"
                self.showAlertSuccess = true // Aquí se establece showAlertSuccess en true después del registro exitoso
                // Vaciar los campos después del registro exitoso
                self.registrationData.email = ""
                self.registrationData.password = ""
                self.registrationData.confirmPassword = ""
            }
        }
    }

    
    func saveUserData(email: String) {
        let db = Firestore.firestore()
        db.collection("users").document(email.lowercased()).setData([
            "email": email.lowercased(),
            // Aquí puedes agregar más campos si es necesario
        ]) { error in
            if let error = error {
                alertMessage = "Error al guardar los datos: \(error.localizedDescription)"
                showAlertError = true
            } else {
                alertMessage = "Datos guardados correctamente"
                showAlertSuccess = true
                
            }
        }
    }
}


struct RegisterView_Previews: PreviewProvider {
    @State static var isRegistrationSuccess = false // Definir isRegistrationSuccess en RegisterView_Previews

    static var previews: some View {
        RegisterView(isRegistrationSuccess: $isRegistrationSuccess)
    }
}
