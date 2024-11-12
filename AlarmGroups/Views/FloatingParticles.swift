import SwiftUI

struct Particle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var scale: CGFloat
    var opacity: Double
    var speed: Double
}

struct FloatingParticles: View {
    @State private var particles: [Particle] = []
    let timer = Timer.publish(every: 0.02, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    Circle()
                        .fill(.white)
                        .frame(width: 4, height: 4)
                        .scaleEffect(particle.scale)
                        .opacity(particle.opacity)
                        .position(particle.position)
                        .blur(radius: 0.5)
                }
            }
            .onAppear {
                setupInitialParticles(in: geometry.size)
            }
            .onReceive(timer) { _ in
                updateParticles(in: geometry.size)
            }
        }
    }
    
    private func setupInitialParticles(in size: CGSize) {
        particles = (0..<30).map { _ in
            Particle(
                position: CGPoint(
                    x: CGFloat.random(in: 0...size.width),
                    y: CGFloat.random(in: 0...size.height)
                ),
                scale: CGFloat.random(in: 0.2...1.0),
                opacity: Double.random(in: 0.1...0.5),
                speed: Double.random(in: 0.2...1.2)
            )
        }
    }
    
    private func updateParticles(in size: CGSize) {
        for index in particles.indices {
            var particle = particles[index]
            
            // Move particle upward with slight horizontal drift
            particle.position.y -= particle.speed
            particle.position.x += sin(particle.position.y * 0.01) * 0.3
            
            // Reset particle if it goes off screen
            if particle.position.y < -10 {
                particle.position.y = size.height + 10
                particle.position.x = CGFloat.random(in: 0...size.width)
                particle.scale = CGFloat.random(in: 0.2...1.0)
                particle.opacity = Double.random(in: 0.1...0.5)
                particle.speed = Double.random(in: 0.2...1.2)
            }
            
            particles[index] = particle
        }
    }
} 