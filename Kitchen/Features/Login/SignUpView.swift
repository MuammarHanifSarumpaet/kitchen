//
//  SignUpView.swift
//  Kitchen
//
//  Created by iCodeWave Community on 23/06/25.
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var displayName = ""
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    var showLoginView: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Logo atau Judul Aplikasi
            Image("kitchen_logo") // Pastikan Anda memiliki aset gambar ini
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .padding(.bottom, 30)

            Text("Buat Akun Dapur Baru")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)

            Text("Daftarkan akun Anda untuk mulai mengelola pesanan.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.bottom, 20)

            // Form Input
            VStack(spacing: 16) {
                TextField("Nama Lengkap", text: $displayName)
                    .autocapitalization(.words)
                    .textContentType(.name)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )

                TextField("Email", text: $email)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )

                HStack {
                    if showPassword {
                        TextField("Password", text: $password)
                    } else {
                        SecureField("Password", text: $password)
                    }
                    Button(action: {
                        showPassword.toggle()
                    }) {
                        Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )

                HStack {
                    if showConfirmPassword {
                        TextField("Konfirmasi Password", text: $confirmPassword)
                    } else {
                        SecureField("Konfirmasi Password", text: $confirmPassword)
                    }
                    Button(action: {
                        showConfirmPassword.toggle()
                    }) {
                        Image(systemName: showConfirmPassword ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )

                if let errorMessage = authManager.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else if showAlert {
                    Text(alertMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            // Tombol Daftar
            Button(action: {
                if validateInput() {
                    authManager.signUp(email: email, pass: password, displayName: displayName, role: "kitchen_staff")
                }
            }) {
                HStack {
                    if authManager.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Daftar")
                    }
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.green) // Warna yang berbeda untuk daftar
                .cornerRadius(12)
                .shadow(color: Color.green.opacity(0.3), radius: 5, x: 0, y: 5)
            }
            .disabled(authManager.isLoading)

            // Tombol Kembali ke Login
            Button(action: showLoginView) {
                Text("Sudah punya akun? **Masuk**")
                    .font(.subheadline)
                    .foregroundColor(.accentColor)
            }
            .padding(.top, 8)

            Spacer()
        }
        .padding(32)
        .background(Color(.systemBackground).ignoresSafeArea())
        .onAppear {
            // Bersihkan pesan error saat tampilan muncul
            authManager.errorMessage = nil
            alertMessage = ""
            showAlert = false
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Peringatan"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    private func validateInput() -> Bool {
        if displayName.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty {
            alertMessage = "Semua kolom harus diisi."
            showAlert = true
            return false
        }
        if password != confirmPassword {
            alertMessage = "Password dan Konfirmasi Password tidak cocok."
            showAlert = true
            return false
        }
        // Tambahkan validasi password strength atau format email jika perlu
        return true
    }
}

// Preview Provider
struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView(showLoginView: {})
            .environmentObject(AuthenticationManager())
    }
}
