//
//  LoginView.swift
//  Kitchen
//
//  Created by iCodeWave Community on 23/06/25.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @StateObject private var viewModel = LoginViewModel() // Menggunakan StateObject untuk ViewModel lokal

    var showSignUpView: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Logo atau Judul Aplikasi
            Image("kitchen_logo") // Pastikan Anda memiliki aset gambar ini
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .padding(.bottom, 30)

            Text("Selamat Datang di Dapur Restoran")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)

            Text("Masuk untuk mengelola pesanan.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.bottom, 20)

            // Form Input
            VStack(spacing: 16) {
                TextField("Email", text: $viewModel.email)
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
                    if viewModel.showPassword {
                        TextField("Password", text: $viewModel.password)
                    } else {
                        SecureField("Password", text: $viewModel.password)
                    }
                    Button(action: {
                        viewModel.showPassword.toggle()
                    }) {
                        Image(systemName: viewModel.showPassword ? "eye.slash.fill" : "eye.fill")
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
                } else if viewModel.showAlert {
                    Text(viewModel.alertMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            // Tombol Login
            Button(action: {
                if viewModel.validateInput() {
                    viewModel.signIn(authManager: authManager)
                }
            }) {
                HStack {
                    if authManager.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Masuk")
                    }
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.accentColor) // Warna aksen seperti MOKA
                .cornerRadius(12)
                .shadow(color: Color.accentColor.opacity(0.3), radius: 5, x: 0, y: 5)
            }
            .disabled(authManager.isLoading) // Disable saat loading

            // Tombol Daftar
            Button(action: showSignUpView) {
                Text("Belum punya akun? **Daftar Sekarang**")
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
            viewModel.alertMessage = ""
            viewModel.showAlert = false
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text("Peringatan"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
        }
    }
}

// Preview Provider
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(showSignUpView: {})
            .environmentObject(AuthenticationManager()) // Provide a mock or real AuthManager
    }
}
