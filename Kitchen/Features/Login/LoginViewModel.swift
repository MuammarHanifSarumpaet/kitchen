
//
//  LoginViewModel.swift
//  Kitchen
//
//  Created by iCodeWave Community on 23/06/25.
//

import SwiftUI
import Combine

class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var showPassword = false // Untuk toggle visibilitas password
    @Published var showAlert = false
    @Published var alertMessage = ""

    // Ini akan diinject dari environment, jadi tidak perlu @Published di sini
    // Nanti akan diakses melalui @EnvironmentObject di LoginView
    // var authManager: AuthenticationManager // Tidak perlu ini jika pakai @EnvironmentObject

    // Karena authManager akan diinject, kita tidak perlu init dengan authManager
    init() { }

    func signIn(authManager: AuthenticationManager) {
        // Clear previous alerts
        alertMessage = ""
        showAlert = false

        authManager.signIn(email: email, pass: password)
        // authManager akan mengupdate isLoading dan errorMessage
        // View akan bereaksi terhadap perubahan tersebut melalui EnvironmentObject
    }

    func validateInput() -> Bool {
        if email.isEmpty || password.isEmpty {
            alertMessage = "Email dan password tidak boleh kosong."
            showAlert = true
            return false
        }
        // Tambahkan validasi format email jika diperlukan
        return true
    }
}
