import SwiftUI

struct BackgroundView: View {
    @State private var animateGradient = false
    
    private let gradient1 = Gradient(colors: [
        Color(red: 0.1, green: 0.1, blue: 0.3),
        Color(red: 0.2, green: 0.2, blue: 0.4),
        Color(red: 0.3, green: 0.3, blue: 0.5)
    ])
    
    private let gradient2 = Gradient(colors: [
        Color(red: 0.2, green: 0.2, blue: 0.4),
        Color(red: 0.3, green: 0.3, blue: 0.5),
        Color(red: 0.4, green: 0.4, blue: 0.6)
    ])
    
    var body: some View {
        LinearGradient(gradient: animateGradient ? gradient1 : gradient2, 
                      startPoint: .topLeading, 
                      endPoint: .bottomTrailing)
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.linear(duration: 5.0).repeatForever(autoreverses: true)) {
                    animateGradient.toggle()
                }
            }
    }
} 