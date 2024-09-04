//
//  LoginView.swift
//  Goodworkouts-ios
//
//  Created by Elliott Rarden on 02.09.24.
//

import SwiftUI

struct LoginView: View {
    @State var username: String = ""
    @State var password: String = ""
    @State var showPass: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("GoodWorkouts by ellman121")
                .font(.title)
            
            TextField("Username", text: $username)
                .padding()
                .textInputAutocapitalization(.never)
            
            HStack {
                if showPass {
                    TextField("Passowrd", text: $password)
                        .padding()
                } else {
                    SecureField("Password", text: $password)
                        .padding()
                }
                
                Button {
                    showPass.toggle()
                } label: {
                    Image(systemName: showPass ? "eye.slash" : "eye")
                        .foregroundColor(.accentColor)
                }
            }
            
            if APIManager.shared.isLoading {
                ProgressView()
            } else {
                Button {
                    APIManager.attemptToLogin(withUsername: $username.wrappedValue, andWithPassword: $password.wrappedValue)
                } label: {
                    Text("Sign In")
                        .font(.title3)
                }
                .disabled(username.isEmpty || password.isEmpty)
            }
        }
        .padding()
    }
}

#Preview {
    LoginView()
}
