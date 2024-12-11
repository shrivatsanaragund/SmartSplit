//import SwiftUI
//
//struct AdminAccessControl: View {
//    var body: some View {
//        
//            VStack {
//                // Title for Admin Access Control
//                VStack {
//                    Text("Admin Access Control")
//                        .font(.largeTitle)
//                        .fontWeight(.bold)
//                        .padding(.top, 40)
//                    
//                    Text("Choose an option to manage.")
//                        .font(.subheadline)
//                        .foregroundColor(.gray)
//                        .padding(.top, 5)
//                }
//                .frame(maxWidth: .infinity, alignment: .center)
//                
//                Spacer()
//                
//                // Buttons for Users and Categories
//                VStack(spacing: 20) {
//                    NavigationLink(destination: AllUsersView()) {
//                        Text("Users")
//                            .frame(maxWidth: .infinity)
//                            .padding()
//                            .background(Color.blue)
//                            .foregroundColor(.white)
//                            .cornerRadius(8)
//                    }
//                    
//                    Button(action: {
//                        // Action for Categories button
//                        print("Categories button tapped")
//                    }) {
//                        Text("Categories")
//                            .frame(maxWidth: .infinity)
//                            .padding()
//                            .background(Color.blue)
//                            .foregroundColor(.white)
//                            .cornerRadius(8)
//                    }
//                }
//                .padding(.horizontal)
//                
//                Spacer()
//            }
//        
//    }
//}

import SwiftUI

struct AdminAccessControl: View {
    @State private var showNotification: Bool = true
    
    var body: some View {
        VStack {
            if showNotification {
                Text("Admin Logged in Successfully")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(8)
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.5), value: showNotification)
                    .padding(.top, 10)
            }
            
            // Title for Admin Access Control
            VStack {
                Text("Admin Access Control")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 40)
                
                Text("Choose an option to manage.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.top, 5)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            
            Spacer()
            
            // Buttons for Users and Categories
            VStack(spacing: 20) {
                NavigationLink(destination: AllUsersView()) {
                    Text("Users")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Button(action: {
                    // Action for Categories button
                    print("Categories button tapped")
                }) {
                    Text("Categories")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    showNotification = false
                }
            }
        }
    }
}
