//
//  AuthenticationContainerView.swift
//  Kitchen
//
//  Created by iCodeWave Community on 10/06/25.
//
import SwiftUI

struct AuthenticationContainerView: View {
    @State private var showLogin: Bool = true

    var body: some View {
        Group { // Group agar modifier bisa diterapkan sekali jika perlu
            if showLogin {
                LoginView(showSignUpView: {
                    withAnimation {
                        self.showLogin = false
                    }
                })
            } else {
                SignUpView(showLoginView: {
                    withAnimation {
                        self.showLogin = true
                    }
                })
            }
        }
    }
}                                                                                      
