import SwiftUI

struct LandingPage: View {
    // Navigation State
    @State private var isLoginRegisterPresented: Bool = false
    
    // Animation States for each section
    @State private var titleOffset: CGFloat = -500 // Start off-screen to the left
    @State private var logoOffset: CGFloat = 500 // Start off-screen to the right
    @State private var feature1Opacity: Double = 0
    @State private var feature2Opacity: Double = 0
    @State private var feature3Opacity: Double = 0
    @State private var feature4Opacity: Double = 0
    @State private var buttonOpacity: Double = 0
    
    var body: some View {
        ZStack {
            // New Gradient Background - Dark Blue to Teal for a cool look
            LinearGradient(gradient: Gradient(colors: [Color.blue, Color.teal, Color.black]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            // Content Stack - Center everything
            VStack(spacing: 15) { // Reduced the spacing between the title and logo
                // SmartSplit Title - Using Gold Gradient
                Text("SmartSplit")
                    .font(.custom("Georgia", size: 60, relativeTo: .title)) // Using a custom font for a cool look
                    .foregroundStyle(LinearGradient(gradient: Gradient(colors: [Color(red: 1.0, green: 0.8, blue: 0.6), Color(red: 1.0, green: 0.5, blue: 0.3)]), startPoint: .topLeading, endPoint: .bottomTrailing)) // Gold gradient
                    .offset(x: titleOffset) // Apply slide-in effect for the title
                    .onAppear {
                        withAnimation(.easeOut(duration: 1.0).delay(0.5)) {
                            titleOffset = 0 // Slide the title into the center after 0.5 seconds
                        }
                    }
                
                // Logo Image - Corner radius added
                // Logo Image - Enhanced with Shadow, Rounded Border, Zoom-in Animation, and Gradient Mask
                Image("logo") // Make sure logo is added in your asset catalog
                    .resizable()
                    .scaledToFit()
                    .frame(width: 350, height: 350)
                    .cornerRadius(20) // Apply corner radius to the logo
                    .shadow(color: .black, radius: 10, x: 5, y: 5) // Adding a shadow to make it pop
                    .overlay(LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.6), Color.clear]), startPoint: .top, endPoint: .bottom)) // Gradient mask for smooth blend
                    .scaleEffect(logoOffset == 0 ? 1.05 : 1) // Zoom-in effect when it comes into view
                    .rotationEffect(.degrees(logoOffset == 0 ? 5 : 0)) // Slight rotation for dynamic feel
                    .offset(x: logoOffset) // Apply slide-in effect for the logo
                    .onAppear {
                        withAnimation(.easeOut(duration: 1.0).delay(1.0)) {
                            logoOffset = 0 // Slide the logo into the center after 1 second
                        }
                    }


                // Feature Bullets - Fade-in each one by one after the logo
                VStack(alignment: .leading, spacing: 10) {
                    Text("• Easily Track Shared Expenses 🍳")
                        .font(.custom("AvenirNextCondensed-DemiBold", size: 24)) // Cool fancy font for bullets
                        .foregroundColor(.white) // White for bullets
                        .opacity(feature1Opacity)
                        .onAppear {
                            withAnimation(.easeOut(duration: 1.0).delay(1.5)) {
                                feature1Opacity = 1 // Fade-in first feature after logo
                            }
                        }
                    
                    Text("• Balance Summary 💸")
                        .font(.custom("AvenirNextCondensed-DemiBold", size: 24)) // Cool fancy font for bullets
                        .foregroundColor(.white) // White for bullets
                        .opacity(feature2Opacity)
                        .onAppear {
                            withAnimation(.easeOut(duration: 1.0).delay(1.8)) {
                                feature2Opacity = 1 // Fade-in second feature
                            }
                        }
                    
                    Text("• Category-Based Organization 📊")
                        .font(.custom("AvenirNextCondensed-DemiBold", size: 24)) // Cool fancy font for bullets
                        .foregroundColor(.white) // White for bullets
                        .opacity(feature3Opacity)
                        .onAppear {
                            withAnimation(.easeOut(duration: 1.0).delay(2.1)) {
                                feature3Opacity = 1 // Fade-in third feature
                            }
                        }
                    
                    Text("• Expense Insights 📈")
                        .font(.custom("AvenirNextCondensed-DemiBold", size: 24)) // Cool fancy font for bullets
                        .foregroundColor(.white) // White for bullets
                        .opacity(feature4Opacity)
                        .onAppear {
                            withAnimation(.easeOut(duration: 1.0).delay(2.4)) {
                                feature4Opacity = 1 // Fade-in fourth feature
                            }
                        }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Get Started Button - Gold Gradient Background
                Button(action: {
                    // Navigate to LoginRegisterView
                    isLoginRegisterPresented = true
                }) {
                    Text("Get Started!")
                        .font(.system(size: 22, weight: .bold)) // Adjusted font size
                        .foregroundColor(.white)
                        .padding()
                        .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple.opacity(0.8)]), startPoint: .top, endPoint: .bottom))

                        .cornerRadius(12)
                        .shadow(radius: 10)
                        .opacity(buttonOpacity)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 40)
                .fullScreenCover(isPresented: $isLoginRegisterPresented) {
                    LoginRegisterView() // Your LoginRegisterView
                }
                .onAppear {
                    withAnimation(.easeOut(duration: 1.0).delay(2.7)) {
                        buttonOpacity = 1 // Fade-in the button last
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity) // Center content vertically and horizontally
        }
    }
}

struct LandingPage_Previews: PreviewProvider {
    static var previews: some View {
        LandingPage()
    }
}
