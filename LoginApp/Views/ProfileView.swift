import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class UserData: ObservableObject {
@Published var receiveNotifications = false
}

struct ProfileView: View {
    @State private var email: String = ""
    @State private var username: String = ""
    @State private var lastName: String = ""
    @State private var birthDate = Date()
    
    @State private var isDarkModeEnabled = false
    @State private var showAlert = false
    @Environment(\.presentationMode) var presentationMode
    
    // Firestore
    let db = Firestore.firestore()
    @State private var userData: UserData?
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Perfil")) {
                    TextField("Nombre de Usuario", text: $username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Apellido", text: $lastName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Correo Electrónico", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Section(header: Text("Fecha de Nacimiento")) {
                        DatePicker("Fecha de Nacimiento", selection: $birthDate, displayedComponents: [.date])
                            .datePickerStyle(GraphicalDatePickerStyle())
                    }
                }
                
                Section(header: Text("Configuraciones")) {
                    Toggle("Modo Oscuro", isOn: $isDarkModeEnabled)
                    
                    Button(action: saveUserData) {
                        Text("Guardar")
                    }
                }
                
                Button(action: signOut) {
                    Text("Cerrar sesión")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .navigationBarTitle("Perfil y Configuraciones", displayMode: .inline)
            .onAppear(perform: loadUserData)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Datos Guardados"),
                    message: Text("Los datos se han guardado exitosamente."),
                    dismissButton: .default(Text("Aceptar"))
                )
            }
        }
        .preferredColorScheme(isDarkModeEnabled ? .dark : .light)
    }
    
    private func loadUserData() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(userId).getDocument { document, error in
            if let error = error {
                print("Error al obtener los datos del perfil:", error.localizedDescription)
                return
            }
            
            if let document = document, document.exists {
                let data = document.data()
                self.username = data?["username"] as? String ?? ""
                self.lastName = data?["lastName"] as? String ?? ""
                self.email = data?["email"] as? String ?? ""
                let timestamp = data?["birthDate"] as? Timestamp
                self.birthDate = timestamp?.dateValue() ?? Date()
            }
        }
    }
    
    private func saveUserData() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let userData = [
            "username": username,
            "lastName": lastName,
            "email": email,
            "birthDate": birthDate
        ] as [String : Any]
        
        db.collection("users").document(userId).setData(userData) { error in
            if let error = error {
                print("Error al guardar los datos del perfil:", error.localizedDescription)
                return
            }
            
            showAlert = true
        }
    }
    
    private func signOut() {
        do {
            try Auth.auth().signOut()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error al cerrar sesión:", error.localizedDescription)
        }
    }
}
    
    struct UserInfoRow: View {
        var title: String
        var value: String
        
        var body: some View {
            HStack {
                Text(title)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                Text(value)
            }
        }
        
    }


    struct ProfileView_Preview: PreviewProvider {
        static var previews: some View {
            ProfileView()
        }
    }

