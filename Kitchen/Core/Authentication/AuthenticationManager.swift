import FirebaseAuth
import FirebaseFirestore

class AuthenticationManager: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false // Untuk sign-in/sign-up process
    @Published var isFetchingUser: Bool = false // Untuk proses fetch user record

    private var db = Firestore.firestore()
    private var authStateHandler: AuthStateDidChangeListenerHandle?

    init() {
        // userSession = Auth.auth().currentUser // Akan di-handle oleh listener
        addAuthStateListener()
        if Auth.auth().currentUser != nil {
             fetchUserRecord() // Fetch jika sudah ada sesi saat init
        }
    }

    func addAuthStateListener() {
        authStateHandler = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.userSession = user
                if user != nil {
                    self.fetchUserRecord()
                } else {
                    self.currentUser = nil // Clear user data on logout
                }
            }
        }
    }

    func signIn(email: String, pass: String) {
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }
        Auth.auth().signIn(withEmail: email, password: pass) { [weak self] result, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                if let error = error {
                    self.errorMessage = "Login Gagal: \(error.localizedDescription)"
                    return
                }
                // userSession akan diupdate oleh listener, dan fetchUserRecord akan dipanggil
                print("Sign in successful for user: \(result?.user.uid ?? "N/A")")
            }
        }
    }

    // Fungsi Sign Up Baru
    func signUp(email: String, pass: String, displayName: String, role: String = "kitchen_staff") { // Default role untuk kitchen
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }
        Auth.auth().createUser(withEmail: email, password: pass) { [weak self] authResult, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if let error = error {
                    self.isLoading = false
                    self.errorMessage = "Registrasi Gagal: \(error.localizedDescription)"
                    return
                }
                
                guard let firebaseUser = authResult?.user else {
                    self.isLoading = false
                    self.errorMessage = "Registrasi Gagal: Tidak mendapatkan data user."
                    return
                }

                // Simpan detail user ke Firestore
                let newUser = User(id: firebaseUser.uid, email: email, displayName: displayName)
                    do {
                    // id: firebaseUser.uid sudah ada di newUser jika @DocumentID digunakan dengan benar
                    // Kita akan set dokumen dengan ID eksplisit
                    try self.db.collection("users").document(firebaseUser.uid).setData(from: newUser) { firestoreError in
                        self.isLoading = false // Pindahkan isLoading = false setelah operasi Firestore
                        if let firestoreError = firestoreError {
                            self.errorMessage = "Gagal menyimpan data user: \(firestoreError.localizedDescription)"
                            // Pertimbangkan untuk menghapus user dari Auth jika penyimpanan Firestore gagal
                            // firebaseUser.delete { _ in }
                        } else {
                            print("User registered and data saved to Firestore: \(firebaseUser.uid)")
                            // userSession akan diupdate oleh listener, dan fetchUserRecord akan dipanggil
                        }
                    }
                } catch {
                    self.isLoading = false
                    self.errorMessage = "Gagal menyimpan data user (encoding): \(error.localizedDescription)"
                }
            }
        }
    }


    func fetchUserRecord() {
        guard let uid = Auth.auth().currentUser?.uid else {
            DispatchQueue.main.async {
                self.currentUser = nil
                self.isFetchingUser = false
            }
            return
        }

        DispatchQueue.main.async {
            self.isFetchingUser = true
            self.errorMessage = nil // Clear previous errors
        }

        db.collection("users").document(uid).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isFetchingUser = false
                if let error = error {
                    self.errorMessage = "Error fetching user data: \(error.localizedDescription)"
                    self.currentUser = nil
                    // Pertimbangkan untuk logout jika user record tidak ditemukan krusial
                    // self.signOut()
                    return
                }

                if snapshot?.exists == false {
                    self.errorMessage = "User record tidak ditemukan di Firestore."
                    self.currentUser = nil
                     // Pertimbangkan untuk logout jika user record tidak ditemukan krusial
                    // self.signOut()
                    return
                }

                do {
                    self.currentUser = try snapshot?.data(as: User.self)
                    print("User record fetched: \(self.currentUser?.email ?? "N/A")")
                } catch {
                    self.errorMessage = "Error decoding user data: \(error.localizedDescription)"
                    self.currentUser = nil
                }
            }
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            // userSession dan currentUser akan otomatis di-nil-kan oleh listener dan logika fetchUserRecord
            print("User signed out")
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Error signing out: \(error.localizedDescription)"
            }
        }
    }
    
    deinit {
        if let handle = authStateHandler {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}
