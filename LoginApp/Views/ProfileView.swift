import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var userData: Login?
    @State private var isSignedOut = false // Nuevo estado para rastrear si el usuario ha cerrado sesión
    
    var body: some View {
        VStack {
            Text("Perfil del Usuario")
                .font(.largeTitle)
                .foregroundColor(.blue)
                .padding()
            
            if let userData = userData {
                VStack(alignment: .leading, spacing: 20) {
                    UserInfoRow(title: "Correo electrónico:", value: userData.email)
                    // Agrega más detalles del perfil según sea necesario
                }
                .padding()
                
                Button(action: signOut) {
                    Text("Cerrar sesión")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
                .fullScreenCover(isPresented: $isSignedOut) {
                    LoginView()
                }
            } else {
                ProgressView() // Muestra una vista de carga mientras se carga la información del usuario
            }
            
            Spacer()
        }
        .onAppear {
            fetchUserData()
        }
    }
    
    func fetchUserData() {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        // Simulamos algunos datos de usuario basados en la estructura Login
        let fakeUserData = Login(email: currentUser.email ?? "example@example.com", password: "")
        self.userData = fakeUserData
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            presentationMode.wrappedValue.dismiss()
            isSignedOut = true // Indicar que el usuario ha cerrado sesión
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

#Preview {
    ProfileView()
}
