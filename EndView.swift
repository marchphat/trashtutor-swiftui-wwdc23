//
//  SwiftUIView.swift
//  
//
//  Created by Nantanat Thongthep on 19/4/2566 BE.
//

import SwiftUI
import AVFoundation

struct Congratulations: View {
    private let padding: CGFloat = 25
    private let fontSize: CGFloat = 20
    
    var body: some View {
        ZStack {
            VStack (spacing: 5) {
                Text("❤️")
                    .font(.system(size: fontSize))
                Text("Congratulations on your achievement!")
                    .font(.system(size: fontSize))
                Text("Go change the world for the better.")
                    .font(.system(size: fontSize - 2))
                Text("I am very proud of you!")
                    .font(.system(size: fontSize - 2))
            }
            .padding(.horizontal, padding)
            .multilineTextAlignment(.center)
            
            Circle()
                .fill(Color.blue)
                .frame(width: 12, height: 12)
                .modifier(ParticlesModifier())
                .offset(x: -100, y : -50)
            
            Circle()
                .fill(Color.red)
                .frame(width: 12, height: 12)
                .modifier(ParticlesModifier())
                .offset(x: 60, y : 70)
        }
        .onAppear {
            MusicPlayer.shared.playMusic(name: "end-sound", type: "mp3", loop: true, action: "BGM")
        }
    }
}

struct FireworkParticlesGeometryEffect : GeometryEffect {
    var time : Double
    var speed = Double.random(in: 20 ... 200)
    var direction = Double.random(in: -Double.pi ...  Double.pi)
    
    var animatableData: Double {
        get { time }
        set { time = newValue }
    }
    func effectValue(size: CGSize) -> ProjectionTransform {
        let xTranslation = speed * cos(direction) * time
        let yTranslation = speed * sin(direction) * time
        let affineTranslation =  CGAffineTransform(translationX: xTranslation, y: yTranslation)
        return ProjectionTransform(affineTranslation)
    }
}

struct ParticlesModifier: ViewModifier {
    @State var time = 0.0
    @State var scale = 0.1
    let duration = 5.0
    
    func body(content: Content) -> some View {
        ZStack {
            ForEach(0..<80, id: \.self) { index in
                content
                    .hueRotation(Angle(degrees: time * 80))
                    .scaleEffect(scale)
                    .modifier(FireworkParticlesGeometryEffect(time: time))
                    .opacity(((duration-time) / duration))
            }
        }
        .onAppear {
            withAnimation (.easeOut(duration: duration).repeatForever(autoreverses: false)) {
                self.time = duration
                self.scale = 1.0
            }
        }
    }
}

