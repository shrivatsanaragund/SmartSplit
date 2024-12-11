import SwiftUI

struct LandingPage: View {
    // Navigation State
    @State private var isLoginRegisterPresented: Bool = false

    var body: some View {
        ZStack {
            // Dark Gradient Background Color
            LinearGradient(gradient: Gradient(colors: [Color.brown.opacity(0.8), Color.black]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            // Content Stack - Center everything
            VStack(spacing: 20) {
                // SmartSplit Text
                Text("SmartSplit")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                // Logo Image (bigger size)
                Image("logo") // Make sure logo is added in your asset catalog
                    .resizable()
                    .scaledToFit()
                    .frame(width: 350, height: 350) // Adjust the size of the logo
                
                // Simple Text List of Features - Centered with bold bullets and left-aligned text
                VStack(alignment: .leading, spacing: 10) {
                    Text("• Easily Track Shared Expenses")
                        .font(.title2)
                        .fontWeight(.bold) // Make text bold
                        .foregroundColor(.white)
                    Text("• Balance Summary")
                        .font(.title2)
                        .fontWeight(.bold) // Make text bold
                        .foregroundColor(.white)
                    Text("• Category-Based Organization")
                        .font(.title2)
                        .fontWeight(.bold) // Make text bold
                        .foregroundColor(.white)
                    Text("• Expense Insights")
                        .font(.title2)
                        .fontWeight(.bold) // Make text bold
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity, alignment: .leading) // Left-align the list
                
                // Get Started Button with gradient color
                Button(action: {
                    // Navigate to LoginRegisterView
                    isLoginRegisterPresented = true
                }) {
                    Text("Get Started!")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.green]), startPoint: .topLeading, endPoint: .bottomTrailing))
                        .cornerRadius(12)
                        .shadow(radius: 10)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 40)
                .fullScreenCover(isPresented: $isLoginRegisterPresented) {
                    LoginRegisterView() // Your LoginRegisterView
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity) // Center content vertically and horizontally
        }
        .transition(.slide) // Smooth transition when the view appears
    }
}
